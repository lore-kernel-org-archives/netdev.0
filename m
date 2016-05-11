From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] cfg80211/nl80211: add wifi tx power mode switching
 support
Date: Wed, 11 May 2016 13:33:40 -0500
Message-ID: <1462991620.22404.5.camel@redhat.com>
References: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
	 <1462464478.23962.12.camel@redhat.com>
	 <CABicQ-VWrRG+0rEEF0GxUTPixSbkA18Gq4b5hbgph60SoEQ+2Q@mail.gmail.com>
	 <CABicQ-XWm=Rxdj3at4+-0OAWn=T7qOTWEaTK=JY7LDOmcN87yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-Wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Sameer Nanda <snanda@chromium.org>,
	Todd Broch <tbroch@chromium.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Wei-Ning Huang <wnhuang@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABicQ-XWm=Rxdj3at4+-0OAWn=T7qOTWEaTK=JY7LDOmcN87yw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-05-11 at 13:03 +0800, Wei-Ning Huang wrote:
> On Fri, May 6, 2016 at 4:19 PM, Wei-Ning Huang <wnhuang@google.com>
> wrote:
> >=20
> > On Fri, May 6, 2016 at 12:07 AM, Dan Williams <dcbw@redhat.com>
> > wrote:
> > >=20
> > >=20
> > > On Thu, 2016-05-05 at 14:44 +0800, Wei-Ning Huang wrote:
> > > >=20
> > > > Recent new hardware has the ability to switch between tablet
> > > > mode and
> > > > clamshell mode. To optimize WiFi performance, we want to be
> > > > able to
> > > > use
> > > > different power table between modes. This patch adds a new
> > > > netlink
> > > > message type and cfg80211_ops function to allow userspace to
> > > > trigger
> > > > a
> > > > power mode switch for a given wireless interface.
> > > >=20
> > > > Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
> > > > ---
> > > > =C2=A0include/net/cfg80211.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0| 11 +++++++++++
> > > > =C2=A0include/uapi/linux/nl80211.h | 21 +++++++++++++++++++++
> > > > =C2=A0net/wireless/nl80211.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0| 16 ++++++++++++++++
> > > > =C2=A0net/wireless/rdev-ops.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
| 22 ++++++++++++++++++++++
> > > > =C2=A0net/wireless/trace.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0| 20 ++++++++++++++++++++
> > > > =C2=A05 files changed, 90 insertions(+)
> > > >=20
> > > > diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> > > > index 9e1b24c..aa77fa0 100644
> > > > --- a/include/net/cfg80211.h
> > > > +++ b/include/net/cfg80211.h
> > > > @@ -2370,6 +2370,12 @@ struct cfg80211_qos_map {
> > > > =C2=A0 * @get_tx_power: store the current TX power into the dbm
> > > > variable;
> > > > =C2=A0 *=C2=A0=C2=A0=C2=A0return 0 if successful
> > > > =C2=A0 *
> > > > + * @set_tx_power_mode: set the transmit power mode. Some
> > > > device have
> > > > the ability
> > > > + *=C2=A0=C2=A0=C2=A0to transform between different mode such a=
s clamshell and
> > > > tablet mode.
> > > > + *=C2=A0=C2=A0=C2=A0set_tx_power_mode allows setting of differ=
ent TX power
> > > > mode at runtime.
> > > > + * @get_tx_power_mode: store the current TX power mode into
> > > > the mode
> > > > variable;
> > > > + *=C2=A0=C2=A0=C2=A0return 0 if successful
> > > > + *
> > > > =C2=A0 * @set_wds_peer: set the WDS peer for a WDS interface
> > > > =C2=A0 *
> > > > =C2=A0 * @rfkill_poll: polls the hw rfkill line, use cfg80211
> > > > reporting
> > > > @@ -2631,6 +2637,11 @@ struct cfg80211_ops {
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0(*get_tx_power)(struct wiphy *wiphy, struct
> > > > wireless_dev *wdev,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int *dbm);
> > > >=20
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
(*set_tx_power_mode)(struct wiphy *wiphy,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0en=
um nl80211_tx_power_mode
> > > > mode);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
(*get_tx_power_mode)(struct wiphy *wiphy,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0en=
um nl80211_tx_power_mode
> > > > *mode);
> > > > +
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0(*set_wds_peer)(struct wiphy *wiphy, struct
> > > > net_device *dev,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const u8 *addr);
> > > >=20
> > > > diff --git a/include/uapi/linux/nl80211.h
> > > > b/include/uapi/linux/nl80211.h
> > > > index 5a30a75..9b1888a 100644
> > > > --- a/include/uapi/linux/nl80211.h
> > > > +++ b/include/uapi/linux/nl80211.h
> > > > @@ -1796,6 +1796,9 @@ enum nl80211_commands {
> > > > =C2=A0 *=C2=A0=C2=A0=C2=A0connecting to a PCP, and in %NL80211_=
CMD_START_AP to
> > > > start
> > > > =C2=A0 *=C2=A0=C2=A0=C2=A0a PCP instead of AP. Relevant for DMG=
 networks only.
> > > > =C2=A0 *
> > > > + * @NL80211_ATTR_WIPHY_TX_POWER_MODE: Transmit power mode. See
> > > > + *=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0&enum nl80211_tx_power_m=
ode for possible values.
> > > > + *
> > > > =C2=A0 * @NUM_NL80211_ATTR: total number of nl80211_attrs avail=
able
> > > > =C2=A0 * @NL80211_ATTR_MAX: highest attribute number currently
> > > > defined
> > > > =C2=A0 * @__NL80211_ATTR_AFTER_LAST: internal use
> > > > @@ -2172,6 +2175,8 @@ enum nl80211_attrs {
> > > >=20
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_ATTR_PBSS,
> > > >=20
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_ATTR_WIPHY_TX_POWER_MODE=
,
> > > > +
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* add attributes here, upd=
ate the policy in nl80211.c */
> > > >=20
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__NL80211_ATTR_AFTER_LAST,
> > > > @@ -3703,6 +3708,22 @@ enum nl80211_tx_power_setting {
> > > > =C2=A0};
> > > >=20
> > > > =C2=A0/**
> > > > + * enum nl80211_tx_power_mode - TX power mode setting
> > > > + * @NL80211_TX_POWER_LOW: general low TX power mode
> > > > + * @NL80211_TX_POWER_MEDIUM: general medium TX power mode
> > > > + * @NL80211_TX_POWER_HIGH: general high TX power mode
> > > > + * @NL80211_TX_POWER_CLAMSHELL: clamshell mode TX power mode
> > > > + * @NL80211_TX_POWER_TABLET: tablet mode TX power mode
> > > > + */
> > > > +enum nl80211_tx_power_mode {
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_TX_POWER_LOW,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_TX_POWER_MEDIUM,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_TX_POWER_HIGH,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_TX_POWER_CLAMSHELL,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0NL80211_TX_POWER_TABLET,
> > >=20
> > > "clamshell" and "tablet" probably mean many different things to
> > > many
> > > different people with respect to whether or not they should do
> > > anything
> > > with power saving or wifi.=C2=A0=C2=A0I feel like a more generic =
interface
> > > is
> > > needed here.
> > We could probably drop those two CLAMSHELL and TABLET constant or
> > describing what they mean
> > in more detail?
> >=20
> > >=20
> > >=20
> > > Could this be already done by:
> > > @NL80211_ATTR_WIPHY_TX_POWER_SETTING =3D NL80211_TX_POWER_LIMITED
> > > @NL80211_ATTR_WIPHY_TX_POWER_LEVEL =3D <limit for clamshell/table=
t
> > > mode>
> > >=20
> > > and then the device would be able to change its TX power as it
> > > saw fit
> > > up to that limit set by your application which figures out
> > > whether it's
> > > in clamshell or tablet mode?
> > We usually want different power settings in different band/channel.
> > For example, we can have three different power settings
> > in 2.4Ghz, channels 36-64 & channels 100+ on 5Ghz. In this case, we
> > can not simply set a fixed number to the power level.
> > A power table is required to map channel/band to actual power
> > limit.
> > For most of the driver, changing power table requires loading
> > a new set of calibration data from either devicetree or ACPI. Due
> > to
> > this, a new message type is required to allow the driver to
> > switch between tables.
> >=20
> > Wei-Ning
> Hi Dan,
>=20
> Does this make sense to you? If so I'll send another patch to clarify
> the term clamshell / tablet mode.
> Thanks for reviewing.

Yes, you're right that=C2=A0NL80211_ATTR_WIPHY_TX_POWER_SETTING is prob=
ably
too limiting. =C2=A0But I feel that the constants that you've proposed =
are
too "magic" and will mean many different things to different driver
writers and userspace clients. =C2=A0I think it would be better impleme=
nted
as a request to simply load specific power calibration data or a new
power table, instead of attempting to classify power tables through
kernel constants that could mean something different to everyone.

Dan

> Wei-Ning
> >=20
> > >=20
> > >=20
> > >=20
> > > Dan
> > >=20
> > > >=20
> > > > +};
> > > > +
> > > > +/**
> > > > =C2=A0 * enum nl80211_packet_pattern_attr - packet pattern attr=
ibute
> > > > =C2=A0 * @__NL80211_PKTPAT_INVALID: invalid number for nested
> > > > attribute
> > > > =C2=A0 * @NL80211_PKTPAT_PATTERN: the pattern, values where the=
 mask
> > > > has
> > > > diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> > > > index 056a730..61b474d 100644
> > > > --- a/net/wireless/nl80211.c
> > > > +++ b/net/wireless/nl80211.c
> > > > @@ -402,6 +402,7 @@ static const struct nla_policy
> > > > nl80211_policy[NUM_NL80211_ATTR] =3D {
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NL80211_ATTR_SCHED_SCAN_DE=
LAY] =3D { .type =3D NLA_U32 },
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NL80211_ATTR_REG_INDOOR] =3D=
 { .type =3D NLA_FLAG },
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NL80211_ATTR_PBSS] =3D { .=
type =3D NLA_FLAG },
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0[NL80211_ATTR_WIPHY_TX_POWER_MOD=
E] =3D { .type =3D NLA_U32 },
> > > > =C2=A0};
> > > >=20
> > > > =C2=A0/* policy for the key attributes */
> > > > @@ -2218,6 +2219,21 @@ static int nl80211_set_wiphy(struct
> > > > sk_buff
> > > > *skb, struct genl_info *info)
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0re=
turn result;
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> > > >=20
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (info->attrs[NL80211_ATTR_WIP=
HY_TX_POWER_MODE]) {
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0enum nl80211_tx_power_mode mode;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0int idx =3D 0;
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0if (!rdev->ops->set_tx_power_mode)
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return -=
EOPNOTSUPP;
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0idx =3D NL80211_ATTR_WIPHY_TX_POWER_MODE;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0mode =3D nla_get_u32(info->attrs[idx]);
> > > > +
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0result =3D rdev_set_tx_power_mode(rdev, mode);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0if (result)
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return r=
esult;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> > > > +
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (info->attrs[NL80211_ATT=
R_WIPHY_ANTENNA_TX] &&
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0inf=
o->attrs[NL80211_ATTR_WIPHY_ANTENNA_RX]) {
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0u32 tx_ant, rx_ant;
> > > > diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
> > > > index 8ae0c04..c3a1035 100644
> > > > --- a/net/wireless/rdev-ops.h
> > > > +++ b/net/wireless/rdev-ops.h
> > > > @@ -552,6 +552,28 @@ static inline int rdev_get_tx_power(struct
> > > > cfg80211_registered_device *rdev,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return ret;
> > > > =C2=A0}
> > > >=20
> > > > +static inline int
> > > > +rdev_set_tx_power_mode(struct cfg80211_registered_device
> > > > *rdev,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0enum nl80211_t=
x_power_mode mode)
> > > > +{
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int ret;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0trace_rdev_set_tx_power_mode(&rd=
ev->wiphy, mode);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ret =3D rdev->ops->set_tx_power_=
mode(&rdev->wiphy, mode);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0trace_rdev_return_int(&rdev->wip=
hy, ret);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return ret;
> > > > +}
> > > > +
> > > > +static inline int
> > > > +rdev_get_tx_power_mode(struct cfg80211_registered_device
> > > > *rdev,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0enum nl80211_t=
x_power_mode *mode)
> > > > +{
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0int ret;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0trace_rdev_get_tx_power_mode(&rd=
ev->wiphy);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0ret =3D rdev->ops->get_tx_power_=
mode(&rdev->wiphy, mode);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0trace_rdev_return_int_int(&rdev-=
>wiphy, ret, *mode);
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return ret;
> > > > +}
> > > > +
> > > > =C2=A0static inline int rdev_set_wds_peer(struct
> > > > cfg80211_registered_device *rdev,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0st=
ruct net_device *dev, const
> > > > u8
> > > > *addr)
> > > > =C2=A0{
> > > > diff --git a/net/wireless/trace.h b/net/wireless/trace.h
> > > > index 09b242b..132c8c2 100644
> > > > --- a/net/wireless/trace.h
> > > > +++ b/net/wireless/trace.h
> > > > @@ -1420,6 +1420,26 @@ TRACE_EVENT(rdev_set_tx_power,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0WIPHY_PR_ARG, WDEV_PR_ARG,__entry->typ=
e,
> > > > __entry-
> > > > >=20
> > > > > mbm)
> > > > =C2=A0);
> > > >=20
> > > > +DEFINE_EVENT(wiphy_only_evt, rdev_get_tx_power_mode,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_PROTO(struct wiphy *wiphy),
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_ARGS(wiphy)
> > > > +);
> > > > +
> > > > +TRACE_EVENT(rdev_set_tx_power_mode,
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_PROTO(struct wiphy *wiphy, en=
um nl80211_tx_power_mode
> > > > mode),
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_ARGS(wiphy, mode),
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_STRUCT__entry(
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0WIPHY_ENTRY
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__field(enum nl80211_tx_power_mode, mode)
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0),
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_fast_assign(
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0WIPHY_ASSIGN;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0__entry->mode =3D mode;
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0),
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_printk(WIPHY_PR_FMT ", mode: =
%d",
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0WIPHY_PR_ARG, __entry->mode)
> > > > +);
> > > > +
> > > > =C2=A0TRACE_EVENT(rdev_return_int_int,
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_PROTO(struct wiphy *wiph=
y, int func_ret, int
> > > > func_fill),
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_ARGS(wiphy, func_ret, fu=
nc_fill),
> >=20
> >=20
> >=20
> > --
> > Wei-Ning Huang, =E9=BB=83=E5=81=89=E5=AF=A7 | Software Engineer, Go=
ogle Inc., Taiwan |
> > wnhuang@google.com | Cell: +886 910-380678
>=20
>=20
