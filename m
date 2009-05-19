From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: [PATCH] IPv6: set RTPROT_KERNEL to initial route
Date: Tue, 19 May 2009 09:56:15 +0200
Message-ID: <4A12661F.1090301@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090605020306060106090202"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from milan.magic.fr ([195.154.126.74]:40809 "EHLO milan.magic.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbZESI1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 04:27:13 -0400
Received: from localhost (localhost [127.0.0.1])
	by milan.magic.fr (Postfix) with ESMTP id 4F56119CD18
	for <netdev@vger.kernel.org>; Tue, 19 May 2009 09:55:40 +0200 (CEST)
Received: from milan.magic.fr ([127.0.0.1])
	by localhost (milan.magic.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zpmYVvqZrxEa for <netdev@vger.kernel.org>;
	Tue, 19 May 2009 09:55:34 +0200 (CEST)
Received: from [192.168.0.11] (xbn44-4-88-165-25-172.fbx.proxad.net [88.165.25.172])
	by milan.magic.fr (Postfix) with ESMTP id 4A0EB19CD16
	for <netdev@vger.kernel.org>; Tue, 19 May 2009 09:55:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090605020306060106090202
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

The use of unspecified protocol in IPv6 initial route prevents quagga to
install IPv6 default route:
# show ipv6 route
S   ::/0 [1/0] via fe80::1, eth1_0
K>* ::/0 is directly connected, lo, rej
C>* ::1/128 is directly connected, lo
C>* fe80::/64 is directly connected, eth1_0

# ip -6 route
fe80::/64 dev eth1_0  proto kernel  metric 256  mtu 1500 advmss 1440
hoplimit -1
ff00::/8 dev eth1_0  metric 256  mtu 1500 advmss 1440 hoplimit -1
unreachable default dev lo  proto none  metric -1  error -101 hoplimit 255

The attached patch ensures RTPROT_KERNEL to the default initial route
and fixes the problem for quagga.
This is similar to "ipv6: protocol for address routes"
f410a1fba7afa79d2992620e874a343fdba28332.

# show ipv6 route
S>* ::/0 [1/0] via fe80::1, eth1_0
C>* ::1/128 is directly connected, lo
C>* fe80::/64 is directly connected, eth1_0

# ip -6 route
fe80::/64 dev eth1_0  proto kernel  metric 256  mtu 1500 advmss 1440
hoplimit -1
fe80::/64 dev eth1_0  proto kernel  metric 256  mtu 1500 advmss 1440
hoplimit -1
ff00::/8 dev eth1_0  metric 256  mtu 1500 advmss 1440 hoplimit -1
default via fe80::1 dev eth1_0  proto zebra  metric 1024  mtu 1500
advmss 1440 hoplimit -1
unreachable default dev lo  proto kernel  metric -1  error -101 hoplimit 255

Regards,
Jean-Mickael

--------------090605020306060106090202
Content-Type: text/plain;
 name="ipv6-route.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6-route.diff"

Signed-off-by: jean-mickael.guerin@6wind.com

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 32392d7..a7f9fb7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -140,6 +140,7 @@ static struct rt6_info ip6_null_entry_template = {
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_protocol  = RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
@@ -162,6 +163,7 @@ static struct rt6_info ip6_prohibit_entry_template = {
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_protocol  = RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
@@ -179,6 +181,7 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_protocol  = RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
 };

--------------090605020306060106090202--
