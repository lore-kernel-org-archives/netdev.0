From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch asic
 if feature flag set
Date: Fri, 5 Dec 2014 22:54:43 -0800
Message-ID: <CAE4R7bAKTtWi6TbOaeNDxKkDFXf5H2E3NUdbNSizvq77ADtuNg@mail.gmail.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com>
	<54815883.80909@cumulusnetworks.com>
	<E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com>
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
Received: from mail-wg0-f50.google.com ([74.125.82.50]:50291 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbaLFGyp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 01:54:45 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so2519723wgh.37
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 22:54:43 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D842BA@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 3:21 PM, Arad, Ronen <ronen.arad@intel.com> wrot=
e:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Roopa Prabhu
>> Sent: Thursday, December 04, 2014 11:02 PM
>> To: Scott Feldman
>> Cc: Ji=C5=99=C3=AD P=C3=ADrko; Jamal Hadi Salim; Benjamin LaHaise; T=
homas Graf; john
>> fastabend; stephen@networkplumber.org; John Linville;
>> nhorman@tuxdriver.com; Nicolas Dichtel; vyasevic@redhat.com; Florian
>> Fainelli; buytenh@wantstofly.org; Aviad Raveh; Netdev; David S. Mill=
er;
>> shm@cumulusnetworks.com; Andy Gospodarek
>> Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to s=
witch asic
>> if feature flag set
>>
>> On 12/4/14, 10:41 PM, Scott Feldman wrote:
>> > On Thu, Dec 4, 2014 at 6:26 PM,  <roopa@cumulusnetworks.com> wrote=
:
>> >> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> >>
>> >> This allows offloading to switch asic without having the user to =
set
>> >> any flag. And this is done in the bridge driver to rollback kerne=
l
>> >> settings on hw offload failure if required in the future.
>> >>
>> >> With this, it also makes sure a notification goes out only after =
the
>> >> attributes are set both in the kernel and hw.
>> > I like this approach as it streamlines the steps for the user in
>> > setting port flags.  There is one case for FLOODING where you'll h=
ave
>> > to turn off flooding for both, and then turn on flooding in hw.  Y=
ou
>> > don't want flooding turned on on kernel and hw.
>> ok, maybe using the higher bits as in
>> https://patchwork.ozlabs.org/patch/413211/
>>
>> might help with that. Let me think some more.
>> >
>> >> ---
>> >>   net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>> >>   1 file changed, 26 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c in=
dex
>> >> 9f5eb55..ce173f0 100644
>> >> --- a/net/bridge/br_netlink.c
>> >> +++ b/net/bridge/br_netlink.c
>> >> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struc=
t
>> nlmsghdr *nlh)
>> >>                                  afspec, RTM_SETLINK);
>> >>          }
>> >>
>> >> +       if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>> >> +                       dev->netdev_ops->ndo_bridge_setlink) {
>> >> +               int ret =3D dev->netdev_ops->ndo_bridge_setlink(d=
ev,
>> >> + nlh);
>> > I think you want to up-level this to net/core/rtnetlink.c because
>> > you're only enabling the feature for one instance of a driver that
>> > implements ndo_bridge_setlink: the bridge driver.  If another driv=
er
>> > was MASTER and implemented ndo_bridge_setlink, you'd want same che=
ck
>> > to push setting down to SELF port driver.
>>
>> yeah, i thought about that. But i moved it here so that rollback wou=
ld be
>> easier.
>
> There is a need for propagating setlink/dellink requests down multipl=
e levels.
> The use-case I have in mind is a bridge at the top, team/bond in the =
middle, and port devices at the bottom.
> A setlink for VLAN filtering attributes would come with MASTER flag s=
et, and either port or bond/team netdev.
> How would this be handled?
>
> The propagation rules between bridge and enslaved port device could b=
e different from those between bond/team and enslaved devices.
> The current bridge driver does not propagate VLAN filtering from brid=
ge to its ports as each port could have different configuration. In a c=
ase of a bond/team all members need to have the same configuration such=
 that the a bond/team would be indistinguishable from a simple port.
>
> Therefore rtnetlink.c might not have the knowledge for propagation ac=
ross multiple levels.
> It seems that each device which implements ndo_bridge_setlink/ndo_bri=
dge_dellink  and could have master role, need to take care of propagati=
on to its slaves.

Thanks Ronen for bringing up this use-case of stacked masters.  I
think for VLAN filtering, the stacked master case is handled, not by
ndo_setlink/dellink at each level, but with ndo_vlan_rx_kill_vid and
ndo_vlan_rx_add_vid.  So the switch port driver can know VLAN
membership for port even if port is under bond which is under bridge,
by using ndo_vlan_rx_xxx and setting NETIF_F_HW_VLAN_CTAG_FILTER.  The
bonding driver's ndo_vlan_rx_xxx handlers seem to keep ports in bond
VLAN membership consistent across bond.

But in general, ndo_setlink/dellink don't work for the stack use-case
for other non-VLAN attributes.  Maybe the answer is to use the VLAN
propogation model for other attributes.  ndo_setlink/dellink/getlink
have enough weird-isms it might be time to define cleaner ndo ops to
propagate the other attrs down.
