From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH v2] 8021q: set hard_header_len when VLAN
 offload features are toggled
Date: Tue, 26 Oct 2010 19:05:07 -0700
Message-ID: <AANLkTi=9tL5yrVGWsOagcgyKte5z8R9ADdz5n-Uf2Lsw@mail.gmail.com>
References: <20101026215933.2339.45454.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53174 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab0J0CFJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 22:05:09 -0400
Received: by wyf28 with SMTP id 28so149704wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 19:05:07 -0700 (PDT)
In-Reply-To: <20101026215933.2339.45454.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 2:59 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
> This results in pskb_expand_head() being used unnecessarily.
>
> This add a check in vlan_transfer_features =A0to catch the ETH_FLAG_T=
XVLAN
> flag and set the header length. This requires drivers to add the
> ETH_FLAG_TXVLAN to vlan_features.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I think this addresses all of the original problems.  However, I don't
think that we want to have drivers claim to support vlan offloading as
a feature for vlan packets.  That implies some type of QinQ
functionality to me.  In addition, if the vlan device claims to
support offloading and a second vlan device is stacked on top of it,
then the two will clobber skb->vlan_tci.  It's probably simpler to
just keep track of whether vlan offloading is currently enabled so we
can find out whether it changed.

> ---
>
> =A0net/8021q/vlan.c | =A0 10 ++++++++++
> =A01 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 05b867e..825011b 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -334,6 +334,16 @@ static void vlan_transfer_features(struct net_de=
vice *dev,
> =A0 =A0 =A0 =A0vlandev->features &=3D ~dev->vlan_features;
> =A0 =A0 =A0 =A0vlandev->features |=3D dev->features & dev->vlan_featu=
res;
> =A0 =A0 =A0 =A0vlandev->gso_max_size =3D dev->gso_max_size;
> +
> + =A0 =A0 =A0 /* is ETH_FLAGS_TXVLAN being toggled */
> + =A0 =A0 =A0 if ((vlandev->features & ETH_FLAG_TXVLAN) ^
> + =A0 =A0 =A0 =A0 =A0 (old_features & ETH_FLAG_TXVLAN)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vlandev->features & ETH_FLAG_TXVLAN=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlandev->hard_header_le=
n -=3D VLAN_HLEN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlandev->hard_header_le=
n +=3D VLAN_HLEN;
> + =A0 =A0 =A0 }

The correct flag for dev->features is NETIF_F_HW_VLAN_TX.
ETH_FLAGS_TXVLAN is an ethtool construct (that happens to have the
same value).

Thanks.
