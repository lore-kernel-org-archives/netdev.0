From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-2.6 3/3] bonding/vlan: Fix mangled NAs on slaves
 without VLAN tag insertion
Date: Mon, 13 Dec 2010 14:20:57 -0800
Message-ID: <AANLkTimHQhOWxj-2ParX_-Tfyhf=OmkkWpq34chixX6=@mail.gmail.com>
References: <1292264216.9860.11.camel@bwh-desktop>
	<1292264424.9860.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:39330 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab0LMWU6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 17:20:58 -0500
Received: by fxm18 with SMTP id 18so6870535fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:20:57 -0800 (PST)
In-Reply-To: <1292264424.9860.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 10:20 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> bond_na_send() attempts to insert a VLAN tag in between building and
> sending packets of the respective formats. =A0If the slave does not
> implement hardware VLAN tag insertion then vlan_put_tag() will mangle
> the network-layer header because the Ethernet header is not present a=
t
> this point (unlike in bond_arp_send()).
>
> Fix this by adding the tag out-of-line and relying on
> dev_hard_start_xmit() to insert it inline if necessary.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> =A0drivers/net/bonding/bond_ipv6.c | =A0 =A07 ++++++-
> =A01 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bo=
nd_ipv6.c
> index 121b073..84fbd4e 100644
> --- a/drivers/net/bonding/bond_ipv6.c
> +++ b/drivers/net/bonding/bond_ipv6.c
> @@ -88,7 +88,12 @@ static void bond_na_send(struct net_device *slave_=
dev,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (vlan_id) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D vlan_put_tag(skb, vlan_id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The Ethernet header is not present y=
et, so it is
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* too early to insert a VLAN tag. =A0=
=46orce use of an
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* out-of-line tag here and let dev_h=
ard_start_xmit()
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* insert it if the slave hardware ca=
n't.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D __vlan_hwaccel_put_tag(skb, vla=
n_id);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!skb) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("failed to inse=
rt VLAN tag\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;

You could drop the check for !skb, since __vlan_hwaccel_put_tag() can
never fail.

Actually, my plan is to remove all current users of vlan_put_tag() and
replace them with __vlan_hwaccel_put_tag (and then rename that to
vlan_put_tag()).  There's really no reason why the upper layers should
have to care what the underlying device is capable of, now that
dev_hard_start_xmit() can handle it.

Reviewed-by: Jesse Gross <jesse@nicira.com>
