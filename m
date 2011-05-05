From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCHv2 1/2] net: Allow ethtool to set interface in loopback mode.
Date: Wed, 4 May 2011 18:28:57 -0700
Message-ID: <BANLkTi=0piGsSiVrte-_Pp8yrPSe6UOdig@mail.gmail.com>
References: <1304558800-15877-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:53943 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579Ab1EECG5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 22:06:57 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p451Sxnk032533
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 18:28:59 -0700
Received: from bwg12 (bwg12.prod.google.com [10.188.7.12])
	by hpaq12.eem.corp.google.com with ESMTP id p451Sv0B015108
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 18:28:58 -0700
Received: by bwg12 with SMTP id 12so1517622bwg.26
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 18:28:57 -0700 (PDT)
In-Reply-To: <1304558800-15877-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please discard this, I do not wish to create a new thread for this.

Thanks,
--mahesh..

On Wed, May 4, 2011 at 6:26 PM, Mahesh Bandewar <maheshb@google.com> wr=
ote:
> This patch enables ethtool to set the loopback mode on a given interf=
ace.
> By configuring the interface in loopback mode in conjunction with a p=
olicy
> route / rule, a userland application can stress the egress / ingress =
path
> exposing the flows of the change in progress and potentially help dev=
eloper(s)
> understand the impact of those changes without even sending a packet =
out
> on the network.
>
> Following set of commands illustrates one such example -
> =A0 =A0a) ip -4 addr add 192.168.1.1/24 dev eth1
> =A0 =A0b) ip -4 rule add from all iif eth1 lookup 250
> =A0 =A0c) ip -4 route add local 0/0 dev lo proto kernel scope host ta=
ble 250
> =A0 =A0d) arp -Ds 192.168.1.100 eth1
> =A0 =A0e) arp -Ds 192.168.1.200 eth1
> =A0 =A0f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
> =A0 =A0g) sysctl -w net.ipv4.conf.all.accept_local=3D1
> =A0 =A0# Assuming that the machine has 8 cores
> =A0 =A0h) taskset 000f netserver -L 192.168.1.200
> =A0 =A0i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168=
=2E1.200 -l 30
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> Changes since v1
> =A0Added NETIF_F_LOOPBACK in loopback device's feature-set.
>
> =A0drivers/net/loopback.c =A0 =A0| =A0 =A03 ++-
> =A0include/linux/netdevice.h | =A0 =A03 ++-
> =A0net/core/ethtool.c =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A03 files changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index d70fb76..4ce9e5f 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -174,7 +174,8 @@ static void loopback_setup(struct net_device *dev=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| NETIF_F_HIGHDMA
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| NETIF_F_LLTX
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| NETIF_F_NETNS_LOCAL
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_VLAN_CHALLENGED;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_VLAN_CHALLENGED
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_LOOPBACK;
> =A0 =A0 =A0 =A0dev->ethtool_ops =A0 =A0 =A0 =A0=3D &loopback_ethtool_=
ops;
> =A0 =A0 =A0 =A0dev->header_ops =A0 =A0 =A0 =A0 =3D &eth_header_ops;
> =A0 =A0 =A0 =A0dev->netdev_ops =A0 =A0 =A0 =A0 =3D &loopback_ops;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d5de66a..e7244ed 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1067,6 +1067,7 @@ struct net_device {
> =A0#define NETIF_F_RXHASH =A0 =A0 =A0 =A0 (1 << 28) /* Receive hashin=
g offload */
> =A0#define NETIF_F_RXCSUM =A0 =A0 =A0 =A0 (1 << 29) /* Receive checks=
umming offload */
> =A0#define NETIF_F_NOCACHE_COPY =A0 (1 << 30) /* Use no-cache copyfro=
muser */
> +#define NETIF_F_LOOPBACK =A0 =A0 =A0 (1 << 31) /* Enable loopback */
>
> =A0 =A0 =A0 =A0/* Segmentation offload features */
> =A0#define NETIF_F_GSO_SHIFT =A0 =A0 =A016
> @@ -1082,7 +1083,7 @@ struct net_device {
> =A0 =A0 =A0 =A0/* =3D all defined minus driver/device-class-related *=
/
> =A0#define NETIF_F_NEVER_CHANGE =A0 (NETIF_F_VLAN_CHALLENGED | \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NE=
TIF_F_LLTX | NETIF_F_NETNS_LOCAL)
> -#define NETIF_F_ETHTOOL_BITS =A0 (0x7f3fffff & ~NETIF_F_NEVER_CHANGE=
)
> +#define NETIF_F_ETHTOOL_BITS =A0 (0xff3fffff & ~NETIF_F_NEVER_CHANGE=
)
>
> =A0 =A0 =A0 =A0/* List of features with software fallbacks. */
> =A0#define NETIF_F_GSO_SOFTWARE =A0 (NETIF_F_TSO | NETIF_F_TSO_ECN | =
\
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index d8b1a8d..f26649d 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -362,7 +362,7 @@ static const char netdev_features_strings[ETHTOOL=
_DEV_FEATURE_WORDS * 32][ETH_GS
> =A0 =A0 =A0 =A0/* NETIF_F_RXHASH */ =A0 =A0 =A0 =A0 =A0"rx-hashing",
> =A0 =A0 =A0 =A0/* NETIF_F_RXCSUM */ =A0 =A0 =A0 =A0 =A0"rx-checksum",
> =A0 =A0 =A0 =A0/* NETIF_F_NOCACHE_COPY */ =A0 =A0"tx-nocache-copy"
> - =A0 =A0 =A0 "",
> + =A0 =A0 =A0 /* NETIF_F_LOOPBACK */ =A0 =A0 =A0 =A0"loopback",
> =A0};
>
> =A0static int __ethtool_get_sset_count(struct net_device *dev, int ss=
et)
> --
> 1.7.3.1
>
>
