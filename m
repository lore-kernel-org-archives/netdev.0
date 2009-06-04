From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Thu, 4 Jun 2009 18:51:58 +0400
Message-ID: <bc64b4640906040751i3c64c317i4eedb7d53307092a@mail.gmail.com>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com>
	 <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com>
	 <1244021964.10665.5.camel@johannes.local>
	 <20090603.030911.162861804.davem@davemloft.net>
	 <20090603105256.GB20508@doriath.ww600.siemens.net>
	 <1244027110.1693.9.camel@johannes.local>
	 <20090603122744.GC20508@doriath.ww600.siemens.net>
	 <1244124749.22576.71.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244124749.22576.71.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/4 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
> On Wed, 2009-06-03 at 16:27 +0400, Dmitry Eremin-Solenikov wrote:
>
>> > > +static int ieee802154_nl_put_failure(struct sk_buff *msg)
>> > > +{
>> > > + void *hdr =3D genlmsg_data(NLMSG_DATA(msg->data)); /* XXX: nlh=
 is right at the start of msg */
>> > > + genlmsg_cancel(msg, hdr);
>> > > + nlmsg_free(msg);
>> > > + return -ENOBUFS;
>> > > +}
>> >
>> > This seems weird.
>>
>> Why?
>
> Because it's strange to cancel then free?

=46rom looking at the other code, the usual pattern for netlink is
(please, correct me if I'm wrong):

int fill (....)
{
   genlmsg_put();
   NLA_PUT(...)
   NLA_PUT(...)
   return genlmsg_end();

nla_put_failure:
   genlmsg_cancel();
   return -EMSGSIZE;
}

int cmd(...)
{
    int rc;
    nlmsg_new();

    rc =3D fill();
    if (rc < 0)
        goto out;

    genlmsg_unicast();

out:
    nlmsg_free();
    return -ENOBUFS;
}

This is equivalent to our code:

sk_buff *new()
{
   msg =3D nlmsg_new();
   genlmsg_put();
   return msg;
}

int finish()
{
    genlmsg_end();
    return genlmsg_unicast(); /*multicast in our case, but doesn't matt=
er */
}

int cancel()
{
   genlmsg_cancel();
   nlmsg_free();
   return -ENOBUFS;
}

int cmd()
{
  msg =3D new();
  NLA_PUT()
  NLA_PUT();
  return finish();
nla_put_failure:
  return cancel();
}

>> > > +static int ieee802154_associate_req(struct sk_buff *skb, struct=
 genl_info *info)
>> > > +{
>> > > + struct net_device *dev;
>> > > + struct ieee802154_addr addr;
>> > > + int ret =3D -EINVAL;
>> > > +
>> > > + if (!info->attrs[IEEE802154_ATTR_CHANNEL]
>> > > + =A0|| !info->attrs[IEEE802154_ATTR_COORD_PAN_ID]
>> > > + =A0|| (!info->attrs[IEEE802154_ATTR_COORD_HW_ADDR] && !info->a=
ttrs[IEEE802154_ATTR_COORD_SHORT_ADDR])
>> > > + =A0|| !info->attrs[IEEE802154_ATTR_CAPABILITY])
>> > > + =A0 =A0 =A0 =A0 return -EINVAL;
>> >
>> > That's some odd coding style.
>>
>> Could you please elaborate this? What seems odd to you?
>
> if (X
> =A0 =A0&& Y)
>
> vs
>
> if (X &&
> =A0 =A0Y)
>
> where the latter is used for all other sources files in the kernel. T=
ry
> applying that to _all_ your patches while you rework the sources to f=
it
> into 80 columns.

=46ine, I'll apply the latter pattern and try to reformat code to fit t=
o
80 columns.

--=20
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
