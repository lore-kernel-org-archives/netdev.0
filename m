From: kaber@trash.net
Subject: [PATCH 1/2] netfilter: NF_HOOK_COND has wrong conditional
Date: Fri, 12 Nov 2010 16:19:31 +0100
Message-ID: <1289575172-7272-2-git-send-email-kaber@trash.net>
References: <1289575172-7272-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Paris <eparis@redhat.com>, stable@kernel.org,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34575 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100Ab0KLPWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 10:22:31 -0500
In-Reply-To: <1289575172-7272-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Paris <eparis@redhat.com>

The NF_HOOK_COND returns 0 when it shouldn't due to what I believe to be an
error in the code as the order of operations is not what was intended.  C will
evalutate == before =.  Which means ret is getting set to the bool result,
rather than the return value of the function call.  The code says

if (ret = function() == 1)
when it meant to say:
if ((ret = function()) == 1)

Normally the compiler would warn, but it doesn't notice it because its
a actually complex conditional and so the wrong code is wrapped in an explict
set of () [exactly what the compiler wants you to do if this was intentional].
Fixing this means that errors when netfilter denies a packet get propagated
back up the stack rather than lost.

Problem introduced by commit 2249065f (netfilter: get rid of the grossness
in netfilter.h).

Signed-off-by: Eric Paris <eparis@redhat.com>
Cc: stable@kernel.org
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 89341c3..03317c8 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -215,7 +215,7 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sk_buff *skb,
 	int ret;
 
 	if (!cond ||
-	    (ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MIN) == 1))
+	    ((ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MIN)) == 1))
 		ret = okfn(skb);
 	return ret;
 }
-- 
1.7.3.2

