From: "Knut Tidemann" <knut.andre.tidemann@jotron.com>
Subject: kernel 2.6.39 eats multicast packets
Date: Fri, 17 Jun 2011 10:32:23 +0200
Message-ID: <op.vw7on9im1qh6di@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vip4scan.telenor.net ([148.123.15.78]:13461 "EHLO
	virusvask.telenor.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758399Ab1FQIrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 04:47:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

We're seeing an issue where a listening UDP socket in a multicast group  
doesn't receive some multicast packets.
 From simple testing it seems that the first packet from a new host is not  
passed through the kernel and down to the socket, but the next packets  
are. The packets can be
seen with a tool such as tcpdump, but they never reach the user space  
socket. It is worth noting, that the packet loss does not occur when  
sending to and from the same host,
to a multicast address. The address and port we have been using in our  
tests are 224.0.1.75:5060. I've also attached the testing code at the end  
of this email. The issue was also present in 3.0-rc1.

This issue is not present in 2.6.38 and I've bisected the issue to the  
following commit:

----
b23dd4fe42b455af5c6e20966b7d6959fa8352ea is the first bad commit
commit b23dd4fe42b455af5c6e20966b7d6959fa8352ea
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Mar 2 14:31:35 2011 -0800

     ipv4: Make output route lookup return rtable directly.

     Instead of on the stack.

     Signed-off-by: David S. Miller <davem@davemloft.net>
----


PS:
The history around this commit seems somewhat confusing, so the bisect  
lead us to a 2.6.38-rc5 commit, even though 2.6.38 is clean and without  
issues. I've
tried to revert the commit in 2.6.39, but the conflicts were too many to  
test if the issue went away or not. Not being a kernel hacker my self I  
did not make
any good attempts to resolve these conflicts.


----
Test code:
Sender application:

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

int setup_socket()
{
     int fd;

     struct sockaddr_in addr;

     if((fd = socket(PF_INET, SOCK_DGRAM, 0)) == -1) {
         perror("Could not creat socket");
         return -1;
     }

     memset(&addr, 1, sizeof(addr));
     addr.sin_family = AF_INET;
     addr.sin_port = 0;
     addr.sin_addr.s_addr = INADDR_ANY;
     if(bind(fd, (const sockaddr*)&addr, sizeof(addr)) == -1) {
         perror("Could not bind socket to 0.0.0.0:5060");
         return -1;
     }

     return fd;
}

int main(int argc, char *argv[])
{
     int fd, len, res, packet_nr;
     char buf[256];
     struct sockaddr_in addr;

     res = 1;
     packet_nr = 0;

     if((fd = setup_socket()) == -1) {
         fprintf(stderr, "Could not setup socket. Aborting.\n");
         return -1;
     }

     fprintf(stdout, "Simple sender ready to send to 224.0.1.75:5060\n");

     memset(&addr, 0, sizeof(struct sockaddr_in));
     addr.sin_family = AF_INET;
     addr.sin_port = htons(5060);
     addr.sin_addr.s_addr = inet_addr("224.0.1.75");

     while(res > 0) {
         len = sprintf(buf, "Packet %d", packet_nr);
         res = sendto(fd, buf, len, 0, (const sockaddr *)&addr,  
sizeof(addr));
         fprintf(stdout, "Sent packet nr %d\n", packet_nr);
         ++packet_nr;
         sleep(2);
     }

     if(res < 0) {
         perror("Error during sending");
     }

     return res;
}

------
Receiver application

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <string.h>
#include <stdio.h>

int setup_socket()
{
     int fd;

     struct ip_mreq mreq;
     struct sockaddr_in addr;

     if((fd = socket(PF_INET, SOCK_DGRAM, 0)) == -1) {
         perror("Could not creat socket");
         return -1;
     }

     memset(&addr, 1, sizeof(addr));
     addr.sin_family = AF_INET;
     addr.sin_port = htons(5060);
     addr.sin_addr.s_addr = INADDR_ANY;
     if(bind(fd, (const sockaddr*)&addr, sizeof(addr)) == -1) {
         perror("Could not bind socket to 0.0.0.0:5060");
         return -1;
     }

     memset(&mreq, 0, sizeof(mreq));
     mreq.imr_multiaddr.s_addr = inet_addr("224.0.1.75");
     mreq.imr_interface.s_addr = INADDR_ANY;

     if(setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq))  
== -1) {
         perror("Could not join multicast group");
         return -1;
     }

     return fd;
}

int main(int argc, char *argv[])
{
     int fd, res;
     char buf[8192], *from;
     struct sockaddr_in addr;
     socklen_t addr_len = sizeof(addr);

     if((fd = setup_socket()) == -1) {
         fprintf(stderr, "Could not setup socket. Aborting.\n");
         return -1;
     }

     fprintf(stdout, "Simple receiver ready on 0.0.0.0:5060\n");

     res = recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr*)&addr,  
&addr_len);
     while(res > 0)
     {
         buf[res] = 0;
         from = inet_ntoa(addr.sin_addr);
         fprintf(stdout, "Got packet from %s:%d\n",from,  
ntohs(addr.sin_port));
         fprintf(stdout, "%s\n", buf);

         res = recvfrom(fd, buf, sizeof(buf), 0, (struct sockaddr*)&addr,  
&addr_len);
     }

     if(res < 0) {
         perror("Error during receive");
     }

     return res;
}

------

With regards
Knut Andre Tidemann
