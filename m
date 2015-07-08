From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 2/6] net: Preparation for vrf device
Date: Wed, 08 Jul 2015 10:37:10 +0200
Message-ID: <559CE136.7060407@6wind.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com> <1436195001-4818-3-git-send-email-dsa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:33888 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933911AbbGHIhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 04:37:13 -0400
Received: by wgov12 with SMTP id v12so4354769wgo.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 01:37:12 -0700 (PDT)
In-Reply-To: <1436195001-4818-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/07/2015 17:03, David Ahern a =C3=A9crit :
> Add a VRF_MASTER flag for interfaces and helper functions for determi=
ning
> if a device is a VRF_MASTER.
>
> Also, add link attribute for passing VRF_TABLE id.
>
> Both are used in the following patch that adds a VRF device driver.
>
> Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   include/linux/netdevice.h    | 21 +++++++++++++++++++++
>   include/uapi/linux/if_link.h |  9 +++++++++
>   2 files changed, 30 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e20979dfd6a9..142cb64f139c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1274,6 +1274,7 @@ enum netdev_priv_flags {
>   	IFF_XMIT_DST_RELEASE_PERM	=3D 1<<22,
>   	IFF_IPVLAN_MASTER		=3D 1<<23,
>   	IFF_IPVLAN_SLAVE		=3D 1<<24,
> +	IFF_VRF_MASTER		        =3D 1<<25,
nit: use tab instead space here  ^^^^^^^

Also, why calling this '_MASTER', is there a notion of SLAVE?

>   };
>
>   #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
> @@ -1301,6 +1302,7 @@ enum netdev_priv_flags {
>   #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
>   #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
>   #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
> +#define IFF_VRF_MASTER		        IFF_VRF_MASTER
nit: use tab instead space here          ^^^^^^^

>
>   /**
>    *	struct net_device - The DEVICE structure.
> @@ -1417,6 +1419,7 @@ enum netdev_priv_flags {
>    *	@dn_ptr:	DECnet specific data
>    *	@ip6_ptr:	IPv6 specific data
>    *	@ax25_ptr:	AX.25 specific data
> + *	@vrf_ptr:	VRF specific data
>    *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registe=
ring
>    *
>    *	@last_rx:	Time of last Rx
> @@ -1629,6 +1632,7 @@ struct net_device {
>   	struct dn_dev __rcu     *dn_ptr;
>   	struct inet6_dev __rcu	*ip6_ptr;
>   	void			*ax25_ptr;
> +	struct net_vrf_dev      *vrf_ptr;
nit: use tab here         ^^^^^^

>   	struct wireless_dev	*ieee80211_ptr;
>   	struct wpan_dev		*ieee802154_ptr;
>   #if IS_ENABLED(CONFIG_MPLS_ROUTING)
> @@ -3781,6 +3785,23 @@ static inline bool netif_supports_nofcs(struct=
 net_device *dev)
>   	return dev->priv_flags & IFF_SUPP_NOFCS;
>   }
>
> +static inline bool netif_is_vrf(struct net_device *dev)
> +{
> +	return dev->priv_flags & IFF_VRF_MASTER;
> +}
> +
> +static inline bool netif_idx_is_vrf(struct net *net, int idx)
Usally, the index of an interface is named 'ifindex', it eases code rea=
ding
to keep the same name. Something like:
netif_index_is_vrf(struct net *net, int ifindex)

> +{
> +	struct net_device *dev =3D dev_get_by_index(net, idx);
> +	bool rc =3D false;
> +
> +	if (dev) {
> +		rc =3D netif_is_vrf(dev);
> +		dev_put(dev);
> +	}
> +	return rc;
> +}
> +
[snip]
