From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH 1/1] igmp: fix ip_mc_clear_src to not reset
 ip_mc_list->sf{mode,count}
Date: Tue, 17 May 2011 15:30:07 +0200
Message-ID: <20110517133007.GB30366@darkmag.usersys.redhat.com>
References: <20110515165945.GA20024@darkmag.usersys.redhat.com>
 <20110516.140359.111037536766782557.davem@davemloft.net>
 <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	mmarek@suse.cz, netdev@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF948388D5.90B3F5A7-ON88257892.006C3228-88257892.0071B9D5@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 16, 2011 at 01:42:11PM -0700, David Stevens wrote:
> 
>         On NETDEV_DOWN, all group memberships are dropped. 
> ip_mc_clear_src()
> is simply freeing all the source filters and turning it into an "EXCLUDE 
> nobody"
> membership (ie, the same as an ordinary join without source filtering). 
> This
> ordinarily happens when you are deleting the group entirely (when the 
> reference
> count goes to 0), but is also called on device down.
>         This patch is not appropriate; when the groups are deleted, the 
> source
> filters are deleted, and the filter counts have to reflect the source 
> filters
> in the list. If you had an "INCLUDE A" filter, for example, that would 
> become
> an "INCLUDE nobody" filter and drop all traffic (from A or not). The 
> number
> of source filters is not related to the number of listener sockets, and 
> the
> function of ip_mc_clear_src() is to make it 0 (with the special case of 1 
> for
> EXCLUDE), so setting the counts has to be done for proper functioning.
>         I don't quite understand the problem you're trying to solve here 
> --
> when the device comes back up, the group should be re-added with 
> {EXCLUDE,nobody} and
> ip_check_mc() should therefore return 1. Of course, while the interface is
> down, the mc_list is empty and it'd return 0 in that case.
>         Do you have a small test program to demonstrate the problem?

Yes, attached are two programs, one sender and one receiver, they bind both
to localhost and send each other traffic. To reproduce, start the sender
and two instances of receivers, then do an ifconfig lo up; ifconfig lo
down;, restart the sender program (both of the receivers should once again
receive the multicast traffic). Then kill one receiver (the MCAST_EXCLUDE
will become 0), and do an "ip route flush cache". The new route cache will
be without the local flag on, and the remaining receiver will stop
receiving traffic.

What happens:

1) When both receivers start, ip_mc_list->sfcount[MCAST_EXCLUDE] == 2
2) On NETDEV_DOWN event, groups are dropped and sfmode = MCAST_EXCLUDE,
	sfcount[MCAST_EXCLUDE] = 1
3) On NETDEV_UP, the group is re-joined, but kernel thinks that there's
	only one listener (sfcount[MCAST_EXCLUDE]).
4) On socket destroy (when one receiver is terminated), the count is 0.
5) On route cache flush, __mkroute_output() doesn't see the remaining
	listener, and creates a route cache without RTCF_LOCAL flag, thus not
	allowing any traffic on that group to local listeners.

The igmp_group_dropped() (the actual routine that drops a group) is called
when:

1) ip_mc_dec_group() is called and im->users == 0
2) ip_mc_unmap()
3) ip_mc_down()
4) ip_mc_destroy_dev()

The 1) we call either on socket destroy or when the socket actually asks to
leave a group. In this case, we need to "reset" the state on no listeners.

2),3),4) are called on various device modifications
(NETDEV_PRE_TYPE_CHANGE, NETDEV_DOWN and NETDEV_UNREGISTER) - but the group
can be rejoined on their next events - NETDEV_POST_TYPE_CHANGE, NETDEV_UP
and NETDEV_REGISTER, which will cause the ip_mc_list to loose track of
existing listeners.

So, I tend to think that we must clear the sources only on 1).

Will send the patch shortly.

Thank you!

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mcsend.c"

#include <sys/types.h>   /* for type definitions */
#include <sys/socket.h>  /* for socket API function calls */
#include <netinet/in.h>  /* for address structs */
#include <arpa/inet.h>   /* for sockaddr_in */
#include <stdio.h>       /* for printf() */
#include <stdlib.h>      /* for atoi() */
#include <string.h>      /* for strlen() */
#include <unistd.h>      /* for close() */

