From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6 37/47] igb: do vlan cleanup
Date: Thu, 21 Jul 2011 14:45:13 -0700
Message-ID: <CAEP_g=-Gd0fPObLGWKTdFQLG0epiaDMMvsDZjkSMfQ-hQ-a7iw@mail.gmail.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-38-git-send-email-jpirko@redhat.com> <CAEP_g=_0Ej09+KYbvEJz1+joYtms+S_67XSVVPMoG_hfJnmrBQ@mail.gmail.com>
 <20110720191045.GD2688@minipsycho.redhat.com> <CAEP_g=9j3=s74_VQ6RQxVRGOOs-mVR94s31ETXJ1S5P7aQV4iQ@mail.gmail.com>
 <20110721065721.GA2199@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, eric.dumazet@gmail.com,
	greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49288 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab1GUVpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 17:45:33 -0400
Received: by gxk21 with SMTP id 21so863857gxk.19
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 14:45:33 -0700 (PDT)
In-Reply-To: <20110721065721.GA2199@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 11:57 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Thu, Jul 21, 2011 at 01:58:10AM CEST, jesse@nicira.com wrote:
>>On Wed, Jul 20, 2011 at 12:10 PM, Jiri Pirko <jpirko@redhat.com> wrot=
e:
>>> Wed, Jul 20, 2011 at 07:35:33PM CEST, jesse@nicira.com wrote:
>>>>On Wed, Jul 20, 2011 at 7:54 AM, Jiri Pirko <jpirko@redhat.com> wro=
te:
>>>>> @@ -2943,7 +2944,7 @@ static void igb_rlpml_set(struct igb_adapte=
r *adapter)
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct e1000_hw *hw =3D &adapter->hw;
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 pf_id =3D adapter->vfs_allocated_c=
ount;
>>>>>
>>>>> - =C2=A0 =C2=A0 =C2=A0 if (adapter->vlgrp)
>>>>> + =C2=A0 =C2=A0 =C2=A0 if (igb_vlan_used(adapter))
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0max_frame_=
size +=3D VLAN_TAG_SIZE;
>>>>
>>>>There are similar issues here as with the VF driver. =C2=A0I think =
you're
>>>>also confusing vlan acceleration with vlan filtering. =C2=A0If no v=
lan
>>>>filters are in use but the card is in promiscuous mode, the buffer
>>>>will be undersized and we lose tagged packets.
>>>
>>> I'm certainly not confusing vlan accel and filtering. Here is the
>>> intension is the behaviour remains intact as well. I believe it's t=
rue.
>>
>>I believe the underlying issue for all three of these threads is the
>>same, so I'll just respond to them all here.
>>
>>I agree that this doesn't change the behavior of the driver but I
>>don't think that should be the goal. =C2=A0When I originally designed=
 this
>>new vlan model my intention was to eliminate a whole class of driver
>>bugs that I was repeatedly hitting in various forms. =C2=A0In the exa=
mple
>>above, if you run tcpdump on this device without configuring a vlan
>>group on it then you will see that MTU sized packets are missing
>>because the receive buffer was undersized.
>>
>>The common theme for these problems is that they all occur in
>>situations where vlans are not configured on the device and the drive=
r
>>does something different as a result of this. =C2=A0The solution was =
to
>>prevent drivers from changing their behavior in such situations by
>>completely removing the concept of a vlan group from them and letting
>>the networking core tell them when to make the changes instead of
>>doing it implicitly. =C2=A0That's why I don't see the fact that this =
change
>>essentially emulates the knowledge of configuring a group to be a
>>plus. =C2=A0By the way, plenty of your other patches change the behav=
ior of
>>the drivers - on any of the NICs that always enable stripping, try
>>running tcpdump on the interface without configuring a vlan group.
>>Before the change you will see that tags have disappeared and
>>afterwards the tags are intact. =C2=A0So I think that changing the be=
havior
>>of drivers in this regard is a positive thing.
>>
>>As an aside, thank you for taking the time to work on all of these
>>drivers. =C2=A0The only reason why I'm complaining about these few dr=
ivers
>>is because I'd like to close the door on this class of problems, whic=
h
>>is finally in reach thanks to your work.
>
>
> Okay now it's clear to me. I tried to stay with the code as much simi=
lar
> as unpatched. But I see your arguments. I will review and repost
> patches which are enabling/disabling vlan accel on add_vid/kill_vid a=
nd
> convert it to set_features.
>
> Thanks. Jesse.

All the new changes look good to me, thanks Jiri.
