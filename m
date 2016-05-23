From: Alan Davey <alan.davey@metaswitch.com>
Subject: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is set.
Date: Mon, 23 May 2016 15:23:45 +0100
Message-ID: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	Alan Davey <alan.davey@metaswitch.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0102.outbound.protection.outlook.com ([157.56.110.102]:35233
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753662AbcEZOYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 10:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the bugs documented in the raw(7) man page is as follows: When the
IP_HDRINCL option is set, datagrams will not be fragmented and are limited to
the interface MTU.

This patch fixes the bug by removing the check for "length > rt->dst.dev->mtu"
in raw_send_hdrinc() (net/ipv4/raw.c).  Datagrams are no longer limited to the
interface MTU size if the IP_HDRINCL option is set, but are fragmented, if
necessary, in the same way as all other datagrams.

Signed-off-by: Alan Davey <alan.davey@metaswitch.com>
---
 net/ipv4/raw.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8d22de7..de690b3 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -351,11 +351,6 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	struct rtable *rt = *rtp;
 	int hlen, tlen;
 
-	if (length > rt->dst.dev->mtu) {
-		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
-			       rt->dst.dev->mtu);
-		return -EMSGSIZE;
-	}
 	if (flags&MSG_PROBE)
 		goto out;
 
-- 
1.8.3.1
