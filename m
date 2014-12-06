From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch asic
 if feature flag set
Date: Fri, 5 Dec 2014 22:29:24 -0800
Message-ID: <CAE4R7bChFLfCX5z4FTWHfnpNuYKnkTtD64xg5BE0yAwA381w3g@mail.gmail.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com>
	<54815883.80909@cumulusnetworks.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505D8436D@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Smlyw60gUMOtcmtv?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:61965 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbaLFG3Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 01:29:25 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so594360wiv.8
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 22:29:24 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D8436D@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 5:04 PM, Arad, Ronen <ronen.arad@intel.com> wrot=
e:
> I have another case of propagation which is not covered by the propos=
ed patch.
> A recent patch introduced default_pvid attribute for a bridge (so far=
 supported only via sysfs and not via netlink).
> When a port joins a bridge, it inherits a PVID from the default_pvid =
of the bridge.
> The bridge driver propagates that to the newly created net_bridge_por=
t. This is done in br_vlan.c:
>
> int nbp_vlan_init(struct net_bridge_port *p)
> {
>         int rc =3D 0;
>
>         if (p->br->default_pvid) {
>                 rc =3D nbp_vlan_add(p, p->br->default_pvid,
>                                   BRIDGE_VLAN_INFO_PVID |
>                                   BRIDGE_VLAN_INFO_UNTAGGED);
>         }
>
>         return rc;
> }
>
> When L2 switching is offloaded to the HW, this PVID setting need to b=
e propagated.

Agreed, it would be nice to have it propagated down, but there is a
non-ideal work-around.  If you set default_pvid=3D0 to turn off PVID,
then the switch port driver can pick some internal VLAN ID just for HW
purposes in matching untagged pkts.  It's non-ideal because the switch
port driver needs to reserve a block of VLAN IDs for internal usage or
use some other matching mechanism to keep untagged pkts within this
bridge.

Better to have default_pvid value propagated down.  But, default_pvid
is a per-bridge property, not a per-bridge-port property.
RTM_SETLINK/RTM_GETLINK for PF_BRIDGE does have AFSPEC for per-bridge
and PROTINFO for per-bridge-port, so it seems PVID needs to be part of
AFSPEC.

>However, it does not come via ndo_bridge_setlink. The proposed propaga=
tion at br_setlink or an up level one at rtnetlink are not capable of h=
andling this case.
> One possible way for handling that is to replace the call to nbp_vlan=
_add with a call to a new function let's say
> int br_propagate_vlan_add(struct net_bridge_port *port, u16 vid, u16 =
flags)
> This function will compose a netlink message with VLAN filtering info=
rmation (i.e. AF_SPEC with VLAN_INFO) and call br_setlink - leveraging =
the offload support proposed by Roopa.
>
> If this is an acceptable course of action, I could work on such patch=
=2E
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Arad, Ronen
>> Sent: Friday, December 05, 2014 3:21 PM
>> To: Roopa Prabhu; Scott Feldman; Netdev
>> Cc: Jir=C3=AD P=C3=ADrko; Jamal Hadi Salim; Benjamin LaHaise; Thomas=
 Graf; john
>> fastabend; stephen@networkplumber.org; John Linville;
>> nhorman@tuxdriver.com; Nicolas Dichtel; vyasevic@redhat.com; Florian
>> Fainelli; buytenh@wantstofly.org; Aviad Raveh; David S. Miller;
>> shm@cumulusnetworks.com; Andy Gospodarek
>> Subject: RE: [PATCH 2/3] bridge: offload bridge port attributes to s=
witch asic
>> if feature flag set
>>
>>
>>
>> > -----Original Message-----
>> > From: netdev-owner@vger.kernel.org [mailto:netdev-
>> > owner@vger.kernel.org] On Behalf Of Roopa Prabhu
>> > Sent: Thursday, December 04, 2014 11:02 PM
>> > To: Scott Feldman
>> > Cc: Ji=C5=99=C3=AD P=C3=ADrko; Jamal Hadi Salim; Benjamin LaHaise;=
 Thomas Graf; john
>> > fastabend; stephen@networkplumber.org; John Linville;
>> > nhorman@tuxdriver.com; Nicolas Dichtel; vyasevic@redhat.com; Flori=
an
>> > Fainelli; buytenh@wantstofly.org; Aviad Raveh; Netdev; David S.
>> > Miller; shm@cumulusnetworks.com; Andy Gospodarek
>> > Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to
>> > switch asic if feature flag set
>> >
>> > On 12/4/14, 10:41 PM, Scott Feldman wrote:
>> > > On Thu, Dec 4, 2014 at 6:26 PM,  <roopa@cumulusnetworks.com> wro=
te:
>> > >> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> > >>
>> > >> This allows offloading to switch asic without having the user t=
o
>> > >> set any flag. And this is done in the bridge driver to rollback
>> > >> kernel settings on hw offload failure if required in the future=
=2E
>> > >>
>> > >> With this, it also makes sure a notification goes out only afte=
r
>> > >> the attributes are set both in the kernel and hw.
>> > > I like this approach as it streamlines the steps for the user in
>> > > setting port flags.  There is one case for FLOODING where you'll
>> > > have to turn off flooding for both, and then turn on flooding in=
 hw.
