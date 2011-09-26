From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
Date: Mon, 26 Sep 2011 16:08:47 -0700
Message-ID: <CAEP_g=-xqgrS1hjApx5bPE2GFkAPJa6meaL0nmUcUbvSOPK-hQ@mail.gmail.com>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1316855863-6091-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAEP_g=93GcR7yE7N+GtaB6dpjPuGGtCBXznEmV6Sx=BX-kSbmg@mail.gmail.com> <43F901BD926A4E43B106BF17856F0755019C519319@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53624 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab1IZXJJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 19:09:09 -0400
Received: by wyg34 with SMTP id 34so6433344wyg.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 16:09:07 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C519319@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 8:57 AM, Rose, Gregory V
<gregory.v.rose@intel.com> wrote:
>> -----Original Message-----
>> From: Jesse Gross [mailto:jesse@nicira.com]
>> Sent: Saturday, September 24, 2011 9:33 AM
>> To: Kirsher, Jeffrey T
>> Cc: davem@davemloft.net; Rose, Gregory V; netdev@vger.kernel.org;
>> gospo@redhat.com; Jiri Pirko
>> Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
>>
>> On Sat, Sep 24, 2011 at 2:17 AM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Greg Rose <gregory.v.rose@intel.com>
>> >
>> > Changes to clean up the vlan rx path broke trunk vlan. =C2=A0Trunk=
 vlans in
>> > a VF driver are those set using:
>> >
>> > "ip link set <pfdev> vf <n> <vlanid>"
>> >
>> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>> > CC: Jiri Pirko <jpirko@redhat.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> > ---
>> > =C2=A0drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | =C2=A0 =C2=
=A06 ++----
>> > =C2=A01 files changed, 2 insertions(+), 4 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> > index d72905b..4930c46 100644
>> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> > @@ -293,12 +293,10 @@ static void ixgbevf_receive_skb(struct
>> ixgbevf_q_vector *q_vector,
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ixgbevf_adapter *adapter =3D q_v=
ector->adapter;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0bool is_vlan =3D (status & IXGBE_RXD_ST=
AT_VP);
>> > + =C2=A0 =C2=A0 =C2=A0 u16 tag =3D le16_to_cpu(rx_desc->wb.upper.v=
lan);
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 if (is_vlan) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 tag =3D le1=
6_to_cpu(rx_desc->wb.upper.vlan);
>> > -
>> > + =C2=A0 =C2=A0 =C2=A0 if (is_vlan && test_bit(tag, adapter->activ=
e_vlans))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__vlan_hwac=
cel_put_tag(skb, tag);
>> > - =C2=A0 =C2=A0 =C2=A0 }
>>
>> What happens if you run tcpdump without configuring vlan devices?
>> Shouldn't you see tagged packets for the vlans that are being trunke=
d
>> to you? =C2=A0I think this will strip tags in that case. =C2=A0The a=
pparent
>> behavior of vlan filters here is also surprising to me because on on=
e
>> hand if they're truly filtering this test shouldn't be needed and on
>> the other hand they don't seem to be disabled in promiscuous mode.
>
> I think you're not quite understanding the action the HW is taking he=
re. =C2=A0In the physical function driver we have put the VF on a VLAN =
without it knowing that it's on a VLAN. =C2=A0Once that is done by the =
PF, the VF is not allowed to configure its own VLANs anymore. =C2=A0How=
ever, the descriptor still includes a bit for the VLAN tag indicating i=
t was a packet that arrived on a VLAN. =C2=A0The HW is inserting and st=
ripping the VLAN tag though without any awareness of that by the VF dri=
ver.
>
> It's a security measure to allow an administrator to put a VF on a VL=
AN to provide another level of isolation for the VF.
>
> Intel VFs don't support promiscuous mode. =C2=A0If you ran tcpdump yo=
u wouldn't see the VLAN tags because they've been stripped by the HW. =C2=
=A0The VF has no choice in this.

I understand that VFs are limited in what they can do.  What I'm
concerned about are differences in how the driver behaves when a vlan
device is configured on it vs. not.  There are two cases that I think
you will see different behavior:

* The VF driver has it's own vlan filters.  I'm assuming (correct me
if I'm wrong) that this will further restrict the vlans that the guest
sees from the set that have been configured on the PF driver.  If that
is correct, then putting the VF interface in promiscuous mode should
disable the filters and allow packets from all vlans that the PF
allows.  This situation is the same as if an upstream physical switch
is trunking only a subset of vlans to an end host and the NIC is put
in promiscuous mode.  However, it doesn't look like the VF driver does
anything in response to being in promiscuous mode.  This shouldn't
require any hardware support because it is just clearing the filter
table.
* It looks like the VF driver is receiving not just an indication that
a tag was present but the actual tag and although it was already
stripped by the NIC it can be passed up to the network stack just as
if it was stripped in a non-SR-IOV NIC.  After this patch, if you run
tcpdump on the VF interface you will see packets with tags if a vlan
device is configured but packets without tags if there is no vlan
device.

Does the VF know whether it is assigned to a particular vlan or is
allowed to send/receive tagged packets (essentially the difference
between an access port or a trunk port)?  Or is that why the presence
of vlan device is used as an indication?
