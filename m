From: fgao@ikuai8.com
Subject: [PATCH nf-next] netfilter: xt_osf: Use explicit member assignment to avoid implicit no padding rule
Date: Tue, 27 Sep 2016 12:39:53 +0800
Message-ID: <1474951193-3486-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

Current xt_osf codes use memcmp to check if two user fingers are same,
so it depends on that the struct xt_osf_user_finger is no padding.
It is one implicit rule, and is not good to maintain.

Now use zero memory and assign the members explicitly.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/netfilter/xt_osf.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 2455b69..9793670 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -61,6 +61,34 @@ static const struct nla_policy xt_osf_policy[OSF_ATTR_MAX + 1] = {
 	[OSF_ATTR_FINGER]	= { .len = sizeof(struct xt_osf_user_finger) },
 };
 
+static void copy_user_finger(struct xt_osf_user_finger *dst,
+			     const struct xt_osf_user_finger *src)
+{
+#define OSF_COPY_MEMBER(mem)	dst->mem = src->mem
+
+	int i;
+
+	OSF_COPY_MEMBER(wss.wc);
+	OSF_COPY_MEMBER(wss.val);
+
+	OSF_COPY_MEMBER(ttl);
+	OSF_COPY_MEMBER(df);
+	OSF_COPY_MEMBER(ss);
+	OSF_COPY_MEMBER(mss);
+	OSF_COPY_MEMBER(opt_num);
+
+	memcpy(dst->genre, src->genre, sizeof(dst->genre));
+	memcpy(dst->version, src->version, sizeof(dst->version));
+	memcpy(dst->subtype, src->subtype, sizeof(dst->subtype));
+
+	for (i = 0; i < MAX_IPOPTLEN; ++i) {
+		OSF_COPY_MEMBER(opt[i].kind);
+		OSF_COPY_MEMBER(opt[i].length);
+		OSF_COPY_MEMBER(opt[i].wc.wc);
+		OSF_COPY_MEMBER(opt[i].wc.val);
+	}
+}
+
 static int xt_osf_add_callback(struct net *net, struct sock *ctnl,
 			       struct sk_buff *skb, const struct nlmsghdr *nlh,
 			       const struct nlattr * const osf_attrs[])
@@ -77,11 +105,11 @@ static int xt_osf_add_callback(struct net *net, struct sock *ctnl,
 
 	f = nla_data(osf_attrs[OSF_ATTR_FINGER]);
 
-	kf = kmalloc(sizeof(struct xt_osf_finger), GFP_KERNEL);
+	kf = kzalloc(sizeof(*kf), GFP_KERNEL);
 	if (!kf)
 		return -ENOMEM;
 
-	memcpy(&kf->finger, f, sizeof(struct xt_osf_user_finger));
+	copy_user_finger(&kf->finger, f);
 
 	list_for_each_entry(sf, &xt_osf_fingers[!!f->df], finger_entry) {
 		if (memcmp(&sf->finger, f, sizeof(struct xt_osf_user_finger)))
-- 
1.9.1


