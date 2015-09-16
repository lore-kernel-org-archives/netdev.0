From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 03/30] netfilter: Pass net to nf_hook_thresh
Date: Tue, 15 Sep 2015 20:03:51 -0500
Message-ID: <1442365458-16349-3-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 889ac0e11f01..042148dc1e22 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -170,6 +170,7 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
  *	value indicates the packet has been consumed by the hook.
  */
 static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
+				 struct net *net,
 				 struct sock *sk,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
@@ -177,7 +178,6 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 int (*okfn)(struct sock *, struct sk_buff *),
 				 int thresh)
 {
-	struct net *net = dev_net(indev ? indev : outdev);
 	struct list_head *hook_list = &net->nf.hooks[pf][hook];
 
 	if (nf_hook_list_active(hook_list, pf, hook)) {
@@ -195,7 +195,8 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
 			  struct net_device *outdev,
 			  int (*okfn)(struct sock *, struct sk_buff *))
 {
-	return nf_hook_thresh(pf, hook, sk, skb, indev, outdev, okfn, INT_MIN);
+	struct net *net = dev_net(indev ? indev : outdev);
+	return nf_hook_thresh(pf, hook, net, sk, skb, indev, outdev, okfn, INT_MIN);
 }
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -221,7 +222,8 @@ NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sock *sk,
 	       struct net_device *out,
 	       int (*okfn)(struct sock *, struct sk_buff *), int thresh)
 {
-	int ret = nf_hook_thresh(pf, hook, sk, skb, in, out, okfn, thresh);
+	struct net *net = dev_net(in ? in : out);
+	int ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, thresh);
 	if (ret == 1)
 		ret = okfn(sk, skb);
 	return ret;
@@ -232,10 +234,11 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sock *sk,
 	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
 	     int (*okfn)(struct sock *, struct sk_buff *), bool cond)
 {
+	struct net *net = dev_net(in ? in : out);
 	int ret;
 
 	if (!cond ||
-	    ((ret = nf_hook_thresh(pf, hook, sk, skb, in, out, okfn, INT_MIN)) == 1))
+	    ((ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, INT_MIN)) == 1))
 		ret = okfn(sk, skb);
 	return ret;
 }
-- 
2.2.1

