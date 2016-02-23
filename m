From: Kouya Shimura <kouya@jp.fujitsu.com>
Subject: [PATCH] ipv4: do not cache local route when using SO_BINDTODEVICE
Date: Tue, 23 Feb 2016 14:27:32 +0900
Message-ID: <87si0knghn.fsf@pingu.sky.yk.fujitsu.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:14722 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbcBWF1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 00:27:41 -0500
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id B72B4AC018D
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 14:27:33 +0900 (JST)
Received: from G01JPEXCHKW17.g01.fujitsu.local (G01JPEXCHKW17.g01.fujitsu.local [10.0.194.56])
	by g01jpfmpwkw01.exch.g01.fujitsu.local (Postfix) with ESMTP id 067E36925B7
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 14:27:33 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After v3.6, output routes are cached, however, the 'rt_iif' field of
struct rtable can not be shared by various traffics using SO_BINDTODEVICE.
It causes that traffic can not reach the local receiver which also uses 
SO_BINDTODEVICE after another traffic creates a local route cache. 

  /* sender and receiver are running on same host. */
  sender:
    - socket(SOCK_DGRAM)
    - setsockopt(SO_BINDTODEVICE, "eth0")
    - connect(INADDR_ANY)
    - send("message") ------>[loopback]------+
                                             |
  receiver:                                  |
    - socket(SOCK_DGRAM)                     |
    - setsockopt(SO_BINDTODEVICE, "eth0")    |
    - bind(INADDR_ANY)                       |
    - recv()  <------------------------------+
      /* sometimes reach, sometimes not reach!!! */

Before v3.6, above traffics always reached. It seems to be a
regression. Actually the 'dhcp_release' command relies on it.

Commit 7bd86cc282a458b66c41e3f6 ("ipv4: Cache local output routes")
originated this issue. Revert it conditionally.

Signed-off-by: Kouya Shimura <kouya@jp.fujitsu.com>
---
 net/ipv4/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c6229..4b5e024 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2285,6 +2285,8 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		}
 		dev_out = net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
+		if (orig_oif)
+			res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
-- 
1.9.1
