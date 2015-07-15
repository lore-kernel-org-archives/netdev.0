From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: forward packets to CPU when a port
 in promiscuous mode
Date: Tue, 14 Jul 2015 22:32:54 -0700
Message-ID: <CAE4R7bBH3dTfivKqo9qzRVhtpUiDzGdDmoeceY5YBq6A3VR03g@mail.gmail.com>
References: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bChu5sAKpU5tUkENfWZMhaWSs3EQZeggUxR=BjKSOqOeg@mail.gmail.com> <20150715044521.GA7603@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36446 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbbGOFdO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 01:33:14 -0400
Received: by oibn4 with SMTP id n4so21290294oib.3
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 22:33:13 -0700 (PDT)
In-Reply-To: <20150715044521.GA7603@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 9:45 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi Scott,
>
> On Mon, Jul 13, 2015 at 11:37:59PM -0700, Scott Feldman wrote:
>> On Wed, Jul 8, 2015 at 9:25 PM, Simon Horman <simon.horman@netronome=
=2Ecom> wrote:
>> > This change allows the CPU to see all packets seen by a port when =
the
>> > netdev associated with the port is in promiscuous mode.
>> >
>> > This change was previously posted as part of a larger patch and in=
 turn
>> > patchset which also aimed to allow rocker interfaces to receive pa=
ckets
>> > when not bridged. That problem has subsequently been addressed in =
a
>> > different way by Scott Feldman.
>> >
>> > When this change was previously posted Scott indicated that he had=
 some
>> > reservations about sending all packets from a switch to the CPU. T=
he
>> > purpose of posting this patch is to start discussion of weather th=
is
>> > approach is appropriate and if not how else we might move forwards=
=2E
>> >
>> > In my opinion if host doesn't want all packets its shouldn't put a=
 port
>> > in promiscuous mode. But perhaps that is an overly na=C3=AFve view=
 to take.
>> >
>> > My main motivation for this change at this time is to allow rocker=
 to
