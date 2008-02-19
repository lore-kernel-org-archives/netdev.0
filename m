From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: AW: Problem receiving multicast/promiscuous-mode with kernel.2.6.24
Date: Tue, 19 Feb 2008 09:40:03 +0100
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062F17@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([88.116.237.238]:12366 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750796AbYBSIkH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 03:40:07 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall 8.0, Stand G16
________________________________________________________________________



Hi,

ok, i managed to shrink down my code to show the behaviour in small size ;-)

It shows the same effect as my app, sometimes i get all the packets after a mc_join, sometimes i get only the timeouts.
I find no predictive behaviour, i'm really desperate ...
Hope you can see the effect too .. Do u need an app sending the multicast VLAN packets ?

Robert

-----------------------------------------

#include <stdint.h>
#include <sys/select.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <errno.h>
#include <netdb.h>

//#include <linux/if.h>
#include <linux/sockios.h>
#include <sys/ioctl.h>

//#define JOIN_SINGLE_IF
#undef JOIN_SINGLE_IF


#define PORT 10500

/*
** Try to receive VLAN-tagged UDP multicast packets 
** VLAN-ID:3, VLAN_PRI=6, Addr: 224.1.9.0, dstnport 10500
**
** Kernel used: 2.6.24
**
** HW: VIA Epia 5000, VIA Epia LT (VIA Rhine II and VIA VT6107)
**
** Additional network settings:
** vconfig add eth0 3
** vconfig set_egress_map eth0.3 6 6
** ifconfig eth0.3 10.0.0.1
** route add -net 224.0.0.0 netmask 240.0.0.0 dev eth0.3
**
*/

#define MAX_PAYLOAD 1000

/* 
 * Network representation of the rtp header.
 */

struct rtp_header {
#ifdef WORDS_BIGENDIAN
        uint16_t version:2;
        uint16_t padbit:1;
        uint16_t extbit:1;
        uint16_t cc:4;
        uint16_t markbit:1;
        uint16_t paytype:7;
#else
        uint16_t cc:4;
        uint16_t extbit:1;
        uint16_t padbit:1;
        uint16_t version:2;
        uint16_t paytype:7;
        uint16_t markbit:1;
#endif
        uint16_t seq_number;
        uint32_t timestamp;
        uint32_t ssrc;

	/* In fact we rely on rtp_header being not larger than 
	 * the minimum header length. So, there's no contributing
	 * sync source field here. */
};

struct rtp_packet {
	struct rtp_header header;
	unsigned char payload[MAX_PAYLOAD];
};


#ifdef WORDS_BIGENDIAN
#error Sorry this is not supported on bigendian targets.
#endif

#define BYTE0(x) ((x) & 0xff)
#define BYTE1(x) (((x) >> 8)  & 0xff)
#define BYTE2(x) (((x) >> 16)  & 0xff)
#define BYTE3(x) (((x) >> 24)  & 0xff)

static char *my_inet_ntoa (char *buf, size_t n, struct in_addr in)
{
	if (snprintf (buf, n, "%u.%u.%u.%u", BYTE0(in.s_addr), BYTE1(in.s_addr), BYTE2(in.s_addr), BYTE3(in.s_addr))  >= n) {
		return NULL;
	}
	return buf;
}

static int set_non_blocking (int fd)
{
	int flags;

	if ((flags = fcntl (fd, F_GETFL)) < 0) {
		perror ("fcntl getflags ()");
		return -1;
	}
	if (fcntl (fd, F_SETFL, flags | O_NONBLOCK) < 0) {
		perror ("fcntl setflags ()");
		return -1;
	}

	return fd;
}

