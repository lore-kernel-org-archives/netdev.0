From: Marcin =?iso-8859-2?Q?Kami=F1ski?= <maxiu@maxiu.com>
Subject: IN6_PKTINFO
Date: Fri, 29 Nov 2002 14:17:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021129141730.A12882@maxiu.best.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello
I'm programmer in PSNC (www.man.poznan.pl) and I'm trying to write
function which receives UDP packet by IPv6 network and determines
on what address does it arrive.
I wrote program which works on IPv4, and then changed it to IPv6,
but now it is not working. On all boxes I've tested, situation was
the same: msg.msg_control hasn't got any headers when receiving IPv6
packets and msg.msg_controllen = 0. Program is based on informations in
RFC2292 and manual pages for setsockopt(2) and ipv6(7).
This is test program:

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>

#define FATAL(s)        { perror(s); exit(1); }

int main()
{
 int s;
 struct sockaddr_in6 sin6;
 struct msghdr msg;
 struct cmsghdr *c;
 struct in6_pktinfo *pktinfo;
 char buf[1024];
 int a, i;

 char host_src[46];
 s = socket(PF_INET6, SOCK_DGRAM, IPPROTO_UDP);
 if(s < 0)
  FATAL("socket");
 sin6.sin6_family = AF_INET6;
 sin6.sin6_port = htons(7000);
 sin6.sin6_addr = in6addr_any;
 if(bind(s, (struct sockaddr *) &sin6, sizeof(sin6)) < 0)
  FATAL("bind");
 a = 1;
 if(setsockopt(s, SOL_IPV6, IPV6_PKTINFO,  &a, sizeof(int)) < 0)
  FATAL("setsockopt");
 i = sizeof(int);
 if(getsockopt(s, IPPROTO_IPV6, IPV6_PKTINFO, &a, &i) < 0)
  FATAL("getsockopt");
 printf("a = %d\n", a);
 for(;;) {
  memset(&msg, 0, sizeof(struct msghdr));
  msg.msg_control = buf;
  msg.msg_controllen = 1024;
  if((a = recvmsg(s, &msg, MSG_PEEK)) < 0)
   FATAL("recvmsg");
  printf("Packet msg %d len", a); fflush(stdout);
  printf("[%d]\n", msg.msg_controllen);
//  if(msg.msg_controllen) {
   for(c = CMSG_FIRSTHDR(&msg) ; c; c = CMSG_NXTHDR(&msg, c)) {
    printf("%d %d\n", c -> cmsg_level, c -> cmsg_type);
    if(c -> cmsg_level == IPPROTO_IPV6 && c -> cmsg_type == IPV6_PKTINFO) {
     pktinfo = (struct in6_pktinfo *) CMSG_DATA(c);

     inet_ntop(AF_INET6, pktinfo -> ipi6_addr, host_src, 46);
//     printf(" from %s ", pktinfo -> ipi_spec_dst);
     printf(" to %s ", host_src);

     break;
    }
   }
//  }
  if((a = recv(s, buf, 1024, 0)) < 0)
   FATAL("recv");
  printf(", data %d len[", a); fflush(stdout);
  for(i = 0; i < a; i++)
   printf("%c", buf[i]);
  printf("]"); fflush(stdout);

  printf("\n");
 }
}

Have You got any ideas what is wrong?
With regards
  Marcin Kaminski


-- 
- Marcin Kaminski ------------------------------------ maxiu -
--- software developer ---------------------- 6net project ---
----- network administrator ----------- Best Group admin -----
------- mail:maxiu@maxiu.com ------ http://maxiu.com ---------
