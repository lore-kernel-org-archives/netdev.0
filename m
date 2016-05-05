From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] cfg80211/nl80211: add wifi tx power mode switching
 support
Date: Thu, 05 May 2016 11:07:58 -0500
Message-ID: <1462464478.23962.12.camel@redhat.com>
References: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Sameer Nanda <snanda@chromium.org>,
	Todd Broch <tbroch@chromium.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Wei-Ning Huang <wnhuang@chromium.org>,
	Linux-Wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937AbcEEQIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 12:08:02 -0400
In-Reply-To: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-05 at 14:44 +0800, Wei-Ning Huang wrote:
> Recent new hardware has the ability to switch between tablet mode and
> clamshell mode. To optimize WiFi performance, we want to be able to
> use
> different power table between modes. This patch adds a new netlink
> message type and cfg80211_ops function to allow userspace to trigger
> a
> power mode switch for a given wireless interface.
>=20
> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
> ---
> =C2=A0include/net/cfg80211.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
| 11 +++++++++++
> =C2=A0include/uapi/linux/nl80211.h | 21 +++++++++++++++++++++
> =C2=A0net/wireless/nl80211.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
| 16 ++++++++++++++++
> =C2=A0net/wireless/rdev-ops.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 22=
 ++++++++++++++++++++++
