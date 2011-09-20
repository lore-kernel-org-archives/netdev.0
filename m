From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: mlx4_en drops packets on multicast join
Date: Tue, 20 Sep 2011 17:10:46 -0500
Message-ID: <20110920221046.GC2119@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>, jackm@mellanox.co.il
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:60438 "EHLO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752099Ab1ITWKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 18:10:51 -0400
Received: by gwb20 with SMTP id 20so1062668gwb.36
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2011 15:10:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've found that using mlx4_en 1.5.4.1 available in the 3.0 kernel that
my Mellanox Technologies MT26428 will drop packets on a multicast
socket if another process does a bunch of multicast joins.  The same
behavior also occurs in the OFED 1.5.3 driver but not in the OFED 1.5.2
driver or older versions.

I've found that this only happens on sockets receiving multicast data,
and does not happen on a normal UDP socket.  When the packets are
dropped I do not see any indication of the drops in the driver or
kernel counters but only see the drops via the packet sequence
numbers.  I've also found that if the device is put in promiscuous
mode it will not drop packets.  As a secondary issue the device also
drops packets when leaving promiscuous mode though that appears to be
a different issue.

You can reproduce the issue using the iperf multicast benchmark, and
the sample program below.  For example:


server $ iperf -s -u -B 239.0.0.0 -i 1

client $ iperf -u -c 239.0.0.0 -l 16 -b 10M

# While benchmark is running
server $ ./multicast_join



/* sample multicast_join program */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>


#define INTERFACE "10.8.16.21"
#define PORT 12345

main(int argc, char *argv[])
{
     struct sockaddr_in addr;
     int fd, i;
     struct ip_mreq mreq;
     char group[64];

     u_int yes=1;

     if ((fd=socket(AF_INET,SOCK_DGRAM,0)) < 0) {
	  perror("socket");
	  exit(1);
     }


    if (setsockopt(fd,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(yes)) < 0) {
       perror("Reusing ADDR failed");
       exit(1);
     }

     memset(&addr,0,sizeof(addr));
     addr.sin_family=AF_INET;
     addr.sin_addr.s_addr=htonl(INADDR_ANY);
     addr.sin_port=htons(PORT);

     /* bind to receive address */
     if (bind(fd,(struct sockaddr *) &addr,sizeof(addr)) < 0) {
	  perror("bind");
	  exit(1);
     }

     for (i = 1; i < 150; ++i) {
	 sprintf(group, "239.0.0.%d", i);
	 printf("%s\n", group);
	 mreq.imr_multiaddr.s_addr=inet_addr(group);
	 mreq.imr_interface.s_addr=inet_addr(INTERFACE);
	 if (setsockopt(fd,IPPROTO_IP,IP_ADD_MEMBERSHIP,&mreq,sizeof(mreq)) < 0) {
	      perror("setsockopt");
	      exit(1);
	 }
     }
}


---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