#define MAX_LEN  1024    /* maximum string size to send */
#define MIN_PORT 1024    /* minimum port allowed */
#define MAX_PORT 65535   /* maximum port allowed */

int main(int argc, char *argv[]) {

  int sock;                   /* socket descriptor */
  char send_str[MAX_LEN];     /* string to send */
  struct sockaddr_in mc_addr; /* socket address structure */
  unsigned int send_len;      /* length of string to send */
  char* mc_addr_str;          /* multicast IP address */
  unsigned short mc_port;     /* multicast port */
  unsigned char mc_ttl=1;     /* time to live (hop count) */

  /* validate number of arguments */
  if (argc != 3) {
    fprintf(stderr,
            "Usage: %s <Multicast IP> <Multicast Port>\n",
            argv[0]);
    exit(1);
  }

  mc_addr_str = argv[1];       /* arg 1: multicast IP address */
  mc_port     = atoi(argv[2]); /* arg 2: multicast port number */

  /* validate the port range */
  if ((mc_port < MIN_PORT) || (mc_port > MAX_PORT)) {
    fprintf(stderr, "Invalid port number argument %d.\n",
            mc_port);
    fprintf(stderr, "Valid range is between %d and %d.\n",
            MIN_PORT, MAX_PORT);
    exit(1);
  }

  /* create a socket for sending to the multicast address */
  if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
    perror("socket() failed");
    exit(1);
  }

  /* bind socket  to "localhost" */
  struct sockaddr_in lh_addr;   /* socket address structure */
  memset(&lh_addr, 0, sizeof(lh_addr));
  lh_addr.sin_family      = AF_INET;
  lh_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
  lh_addr.sin_port        = 0;
  if ((bind(sock, (struct sockaddr *) &lh_addr,
       sizeof(lh_addr))) < 0) {
    perror("bind() failed");
    exit(1);
  }

  /* enable loopback (should be the default) */
  int mc_loopback = 1;
  if ((setsockopt(sock, IPPROTO_IP, IP_MULTICAST_LOOP,
       (void*) &mc_loopback, sizeof(mc_loopback))) < 0) {
    perror("setsockopt(IP_MULTICAST_LOOP) failed");
    exit(1);
  }

  /* set interface address */
  if ((setsockopt(sock, IPPROTO_IP, IP_MULTICAST_IF,
       (void*) &lh_addr.sin_addr, sizeof(lh_addr.sin_addr))) < 0) {
    perror("setsockopt(IP_MULTICAST_IF) failed");
    exit(1);
  }

  /* set the TTL (time to live/hop count) for the send
  if ((setsockopt(sock, IPPROTO_IP, IP_MULTICAST_TTL,
       (void*) &mc_ttl, sizeof(mc_ttl))) < 0) {
    perror("setsockopt() failed");
    exit(1);
  } */

  /* construct a multicast address structure */
  memset(&mc_addr, 0, sizeof(mc_addr));
  mc_addr.sin_family      = AF_INET;
  mc_addr.sin_addr.s_addr = inet_addr(mc_addr_str);
  mc_addr.sin_port        = htons(mc_port);

  printf("Begin typing (return to send, ctrl-C to quit):\n");

  /* clear send buffer */
  memset(send_str, 0, sizeof(send_str));

  while (fgets(send_str, MAX_LEN, stdin)) {
    send_len = strlen(send_str);

    /* send string to multicast address */
    if ((sendto(sock, send_str, send_len, 0,
         (struct sockaddr *) &mc_addr,
         sizeof(mc_addr))) != send_len) {
      perror("sendto() sent incorrect number of bytes");
      exit(1);
    }

    /* clear send buffer */
    memset(send_str, 0, sizeof(send_str));
  }

  close(sock);

  exit(0);
}


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mcreceive.c"

