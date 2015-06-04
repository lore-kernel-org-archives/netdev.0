From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: fix build due to missing tc_verd
Date: Thu,  4 Jun 2015 08:33:48 -0700
Message-ID: <1433432028-7620-1-git-send-email-ast@plumgrid.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35565 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbFDPeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:34:00 -0400
Received: by qkhq76 with SMTP id q76so25710424qkh.2
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:33:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix build error:
net/core/filter.c: In function 'bpf_clone_redirect':
net/core/filter.c:1429:18: error: 'struct sk_buff' has no member named 'tc_verd'
  if (G_TC_AT(skb2->tc_verd) & AT_INGRESS)

Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
Reported-by: Or Gerlitz <gerlitz.or@gmail.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 64c121c09655..09b2062eb5b8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -46,7 +46,6 @@
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
 #include <linux/bpf.h>
-#include <net/sch_generic.h>
 
 /**
  *	sk_filter - run a packet through a socket filter
@@ -1426,8 +1425,7 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	if (unlikely(!skb2))
 		return -ENOMEM;
 
-	if (G_TC_AT(skb2->tc_verd) & AT_INGRESS)
-		skb_push(skb2, skb2->mac_len);
+	skb_push(skb2, skb2->data - skb_mac_header(skb2));
 
 	if (BPF_IS_REDIRECT_INGRESS(flags))
 		return dev_forward_skb(dev, skb2);
-- 
1.7.9.5
