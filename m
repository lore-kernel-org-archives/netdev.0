From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: [PATCH nf-next,RFC] netfilter: nft_meta: add cgroup version 2 support
Date: Mon, 14 Nov 2016 10:12:41 +0100
Message-ID: <1479114761-19534-1-git-send-email-pablo@netfilter.org>
Cc: daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org, htejun-b10kYP2dOMg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add cgroup version 2 support to nf_tables.

This extension allows us to fetch the cgroup i-node number from the
cgroup socket data, place it in a register, then match it against any
value specified by user. This approach scales up nicely since it
integrates well in the existing nf_tables map infrastructure.

Contrary to what iptables cgroup v2 match does, this patch doesn't use
cgroup_is_descendant() because this call cannot guarantee that the cgroup
hierarchy is honored in anyway given that the cgroup v2 field becomes yet
another packet selector that you can use to build your filtering policy.

Actually, using the i-node approach, it should be easy to build a policy
that honors the hierarchy if you need this, eg.

	meta cgroup2 vmap { "/A/B" : jump b-cgroup-chain,
			    "/A/C" : jump c-cgroup-chain,
			    "/A" : jump a-cgroup-chain }

then, the b-cgroup-chain looks like:

	jump a-cgroup-chain
	... # specific policy b-cgroup-chain goes here

similarly, the c-cgroup-chain looks like:

	jump a-cgroup-chain
	... # specific policy c-cgroup-chain goes here

So both B and C would evaluate A's ruleset. Note that cgroup A would
also jump to the root cgroup chain policy.

Anyway, this cgroup i-node approach provides way more flexibility since
it is up to the sysadmin to decide if he wants to honor the hierarchy or
simply define a fast path to skip any further classification.

Signed-off-by: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_meta.c                 | 15 +++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 0da7ccf65511..5d4d08367a87 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -729,6 +729,7 @@ enum nft_exthdr_attributes {
  * @NFT_META_OIFGROUP: packet output interface group
  * @NFT_META_CGROUP: socket control group (skb->sk->sk_classid)
  * @NFT_META_PRANDOM: a 32bit pseudo-random number
+ * @NFT_META_CGROUP2: socket control group v2 (skb->sk->sk_cgrp_data)
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -756,6 +757,7 @@ enum nft_meta_keys {
 	NFT_META_OIFGROUP,
 	NFT_META_CGROUP,
 	NFT_META_PRANDOM,
+	NFT_META_CGROUP2,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 6c1e0246706e..1e793e133903 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -190,6 +190,18 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		*dest = prandom_u32_state(state);
 		break;
 	}
+#ifdef CONFIG_SOCK_CGROUP_DATA
+	case NFT_META_CGROUP2: {
+		struct cgroup *cgrp;
+
+		if (!skb->sk || !sk_fullsock(skb->sk))
+			goto err;
+
+		cgrp = sock_cgroup_ptr(&skb->sk->sk_cgrp_data);
+		*dest = cgrp->kn->ino;
+		break;
+	}
+#endif
 	default:
 		WARN_ON(1);
 		goto err;
@@ -273,6 +285,9 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 #ifdef CONFIG_CGROUP_NET_CLASSID
 	case NFT_META_CGROUP:
 #endif
+#ifdef CONFIG_SOCK_CGROUP_DATA
+	case NFT_META_CGROUP2:
+#endif
 		len = sizeof(u32);
 		break;
 	case NFT_META_IIFNAME:
-- 
2.1.4
