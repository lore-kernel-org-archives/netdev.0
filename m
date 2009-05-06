From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 03/12] fs_enet: Add FEC TX Alignment workaround for
	MPC5121.
Date: Wed, 6 May 2009 14:37:41 -0600
Message-ID: <fa686aa40905061337w6aa82f5aj787618ba108e528f@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-4-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, netdev@vger.kernel.org,
	John Rigby <jcrigby@gmail.com>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:36366 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbZEFUiB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:38:01 -0400
Received: by yx-out-2324.google.com with SMTP id 3so196620yxj.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 13:38:01 -0700 (PDT)
In-Reply-To: <1241640919-4650-4-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2009 at 2:15 PM, Wolfgang Denk <wd@denx.de> wrote:
> From: John Rigby <jrigby@freescale.com>
>
> The FEC on 5121 has problems with misaligned tx buffers.
> The RM says any alignment is ok but empirical results
> show that packet buffers ending in 0x1E will sometimes
> hang the FEC. =A0Other bad alignment does not hang but will
> cause silent TX failures resulting in about a 1% packet
> loss as tested by ping -f from a remote host.
>
> This patch is a work around that copies every tx packet
> to an aligned skb before sending.

OUCH!

> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index 4170d33..c83ffc3 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -594,6 +594,37 @@ void fs_cleanup_bds(struct net_device *dev)
>
> =A0/*****************************************************************=
*****************/
>
> +#ifdef CONFIG_FS_ENET_FEC_TX_ALIGN_WORKAROUND
> +static struct sk_buff *tx_skb_align_workaround(struct net_device *de=
v,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct sk_buff *new_skb;
> +
> + =A0 =A0 =A0 /* Alloc new skb */
> + =A0 =A0 =A0 new_skb =3D dev_alloc_skb(ENET_RX_FRSIZE + 32);
> + =A0 =A0 =A0 if (!new_skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING DRV_MODULE_NAME
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ": %s M=
emory squeeze, dropping tx packet.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Make sure new skb is properly aligned */
> + =A0 =A0 =A0 skb_align(new_skb, 32);
> +
> + =A0 =A0 =A0 /* Copy data to new skb ... */
> + =A0 =A0 =A0 skb_copy_from_linear_data(skb, new_skb->data, skb->len)=
;
> + =A0 =A0 =A0 skb_put(new_skb, skb->len);
> +
> + =A0 =A0 =A0 /* ... and free an old one */
> + =A0 =A0 =A0 dev_kfree_skb_any(skb);
> +
> + =A0 =A0 =A0 return new_skb;
> +}
> +#else
> +#define tx_skb_align_workaround(dev, skb) (skb)
> +#endif

Another use of #ifdef blocks.  What is the multiplatform impact?

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
