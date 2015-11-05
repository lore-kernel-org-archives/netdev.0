From: "ronny.hegewald@online.de" <ronny.hegewald@online.de>
Subject: question about checksumming and tcp_sendpage
Date: Thu, 5 Nov 2015 22:34:48 +0100
Message-ID: <trinity-80ad84c3-456a-4f51-a3e9-afee4e8ae504-1446759288452@3capp-1and1-bs03>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:55268 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbKEVev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:34:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While reading through net-code i came across some code in tcp_sendpage which i think 
it is not working in the intended way all tie time. But as this code is at that a 
central place and pretty old, im suspicious if my analysis is really right.

The code in question is this

(from net/ipv4/tcp.c)

       if (!(sk->sk_route_caps & NETIF_F_SG) ||
           !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
                 return sock_no_sendpage(sk->sk_socket, page, offset, size,
                                         flags);
 

especially this part.

      !(sk->sk_route_caps & NETIF_F_ALL_CSUM)

The problem occurs if a device only supports checksumming for ipv4 or ipv6. In 
this cases only NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM is set.

Lets assume a device is only supporting checksumming in ipv6 via NETIF_F_IPV6_CSUM,
and we are calling tcp_sendpage for a ipv4 connection. From my understanding the intend
of the above code is that in this case sock_no_sendpage should be called. But the bit-check 
against NETIF_F_ALL_CSUM will be always > 0, as it is defined as

(from include/linux/netdev_features.h)

#define NETIF_F_V4_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
#define NETIF_F_V6_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
#define NETIF_F_ALL_CSUM        (NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)

so it will never get in that branch.

So imo the code should be something like this (in pseudocode) 

      (!(sk->sk_route_caps & NETIF_F_V4_CSUM) && proto == IPV4) ||
      (!(sk->sk_route_caps & NETIF_F_V6_CSUM) && proto == IPV6)

So what am i missing?
