From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCHv2 next 3/3] ipvlan: Introduce l3s mode
Date: Wed, 14 Sep 2016 09:30:10 -0700
Message-ID: <CAF2d9jgEOsSEQXOVJWJsw=RMdr27YiTdcMPrZ6P2EopqU8wtkw@mail.gmail.com>
References: <1473703312-26757-1-git-send-email-mahesh@bandewar.net> <1177f2c5-6c2d-32e1-1628-f272d6b0b5c6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:35460 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756404AbcINQaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 12:30:35 -0400
Received: by mail-yb0-f173.google.com with SMTP id d69so16040832ybf.2
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 09:30:35 -0700 (PDT)
In-Reply-To: <1177f2c5-6c2d-32e1-1628-f272d6b0b5c6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, thanks for the comments.

On Tue, Sep 13, 2016 at 8:24 PM, David Ahern <dsa@cumulusnetworks.com> wrot=
e:
> On 9/12/16 12:01 PM, Mahesh Bandewar wrote:
>
>> +struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *s=
kb,
>> +                           u16 proto)
>> +{
>> +     struct ipvl_addr *addr;
>> +     struct net_device *sdev;
>> +
>> +     addr =3D ipvlan_skb_to_addr(skb, dev);
>> +     if (!addr)
>> +             goto out;
>> +
>> +     sdev =3D addr->master->dev;
>> +     switch (proto) {
>> +     case AF_INET:
>> +     {
>> +             int err;
>> +             struct iphdr *ip4h =3D ip_hdr(skb);
>> +
>> +             err =3D ip_route_input_noref(skb, ip4h->daddr, ip4h->saddr=
,
>> +                                        ip4h->tos, sdev);
>> +             if (unlikely(err))
>> +                     goto out;
>> +             break;
>> +     }
>> +     case AF_INET6:
>> +     {
>> +             struct dst_entry *dst;
>> +             struct ipv6hdr *ip6h =3D ipv6_hdr(skb);
>> +             int flags =3D RT6_LOOKUP_F_HAS_SADDR;
>> +             struct flowi6 fl6 =3D {
>> +                     .flowi6_iif   =3D sdev->ifindex,
>> +                     .daddr        =3D ip6h->daddr,
>> +                     .saddr        =3D ip6h->saddr,
>> +                     .flowlabel    =3D ip6_flowinfo(ip6h),
>> +                     .flowi6_mark  =3D skb->mark,
>> +                     .flowi6_proto =3D ip6h->nexthdr,
>> +             };
>> +
>> +             skb_dst_drop(skb);
>> +             dst =3D ip6_route_input_lookup(dev_net(sdev), sdev, &fl6, =
flags);
>> +             skb_dst_set(skb, dst);
>> +             break;
>> +     }
>> +     default:
>> +             break;
>> +     }
>
> Nit: why not put the above in separate per-version functions (ipvlan_ip_r=
cv and ipvlan_ip6_rcv) similar to what is done for ipvlan_process_outbound?
>
I can but it's small enough to have it together. Also 'proto' is a
parameter to the handler and makes it easier However do you see any
issue having just one function?

>
>> +
>> +out:
>> +     return skb;
>> +}
>> +
>> +unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
>> +                          const struct nf_hook_state *state)
>> +{
>> +     struct ipvl_addr *addr;
>> +     unsigned int len;
>> +
>> +     addr =3D ipvlan_skb_to_addr(skb, skb->dev);
>> +     if (!addr)
>> +             goto out;
>> +
>> +     skb->dev =3D addr->master->dev;
>> +     len =3D skb->len + ETH_HLEN;
>> +     ipvlan_count_rx(addr->master, len, true, false);
>> +out:
>> +     return NF_ACCEPT;
>> +}
>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvla=
n_main.c
>> index 18b4e8c7f68a..d02be277e1db 100644
>> --- a/drivers/net/ipvlan/ipvlan_main.c
>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>> @@ -9,24 +9,65 @@
>>
>>  #include "ipvlan.h"
>>
>> +static struct nf_hook_ops ipvl_nfops[] __read_mostly =3D {
>> +     {
>> +             .hook     =3D ipvlan_nf_input,
>> +             .pf       =3D NFPROTO_IPV4,
>> +             .hooknum  =3D NF_INET_LOCAL_IN,
>> +             .priority =3D INT_MAX,
>> +     },
>> +     {
>> +             .hook     =3D ipvlan_nf_input,
>> +             .pf       =3D NFPROTO_IPV6,
>> +             .hooknum  =3D NF_INET_LOCAL_IN,
>> +             .priority =3D INT_MAX,
>> +     },
>> +};
>> +
>> +static struct l3mdev_ops ipvl_l3mdev_ops __read_mostly =3D {
>> +     .l3mdev_l3_rcv =3D ipvlan_l3_rcv,
>> +};
>> +
>>  static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_devic=
e *dev)
>>  {
>>       ipvlan->dev->mtu =3D dev->mtu - ipvlan->mtu_adj;
>>  }
>>
>> -static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
>> +static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
>>  {
>>       struct ipvl_dev *ipvlan;
>> +     int err =3D 0;
>>
>> +     ASSERT_RTNL();
>>       if (port->mode !=3D nval) {
>> +             if (nval =3D=3D IPVLAN_MODE_L3S) {
>> +                     port->dev->l3mdev_ops =3D &ipvl_l3mdev_ops;
>> +                     port->dev->priv_flags |=3D IFF_L3MDEV_MASTER;
>> +                     if (!port->ipt_hook_added) {
>> +                             err =3D _nf_register_hooks(ipvl_nfops,
>> +                                                     ARRAY_SIZE(ipvl_nf=
ops));
>
> That's clever. The hooks are not device based so why do the register for =
each device? Alternatively, you could use a static dst like VRF does for Tx=
. In the ipvlan rcv function set the dst input handler to send the packet b=
ack to the ipvlan driver via dst->input. From there send the packet through=
 the netfilter hooks and then do the real lookup, update the dst and call i=
ts input function. I have working code for VRF driver somewhere that shows =
how to do this.
>
Do you mean per slave device?  It's registering it for a port (so only
once) depending on the mode. If the mode !=3D l3s it wont bother
registering to keep current modes as they are.
I'm sure dst idea could work as well (as you have suggested) but
l3mdev + ipt-hook is simpler and probably far less intrusive.

>
>> +                             if (!err)
>> +                                     port->ipt_hook_added =3D true;
>> +                             else
>> +                                     return err;
>> +                     }
>> +             } else {
>> +                     port->dev->priv_flags &=3D ~IFF_L3MDEV_MASTER;
>> +                     port->dev->l3mdev_ops =3D NULL;
>> +                     if (port->ipt_hook_added)
>> +                             _nf_unregister_hooks(ipvl_nfops,
>> +                                                  ARRAY_SIZE(ipvl_nfops=
));
>> +                     port->ipt_hook_added =3D false;
>> +             }
>
>
