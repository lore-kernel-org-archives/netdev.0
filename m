From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v7 11/19] Use callback to deal with
 skb_release_data() specially.
Date: Sat, 05 Jun 2010 16:56:13 +0200
Message-ID: <1275749773.5238.244.camel@edumazet-laptop>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-9-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-10-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:33185 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933305Ab0FEO4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 10:56:19 -0400
In-Reply-To: <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 juin 2010 =C3=A0 18:14 +0800, xiaohui.xin@intel.com a =C3=A9=
crit :
> From: Xin Xiaohui <xiaohui.xin@intel.com>
>=20
> If buffer is external, then use the callback to destruct
> buffers.
>=20
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
> ---
>  net/core/skbuff.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 37587f0..418457c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -385,6 +385,11 @@ static void skb_clone_fraglist(struct sk_buff *s=
kb)
> =20
>  static void skb_release_data(struct sk_buff *skb)
>  {
> +	/* check if the skb has external buffers, we have use destructor_ar=
g
> +	 * here to indicate
> +	 */
> +	struct skb_external_page *ext_page =3D skb_shinfo(skb)->destructor_=
arg;
> +

Oh well. This is v7 of your series, and nobody complained yet ?

This is a new cache miss on a _critical_ path.


>  	if (!skb->cloned ||
>  	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : =
1,
>  			       &skb_shinfo(skb)->dataref)) {
> @@ -397,6 +402,12 @@ static void skb_release_data(struct sk_buff *skb=
)
>  		if (skb_has_frags(skb))
>  			skb_drop_fraglist(skb);
> =20
> +		/* if the skb has external buffers, use destructor here,
> +		 * since after that skb->head will be kfree, in case skb->head
> +		 * from external buffer cannot use kfree to destroy.
> +		 */

Why not deferring here the access to skb_shinfo(skb)->destructor_arg ?

> +		if (dev_is_mpassthru(skb->dev) && ext_page && ext_page->dtor)
> +			ext_page->dtor(ext_page);
>  		kfree(skb->head);
>  	}
>  }

if (dev_is_mpassthru(skb->dev)) {
	struct skb_external_page *ext_page =3D
				skb_shinfo(skb)->destructor_arg;
	if (ext_page && ext_page->dtor)
		ext_page->dtor(ext_page);
}

destructor_arg should me moved before frags[] if you really want to use=
 it.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf243fc..b136d90 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -202,10 +202,11 @@ struct skb_shared_info {
         */
        atomic_t        dataref;
=20
-       skb_frag_t      frags[MAX_SKB_FRAGS];
        /* Intermediate layers must ensure that destructor_arg
         * remains valid until skb destructor */
        void *          destructor_arg;
+
+       skb_frag_t      frags[MAX_SKB_FRAGS];
 };
=20
 /* We divide dataref into two halves.  The higher 16 bits hold referen=
ces



