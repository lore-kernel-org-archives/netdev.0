From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH 3/3] fs_enet: Add FEC TX Alignment workaround
	for MPC5121
Date: Thu, 21 Jan 2010 09:49:57 -0700
Message-ID: <fa686aa41001210849l1c9bdfbfla4dcb39d4b0d062b@mail.gmail.com>
References: <1264039999-25731-1-git-send-email-agust@denx.de>
	<1264039999-25731-4-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: wd@denx.de, dzu@denx.de, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1264039999-25731-4-git-send-email-agust@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 20, 2010 at 7:13 PM, Anatolij Gustschin <agust@denx.de> wrote:
> The FEC on 5121 has problems with misaligned tx buffers.
> The RM says any alignment is ok but empirical results
> show that packet buffers ending in 0x1E will sometimes
> hang the FEC. =A0Other bad alignment does not hang but will
> cause silent TX failures resulting in about a 1% packet
> loss as tested by ping -f from a remote host.
>
> This patch is a work around that copies every tx packet
> to an aligned skb before sending.
>
> Signed-off-by: John Rigby <jcrigby@gmail.com>
> Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> Cc: <linuxppc-dev@ozlabs.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> ---
> Changes since previous submited version:
>
> - don't use printk any more and use dev_warn().
>
> =A0drivers/net/fs_enet/fs_enet-main.c | =A0 38 ++++++++++++++++++++++++++=
++++++++++
> =A01 files changed, 38 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_=
enet-main.c
> index 6bce5c8..7f0bd5d 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -580,6 +580,32 @@ void fs_cleanup_bds(struct net_device *dev)
>
> =A0/*********************************************************************=
*************/
>
> +static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct sk_buff *new_skb;
> + =A0 =A0 =A0 struct fs_enet_private *fep =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 /* Alloc new skb */
> + =A0 =A0 =A0 new_skb =3D dev_alloc_skb(ENET_RX_FRSIZE + 32);
> + =A0 =A0 =A0 if (!new_skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "Memory squeeze, droppin=
g tx packet.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Make sure new skb is properly aligned */
> + =A0 =A0 =A0 skb_align(new_skb, 32);
> +
> + =A0 =A0 =A0 /* Copy data to new skb ... */
> + =A0 =A0 =A0 skb_copy_from_linear_data(skb, new_skb->data, skb->len);
> + =A0 =A0 =A0 skb_put(new_skb, skb->len);
> +
> + =A0 =A0 =A0 /* ... and free an old one */
> + =A0 =A0 =A0 dev_kfree_skb_any(skb);
> +
> + =A0 =A0 =A0 return new_skb;
> +}

This looks expensive.  It's allocating a new skb on *every* packet
transmission, rather than just on the ones that fail the alignment
condition.

> +
> =A0static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> @@ -588,6 +614,18 @@ static int fs_enet_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
> =A0 =A0 =A0 =A0u16 sc;
> =A0 =A0 =A0 =A0unsigned long flags;
>
> + =A0 =A0 =A0 if (fep->fec.fec_id =3D=3D FS_ENET_MPC5121_FEC) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D tx_skb_align_workaround(dev, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We have lost packet du=
e to memory allocation error
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in tx_skb_align_workar=
ound(). Hopefully original skb
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is still valid, so try=
 transmit it later.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +

Rather than performing this test every time through on a fast path,
consider creating a new start_xmit hook and registering the correct
one in the ops structure at probe time.

> =A0 =A0 =A0 =A0spin_lock_irqsave(&fep->tx_lock, flags);
>
> =A0 =A0 =A0 =A0/*
> --
> 1.5.6.3
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
