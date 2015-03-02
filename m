From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [E1000-devel] Sporadic packet loss observed with newer in-kernel
 drivers (5.2.15-k)
Date: Mon, 02 Mar 2015 16:28:40 +0800
Message-ID: <54F41F38.1060505@numascale.com>
References: <906FBB8A-98FE-4879-99C5-98EDA7BCB3CD@numascale.com> <9B4A1B1917080E46B64F07F2989DADD653478AB3@ORSMSX114.amr.corp.intel.com> <3F039C86-94C5-42AE-A939-B4A155495216@numascale.com> <9B4A1B1917080E46B64F07F2989DADD653479BB4@ORSMSX114.amr.corp.intel.com> <C59DCFE4-0C0B-4371-B4C5-B2AC43519DE1@numascale.com> <9B4A1B1917080E46B64F07F2989DADD65347CC59@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Persvold <sp@numascale.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>, netdev@vger.kernel.org
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from numascale.com ([213.162.240.84]:35047 "EHLO numascale.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbbCBJKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 04:10:20 -0500
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD65347CC59@ORSMSX114.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Todd,

=46ollowing up on this, since the packet loss doesn't occur when using =
the=20
out-of-tree driver but does when using the mainline driver, it's more=20
plausible that there's a driver behavioural difference causing this.

After instrumenting MDI activity, a bunch of differences come from=20
force_speed_duplex() being called when the hardware is first=20
initialised, wherein hw->mac.autoneg is 0 only with the mainline driver=
=20
along this path:

igb_setup_copper_link+0x2a5/0x2c0
igb_copper_link_setup_igp+0xb7/0x210
igb_setup_copper_link_82575+0xd4/0x180
igb_setup_link+0x36/0x1c0
igb_init_hw_82575+0xba/0x330
igb_reset+0x15f/0x5e0
igb_sriov_reinit+0x88/0xc0
igb_pci_enable_sriov+0x115/0x200
igb_probe+0x4ae/0x11a0
local_pci_probe+0x40/0xa0

The same 6 setup_copper_link() calls occur (three per on-board adapter)=
=20
in the out-of-tree driver, however hw->mac.autoneg is always set; this=20
also fits with our findings that triggering autoneg prevent the packet =
loss.

What's the expectation with value of hw->mac.autoneg?

Many thanks!
   Daniel

On 30/12/2014 00:41, Fujinaka, Todd wrote:
> This could be a BIOS issue as well. If you can't track this down to a=
 specific software bug, you'll have to file the issue with Supermicro a=
nd they'll contact us if they need our help.
>
> Todd Fujinaka
> Software Application Engineer
> Networking Division (ND)
> Intel Corporation
> todd.fujinaka@intel.com
> (503) 712-4565
>
> -----Original Message-----
> From: Steffen Persvold [mailto:sp@numascale.com]
> Sent: Friday, December 26, 2014 11:14 AM
> To: Fujinaka, Todd
> Cc: e1000-devel@lists.sourceforge.net; Daniel J Blueman
> Subject: Re: [E1000-devel] Sporadic packet loss observed with newer i=
n-kernel drivers (5.2.15-k)
>
> Hi Todd,
>
> I don=E2=80=99t think it=E2=80=99s related to queues/settings in the =
OS per se. These machines use shared-mode PHY for BMC (IPMI) access als=
o, and when we get packet loss in the OS driver, we also see packet los=
s on the BMC side.
>
> What we=E2=80=99ve discovered is that if we do =E2=80=9Cethtool -s et=
h0 autoneg on=E2=80=9D it fixes the issue on both sides, however prior =
to doing this autonegotiation *is* enabled in the NIC, it just seems th=
e =E2=80=9Cautoneg on=E2=80=9D operation restarts something in the PHY.
>
> Weird.
>
> Cheers,
> --
> Steffen Persvold
> Chief Architect NumaChip, Numascale AS
> Tel: +47 23 16 71 88  Fax: +47 23 16 71 80 Skype: spersvold
>
>> On 19 Dec 2014, at 18:17, Fujinaka, Todd <todd.fujinaka@intel.com> w=
rote:
>>
>> Before you start, though, do the check for settings and number of qu=
eues being used. The issue may be as simple as that, and that shouldn't=
 take more than a few ethtool commands.
>>
>> Todd Fujinaka
>> Software Application Engineer
>> Networking Division (ND)
>> Intel Corporation
>> todd.fujinaka@intel.com
>> (503) 712-4565
>>
>> -----Original Message-----
>> From: Steffen Persvold [mailto:sp@numascale.com]
>> Sent: Friday, December 19, 2014 9:14 AM
>> To: Fujinaka, Todd
>> Cc: e1000-devel@lists.sourceforge.net; Daniel J Blueman
>> Subject: Re: [E1000-devel] Sporadic packet loss observed with newer
>> in-kernel drivers (5.2.15-k)
>>
>> Hi Todd,
>>
>> Thanks for responding so quickly. It=E2=80=99s probably easier to bi=
sect the changes to igb between the 3.10 kernel in-tree version (5.0.3-=
k) and the 3.14 kernel in-tree version (5.0.5-k), rather than diffing o=
n out-of-tree 5.2.15 and in-kernel 5.2.15-k (I tried, the changes are h=
uge, mostly because out-of-tree code has a lot of compatibility stuff i=
n it naturally).
>>
>> I=E2=80=99ll let you know.
>>
>>
>> Cheers,
>> --
>> Steffen Persvold
>> Chief Architect NumaChip, Numascale AS
>> Tel: +47 23 16 71 88  Fax: +47 23 16 71 80 Skype: spersvold
>>
>>> On 19 Dec 2014, at 17:23, Fujinaka, Todd <todd.fujinaka@intel.com> =
wrote:
>>>
>>> The in-kernel and out-of-tree driver aren't exactly the same and th=
ere could be differences enforced by the community that create that dif=
ference. For example - and I'm just making this up - there could be a d=
ifference in the dropping or passing of packets with bad checksums.
>>>
>>> More likely are differences in the default settings of the two driv=
ers. You may want to check that first.
>>>
>>> If you have a clearly reproducible use case, we can try looking int=
o this, but we are a bit limited in the number of Opteron systems we ha=
ve in-house.
>>>
>>> Todd Fujinaka
>>> Software Application Engineer
>>> Networking Division (ND)
>>> Intel Corporation
>>> todd.fujinaka@intel.com
>>> (503) 712-4565
>>>
>>> -----Original Message-----
>>> From: Steffen Persvold [mailto:sp@numascale.com]
>>> Sent: Thursday, December 18, 2014 10:36 PM
>>> To: e1000-devel@lists.sourceforge.net
>>> Cc: Daniel J Blueman
>>> Subject: [E1000-devel] Sporadic packet loss observed with newer
>>> in-kernel drivers (5.2.15-k)
>>>
>>> Hi,
>>>
>>> We=E2=80=99re currently working with a cluster of SuperMicro H8QGL =
(http://www.supermicro.com/Aplus/motherboard/Opteron6000/SR56x0/H8QGL-i=
=46.cfm) based systems which has two of the 82576 chips :
>>>
>>> 02:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Networ=
k
>>> Connection (rev 01)
>>> 02:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Networ=
k
>>> Connection (rev 01)
>>>
>>>
>>> Consequently the kernel use the igb network driver for this.
>>>
>>> We have observed with kernels 3.14 and onwards that we sometimes ge=
t packet-loss (due to corrupted packets). 3.14 uses igb version 5.0.5-k=
 :
>>>
>>> [    0.000000] Linux version 3.14.27-numascale27+ (sp@build-ubuntu)=
 (gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1) ) #2 SMP Thu Dec 18 08:00:=