#include <sys/types.h>  /* for type definitions */
#include <sys/socket.h> /* for socket API calls */
#include <netinet/in.h> /* for address structs */
#include <arpa/inet.h>  /* for sockaddr_in */
#include <stdio.h>      /* for printf() and fprintf() */
#include <stdlib.h>     /* for atoi() */
#include <string.h>     /* for strlen() */
#include <unistd.h>     /* for close() */

#define MAX_LEN  1024   /* maximum receive string size */
#define MIN_PORT 1024   /* minimum port allowed */
#define MAX_PORT 65535  /* maximum port allowed */

int main(int argc, char *argv[]) {

  int sock;                     /* socket descriptor */
  int flag_on = 1;              /* socket option flag */
  struct sockaddr_in mc_addr;   /* socket address structure */
  char recv_str[MAX_LEN+1];     /* buffer to receive string */
  int recv_len;                 /* length of string received */
  struct ip_mreq mc_req;        /* multicast request structure */
  char* mc_addr_str;            /* multicast IP address */
  unsigned short mc_port;       /* multicast port */
  struct sockaddr_in from_addr; /* packet source */
  unsigned int from_len;        /* source addr length */
  unsigned int fl=1;

  /* validate number of arguments */
  if (argc != 3) {
    fprintf(stderr,
            "Usage: %s <Multicast IP> <Multicast Port>\n",
            argv[0]);
    exit(1);
  }

  mc_addr_str = argv[1];      /* arg 1: multicast ip address */
  mc_port = atoi(argv[2]);    /* arg 2: multicast port number */

  /* validate the port range */
  if ((mc_port < MIN_PORT) || (mc_port > MAX_PORT)) {
    fprintf(stderr, "Invalid port number argument %d.\n",
            mc_port);
    fprintf(stderr, "Valid range is between %d and %d.\n",
            MIN_PORT, MAX_PORT);
    exit(1);
  }

  /* create socket to join multicast group on */
  if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
    perror("socket() failed");
    exit(1);
  }

  /* set reuse port to on to allow multiple binds per host */
  if ((setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &flag_on,
       sizeof(flag_on))) < 0) {
    perror("setsockopt() failed");
    exit(1);
  }

  /* construct a multicast address structure */
  memset(&mc_addr, 0, sizeof(mc_addr));
  mc_addr.sin_family      = AF_INET;
//  mc_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  mc_addr.sin_addr.s_addr = inet_addr(mc_addr_str);
  mc_addr.sin_port        = htons(mc_port);

  /* bind to multicast address to socket */
  if ((bind(sock, (struct sockaddr *) &mc_addr,
       sizeof(mc_addr))) < 0) {
    perror("bind() failed");
    exit(1);
  }

  /* construct an IGMP join request structure */
  mc_req.imr_multiaddr.s_addr = inet_addr(mc_addr_str);
//  mc_req.imr_interface.s_addr = htonl(INADDR_ANY);
  mc_req.imr_interface.s_addr = inet_addr("127.0.0.1");

  /* send an ADD MEMBERSHIP message via setsockopt */
  if (fl && (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP,
       (void*) &mc_req, sizeof(mc_req))) < 0) {
    perror("setsockopt() failed");
    exit(1);
  }

  for (;;) {          /* loop forever */

    /* clear the receive buffers & structs */
    memset(recv_str, 0, sizeof(recv_str));
    from_len = sizeof(from_addr);
    memset(&from_addr, 0, from_len);

    /* block waiting to receive a packet */
    if ((recv_len = recvfrom(sock, recv_str, MAX_LEN, 0,
         (struct sockaddr*)&from_addr, &from_len)) < 0) {
      perror("recvfrom() failed");
      exit(1);
    }

    /* output received string */
    printf("Received %d bytes from %s: ", recv_len,
           inet_ntoa(from_addr.sin_addr));
    printf("%s", recv_str);
  }

  /* send a DROP MEMBERSHIP message via setsockopt */
  if ((setsockopt(sock, IPPROTO_IP, IP_DROP_MEMBERSHIP,
       (void*) &mc_req, sizeof(mc_req))) < 0) {
    perror("setsockopt() failed");
    exit(1);
  }

  close(sock);
}

--M9NhX3UHpAaciwkO--
