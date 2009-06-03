From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
 802.15.4 devices
Date: Wed, 03 Jun 2009 13:05:10 +0200
Message-ID: <1244027110.1693.9.camel@johannes.local>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
	 <1244021964.10665.5.camel@johannes.local>
	 <20090603.030911.162861804.davem@davemloft.net>
	 <20090603105256.GB20508@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-p0ANSyIOHko/XcZDkfvJ"
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	sfr@canb.auug.org.au, slapin@ossfans.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39602 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbZFCLFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 07:05:16 -0400
In-Reply-To: <20090603105256.GB20508@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-p0ANSyIOHko/XcZDkfvJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-03 at 14:52 +0400, Dmitry Eremin-Solenikov wrote:

> +	IEEE802154_ATTR_CAPABILITY, /* FIXME: this is association */

Fix what?

> +#define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
> +#define NLA_HW_ADDR	NLA_U64
> +#define NLA_GET_HW_ADDR(attr, addr) do { u64 _temp =3D nla_get_u64(attr)=
; memcpy(addr, &_temp, 8); } while (0)
> +#define NLA_PUT_HW_ADDR(msg, attr, addr) do { u64 _temp; memcpy(&_temp, =
addr, 8); NLA_PUT_U64(msg, attr, _temp); } while (0)

I really don't like this namespace pollution.

> +#ifdef IEEE802154_NL_WANT_POLICY
> +static struct nla_policy ieee802154_policy[IEEE802154_ATTR_MAX + 1] =3D =
{

Ho humm. This shouldn't be in a header file. Not even with an #ifdef
that exactly one C file then sets.

> +	[IEEE802154_ATTR_DURATION] =3D { .type =3D NLA_U8, },
> +#ifdef __KERNEL__
> +	[IEEE802154_ATTR_ED_LIST] =3D { .len =3D 27 },
> +#else

Ick.

> +/* commands */
> +/* REQ should be responded with CONF
> + * and INDIC with RESP
> + */
> +enum {

kernel-doc explaining the commands would be immensely helpful.


> +	IEEE802154_GTS_REQ, /* Not supported yet */
> +	IEEE802154_GTS_INDIC, /* Not supported yet */
> +	IEEE802154_GTS_CONF, /* Not supported yet */
> +	IEEE802154_RX_ENABLE_REQ, /* Not supported yet */
> +	IEEE802154_RX_ENABLE_CONF, /* Not supported yet */

Just leave it out then. You're fixing ABI here.

> +#ifdef __KERNEL__
> +struct net_device;
> +
> +int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee802154_=
addr *addr, u8 cap);
> +int ieee802154_nl_assoc_confirm(struct net_device *dev, u16 short_addr, =
u8 status);
> +int ieee802154_nl_disassoc_indic(struct net_device *dev, struct ieee8021=
54_addr *addr, u8 reason);
> +int ieee802154_nl_disassoc_confirm(struct net_device *dev, u8 status);
> +int ieee802154_nl_scan_confirm(struct net_device *dev, u8 status, u8 sca=
n_type, u32 unscanned,
> +		u8 *edl/*, struct list_head *pan_desc_list */);
> +int ieee802154_nl_beacon_indic(struct net_device *dev, u16 panid, u16 co=
ord_addr); /* TODO */
> +#endif

Why not just use two header files, one in net/ and one in linux/?

> -obj-$(CONFIG_IEEE802154) +=3D	af_802154.o
> +obj-$(CONFIG_IEEE802154) +=3D	nl802154.o af_802154.o
> +nl802154-objs		:=3D netlink.o

That doesn't make any sense. Why the indirection?

> +#include <net/ieee802154/af_ieee802154.h>
> +#define IEEE802154_NL_WANT_POLICY
> +#include <net/ieee802154/nl802154.h>

Like I thought. That's ugly.

> +static int ieee802154_nl_put_failure(struct sk_buff *msg)
> +{
> +	void *hdr =3D genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh is right=
 at the start of msg */
> +	genlmsg_cancel(msg, hdr);
> +	nlmsg_free(msg);
> +	return -ENOBUFS;
> +}

This seems weird.

> +int ieee802154_nl_assoc_indic(struct net_device *dev, struct ieee802154_=
addr *addr, u8 cap)
> +{
> +	struct sk_buff *msg;
> +
> +	pr_debug("%s\n", __func__);
> +
> +	msg =3D ieee802154_nl_create(/* flags*/ 0, IEEE802154_ASSOCIATE_INDIC);
> +	if (!msg)
> +		return -ENOBUFS;
> +
> +	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
> +	NLA_PUT_U32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex);
> +	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_HW_ADDR, dev->dev_addr);
> +
> +	/* FIXME: check that we really received hw address */
> +	NLA_PUT_HW_ADDR(msg, IEEE802154_ATTR_SRC_HW_ADDR, addr->hwaddr);

?


> +static int ieee802154_associate_req(struct sk_buff *skb, struct genl_inf=
o *info)
> +{
> +	struct net_device *dev;
> +	struct ieee802154_addr addr;
> +	int ret =3D -EINVAL;
> +
> +	if (!info->attrs[IEEE802154_ATTR_CHANNEL]
> +	 || !info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
> +	 || (!info->attrs[IEEE802154_ATTR_COORD_HW_ADDR] && !info->attrs[IEEE80=
2154_ATTR_COORD_SHORT_ADDR])
> +	 || !info->attrs[IEEE802154_ATTR_CAPABILITY])
> +		return -EINVAL;

That's some odd coding style.

johannes

--=-p0ANSyIOHko/XcZDkfvJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKJljiAAoJEODzc/N7+QmaVmkP/3FA0KEHQ04UEG/hfpiwyqJ0
Te/zU/qQohLIvUCEFAY3MsyUnWHjO9jw7OTph107a3GovwNY4BnhQYct3OrJJg9j
MsTbzsLbgmvN1EN0EHQObRzMQcyuRtFDU6aSeqKt83Ky+rByFYsTiG/mPzTepv5e
uLNHTUrSCBFfj1YvN9zEXYsu+g20vrulDv4MgaFPAZItyx/0G2Q7GWZwzQiIk0l0
xbCQhYvvfA7eH/WnJY0Xq8Sg71w3tb0yVX+7vQPiMh1nLl3CXctvAzZhny0nvi5J
myUOdVrPmjsGduiSx6jQcQdjW490fx8rLArw4TonmRdVPzvC1fUb50SlIWncIHHH
ZyYSgmzpoI6y/NJgjd2Wjhc2qLPAv3WzNiMg+TQuRZKqJ2+ni8PxFO5Szuyc672x
SxhbcnQMQgv3Htcg11omBXBUmiEpaOytlfMGp3AJfM0smdWStXhYgoRKHOw6Ljt/
Zz8ig0vEgnJHK7pKTwpwaI8VOr+UBHdPW+QEj+2L/T4RlobhZ3mfUmo1xrK9fVvg
7q1Q89HFTIUq5DGnFUjPKamXP6f3fY0cqEDIgsYIw3eScjTZelnP91qiQkSPkeSF
e6p5LthGh3T3XeMoK9gHkivFKvqVTQPo4k68jhfIrNY9FD6E0QyUASKj6k5pl1jV
6jpMB8sFcLHOU6TWWii8
=niFm
-----END PGP SIGNATURE-----

--=-p0ANSyIOHko/XcZDkfvJ--