int main()
{
  int fd;
  fd_set read_fds;
  struct timespec timeout;
  
  while(1)
  {
    int i, ret;

  	if ((fd = subscribe_udp (PORT)) < 0) {
  		printf("Could not register UDP port.\n");
   		return 1;
    }
    	
  
  	if (join_multicast_group (fd, "224.1.9.0") < 0)
  	{
  	  printf("Error joining multicast !\n");
  	  return 1;  
  	}

    for(i=0;i<10;i++)
    {

      FD_ZERO (&read_fds);
    	FD_SET (fd, &read_fds);
    	timeout.tv_sec = 1;
    	timeout.tv_nsec = 0;
  
  
  		ret = pselect (fd+1, &read_fds, NULL, NULL, &timeout, NULL);
  
  
  		if (ret < 0) {
  			if (errno == EINTR) {
  				continue;
  			} else {
  				printf("select failed.\n");
  				return 1;
  			}
  		}

      if (FD_ISSET(fd, &read_fds))
      {
        ssize_t len;
      	struct rtp_packet p; 
      	struct sockaddr_in from;
      	socklen_t fromlen;
      	char from_ip[20];
        
    	  len = recvfrom (fd, &p, sizeof (p), 0, (struct sockaddr*) &from, &fromlen);
      	my_inet_ntoa (from_ip, sizeof (from_ip), from.sin_addr);
    
        printf("Received data packet from %s, length %u\n", from_ip, len);
      }
      else
      {
        printf("Got timeout receiving Multicast packets !\n");  
      }
    } /* loop 10 */
  
    if (leave_multicast_group(fd, "224.1.9.0") < 0)
  	{
  	  printf("Error leaving multicast !\n");
  	  return 1;  
  	}
    close(fd);	
  }
}

int subscribe_udp (int port)
{
	int s; 

	s = create_listening_socket (port, 1);
	return s;
}

int create_listening_socket (int listen_port, int udp) 
{
	struct sockaddr_in a;
	int s;
	int yes;
	if ((s = socket (AF_INET, udp ? SOCK_DGRAM : SOCK_STREAM, 0)) < 0) {
		perror ("socket");
		return -1;
	}
	yes = 1;
	if (setsockopt (s, SOL_SOCKET, SO_REUSEADDR,
		 (char *) &yes, sizeof (yes)) < 0) {
		perror ("setsockopt reuseaddr");
		close (s);
		return -1;
	}

	memset (&a, 0, sizeof (a));

	a.sin_port = htons (listen_port);
	a.sin_family = AF_INET;
	if (bind (s, (struct sockaddr *) &a, sizeof (a)) < 0) {
		perror ("bind");
		close (s);
		return -1;
	}
	if (set_non_blocking (s) < 0) {
		close (s);
		return -1;
	}

	if (!udp) {
		listen (s, 10);
	}
	return s;
}

int join_multicast_group (int fd, const char *mc_address)
{
	struct ip_mreqn imr;

  printf("In join_mc_group: %s\n",mc_address);


  if (inet_pton(AF_INET, mc_address, &imr.imr_multiaddr) != 1) {
//old	if (inet_aton (mc_address, &imr.imr_multiaddr) == 0) {
		printf ( "join_mc:Bad IP address format: %s\n", mc_address);
		return -1;
	}

	imr.imr_address.s_addr = INADDR_ANY;

#ifdef JOIN_SINGLE_IF
	imr.imr_ifindex = if_nametoindex("eth0.3"); // 0;
//	imr.imr_ifindex = if_nametoindex("eth0"); // Testing
  if (imr.imr_ifindex == 0)
  {
		printf ("join_mc:Got no interface-number from name !\n");
		return -1;    
  }
#else
	imr.imr_ifindex = 0;
#endif

  // Check if already member
	if (setsockopt (fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &imr, sizeof (imr)) < 0)
	{
	  if (errno == EADDRINUSE) // Address already joined for IP_ADD_MEMBERSHIP
	    printf("Already joined IP_ADD_MEMBERSHIP for %s.\n", mc_address);
    else
    {
  		perror ("getsockopt ip_add_membership");
  		return -1;
	  }
	}
	return 0;
}

int leave_multicast_group(int fd, const char *mc_address)
{
	struct ip_mreqn imr;

  printf("In leave_mc_group: %s\n",mc_address);

  if (inet_pton(AF_INET, mc_address, &imr.imr_multiaddr) != 1) {
//	if (inet_aton (mc_address, &imr.imr_multiaddr) == 0) {
		printf ("leave_mc:Bad IP address format: %s\n", mc_address);
		return -1;
	}

	imr.imr_address.s_addr = INADDR_ANY;

#ifdef JOIN_SINGLE_IF
	imr.imr_ifindex = if_nametoindex("eth0.3"); // 0 VLAN_ID ist aber vernderbar !!!!!
//	imr.imr_ifindex = if_nametoindex("eth0"); // 0
  if (imr.imr_ifindex == 0)
  {
		printf ("leave_mc:Got no interface-namber from name !\n");
		return -1;    
  }
#else
	imr.imr_ifindex = 0;
#endif

	if (setsockopt (fd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &imr, sizeof (imr)) < 0) {
		perror ("setsockopt ip_drop_membership");
		return -1;
	}
  return 0;
}
