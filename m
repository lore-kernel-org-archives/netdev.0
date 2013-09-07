From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: fib: fib6_add: fix potential NULL pointer dereference
Date: Sat,  7 Sep 2013 15:13:20 +0200
Message-ID: <1378559600-15858-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Lin Ming <mlin@ss.pku.edu.cn>,
	Matti Vaittinen <matti.vaittinen@nsn.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab3IGNNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Sep 2013 09:13:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the kernel is compiled with CONFIG_IPV6_SUBTREES, and we return
with an error in fn = fib6_add_1(), then error codes are encoded into
the return pointer e.g. ERR_PTR(-ENOENT). In such an error case, we
write the error code into err and jump to out, hence enter the if(err)
condition. Now, if CONFIG_IPV6_SUBTREES is enabled, we check for:

  if (pn != fn && pn->leaf == rt)
    ...
  if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO))
    ...

Since pn is NULL and fn is f.e. ERR_PTR(-ENOENT), then pn != fn
evaluates to true and causes a NULL-pointer dereference on further
checks on pn. Fix it, by setting both NULL in error case, so that
pn != fn already evaluates to false and no further dereference
takes place.

This was first correctly implemented in 4a287eba2 ("IPv6 routing,
NLM_F_* flag support: REPLACE and EXCL flags support, warn about
missing CREATE flag"), but the bug got later on introduced by
188c517a0 ("ipv6: return errno pointers consistently for fib6_add_1()").

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Lin Ming <mlin@ss.pku.edu.cn>
Cc: Matti Vaittinen <matti.vaittinen@nsn.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 73db48e..5bec666 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -825,9 +825,9 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			offsetof(struct rt6_info, rt6i_dst), allow_create,
 			replace_required);
-
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
+		fn = NULL;
 		goto out;
 	}
 
-- 
1.7.11.7
