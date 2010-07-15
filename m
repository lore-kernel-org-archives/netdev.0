From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] Question about tcp_sendmsg()
Date: Thu, 15 Jul 2010 15:14:48 +0200
Message-ID: <1279199688.2496.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64547 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933202Ab0GONOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 09:14:52 -0400
Received: by wyb42 with SMTP id 42so695903wyb.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 06:14:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigating for various bug reports in tcp stack, I looked at
commit def87cf42069a (tcp: Slightly optimize tcp_sendmsg)

One question I have is that the 

sg = sk->sk_route_caps & NETIF_F_SG;

is now done at the beginning of tcp_sendmsg(), and kept in sg variable
for the whole tcp_sendmsg() duration, even if task has to wait for
space.

Previously sk->sk_route_caps & NETIF_F_SG was done in select_size()
itself.

I am wondering if this can have a side effect, if SG capability changes
while a thread has to wait in sk_stream_wait_memory(), and socket route
changes (sk_route_caps flips NETIF_F_SG bit)

Thanks

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9fce8a8..8a4d9bd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1093,6 +1093,7 @@ wait_for_memory:
 				goto do_error;
 
 			mss_now = tcp_send_mss(sk, &size_goal, flags);
+			sg = sk->sk_route_caps & NETIF_F_SG;
 		}
 	}
 


