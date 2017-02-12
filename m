From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the ipsec-next tree with the net-next
 tree
Date: Mon, 13 Feb 2017 10:25:31 +1100
Message-ID: <20170213102531.60d3f36d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Julian Anastasov <ja@ssi.bg>, Florian Westphal <fw@strlen.de>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steffen,

Today's linux-next merge of the ipsec-next tree got a conflict in:

  net/xfrm/xfrm_policy.c

between commit:

  63fca65d0863 ("net: add confirm_neigh method to dst_ops")

from the net-next tree and commits:

  3d7d25a68ea5 ("xfrm: policy: remove garbage_collect callback")
  a2817d8b279b ("xfrm: policy: remove family field")

from the ipsec-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/xfrm/xfrm_policy.c
index f68d75766d51,04ed1a1ae019..000000000000
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@@ -2856,32 -2843,15 +2843,32 @@@ static struct neighbour *xfrm_neigh_loo
  	return dst->path->ops->neigh_lookup(dst, skb, daddr);
  }
  
 +static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
 +{
 +	const struct dst_entry *path = dst->path;
 +
 +	for (; dst != path; dst = dst->child) {
 +		const struct xfrm_state *xfrm = dst->xfrm;
 +
 +		if (xfrm->props.mode == XFRM_MODE_TRANSPORT)
 +			continue;
 +		if (xfrm->type->flags & XFRM_TYPE_REMOTE_COADDR)
 +			daddr = xfrm->coaddr;
 +		else if (!(xfrm->type->flags & XFRM_TYPE_LOCAL_COADDR))
 +			daddr = &xfrm->id.daddr;
 +	}
 +	path->ops->confirm_neigh(path, daddr);
 +}
 +
- int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
+ int xfrm_policy_register_afinfo(const struct xfrm_policy_afinfo *afinfo, int family)
  {
  	int err = 0;
- 	if (unlikely(afinfo == NULL))
- 		return -EINVAL;
- 	if (unlikely(afinfo->family >= NPROTO))
+ 
+ 	if (WARN_ON(family >= ARRAY_SIZE(xfrm_policy_afinfo)))
  		return -EAFNOSUPPORT;
+ 
  	spin_lock(&xfrm_policy_afinfo_lock);
- 	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
+ 	if (unlikely(xfrm_policy_afinfo[family] != NULL))
  		err = -EEXIST;
  	else {
  		struct dst_ops *dst_ops = afinfo->dst_ops;
@@@ -2899,11 -2869,7 +2886,9 @@@
  			dst_ops->link_failure = xfrm_link_failure;
  		if (likely(dst_ops->neigh_lookup == NULL))
  			dst_ops->neigh_lookup = xfrm_neigh_lookup;
 +		if (likely(!dst_ops->confirm_neigh))
 +			dst_ops->confirm_neigh = xfrm_confirm_neigh;
- 		if (likely(afinfo->garbage_collect == NULL))
- 			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
- 		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
+ 		rcu_assign_pointer(xfrm_policy_afinfo[family], afinfo);
  	}
  	spin_unlock(&xfrm_policy_afinfo_lock);
  
