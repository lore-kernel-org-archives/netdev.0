From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] cfg80211/nl80211: add wifi tx power mode switching
 support
Date: Fri, 13 May 2016 00:02:38 +0200
Message-ID: <5734FD7E.7010307@broadcom.com>
References: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
 <1462464478.23962.12.camel@redhat.com>
 <CABicQ-VWrRG+0rEEF0GxUTPixSbkA18Gq4b5hbgph60SoEQ+2Q@mail.gmail.com>
 <CABicQ-XWm=Rxdj3at4+-0OAWn=T7qOTWEaTK=JY7LDOmcN87yw@mail.gmail.com>
 <1462991620.22404.5.camel@redhat.com>
 <CABicQ-UeU-8PPdK9Je51j_KD-BH8G1HuOjo0yZLcNBQgtJsyTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-Wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Sameer Nanda <snanda@chromium.org>,
	Todd Broch <tbroch@chromium.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Wei-Ning Huang <wnhuang@google.com>, Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35202 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbcELWCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 18:02:41 -0400
Received: by mail-wm0-f50.google.com with SMTP id e201so604858wme.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 15:02:41 -0700 (PDT)
In-Reply-To: <CABicQ-UeU-8PPdK9Je51j_KD-BH8G1HuOjo0yZLcNBQgtJsyTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-05-16 11:34, Wei-Ning Huang wrote:
> On Thu, May 12, 2016 at 2:33 AM, Dan Williams <dcbw@redhat.com> wrote=
:
>> On Wed, 2016-05-11 at 13:03 +0800, Wei-Ning Huang wrote:
>>> On Fri, May 6, 2016 at 4:19 PM, Wei-Ning Huang <wnhuang@google.com>
>>> wrote:
>>>>
>>>> On Fri, May 6, 2016 at 12:07 AM, Dan Williams <dcbw@redhat.com>
>>>> wrote:
>>>>>
>>>>>
>>>>> On Thu, 2016-05-05 at 14:44 +0800, Wei-Ning Huang wrote:
>>>>>>
>>>>>> Recent new hardware has the ability to switch between tablet
>>>>>> mode and
>>>>>> clamshell mode. To optimize WiFi performance, we want to be
>>>>>> able to
>>>>>> use
>>>>>> different power table between modes. This patch adds a new
>>>>>> netlink
>>>>>> message type and cfg80211_ops function to allow userspace to
>>>>>> trigger
>>>>>> a
>>>>>> power mode switch for a given wireless interface.
>>>>>>
>>>>>> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
>>>>>> ---
>>>>>>  include/net/cfg80211.h       | 11 +++++++++++
>>>>>>  include/uapi/linux/nl80211.h | 21 +++++++++++++++++++++
>>>>>>  net/wireless/nl80211.c       | 16 ++++++++++++++++
>>>>>>  net/wireless/rdev-ops.h      | 22 ++++++++++++++++++++++
>>>>>>  net/wireless/trace.h         | 20 ++++++++++++++++++++
>>>>>>  5 files changed, 90 insertions(+)
>>>>>>
>>>>>> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
>>>>>> index 9e1b24c..aa77fa0 100644
>>>>>> --- a/include/net/cfg80211.h
>>>>>> +++ b/include/net/cfg80211.h
>>>>>> @@ -2370,6 +2370,12 @@ struct cfg80211_qos_map {
>>>>>>   * @get_tx_power: store the current TX power into the dbm
>>>>>> variable;
>>>>>>   *   return 0 if successful
>>>>>>   *
>>>>>> + * @set_tx_power_mode: set the transmit power mode. Some
>>>>>> device have
>>>>>> the ability
>>>>>> + *   to transform between different mode such as clamshell and
>>>>>> tablet mode.
>>>>>> + *   set_tx_power_mode allows setting of different TX power
>>>>>> mode at runtime.
>>>>>> + * @get_tx_power_mode: store the current TX power mode into
>>>>>> the mode
>>>>>> variable;
>>>>>> + *   return 0 if successful
>>>>>> + *
>>>>>>   * @set_wds_peer: set the WDS peer for a WDS interface
>>>>>>   *
>>>>>>   * @rfkill_poll: polls the hw rfkill line, use cfg80211
>>>>>> reporting
>>>>>> @@ -2631,6 +2637,11 @@ struct cfg80211_ops {
>>>>>>       int     (*get_tx_power)(struct wiphy *wiphy, struct
>>>>>> wireless_dev *wdev,
>>>>>>                               int *dbm);
>>>>>>
>>>>>> +     int     (*set_tx_power_mode)(struct wiphy *wiphy,
>>>>>> +                                  enum nl80211_tx_power_mode
>>>>>> mode);
>>>>>> +     int     (*get_tx_power_mode)(struct wiphy *wiphy,
>>>>>> +                                  enum nl80211_tx_power_mode
>>>>>> *mode);
>>>>>> +
>>>>>>       int     (*set_wds_peer)(struct wiphy *wiphy, struct
>>>>>> net_device *dev,
>>>>>>                               const u8 *addr);
>>>>>>
>>>>>> diff --git a/include/uapi/linux/nl80211.h
>>>>>> b/include/uapi/linux/nl80211.h
>>>>>> index 5a30a75..9b1888a 100644
>>>>>> --- a/include/uapi/linux/nl80211.h
>>>>>> +++ b/include/uapi/linux/nl80211.h
>>>>>> @@ -1796,6 +1796,9 @@ enum nl80211_commands {
>>>>>>   *   connecting to a PCP, and in %NL80211_CMD_START_AP to
>>>>>> start
>>>>>>   *   a PCP instead of AP. Relevant for DMG networks only.
>>>>>>   *
>>>>>> + * @NL80211_ATTR_WIPHY_TX_POWER_MODE: Transmit power mode. See
>>>>>> + *      &enum nl80211_tx_power_mode for possible values.
>>>>>> + *
>>>>>>   * @NUM_NL80211_ATTR: total number of nl80211_attrs available
>>>>>>   * @NL80211_ATTR_MAX: highest attribute number currently
>>>>>> defined
>>>>>>   * @__NL80211_ATTR_AFTER_LAST: internal use
>>>>>> @@ -2172,6 +2175,8 @@ enum nl80211_attrs {
>>>>>>
>>>>>>       NL80211_ATTR_PBSS,
>>>>>>
>>>>>> +     NL80211_ATTR_WIPHY_TX_POWER_MODE,
>>>>>> +
>>>>>>       /* add attributes here, update the policy in nl80211.c */
>>>>>>
>>>>>>       __NL80211_ATTR_AFTER_LAST,
>>>>>> @@ -3703,6 +3708,22 @@ enum nl80211_tx_power_setting {
>>>>>>  };
>>>>>>
>>>>>>  /**
>>>>>> + * enum nl80211_tx_power_mode - TX power mode setting
>>>>>> + * @NL80211_TX_POWER_LOW: general low TX power mode
>>>>>> + * @NL80211_TX_POWER_MEDIUM: general medium TX power mode
>>>>>> + * @NL80211_TX_POWER_HIGH: general high TX power mode
>>>>>> + * @NL80211_TX_POWER_CLAMSHELL: clamshell mode TX power mode
>>>>>> + * @NL80211_TX_POWER_TABLET: tablet mode TX power mode
>>>>>> + */
>>>>>> +enum nl80211_tx_power_mode {
>>>>>> +     NL80211_TX_POWER_LOW,
>>>>>> +     NL80211_TX_POWER_MEDIUM,
>>>>>> +     NL80211_TX_POWER_HIGH,
>>>>>> +     NL80211_TX_POWER_CLAMSHELL,
>>>>>> +     NL80211_TX_POWER_TABLET,
>>>>>
>>>>> "clamshell" and "tablet" probably mean many different things to
>>>>> many
>>>>> different people with respect to whether or not they should do
>>>>> anything
>>>>> with power saving or wifi.  I feel like a more generic interface
>>>>> is
>>>>> needed here.
>>>> We could probably drop those two CLAMSHELL and TABLET constant or
>>>> describing what they mean
>>>> in more detail?
>>>>
>>>>>
>>>>>
>>>>> Could this be already done by:
>>>>> @NL80211_ATTR_WIPHY_TX_POWER_SETTING =3D NL80211_TX_POWER_LIMITED
>>>>> @NL80211_ATTR_WIPHY_TX_POWER_LEVEL =3D <limit for clamshell/table=
t
>>>>> mode>
>>>>>
>>>>> and then the device would be able to change its TX power as it
>>>>> saw fit
>>>>> up to that limit set by your application which figures out
>>>>> whether it's
>>>>> in clamshell or tablet mode?
>>>> We usually want different power settings in different band/channel=
=2E
>>>> For example, we can have three different power settings
>>>> in 2.4Ghz, channels 36-64 & channels 100+ on 5Ghz. In this case, w=
e
>>>> can not simply set a fixed number to the power level.
>>>> A power table is required to map channel/band to actual power
>>>> limit.
>>>> For most of the driver, changing power table requires loading
>>>> a new set of calibration data from either devicetree or ACPI. Due
>>>> to
>>>> this, a new message type is required to allow the driver to
>>>> switch between tables.
>>>>
>>>> Wei-Ning
>>> Hi Dan,
>>>
>>> Does this make sense to you? If so I'll send another patch to clari=
fy
>>> the term clamshell / tablet mode.
>>> Thanks for reviewing.
>>
>> Yes, you're right that NL80211_ATTR_WIPHY_TX_POWER_SETTING is probab=
ly
>> too limiting.  But I feel that the constants that you've proposed ar=
e
>> too "magic" and will mean many different things to different driver
>> writers and userspace clients.  I think it would be better implement=
ed
>> as a request to simply load specific power calibration data or a new
>> power table, instead of attempting to classify power tables through
>> kernel constants that could mean something different to everyone.
>=20
> Dan, Thanks for the pointer. Passing the power table/calibration data
> name instead of
> constants sounds reasonable.
>=20
> Johannes, I feel like being able to set calibration data at runtime i=
s
> something common
> to all wireless drivers

Not really. Only implicitly, eg. when changing to another frequency ban=
d
etc.

> so instead of using vendor commands what do
> you think if I pass
> the calibration data name instead of using those magic constants? Thi=
s
> way, userspace
> does not need to know the details of what band/range power limit the
> driver supports.

user-space still need to have knowledge about what calibration data nam=
e
to pick for different scenarios. Also this means the driver will use
request_firmware() api to obtain the actual calibration data? I think
you then want that signed like the crda database.

Regards,
Arend

> It allows for flexible driver side implementation and easier for
> userspace to control.
>=20
> Wei-Ning
>=20
>>
>> Dan
>>
>>> Wei-Ning
>>>>
>>>>>
>>>>>
>>>>>
>>>>> Dan
>>>>>
>>>>>>
>>>>>> +};
>>>>>> +
>>>>>> +/**
>>>>>>   * enum nl80211_packet_pattern_attr - packet pattern attribute
>>>>>>   * @__NL80211_PKTPAT_INVALID: invalid number for nested
>>>>>> attribute
>>>>>>   * @NL80211_PKTPAT_PATTERN: the pattern, values where the mask
>>>>>> has
>>>>>> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
>>>>>> index 056a730..61b474d 100644
>>>>>> --- a/net/wireless/nl80211.c
>>>>>> +++ b/net/wireless/nl80211.c
>>>>>> @@ -402,6 +402,7 @@ static const struct nla_policy
>>>>>> nl80211_policy[NUM_NL80211_ATTR] =3D {
>>>>>>       [NL80211_ATTR_SCHED_SCAN_DELAY] =3D { .type =3D NLA_U32 },
>>>>>>       [NL80211_ATTR_REG_INDOOR] =3D { .type =3D NLA_FLAG },
>>>>>>       [NL80211_ATTR_PBSS] =3D { .type =3D NLA_FLAG },
>>>>>> +     [NL80211_ATTR_WIPHY_TX_POWER_MODE] =3D { .type =3D NLA_U32=
 },
>>>>>>  };
>>>>>>
>>>>>>  /* policy for the key attributes */
>>>>>> @@ -2218,6 +2219,21 @@ static int nl80211_set_wiphy(struct
>>>>>> sk_buff
>>>>>> *skb, struct genl_info *info)
>>>>>>                       return result;
>>>>>>       }
>>>>>>
>>>>>> +     if (info->attrs[NL80211_ATTR_WIPHY_TX_POWER_MODE]) {
>>>>>> +             enum nl80211_tx_power_mode mode;
>>>>>> +             int idx =3D 0;
>>>>>> +
>>>>>> +             if (!rdev->ops->set_tx_power_mode)
>>>>>> +                     return -EOPNOTSUPP;
>>>>>> +
>>>>>> +             idx =3D NL80211_ATTR_WIPHY_TX_POWER_MODE;
>>>>>> +             mode =3D nla_get_u32(info->attrs[idx]);
>>>>>> +
>>>>>> +             result =3D rdev_set_tx_power_mode(rdev, mode);
>>>>>> +             if (result)
>>>>>> +                     return result;
>>>>>> +     }
>>>>>> +
>>>>>>       if (info->attrs[NL80211_ATTR_WIPHY_ANTENNA_TX] &&
>>>>>>           info->attrs[NL80211_ATTR_WIPHY_ANTENNA_RX]) {
>>>>>>               u32 tx_ant, rx_ant;
>>>>>> diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
>>>>>> index 8ae0c04..c3a1035 100644
>>>>>> --- a/net/wireless/rdev-ops.h
>>>>>> +++ b/net/wireless/rdev-ops.h
>>>>>> @@ -552,6 +552,28 @@ static inline int rdev_get_tx_power(struct
>>>>>> cfg80211_registered_device *rdev,
>>>>>>       return ret;
>>>>>>  }
>>>>>>
>>>>>> +static inline int
>>>>>> +rdev_set_tx_power_mode(struct cfg80211_registered_device
>>>>>> *rdev,
>>>>>> +                    enum nl80211_tx_power_mode mode)
>>>>>> +{
>>>>>> +     int ret;
>>>>>> +     trace_rdev_set_tx_power_mode(&rdev->wiphy, mode);
>>>>>> +     ret =3D rdev->ops->set_tx_power_mode(&rdev->wiphy, mode);
>>>>>> +     trace_rdev_return_int(&rdev->wiphy, ret);
>>>>>> +     return ret;
>>>>>> +}
>>>>>> +
>>>>>> +static inline int
>>>>>> +rdev_get_tx_power_mode(struct cfg80211_registered_device
>>>>>> *rdev,
>>>>>> +                    enum nl80211_tx_power_mode *mode)
>>>>>> +{
>>>>>> +     int ret;
>>>>>> +     trace_rdev_get_tx_power_mode(&rdev->wiphy);
>>>>>> +     ret =3D rdev->ops->get_tx_power_mode(&rdev->wiphy, mode);
>>>>>> +     trace_rdev_return_int_int(&rdev->wiphy, ret, *mode);
>>>>>> +     return ret;
>>>>>> +}
>>>>>> +
>>>>>>  static inline int rdev_set_wds_peer(struct
>>>>>> cfg80211_registered_device *rdev,
>>>>>>                                   struct net_device *dev, const
>>>>>> u8
>>>>>> *addr)
>>>>>>  {
>>>>>> diff --git a/net/wireless/trace.h b/net/wireless/trace.h
>>>>>> index 09b242b..132c8c2 100644
>>>>>> --- a/net/wireless/trace.h
>>>>>> +++ b/net/wireless/trace.h
>>>>>> @@ -1420,6 +1420,26 @@ TRACE_EVENT(rdev_set_tx_power,
>>>>>>                 WIPHY_PR_ARG, WDEV_PR_ARG,__entry->type,
>>>>>> __entry-
>>>>>>>
>>>>>>> mbm)
>>>>>>  );
>>>>>>
>>>>>> +DEFINE_EVENT(wiphy_only_evt, rdev_get_tx_power_mode,
>>>>>> +     TP_PROTO(struct wiphy *wiphy),
>>>>>> +     TP_ARGS(wiphy)
>>>>>> +);
>>>>>> +
>>>>>> +TRACE_EVENT(rdev_set_tx_power_mode,
>>>>>> +     TP_PROTO(struct wiphy *wiphy, enum nl80211_tx_power_mode
>>>>>> mode),
>>>>>> +     TP_ARGS(wiphy, mode),
>>>>>> +     TP_STRUCT__entry(
>>>>>> +             WIPHY_ENTRY
>>>>>> +             __field(enum nl80211_tx_power_mode, mode)
>>>>>> +     ),
>>>>>> +     TP_fast_assign(
>>>>>> +             WIPHY_ASSIGN;
>>>>>> +             __entry->mode =3D mode;
>>>>>> +     ),
>>>>>> +     TP_printk(WIPHY_PR_FMT ", mode: %d",
>>>>>> +               WIPHY_PR_ARG, __entry->mode)
>>>>>> +);
>>>>>> +
>>>>>>  TRACE_EVENT(rdev_return_int_int,
>>>>>>       TP_PROTO(struct wiphy *wiphy, int func_ret, int
>>>>>> func_fill),
>>>>>>       TP_ARGS(wiphy, func_ret, func_fill),
>>>>
>>>>
>>>>
>>>> --
>>>> Wei-Ning Huang, =E9=BB=83=E5=81=89=E5=AF=A7 | Software Engineer, G=
oogle Inc., Taiwan |
>>>> wnhuang@google.com | Cell: +886 910-380678
>>>
>>>
>=20
>=20
>=20
