From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 08:36:28 -0400
Message-ID: <20151021123628.GP6948@oracle.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
 <65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
 <20151021065704.GM7701@secunet.com>
 <20151021105442.GM6948@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	dhowells@redhat.com, davem@davemloft.net, zohar@linux.vnet.ibm.com,
	David.Woodhouse@intel.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151021105442.GM6948@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/21/15 06:54), Sowmini Varadhan wrote:
> But __alignof__(*p) is 8 on sparc, and without the patch I get
> all types of unaligned access. So what do you suggest as the fix?

Even though the alignment is, in fact, 8 (and that comes from
struct xfrm_lifetime_cfg), if uspace is firmly attached to the 4 byte
alignment, I think we can retain that behavior and still avoid
unaligned access in the kernel with the following (admittedly ugly hack).
Can you please take a look? I tested it with 'ip x m' and a transport 
mode tunnel on my sparc.


diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 158ef4a..ca4e7f0 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2620,7 +2620,7 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 {
        struct net *net = xs_net(x);
-       struct xfrm_usersa_info *p;
+       struct xfrm_usersa_info *p, tmp;
        struct xfrm_usersa_id *id;
        struct nlmsghdr *nlh;
        struct sk_buff *skb;
@@ -2659,11 +2659,16 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
                if (attr == NULL)
                        goto out_free_skb;
 
-               p = PTR_ALIGN(nla_data(attr), __alignof__(*p));
+               p = nla_data(attr);
+               err = copy_to_user_state_extra(x, &tmp, skb);
+               if (err)
+                       goto out_free_skb;
+               memcpy((u8 *)p, &tmp, sizeof(tmp));
+       } else {
+               err = copy_to_user_state_extra(x, p, skb);
+               if (err)
+                       goto out_free_skb;
        }
-       err = copy_to_user_state_extra(x, p, skb);
-       if (err)
-               goto out_free_skb;
 
        nlmsg_end(skb, nlh);
