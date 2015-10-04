From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] netfilter: remove the nh_scope test in rpfilter_lookup_reverse of ipt_rpfilter
Date: Sun,  4 Oct 2015 22:56:00 +0800
Message-ID: <c7a265fa26e9558115abb58869caa6012924355b.1443970560.git.lucien.xin@gmail.com>
Cc: fw@strlen.de
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34449 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbbJDO4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 10:56:05 -0400
Received: by padhy16 with SMTP id hy16so10746195pad.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 07:56:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--accept-local  option works for res.type == RTN_LOCAL, which should be from
the local table, but there, the fib_info's nh->nh_scope = RT_SCOPE_NOWHERE
( > RT_SCOPE_HOST). in fib_create_info().

	if (cfg->fc_scope == RT_SCOPE_HOST) {
		struct fib_nh *nh = fi->fib_nh;

		/* Local address is added. */
		if (nhs != 1 || nh->nh_gw)
			goto err_inval;
		nh->nh_scope = RT_SCOPE_NOWHERE;   <===
		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
		err = -ENODEV;
		if (!nh->nh_dev)
			goto failure;

but in our rpfilter_lookup_reverse():

	if (dev_match || flags & XT_RPFILTER_LOOSE)
		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;

if nh->nh_scope > RT_SCOPE_HOST, it will fail. --accept-local option will never
be passed.

it seems the test is bogus and can be removed to fix this issue.

	if (dev_match || flags & XT_RPFILTER_LOOSE)
		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;

ipv6 does not have this issue.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/netfilter/ipt_rpfilter.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 8618fd1..11c5662 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -61,8 +61,6 @@ static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
 	if (FIB_RES_DEV(res) == dev)
 		dev_match = true;
 #endif
-	if (dev_match || flags & XT_RPFILTER_LOOSE)
-		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;
 	return dev_match;
 }
 
-- 
2.1.0