> =C2=A0net/wireless/trace.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0| 20 ++++++++++++++++++++
> =C2=A05 files changed, 90 insertions(+)
>=20
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> index 9e1b24c..aa77fa0 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -2370,6 +2370,12 @@ struct cfg80211_qos_map {
> =C2=A0 * @get_tx_power: store the current TX power into the dbm varia=
ble;
> =C2=A0 *	return 0 if successful
> =C2=A0 *
> + * @set_tx_power_mode: set the transmit power mode. Some device have
> the ability
> + *	to transform between different mode such as clamshell and
> tablet mode.
> + *	set_tx_power_mode allows setting of different TX power
> mode at runtime.
> + * @get_tx_power_mode: store the current TX power mode into the mode
> variable;
> + *	return 0 if successful
> + *
> =C2=A0 * @set_wds_peer: set the WDS peer for a WDS interface
> =C2=A0 *
> =C2=A0 * @rfkill_poll: polls the hw rfkill line, use cfg80211 reporti=
ng
> @@ -2631,6 +2637,11 @@ struct cfg80211_ops {
> =C2=A0	int	(*get_tx_power)(struct wiphy *wiphy, struct
> wireless_dev *wdev,
> =C2=A0				int *dbm);
> =C2=A0
> +	int	(*set_tx_power_mode)(struct wiphy *wiphy,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0enum nl80211_tx_power_mode
> mode);
> +	int	(*get_tx_power_mode)(struct wiphy *wiphy,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0enum nl80211_tx_power_mode
> *mode);
> +
> =C2=A0	int	(*set_wds_peer)(struct wiphy *wiphy, struct
> net_device *dev,
> =C2=A0				const u8 *addr);
> =C2=A0
> diff --git a/include/uapi/linux/nl80211.h
> b/include/uapi/linux/nl80211.h
> index 5a30a75..9b1888a 100644
> --- a/include/uapi/linux/nl80211.h
> +++ b/include/uapi/linux/nl80211.h
> @@ -1796,6 +1796,9 @@ enum nl80211_commands {
> =C2=A0 *	connecting to a PCP, and in %NL80211_CMD_START_AP to start
> =C2=A0 *	a PCP instead of AP. Relevant for DMG networks only.
> =C2=A0 *
> + * @NL80211_ATTR_WIPHY_TX_POWER_MODE: Transmit power mode. See
> + *=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0&enum nl80211_tx_power_mode fo=
r possible values.
> + *
> =C2=A0 * @NUM_NL80211_ATTR: total number of nl80211_attrs available
> =C2=A0 * @NL80211_ATTR_MAX: highest attribute number currently define=
d
> =C2=A0 * @__NL80211_ATTR_AFTER_LAST: internal use
> @@ -2172,6 +2175,8 @@ enum nl80211_attrs {
> =C2=A0
> =C2=A0	NL80211_ATTR_PBSS,
> =C2=A0
> +	NL80211_ATTR_WIPHY_TX_POWER_MODE,
> +
> =C2=A0	/* add attributes here, update the policy in nl80211.c */
> =C2=A0
> =C2=A0	__NL80211_ATTR_AFTER_LAST,
> @@ -3703,6 +3708,22 @@ enum nl80211_tx_power_setting {
> =C2=A0};
> =C2=A0
> =C2=A0/**
> + * enum nl80211_tx_power_mode - TX power mode setting
> + * @NL80211_TX_POWER_LOW: general low TX power mode
> + * @NL80211_TX_POWER_MEDIUM: general medium TX power mode
> + * @NL80211_TX_POWER_HIGH: general high TX power mode
> + * @NL80211_TX_POWER_CLAMSHELL: clamshell mode TX power mode
> + * @NL80211_TX_POWER_TABLET: tablet mode TX power mode
> + */
> +enum nl80211_tx_power_mode {
> +	NL80211_TX_POWER_LOW,
> +	NL80211_TX_POWER_MEDIUM,
> +	NL80211_TX_POWER_HIGH,
> +	NL80211_TX_POWER_CLAMSHELL,
> +	NL80211_TX_POWER_TABLET,

"clamshell" and "tablet" probably mean many different things to many
different people with respect to whether or not they should do anything
with power saving or wifi. =C2=A0I feel like a more generic interface i=
s
needed here.

Could this be already done by:
@NL80211_ATTR_WIPHY_TX_POWER_SETTING =3D=C2=A0NL80211_TX_POWER_LIMITED
@NL80211_ATTR_WIPHY_TX_POWER_LEVEL =3D <limit for clamshell/tablet mode=
>

and then the device would be able to change its TX power as it saw fit
up to that limit set by your application which figures out whether it's
in clamshell or tablet mode?

Dan

> +};
> +
> +/**
> =C2=A0 * enum nl80211_packet_pattern_attr - packet pattern attribute
> =C2=A0 * @__NL80211_PKTPAT_INVALID: invalid number for nested attribu=
te
> =C2=A0 * @NL80211_PKTPAT_PATTERN: the pattern, values where the mask =
has
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 056a730..61b474d 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -402,6 +402,7 @@ static const struct nla_policy
> nl80211_policy[NUM_NL80211_ATTR] =3D {
> =C2=A0	[NL80211_ATTR_SCHED_SCAN_DELAY] =3D { .type =3D NLA_U32 },
> =C2=A0	[NL80211_ATTR_REG_INDOOR] =3D { .type =3D NLA_FLAG },
> =C2=A0	[NL80211_ATTR_PBSS] =3D { .type =3D NLA_FLAG },
> +	[NL80211_ATTR_WIPHY_TX_POWER_MODE] =3D { .type =3D NLA_U32 },
> =C2=A0};
> =C2=A0
> =C2=A0/* policy for the key attributes */
> @@ -2218,6 +2219,21 @@ static int nl80211_set_wiphy(struct sk_buff
> *skb, struct genl_info *info)
> =C2=A0			return result;
> =C2=A0	}
> =C2=A0
> +	if (info->attrs[NL80211_ATTR_WIPHY_TX_POWER_MODE]) {
> +		enum nl80211_tx_power_mode mode;
> +		int idx =3D 0;
> +
> +		if (!rdev->ops->set_tx_power_mode)
> +			return -EOPNOTSUPP;
> +
> +		idx =3D NL80211_ATTR_WIPHY_TX_POWER_MODE;
> +		mode =3D nla_get_u32(info->attrs[idx]);
> +
> +		result =3D rdev_set_tx_power_mode(rdev, mode);
> +		if (result)
> +			return result;
> +	}
> +
> =C2=A0	if (info->attrs[NL80211_ATTR_WIPHY_ANTENNA_TX] &&
> =C2=A0	=C2=A0=C2=A0=C2=A0=C2=A0info->attrs[NL80211_ATTR_WIPHY_ANTENNA=
_RX]) {
> =C2=A0		u32 tx_ant, rx_ant;
> diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
> index 8ae0c04..c3a1035 100644
> --- a/net/wireless/rdev-ops.h
> +++ b/net/wireless/rdev-ops.h
> @@ -552,6 +552,28 @@ static inline int rdev_get_tx_power(struct
> cfg80211_registered_device *rdev,
> =C2=A0	return ret;
> =C2=A0}
> =C2=A0
> +static inline int
> +rdev_set_tx_power_mode(struct cfg80211_registered_device *rdev,
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0enum nl80211_tx_power_mo=
de mode)
> +{
> +	int ret;
> +	trace_rdev_set_tx_power_mode(&rdev->wiphy, mode);
> +	ret =3D rdev->ops->set_tx_power_mode(&rdev->wiphy, mode);
> +	trace_rdev_return_int(&rdev->wiphy, ret);
> +	return ret;
> +}
> +
> +static inline int
> +rdev_get_tx_power_mode(struct cfg80211_registered_device *rdev,
> +		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0enum nl80211_tx_power_mo=
de *mode)
> +{
> +	int ret;
> +	trace_rdev_get_tx_power_mode(&rdev->wiphy);
> +	ret =3D rdev->ops->get_tx_power_mode(&rdev->wiphy, mode);
> +	trace_rdev_return_int_int(&rdev->wiphy, ret, *mode);
> +	return ret;
> +}
> +
> =C2=A0static inline int rdev_set_wds_peer(struct
> cfg80211_registered_device *rdev,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0struct net_device *dev, const u8
> *addr)
> =C2=A0{
> diff --git a/net/wireless/trace.h b/net/wireless/trace.h
> index 09b242b..132c8c2 100644
> --- a/net/wireless/trace.h
> +++ b/net/wireless/trace.h
> @@ -1420,6 +1420,26 @@ TRACE_EVENT(rdev_set_tx_power,
> =C2=A0		=C2=A0=C2=A0WIPHY_PR_ARG, WDEV_PR_ARG,__entry->type, __entry-
> >mbm)
> =C2=A0);
> =C2=A0
> +DEFINE_EVENT(wiphy_only_evt, rdev_get_tx_power_mode,
> +	TP_PROTO(struct wiphy *wiphy),
> +	TP_ARGS(wiphy)
> +);
> +
> +TRACE_EVENT(rdev_set_tx_power_mode,
> +	TP_PROTO(struct wiphy *wiphy, enum nl80211_tx_power_mode
> mode),
> +	TP_ARGS(wiphy, mode),
> +	TP_STRUCT__entry(
> +		WIPHY_ENTRY
> +		__field(enum nl80211_tx_power_mode, mode)
> +	),
> +	TP_fast_assign(
> +		WIPHY_ASSIGN;
> +		__entry->mode =3D mode;
> +	),
> +	TP_printk(WIPHY_PR_FMT ", mode: %d",
> +		=C2=A0=C2=A0WIPHY_PR_ARG, __entry->mode)
> +);
> +
> =C2=A0TRACE_EVENT(rdev_return_int_int,
> =C2=A0	TP_PROTO(struct wiphy *wiphy, int func_ret, int func_fill),
> =C2=A0	TP_ARGS(wiphy, func_ret, func_fill),