>> > work with Open vSwitch and it appears that this change is sufficie=
nt to
>> > reach that goal. Another approach might be to teach
>> > rocker_port_master_changed() about Open vSwitch.
>> >
>> > In the longer term I believe Open vSwitch should be able to progra=
m
>> > flows into rocker 'hardware' and thus not all packets would reach =
the CPU.
>>
>> Hi Simon,
>>
>> I like your alternate approach to teach rocker about Open vSwitch
>> using rocker_port_master_change() and only when port is captured by
>> OVS would we install the "promisc" filter to pass all traffic up.
>> (Maybe call it ROCKER_CTRL_DFLT_OVS rule?).
>>
>> Putting a non-bridged, non-ovs port into promisc is kind of weird fo=
r
>> a switch port.  I think of the port in L3 mode by default, where the
>> port is locked down for all but some selective mcasts, and only open=
ed
>> up by installing explicit routes.  (Unlike a bridged port where we
>> flood everything L2 we don't understand).
>>
>> So maybe first pass is to pass up everything when port is captured b=
y
>> OVS, and then later refine what's passed up per ovs flows on that
>> port.
>
> That sounds reasonable to me. Its pretty clear to me from the respons=
es
> from John and yourself that my approach to the promiscuous flag isn't
> as clean-cut as I had hoped. And it seems that we have a nice way to
> move forwards on supporting Open vSwitch.
>
> How about this?

Looks good, some inline comments...

> From: Simon Horman <simon.horman@netronome.com>
>
> Subject: rocker: forward packets to CPU when port is joined to openvs=
witch
>
> Teach rocker to forward packets to CPU when a port is joined to Open =
vSwitch.
> There is scope to later refine what is passed up as per Open vSwitch =
flows
> on a port.
>
> This does not change the behaviour of rocker ports that are
> not joined to Open vSwitch.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c | 55 ++++++++++++++++++++++++++=
++++++----
>  1 file changed, 49 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ether=
net/rocker/rocker.c
> index c0051673c9fa..8c53d6839260 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -202,6 +202,7 @@ enum {
>         ROCKER_CTRL_IPV4_MCAST,
>         ROCKER_CTRL_IPV6_MCAST,
>         ROCKER_CTRL_DFLT_BRIDGING,
> +       ROCKER_CTRL_DFLT_OVS,
>         ROCKER_CTRL_MAX,
>  };
>
> @@ -321,9 +322,21 @@ static u16 rocker_port_vlan_to_vid(const struct =
rocker_port *rocker_port,
>         return ntohs(vlan_id);
>  }
>
> +static bool rocker_port_is_bridged__(const struct rocker_port *rocke=
r_port,
> +                                    const char *kind)

Maybe use __rocker_port_is_bridged?  (leading '__'; I've not seen use
of trailing '__').  Or __rocker_port_is_slave(port, kind)?

> +{
> +       return rocker_port->bridge_dev &&
> +               !strcmp(rocker_port->bridge_dev->rtnl_link_ops->kind,=
 kind);
> +}
> +
>  static bool rocker_port_is_bridged(const struct rocker_port *rocker_=
port)
>  {
> -       return !!rocker_port->bridge_dev;
> +       return rocker_port_is_bridged__(rocker_port, "bridge");
> +}
> +
> +static bool rocker_port_is_ovs(const struct rocker_port *rocker_port=
)

rocker_port_is_ovsed?  Just to be consistent with is_bridged.

> +{
> +       return rocker_port_is_bridged__(rocker_port, "openvswitch");
>  }
>
>  #define ROCKER_OP_FLAG_REMOVE          BIT(0)
> @@ -3275,6 +3288,12 @@ static struct rocker_ctrl {
>                 .bridge =3D true,
>                 .copy_to_cpu =3D true,
>         },
> +       [ROCKER_CTRL_DFLT_OVS] =3D {
> +               /* pass all pkts up to CPU */
> +               .eth_dst =3D zero_mac,
> +               .eth_dst_mask =3D zero_mac,
> +               .acl =3D true,
> +       },
>  };
>
>  static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port=
,
> @@ -3787,11 +3806,14 @@ static int rocker_port_stp_update(struct rock=
er_port *rocker_port,
>                 break;
>         case BR_STATE_LEARNING:
>         case BR_STATE_FORWARDING:
> -               want[ROCKER_CTRL_LINK_LOCAL_MCAST] =3D true;
> +               if (!rocker_port_is_ovs(rocker_port))
> +                       want[ROCKER_CTRL_LINK_LOCAL_MCAST] =3D true;
>                 want[ROCKER_CTRL_IPV4_MCAST] =3D true;
>                 want[ROCKER_CTRL_IPV6_MCAST] =3D true;
>                 if (rocker_port_is_bridged(rocker_port))
>                         want[ROCKER_CTRL_DFLT_BRIDGING] =3D true;
> +               else if (rocker_port_is_ovs(rocker_port))
> +                       want[ROCKER_CTRL_DFLT_OVS] =3D true;
>                 else
>                         want[ROCKER_CTRL_LOCAL_ARP] =3D true;
>                 break;
> @@ -5251,6 +5273,22 @@ static int rocker_port_bridge_leave(struct roc=
ker_port *rocker_port)
>         return err;
>  }
>
> +
> +static int rocker_port_ovs_changed(struct rocker_port *rocker_port,
> +                                  struct net_device *master)
> +{
> +       int err;
> +
> +       rocker_port->bridge_dev =3D master;
> +
> +       err =3D rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_=
NONE, 0);
> +       if (err)
> +               return err;
> +       err =3D rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_N=
ONE, 0);
> +
> +       return err;
> +}
> +
>  static int rocker_port_master_changed(struct net_device *dev)
>  {
>         struct rocker_port *rocker_port =3D netdev_priv(dev);
> @@ -5263,11 +5301,16 @@ static int rocker_port_master_changed(struct =
net_device *dev)
>          * 3. Other, e.g. being added to or removed from a bond or op=
envswitch,
>          *    in which case nothing is done
>          */

Maybe comment above needs adjusting?

> -       if (master && master->rtnl_link_ops &&
> -           !strcmp(master->rtnl_link_ops->kind, "bridge"))
> -               err =3D rocker_port_bridge_join(rocker_port, master);
> -       else if (rocker_port_is_bridged(rocker_port))
> +       if (master && master->rtnl_link_ops) {
> +               if (!strcmp(master->rtnl_link_ops->kind, "bridge"))
> +                       err =3D rocker_port_bridge_join(rocker_port, =
master);
> +               else if (!strcmp(master->rtnl_link_ops->kind, "openvs=
witch"))
> +                       err =3D rocker_port_ovs_changed(rocker_port, =
master);
> +       } else if (rocker_port_is_bridged(rocker_port)) {
>                 err =3D rocker_port_bridge_leave(rocker_port);
> +       } else if (rocker_port_is_ovs(rocker_port)) {
> +               err =3D rocker_port_ovs_changed(rocker_port, NULL);
> +       }
>
>         return err;
>  }
> --
> 2.1.4
>
>
