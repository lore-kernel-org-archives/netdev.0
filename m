From: michael-dev <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Subject: Re: [PATCH 3/3] mac80211: multicast to unicast conversion
Date: Wed, 05 Oct 2016 13:40:03 +0200
Message-ID: <1690671fb30f19c53c7883a5207c5721@fami-braun.de>
References: <1475643324-2845-1-git-send-email-michael-dev@fami-braun.de>
 <1475643324-2845-3-git-send-email-michael-dev@fami-braun.de>
 <1475662791.4994.39.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475662791.4994.39.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 05.10.2016 12:19, schrieb Johannes Berg:
>> on both ends. Furthermore, I've seen a few mobile phone stations
>> locally that indicate qos support but won't complete DHCP if their
>> broadcasts are encapsulated as A-MSDU. Though they work fine with
>> this series approach.
>=20
> Presumably those phones also don't even try to use DMS, right?

When I traced this two years ago, almost no device indicated DMS=20
support, even though almost all seem to accepted multicast in unicast=20
a-msdu frames.

>=20
>> This patch therefore does not opt to implement DMS but instead just
>> replicates the packet and changes the destination address. As this
>> works fine with ARP, IPv4 and IPv6, it is limited to these protocols
>> and normal 802.11 multicast frames are send out for all other payload
>> protocols.
>=20
> How did you determine that it "works fine"?

First, I tested this manually using my own devices or asked friends. I=20
think this covered at least a recent debian x64 with an intel wireless=20
card, a windows 7 x64 with an intel wireless card, an android phone, an=20
ios phone and some recent macbook. Manually testing included visiting an=20
IPv6 only website (this network uses IPv6 router advertismentens (RA)=20
but no DHCPv6), so RA is accepted and ND working. Additionally,=20
arping'ing these station using broadcast arp request worked fine, so=20
broadcast arp requests are working. Finally, DHCP worked fine and UPNP=20
multicast discovery for some closed source media streaming wireless=20
device was reported working.

Next, that change was rolled out. It is now in use for at least three=20
years with about 300 simulatenously online stations and >2000 currently=20
registered devices and there hasn't been a single problem report that=20
could be related to that change. Though, e.g. our samsung galaxy users=20
report consistently that their devices refuse to connect using WPA-PSK=20
as our network advertises FT-PSK next to WPA-PSK and I learned that=20
there was at least one device there that did not like the=20
multicast-as-unicast-amsdu packets due to a user problem report.

> I see at least one undesirable impact of this, which DMS doesn't have;
> it breaks a client's MUST NOT requirement from RFC 1122:

Okay, so this cannot go into linux, right?

The thing I dislike most about DMS is that it is client driven, that is=20
an AP will only apply unicast conversion if a station actively requests=20
so.

> You should split the patch into cfg80211 and mac80211, IMHO it's big
> enough to do that.

ok

>> + * @set_ap_unicast: set the multicast to unicast flag for a AP
>> interface
>=20
> That API name isn't very descriptive, I'm sure we can do something
> better there.

proposal: "request multicast packets to be trasnmitted as unicast" ?

> Also, perhaps we should structure this already like we would DMS, with
> a per-station toggle or even list of multicast addresses?

should be possible, yes


>> +static int ieee80211_set_ap_unicast(struct wiphy *wiphy, struct
>> net_device *dev,
>> +				=C2=A0=C2=A0=C2=A0=C2=A0const bool unicast)
>> +{
>> +	struct ieee80211_sub_if_data *sdata =3D
>> IEEE80211_DEV_TO_SUB_IF(dev);
>> +
>> +	if (sdata->vif.type !=3D NL80211_IFTYPE_AP)
>> +		return -1;
>=20
> Was this not documented but also intended to apply to its dependent
> VLANs?

it was intended as a per per-BSS toggle, so it applies to all dependent=20
VLANs automatically.

>> +/* Check if multicast to unicast conversion is needed and do it.
>> + * Returns 1 if skb was freed and should not be send out. */
>=20
> wrong comment style :)

you mean the */ at end of line instead of on a new line?

>> +	unicast =3D nla_data(info->attrs[NL80211_ATTR_UNICAST]);
>=20
> What's this supposed to mean?

this was supposed to be nla_get_u8.

michael
