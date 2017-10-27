From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 2/2] bpf: rename sk_actions to align with bpf
 infrastructure
Date: Fri, 27 Oct 2017 09:45:53 -0700
Message-ID: <20171027164553.28498.47472.stgit@john-Precision-Tower-5810>
References: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, daniel@iogearbox.net
To: alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:50142 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdJ0QqG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 12:46:06 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so5339769pfe.6
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 09:46:05 -0700 (PDT)
In-Reply-To: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent additions to support multiple programs in cgroups impose
a strict requirement, "all yes is yes, any no is no". To enforce
this the infrastructure requires the 'no' return code, SK_DROP in
this case, to be 0.

To apply these rules to SK_SKB program types the sk_actions return
codes need to be adjusted.

This fix adds SK_PASS and makes 'SK_DROP = 0'. Finally, remove
SK_ABORTED to remove any chance that the API may allow aborted
program flows to be passed up the stack. This would be incorrect
behavior and allow programs to break existing policies.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/uapi/linux/bpf.h       |    6 +++---
 kernel/bpf/sockmap.c           |    3 ++-
 net/core/filter.c              |    5 +++--
 tools/include/uapi/linux/bpf.h |    4 ++--
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f90860d..0d7948c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -575,7 +575,7 @@ enum bpf_attach_type {
  *     @map: pointer to sockmap
  *     @key: key to lookup sock in map
  *     @flags: reserved for future use
- *     Return: SK_REDIRECT
+ *     Return: SK_PASS
  *
  * int bpf_sock_map_update(skops, map, key, flags)
  *	@skops: pointer to bpf_sock_ops
@@ -786,8 +786,8 @@ struct xdp_md {
 };
 
 enum sk_action {
-	SK_ABORTED = 0,
-	SK_DROP,
+	SK_DROP = 0,
+	SK_PASS,
 	SK_REDIRECT,
 };
 
diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 6778fb7..66f00a2 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -122,7 +122,8 @@ static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 	preempt_enable();
 	skb->sk = NULL;
 
-	return rc;
+	return rc == SK_PASS ?
+		(TCP_SKB_CB(skb)->bpf.map ? SK_REDIRECT : SK_PASS) : SK_DROP;
 }
 
 static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
diff --git a/net/core/filter.c b/net/core/filter.c
index 68eaa2f..6ae94f8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1844,14 +1844,15 @@ int skb_do_redirect(struct sk_buff *skb)
 {
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
+	/* If user passes invalid input drop the packet. */
 	if (unlikely(flags))
-		return SK_ABORTED;
+		return SK_DROP;
 
 	tcb->bpf.key = key;
 	tcb->bpf.flags = flags;
 	tcb->bpf.map = map;
 
-	return SK_REDIRECT;
+	return SK_PASS;
 }
 
 struct sock *do_sk_redirect_map(struct sk_buff *skb)
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 24b35a1..c174971 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -787,8 +787,8 @@ struct xdp_md {
 };
 
 enum sk_action {
-	SK_ABORTED = 0,
-	SK_DROP,
+	SK_DROP = 0,
+	SK_PASS,
 	SK_REDIRECT,
 };
 
