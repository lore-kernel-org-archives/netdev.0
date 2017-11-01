From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH] bpf: remove SK_REDIRECT from UAPI
Date: Tue, 31 Oct 2017 19:17:31 -0700
Message-ID: <20171101021731.10955.49498.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:44066 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:17:43 -0400
Received: by mail-pg0-f67.google.com with SMTP id j3so855385pga.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 19:17:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that SK_REDIRECT is no longer a valid return code. Remove it
from the UAPI completely. Then do a namespace remapping internal
to sockmap so SK_REDIRECT is no longer externally visible.

Patchs primary change is to do a namechange from SK_REDIRECT to
__SK_REDIRECT

Reported-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 include/uapi/linux/bpf.h       |    1 -
 kernel/bpf/sockmap.c           |   16 ++++++++++++----
 tools/include/uapi/linux/bpf.h |    3 +--
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0d7948c..7bf4c75 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -788,7 +788,6 @@ struct xdp_md {
 enum sk_action {
 	SK_DROP = 0,
 	SK_PASS,
-	SK_REDIRECT,
 };
 
 #define BPF_TAG_SIZE	8
diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
index 66f00a2..dbd7b32 100644
--- a/kernel/bpf/sockmap.c
+++ b/kernel/bpf/sockmap.c
@@ -101,13 +101,19 @@ static inline void bpf_compute_data_end_sk_skb(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->bpf.data_end = skb->data + skb_headlen(skb);
 }
 
+enum __sk_action {
+	__SK_DROP = 0,
+	__SK_PASS,
+	__SK_REDIRECT,
+};
+
 static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 {
 	struct bpf_prog *prog = READ_ONCE(psock->bpf_verdict);
 	int rc;
 
 	if (unlikely(!prog))
-		return SK_DROP;
+		return __SK_DROP;
 
 	skb_orphan(skb);
 	/* We need to ensure that BPF metadata for maps is also cleared
@@ -122,8 +128,10 @@ static int smap_verdict_func(struct smap_psock *psock, struct sk_buff *skb)
 	preempt_enable();
 	skb->sk = NULL;
 
+	/* Moving return codes from UAPI namespace into internal namespace */
 	return rc == SK_PASS ?
-		(TCP_SKB_CB(skb)->bpf.map ? SK_REDIRECT : SK_PASS) : SK_DROP;
+		(TCP_SKB_CB(skb)->bpf.map ? __SK_REDIRECT : __SK_PASS) :
+		__SK_DROP;
 }
 
 static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
@@ -133,7 +141,7 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 
 	rc = smap_verdict_func(psock, skb);
 	switch (rc) {
-	case SK_REDIRECT:
+	case __SK_REDIRECT:
 		sk = do_sk_redirect_map(skb);
 		if (likely(sk)) {
 			struct smap_psock *peer = smap_psock_sk(sk);
@@ -149,7 +157,7 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
 			}
 		}
 	/* Fall through and free skb otherwise */
-	case SK_DROP:
+	case __SK_DROP:
 	default:
 		kfree_skb(skb);
 	}
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index c174971..01cc7ba 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -576,7 +576,7 @@ enum bpf_attach_type {
  *     @map: pointer to sockmap
  *     @key: key to lookup sock in map
  *     @flags: reserved for future use
- *     Return: SK_REDIRECT
+ *     Return: SK_PASS
  *
  * int bpf_sock_map_update(skops, map, key, flags)
  *	@skops: pointer to bpf_sock_ops
@@ -789,7 +789,6 @@ struct xdp_md {
 enum sk_action {
 	SK_DROP = 0,
 	SK_PASS,
-	SK_REDIRECT,
 };
 
 #define BPF_TAG_SIZE	8
