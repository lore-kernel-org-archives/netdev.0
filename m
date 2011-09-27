From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
Date: Mon, 26 Sep 2011 17:54:22 -0700
Message-ID: <CAEP_g=-OhrQ5QMbj5_d4BhLHEdDim1_STgy96Vdx5mYFagpVGg@mail.gmail.com>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1316855863-6091-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAEP_g=93GcR7yE7N+GtaB6dpjPuGGtCBXznEmV6Sx=BX-kSbmg@mail.gmail.com>
 <43F901BD926A4E43B106BF17856F0755019C519319@orsmsx508.amr.corp.intel.com>
 <CAEP_g=-xqgrS1hjApx5bPE2GFkAPJa6meaL0nmUcUbvSOPK-hQ@mail.gmail.com> <43F901BD926A4E43B106BF17856F0755019C5E5B68@orsmsx508.amr.corp.intel.com>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36349 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab1I0Ayn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 20:54:43 -0400
Received: by wyg34 with SMTP id 34so6528683wyg.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 17:54:42 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C5E5B68@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 4:24 PM, Rose, Gregory V
<gregory.v.rose@intel.com> wrote:
>> -----Original Message-----
>> From: Jesse Gross [mailto:jesse@nicira.com]
>> Sent: Monday, September 26, 2011 4:09 PM
>> To: Rose, Gregory V
>> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
>> gospo@redhat.com; Jiri Pirko
>> Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
>>
>> On Mon, Sep 26, 2011 at 8:57 AM, Rose, Gregory V
>> <gregory.v.rose@intel.com> wrote:
>> >> -----Original Message-----
>> >> From: Jesse Gross [mailto:jesse@nicira.com]
>> >> Sent: Saturday, September 24, 2011 9:33 AM
>> >> To: Kirsher, Jeffrey T
>> >> Cc: davem@davemloft.net; Rose, Gregory V; netdev@vger.kernel.org;
>> >> gospo@redhat.com; Jiri Pirko
>> >> Subject: Re: [net-next 02/10] ixgbevf: Fix broken trunk vlan
>> >>
>> >> What happens if you run tcpdump without configuring vlan devices?
>> >> Shouldn't you see tagged packets for the vlans that are being tru=
nked
>> >> to you? =C2=A0I think this will strip tags in that case. =C2=A0Th=
e apparent
>> >> behavior of vlan filters here is also surprising to me because on=
 one
>> >> hand if they're truly filtering this test shouldn't be needed and=
 on
>> >> the other hand they don't seem to be disabled in promiscuous mode=
=2E
>> >
>> > I think you're not quite understanding the action the HW is taking=
 here.
>> =C2=A0In the physical function driver we have put the VF on a VLAN w=
ithout it
>> knowing that it's on a VLAN. =C2=A0Once that is done by the PF, the =
VF is not
>> allowed to configure its own VLANs anymore. =C2=A0However, the descr=
iptor still
>> includes a bit for the VLAN tag indicating it was a packet that arri=
ved on
>> a VLAN. =C2=A0The HW is inserting and stripping the VLAN tag though =
without any
>> awareness of that by the VF driver.
>> >
>> > It's a security measure to allow an administrator to put a VF on a=
 VLAN
>> to provide another level of isolation for the VF.
>> >
>> > Intel VFs don't support promiscuous mode. =C2=A0If you ran tcpdump=
 you
>> wouldn't see the VLAN tags because they've been stripped by the HW. =
=C2=A0The
>> VF has no choice in this.
>>
>> I understand that VFs are limited in what they can do. =C2=A0What I'=
m
>> concerned about are differences in how the driver behaves when a vla=
n
>> device is configured on it vs. not. =C2=A0There are two cases that I=
 think
>> you will see different behavior:
>>
>> * The VF driver has it's own vlan filters. =C2=A0I'm assuming (corre=
ct me
>> if I'm wrong) that this will further restrict the vlans that the gue=
st
>> sees from the set that have been configured on the PF driver. =C2=A0=
If that
>> is correct, then putting the VF interface in promiscuous mode should
>> disable the filters and allow packets from all vlans that the PF
>> allows. =C2=A0This situation is the same as if an upstream physical =
switch
>> is trunking only a subset of vlans to an end host and the NIC is put
>> in promiscuous mode. =C2=A0However, it doesn't look like the VF driv=
er does
>> anything in response to being in promiscuous mode. =C2=A0This should=
n't
>> require any hardware support because it is just clearing the filter
>> table.
>
> The VF does not have its own VLAN filters. =C2=A0It must request them=
 through the PF via the mailbox messaging feature in the NIC. =C2=A0Whe=
n the PF puts the VF in trunk VLAN mode via the 'ip link set <dev> vf <=
n> vlan <vlanid>' command then the PF also flags that VF and will not t=
ake VLAN filter requests from it. =C2=A0In effect, the VF is forced to =
a VLAN and has no choice. =C2=A0So it cannot further restrict what VLAN=
s the guest sees. =C2=A0And the VF can only be on a single trunk VLAN, =
it does not support multiple trunk VLANs.
>
> And again, the VF doesn=E2=80=99t support promiscuous mode. =C2=A0The=
 VF device HW doesn't have that feature.
>
>> * It looks like the VF driver is receiving not just an indication th=
at
>> a tag was present but the actual tag and although it was already
>> stripped by the NIC it can be passed up to the network stack just as
>> if it was stripped in a non-SR-IOV NIC. =C2=A0After this patch, if y=
ou run
>> tcpdump on the VF interface you will see packets with tags if a vlan
>> device is configured but packets without tags if there is no vlan
>> device.
>>
>
> No. =C2=A0In trunk VLAN mode the receive descriptor provided by the H=
W has a VLAN tag present bit and that is set but unless someone has use=
d vconfig to configure a VLAN and a bit is set for that VLAN in the act=
ive_vlans bit table then the packet is sent up the stack without the ta=
g. =C2=A0Upper layers don't have access to the driver's internal descri=
ptor rings and have no idea that the VLAN tag present bit was set in th=
e descriptor. =C2=A0Upper layer SW in the network stack won't be lookin=
g for VLAN tags since it never requested any VLANs. =C2=A0And since the=
 VLAN tag was stripped, and the upper layers haven't ever set a VLAN fi=
lter, then there is no expectation of a VLAN tag.
>
>> Does the VF know whether it is assigned to a particular vlan or is
>> allowed to send/receive tagged packets (essentially the difference
>> between an access port or a trunk port)?
>
> Yes, it knows if it has requested a VLAN filter via the active_vlans =
bit table. =C2=A0If no VLANs are set in the active_vlans table then it =
knows to ignore the VLAN tag present bit set in the descriptor since it=
 must be in trunk VLAN mode.
>
>> =C2=A0Or is that why the presence
>> of vlan device is used as an indication?
>
> Correct, that is the case.

OK, maybe due to hardware limitations what I'm looking for just really
isn't possible.  However, what I'm trying to emphasize is that vconfig
is not the only way that vlans can be consumed by the network stack
and active_vlans is just an indication of whether a vlan filter was
set, nothing more (perhaps I should have picked a better name when I
originally designed this stuff).  In particular, it is not intended to
determine whether a tag should be stripped off or not because
non-vconfig users don't necessarily know which vlans they care about
(think tcpdump or trunking over a bridge).  A major goal of the
existing vlan infrastructure is to avoid having drivers make
assumptions about the consumer of the tag and instead just hand all
information over to the network stack so it can behave in a consistent
manner.  That's why I was looking for alternate ways to get this
information without depending on active_vlans as this driver behaves
quite a bit differently from others, include the ixgbe PF driver.
