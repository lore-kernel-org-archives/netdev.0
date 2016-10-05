From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 3/3] mac80211: multicast to unicast conversion
Date: Wed, 05 Oct 2016 12:19:51 +0200
Message-ID: <1475662791.4994.39.camel@sipsolutions.net>
References: <1475643324-2845-1-git-send-email-michael-dev@fami-braun.de>
         <1475643324-2845-3-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475643324-2845-3-git-send-email-michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

+netdev

> IEEE802.11-2012 proposes directed multicast service (DMS) using A-
> MSDU frames and a station initiated control protocol. It has the
> advantage that the station can recover the destination multicast mac
> address, but it is not backward compatible with non QOS stations and
> does not enable the administrator of a BSS to force this mode of
> operation within a BSS. Additionally, it would require both the ap
> and the station to implement the control protocol, which is optional
> on both ends. Furthermore, I've seen a few mobile phone stations
> locally that indicate qos support but won't complete DHCP if their
> broadcasts are encapsulated as A-MSDU. Though they work fine with
> this series approach.

Presumably those phones also don't even try to use DMS, right?

> This patch therefore does not opt to implement DMS but instead just
> replicates the packet and changes the destination address. As this
> works fine with ARP, IPv4 and IPv6, it is limited to these protocols
> and normal 802.11 multicast frames are send out for all other payload
> protocols.

How did you determine that it "works fine"?

I see at least one undesirable impact of this, which DMS doesn't have;
it breaks a client's MUST NOT requirement from RFC 1122:

         An ICMP error message MUST NOT be sent as the result of
         receiving:
[...]
         *    a datagram sent as a link-layer broadcast, or
[...]

since the client can no longer realize that the datagram was in fact
sent as a link-layer broadcast (or multicast).

>  include/net/cfg80211.h        |   5 ++
>  include/uapi/linux/nl80211.h  |   7 +++
>  net/mac80211/cfg.c            |  14 ++++++
>  net/mac80211/debugfs_netdev.c |  29 ++++++++++++
>  net/mac80211/ieee80211_i.h    |   1 +
>  net/mac80211/tx.c             | 103
> ++++++++++++++++++++++++++++++++++++++++++
>  net/wireless/nl80211.c        |  33 ++++++++++++++
>  net/wireless/rdev-ops.h       |  11 +++++
>  net/wireless/trace.h          |  19 ++++++++
>  9 files changed, 222 insertions(+)

You should split the patch into cfg80211 and mac80211, IMHO it's big
enough to do that.

> + * @set_ap_unicast: set the multicast to unicast flag for a AP
> interface

That API name isn't very descriptive, I'm sure we can do something
better there.

Also, perhaps we should structure this already like we would DMS, with
a per-station toggle or even list of multicast addresses?

> @@ -2261,6 +2266,8 @@ enum nl80211_attrs {
>  
>  	NL80211_ATTR_MESH_PEER_AID,
>  
> +	NL80211_ATTR_UNICAST,

missing docs, but likely doesn't matter after the comment above

> +static int ieee80211_set_ap_unicast(struct wiphy *wiphy, struct
> net_device *dev,
> +				    const bool unicast)
> +{
> +	struct ieee80211_sub_if_data *sdata =
> IEEE80211_DEV_TO_SUB_IF(dev);
> +
> +	if (sdata->vif.type != NL80211_IFTYPE_AP)
> +		return -1;

Was this not documented but also intended to apply to its dependent
VLANs?

> +static ssize_t
> +ieee80211_if_fmt_unicast(const struct ieee80211_sub_if_data *sdata,
> +			 char *buf, int buflen)
> +{
> +	const struct ieee80211_if_ap *ifap = &sdata->u.ap;
> +
> +	return snprintf(buf, buflen, "0x%x\n", ifap->unicast);
> +}
> +
> +static ssize_t
> +ieee80211_if_parse_unicast(struct ieee80211_sub_if_data *sdata,
> +			   const char *buf, int buflen)
> +{
> +	struct ieee80211_if_ap *ifap = &sdata->u.ap;
> +	u8 val;
> +	int ret;
> +
> +	ret = kstrtou8(buf, 0, &val);
> +	if (ret)
> +		return ret;
> +
> +	ifap->unicast = val ? 1 : 0;
> +
> +	return buflen;
> +}
> +
> +IEEE80211_IF_FILE_RW(unicast);

No need for this, at least the setter, any more.

> +/* Check if multicast to unicast conversion is needed and do it.
> + * Returns 1 if skb was freed and should not be send out. */

wrong comment style :)

> +static int
> +ieee80211_tx_multicast_to_unicast(struct ieee80211_sub_if_data
> *sdata,
> +				  struct sk_buff *skb,
> u32  info_flags)
> +{
> +	struct ieee80211_local *local = sdata->local;
> +	const struct ethhdr *eth = (void *)skb->data;
> +	const struct vlan_ethhdr *ethvlan = (void *)skb->data;
> +	struct sta_info *sta, *prev = NULL;
> +	struct sk_buff *cloned_skb;
> +	u16 ethertype;
> +
> +	/* multicast to unicast conversion only for AP interfaces */
> +	switch (sdata->vif.type) {
> +	case NL80211_IFTYPE_AP_VLAN:
> +		sta = rcu_dereference(sdata->u.vlan.sta);
> +		if (sta) /* 4addr */
> +			return 0;
> +	case NL80211_IFTYPE_AP:
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	/* check runtime toggle for this bss */
> +	if (!sdata->bss->unicast)
> +		return 0;
> +
> +	/* check if this is a multicast frame */
> +	if (!is_multicast_ether_addr(eth->h_dest))
> +		return 0;

That should probably come first, would make this far easier to read.

> +		if (unlikely(!memcmp(eth->h_source, sta->sta.addr,
> ETH_ALEN)))
> +			/* do not send back to source */
> +			continue;

ether_addr_something, instead of memcmp?

> +		if (unlikely(is_multicast_ether_addr(sta-
> >sta.addr))) {
> +			WARN_ONCE(1, "sta with multicast address
> %pM",
> +				  sta->sta.addr);
> +			continue;
> +		}

Err, no, remove this... it cannot happen. We could move the check into
cfg80211 from mac80211, but we surely shouldn't add it into the TX
hotpath!

> +		if (prev) {
> +			cloned_skb = skb_clone(skb, GFP_ATOMIC);
> +			if (likely(!ieee80211_change_da(cloned_skb,
> prev)))
> +				ieee80211_subif_start_xmit(cloned_sk
> b,
> +							   cloned_sk
> b->dev);

I'm not very happy with this recursion, but I guess it can't be avoided
easily. However, you can easily call the more
sensible __ieee80211_subif_start_xmit() instead of this one.

> +	unicast = nla_data(info->attrs[NL80211_ATTR_UNICAST]);

What's this supposed to mean?

johannes