>> > > You don't want flooding turned on on kernel and hw.
>> > ok, maybe using the higher bits as in
>> > https://patchwork.ozlabs.org/patch/413211/
>> >
>> > might help with that. Let me think some more.
>> > >
>> > >> ---
>> > >>   net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>> > >>   1 file changed, 26 insertions(+), 1 deletion(-)
>> > >>
>> > >> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> > >> index
>> > >> 9f5eb55..ce173f0 100644
>> > >> --- a/net/bridge/br_netlink.c
>> > >> +++ b/net/bridge/br_netlink.c
>> > >> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, str=
uct
>> > nlmsghdr *nlh)
>> > >>                                  afspec, RTM_SETLINK);
>> > >>          }
>> > >>
>> > >> +       if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>> > >> +                       dev->netdev_ops->ndo_bridge_setlink) {
>> > >> +               int ret =3D dev->netdev_ops->ndo_bridge_setlink=
(dev,
>> > >> + nlh);
>> > > I think you want to up-level this to net/core/rtnetlink.c becaus=
e
>> > > you're only enabling the feature for one instance of a driver th=
at
>> > > implements ndo_bridge_setlink: the bridge driver.  If another dr=
iver
>> > > was MASTER and implemented ndo_bridge_setlink, you'd want same
>> check
>> > > to push setting down to SELF port driver.
>> >
>> > yeah, i thought about that. But i moved it here so that rollback w=
ould
>> > be easier.
>>
>> There is a need for propagating setlink/dellink requests down multip=
le levels.
>> The use-case I have in mind is a bridge at the top, team/bond in the=
 middle,
>> and port devices at the bottom.
>> A setlink for VLAN filtering attributes would come with MASTER flag =
set, and
>> either port or bond/team netdev.
>> How would this be handled?
>>
>> The propagation rules between bridge and enslaved port device could =
be
>> different from those between bond/team and enslaved devices.
>> The current bridge driver does not propagate VLAN filtering from bri=
dge to its
>> ports as each port could have different configuration. In a case of =
a
>> bond/team all members need to have the same configuration such that =
the a
>> bond/team would be indistinguishable from a simple port.
>>
>> Therefore rtnetlink.c might not have the knowledge for propagation a=
cross
>> multiple levels.
>> It seems that each device which implements
>> ndo_bridge_setlink/ndo_bridge_dellink  and could have master role, n=
eed to
>> take care of propagation to its slaves.
>>
>> > >
>> > >> +               if (ret && ret !=3D -EOPNOTSUPP) {
>> > >> +                       /* XXX Fix this in the future to rollba=
ck
>> > >> +                        * kernel settings and return error
>> > >> +                        */
>> > > The future is now.  Let's fix this now for the rollback case (ag=
ain
>> > > up in rtnetlink.c).  So then a general question comes to mind: f=
or
>> > > these dual target sets, is it best to try HW first and then SW, =
or
>> > > the other way around?  Either way, on failure on second you need=
 to
>> > > rollback first.  And, on failure, you need to know rollback valu=
e
>> > > for first, so you have to do a getlink on first before attemptin=
g set.
>> > yep, exactly, I went through the same thought process yesterday wh=
en i
>> > was trying to implement rollback.
>> > >
>> > >> +                       br_warn(p->br, "error offloading bridge=
 attributes "
>> > >> +                                       "on port %u(%s)\n", (un=
signed int) p->port_no,
>> > >> +                                       p->dev->name);
>> > >> +               }
>> > >> +       }
>> > >> +
>> > >>          if (err =3D=3D 0)
>> > >>                  br_ifinfo_notify(RTM_NEWLINK, p);
>> > >> -
>> > >>   out:
>> > >>          return err;
>> > >>   }
>> > >> @@ -433,6 +445,19 @@ int br_dellink(struct net_device *dev, str=
uct
>> > nlmsghdr *nlh)
>> > >>          err =3D br_afspec((struct net_bridge *)netdev_priv(dev=
), p,
>> > >>                          afspec, RTM_DELLINK);
>> > >>
>> > >> +       if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD
>> > >> +                       && dev->netdev_ops->ndo_bridge_setlink)=
 {
>> > >> +               int ret =3D dev->netdev_ops->ndo_bridge_dellink=
(dev, nlh);
>> > >> +               if (ret && ret !=3D -EOPNOTSUPP) {
>> > >> +                       /* XXX Fix this in the future to rollba=
ck
>> > >> +                        * kernel settings and return error
>> > >> +                        */
>> > >> +                       br_warn(p->br, "error offloading bridge=
 attributes "
>> > >> +                                       "on port %u(%s)\n", (un=
signed int) p->port_no,
>> > >> +                                       p->dev->name);
>> > >> +               }
>> > >> +       }
>> > >> +
>> > > Same comments as setlink above.
>> > >
>> > >>          return err;
>> > >>   }
>> > >>   static int br_validate(struct nlattr *tb[], struct nlattr
>> > >> *data[])
>> > >> --
>> > >> 1.7.10.4
>> > >>
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>> > the body of a message to majordomo@vger.kernel.org More majordomo
>> info
>> > at http://vger.kernel.org/majordomo-info.html
>>   {.n +       +%  lzwm  b =EB=A7=B2  r  zw u   ^n r   z    h    &   =
 G   h  ( =E9=9A=8E =DD=A2j"     m     z =DE=96
>> f   h   ~ m
