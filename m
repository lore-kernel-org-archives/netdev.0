From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36/stable v2] vlan: Fix crash when hwaccel rx pkt for
 non-existant vlan.
Date: Wed, 27 Oct 2010 17:11:00 -0700
Message-ID: <AANLkTi=EHVBSNNmsts4xTVZ2DGTBD92mHnpP0e5ZYEx1@mail.gmail.com>
References: <1288112797-21550-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51123 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757365Ab0J1ALB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 20:11:01 -0400
Received: by wwe15 with SMTP id 15so1420092wwe.1
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 17:11:00 -0700 (PDT)
In-Reply-To: <1288112797-21550-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:06 AM, Ben Greear <greearb@candelatech.com> =
wrote:
> The vlan_hwaccel_do_receive code expected skb->dev to always
> be a vlan device, but if the NIC was promisc, and the VLAN
> for a particular VID was not configured, then this method
> could receive a packet where skb->dev was NOT a vlan
> device. =A0This caused access of bad memory and a crash.
>
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> v1 -> v2: =A0Simplify patch..no need for setting pkt-type, etc.
>
> :100644 100644 0eb96f7... 0687b6c... M =A0net/8021q/vlan_core.c
> :100644 100644 660dd41... 5dc45b9... M =A0net/core/dev.c
> =A0net/8021q/vlan_core.c | =A0 =A03 +++
> =A0net/core/dev.c =A0 =A0 =A0 =A0| =A0 =A05 +++--
> =A02 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 0eb96f7..0687b6c 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -43,6 +43,9 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
> =A0 =A0 =A0 =A0struct net_device *dev =3D skb->dev;
> =A0 =A0 =A0 =A0struct vlan_rx_stats =A0 =A0 *rx_stats;
>
> + =A0 =A0 =A0 if (!is_vlan_dev(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> =A0 =A0 =A0 =A0skb->dev =3D vlan_dev_info(dev)->real_dev;
> =A0 =A0 =A0 =A0netif_nit_deliver(skb);
>

What if we dropped any packet with a tag in skb->vlan_tci before it
gets to the bridge hooks?  That would accomplish the original goal of
getting packets to tcpdump while preventing them from making it to
places where they aren't expected,  It will provide the same behavior
as earlier kernels.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 660dd41..5dc45b9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2828,8 +2828,9 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
> =A0 =A0 =A0 =A0if (!netdev_tstamp_prequeue)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0net_timestamp_check(skb);
>
> - =A0 =A0 =A0 if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive=
(skb))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_RX_SUCCESS;
> + =A0 =A0 =A0 if (vlan_tx_tag_present(skb))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This method cannot fail at this time=
=2E */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_hwaccel_do_receive(skb);

This is correct but it's not a bugfix, so I'm not sure that it should
go to -stable.  It's already been fixed for 2.6.37.
