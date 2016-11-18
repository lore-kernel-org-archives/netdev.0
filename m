From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Fri, 18 Nov 2016 18:12:27 +0100
Message-ID: <20161118181227.41333853@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117155753.17b76f5a@redhat.com>
        <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117193021.580589ae@redhat.com>
        <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117221941.3b525181@redhat.com>
        <1479419042.8455.280.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752301AbcKRRMc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 12:12:32 -0500
In-Reply-To: <1479419042.8455.280.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2016 13:44:02 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-11-17 at 22:19 +0100, Jesper Dangaard Brouer wrote:
> 
> > 
> > Maybe you can share your udp flood "udpsnd" program source?  
> 
> Very ugly. This is based on what I wrote when tracking the UDP v6
> checksum bug (4f2e4ad56a65f3b7d64c258e373cb71e8d2499f4 net: mangle zero
> checksum in skb_checksum_help()), because netperf sends the same message
> over and over...

Thanks a lot, hope you don't mind; I added the code to my github repo:
 https://github.com/netoptimizer/network-testing/blob/master/src/udp_snd.c

So I identified the difference, and reason behind the route lookups.
Your program is using send() and I was using sendmsg().  Given
udp_flood is designed to test different calls, I simply added --send as
a new possibility.
 https://github.com/netoptimizer/network-testing/commit/16166c2cd1fa8

If I use --write instead, then I can also avoid the fib_table_lookup
and __ip_route_output_key_hash calls.


> Use -d 2   to remove the ip_idents_reserve() overhead.

#define IP_PMTUDISC_DO	2 /* Always DF	*/

Added a --pmtu option to my udp_flood program
 https://github.com/netoptimizer/network-testing/commit/23a78caf4bb5b

 
> #define _GNU_SOURCE
> 
> #include <errno.h>
> #include <error.h>
> #include <linux/errqueue.h>
> #include <netinet/in.h>
> #include <sched.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/time.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <unistd.h>
> 
> char buffer[1400];
> 
> int main(int argc, char** argv) {
>   int fd, i;
>   struct sockaddr_in6 addr;
>   char *host = "2002:af6:798::1";
>   int family = AF_INET6;
>   int discover = -1;
> 
>   while ((i = getopt(argc, argv, "4H:d:")) != -1) {
>     switch (i) {
>     case 'H': host = optarg; break;
>     case '4': family = AF_INET; break;
>     case 'd': discover = atoi(optarg); break;
>     }
>   }
>   fd = socket(family, SOCK_DGRAM, 0);
>   if (fd < 0)
>     error(1, errno, "failed to create socket");
>   if (discover != -1)
>     setsockopt(fd, SOL_IP, IP_MTU_DISCOVER,
>                &discover, sizeof(discover));
> 
>   memset(&addr, 0, sizeof(addr));
>   if (family == AF_INET6) {
> 	  addr.sin6_family = AF_INET6;
> 	  addr.sin6_port = htons(9);
>       inet_pton(family, host, (void *)&addr.sin6_addr.s6_addr);
>   } else {
>     struct sockaddr_in *in = (struct sockaddr_in *)&addr;
>     in->sin_family = family;
>     in->sin_port = htons(9);
>       inet_pton(family, host, &in->sin_addr);
>   }
>   connect(fd, (struct sockaddr *)&addr,
>           (family == AF_INET6) ? sizeof(addr) :
>                                  sizeof(struct sockaddr_in));
>   memset(buffer, 1, 1400);
>   for (i = 0; i < 655360000; i++) {
>     memcpy(buffer, &i, sizeof(i));
>     send(fd, buffer, 100 + rand() % 200, 0);

Using send() avoids the fib_table_lookup, on a connected UDP socket.

>   }
>   return 0;
> }


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
