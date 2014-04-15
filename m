From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 3/3] ipv4,fib: pass 0 instead of LOOPBACK_IFINDEX to fib_validate_source()
Date: Mon, 14 Apr 2014 18:33:28 -0700
Message-ID: <1397525608-11592-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:51709 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaDOBdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 21:33:40 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so8846995pdb.28
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 18:33:40 -0700 (PDT)
In-Reply-To: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

In my special case, when a packet is redirected from veth0 to lo,
its skb->dev->ifindex would be LOOPBACK_IFINDEX. Meanwhile we
pass the hard-coded LOOPBACK_IFINDEX to fib_validate_source()
in ip_route_input_slow(). This would cause the following check
in fib_validate_source() fail:

            (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))

when rp_filter is disabeld on loopback. As suggested by Julian,
the caller should pass 0 here so that we will not end up by
calling __fib_validate_source().

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/ipv4/route.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 20a59c3..93d4921 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1700,8 +1700,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
-					  LOOPBACK_IFINDEX,
-					  dev, in_dev, &itag);
+					  0, dev, in_dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		goto local_input;
-- 
1.8.3.1