08 CET 2014
>>> ...
>>> [    6.338430] igb: Intel(R) Gigabit Ethernet Network Driver - vers=
ion 5.0.5-k
>>> [    6.345394] igb: Copyright (c) 2007-2013 Intel Corporation.
>>>
>>>
>>> If we revert back to 3.10 kernels (3.10.63), which uses the 5.0.3-k=
 igb driver we have no packet loss scenarios :
>>>
>>> [    0.000000] Linux version 3.10.63-numascale27+ (sp@build-ubuntu)=
 (gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1) ) #1 SMP Wed Dec 17 15:56:=
25 CET 2014
>>> ...
>>> [    6.749783] igb: Intel(R) Gigabit Ethernet Network Driver - vers=
ion 5.0.3-k
>>> [    6.756740] igb: Copyright (c) 2007-2013 Intel Corporation.
>>>
>>>
>>> I have also tested the most recent kernel; 3.18.1 :
>>>
>>> [    0.000000] Linux version 3.18.1-numascale27+ (sp@build-ubuntu) =
(gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1) ) #1 SMP Thu Dec 18 08:36:0=
3 CET 2014
>>> ...
>>> [    8.010000] igb: Intel(R) Gigabit Ethernet Network Driver - vers=
ion 5.2.15-k
>>> [    8.010000] igb: Copyright (c) 2007-2014 Intel Corporation.
>>>
>>> Also in this version we observe packet loss/corrupted packets.
>>>
>>> While in the failed state we observe with ethtool -S (snapshot take=
n on 3.14 with igb-5.0.5-k) :
>>>
>>>     rx_short_length_errors: 235
>>>     rx_errors: 235
>>>     rx_length_errors: 235
>>>     rx_queue_6_csum_err: 256
>>>
>>>
>>> Now to the interesting part :) If I download igb-5.2.15.tar.gz from=
 the sourceforge site (http://sourceforge.net/projects/e1000/files/igb%=
20stable/5.2.15/igb-5.2.15.tar.gz/download), and build this for 3.18.1,=
 the packet loss is gone. Which doesn=E2=80=99t make sense at all since=
 3.18.1 already has 5.2.15 driver (albeit an in-kernel variant). This a=
lso applies if we apply the same driver version to the 3.14 kernel (rep=
lacing 5.0.5-k).
>>>
>>>
>>> Any idea what might be causing this ? Any insight you might have wo=
uld be highly appreciated.
--=20
Daniel J Blueman
Principal Software Engineer, Numascale
