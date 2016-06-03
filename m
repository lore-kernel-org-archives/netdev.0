From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] net: vrf: Add l3mdev rules on first device create
Date: Fri, 3 Jun 2016 14:05:48 +0300
Message-ID: <5D5BA326-86D8-4C53-B27C-0120397893ED@cumulusnetworks.com>
References: <1464916959-4029-1-git-send-email-dsa@cumulusnetworks.com> <1464916959-4029-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36371 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbcFCLFs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 07:05:48 -0400
Received: by mail-wm0-f45.google.com with SMTP id n184so120488155wmn.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 04:05:47 -0700 (PDT)
In-Reply-To: <1464916959-4029-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 3, 2016, at 4:22 AM, David Ahern <dsa@cumulusnetworks.com> wro=
te:
>=20
> Add l3mdev rule per address family when the first VRF device is
> created. Remove them when the last is deleted.
>=20
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - added EXCL flag and EEXISTS check. Appropriate once the exclude fib=
 rule
>  patch is accepted
> - changed 3rd arg to vrf_fib_rule from 0/1 to false/true per Dave's c=
omment
>=20
> drivers/net/vrf.c | 119 +++++++++++++++++++++++++++++++++++++++++++++=
++++++++-
> 1 file changed, 118 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index d356f5d0f7b0..1d13c95cab97 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -35,6 +35,7 @@
> #include <net/route.h>
> #include <net/addrconf.h>
> #include <net/l3mdev.h>
> +#include <net/fib_rules.h>
>=20
> #define RT_FL_TOS(oldflp4) \
> 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
> @@ -42,6 +43,11 @@
> #define DRV_NAME	"vrf"
> #define DRV_VERSION	"1.0"
>=20
> +static atomic_t num_vrfs;

num_vrfs seems to be used only with rtnl held, so it seems you can avoi=
d the atomic ops altogether.

> +
> +static u32 rule_pref =3D 1000;
> +module_param(rule_pref, uint,  S_IRUGO);
> +
> struct net_vrf {
> 	struct rtable __rcu	*rth;
> 	struct rt6_info	__rcu	*rt6;
> @@ -729,6 +735,98 @@ static const struct ethtool_ops vrf_ethtool_ops =
=3D {
> 	.get_drvinfo	=3D vrf_get_drvinfo,
> };
[snip]
> static void vrf_setup(struct net_device *dev)
> {
> 	ether_setup(dev);
> @@ -763,12 +861,17 @@ static int vrf_validate(struct nlattr *tb[], st=
ruct nlattr *data[])
> static void vrf_dellink(struct net_device *dev, struct list_head *hea=
d)
> {
> 	unregister_netdevice_queue(dev, head);
> +
> +	atomic_dec(&num_vrfs);
> +	if (!atomic_read(&num_vrfs))

If you=E2=80=99re sticking with atomics, this looks like atomic_dec_and=
_test().

> +		vrf_del_fib_rules(dev);
> }
>=20
> static int vrf_newlink(struct net *src_net, struct net_device *dev,
> 		       struct nlattr *tb[], struct nlattr *data[])
> {
> 	struct net_vrf *vrf =3D netdev_priv(dev);
> +	int err;
>=20
> 	if (!data || !data[IFLA_VRF_TABLE])
> 		return -EINVAL;

Cheers,
 Nik
