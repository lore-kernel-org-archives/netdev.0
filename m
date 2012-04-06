From: Chris Boot <bootc@bootc.net>
Subject: Re: e1000e interface hang on 82574L
Date: Fri, 6 Apr 2012 14:48:39 +0100
Message-ID: <C0519712-0BDA-4C3F-9892-E8BE950370C8@bootc.net>
References: <9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com>
	<4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net>
	<4F64CFCB.7060702@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
	<87r4wova0b.fsf@spindle.srvr.nix>
	<9BBC4E0CF881AA4299206E2E1412B6260E512FB9@ORSMSX102.amr.corp.intel.com>
	<87ehsov6ot.fsf@spindle.srvr.nix>
	<1590F833-7D40-42FE-8FA2-6DCCADF9C6B0@bootc.net>
	<CAErSpo4TJ-9NsD5QTpFi9fsnD9qHt7+Tr5jJHQPuS7vg6ghq_w@mail.gmail.com>
	<20120406134144.GA22526@khazad-dum.debian.net>
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1444\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, Nix <nix@esperi.org.uk>,
	linux-pci@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Matthew Garrett <mjg@redhat.com>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120406134144.GA22526@khazad-dum.debian.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 6 Apr 2012, at 14:41, Henrique de Moraes Holschuh <hmh@hmh.eng.br> wrote:

> On Fri, 06 Apr 2012, Bjorn Helgaas wrote:
>> On Fri, Apr 6, 2012 at 4:17 AM, Chris Boot <bootc@bootc.net> wrote:
>>> On 19 Mar 2012, at 17:31, Nix wrote:
>>> 
>>>> On 19 Mar 2012, Carolyn Wyborny said:
>>>> 
>>>>>> you'll see that I tested that, and it doesn't work :( even if it
>>>>>> did work, it shouldn't be needed: the driver attempts to turn off
>>>>>> PCIe ASPM on affected NICs, and fails, apparently because
>>>>>> *something* turns it back on again.
>>>>>> 
>>>>> The driver attempts to disable L0s state, not the entire feature.
>>>>> It
>>>> 
>>>> It tries to disable L1 state as well (or it did when I tested this
>>>> last, although I suspect you're right and it may leave L1 turned on
>>>> these days: judging by the contents of e1000_82574_info, anyway.)
>>>> 
>>>>> is also required that the device upstream on the bus from the
>>>>> 82574L have this disabled. Yes, I agree there appears to be
>>>>> something in the os that either ren-enables or fails to disable
>>>>> the feature on the upstream device, as desired. Platforms/systems
>>>>> also appear to vary in this regard, so the solutions may vary a
>>>>> bit as well.
>>>>> 
>>>>> Its worth trying your solution as well if what I suggested doesn't
>>>>> work, but there is not one solution that fits all, unfortunately.
>>>> 
>>>> I don't *have* a solution. :( 'setpci by hand some unknown amount
>>>> of time after booting once the interface has stabilized' hardly
>>>> counts as a solution of any sort. It's, at best, a workaround that
>>>> lets me use my systems without hourly lockups until a real solution
>>>> is found.
>>>> 
>>>> (To clarify: manual setpci to force off the ASPM bits is the only
>>>> thing that works for me. The driver's automatic disabling of L0s
>>>> and L1 doesn't work: nor does booting with pcie_aspm=off. In both
>>>> cases, I end up with both L0s and L1 turned on, and a lockup some
>>>> time later, unless I setpci the bits off by hand.)
>>> 
>>> 
>>> Well, with that setpci incantation run against the NIC and its
>>> upstream device to disable ASPM L1s (setpci -s <dev>
>>> CAP_EXP+10.b=40), everything has been working very well indeed. Is
>>> there something the e1000e driver could do to disable L1s as well as
>>> L0s if we know there's a problem with them for these devices?
>>> 
>>> Adding Bjorn Helgaas and linux-pci to CCs to try to get the ball
>>> rolling some more, as this is crippling without the fixes.
>> 
>> [+cc Matthew Garrett for ASPM stuff]
>> 
>> If I understand correctly, e1000e attempts to disable ASPM to work
>> around an 82574L hardware erratum, but the PCI core either doesn't
>> disable ASPM or it gets re-enabled somehow.
> 
> You probably need to disable it upstream of the 82574L as well.  Here
> (SuperMicro C7X58) I managed to get it to be stable by telling the BIOS
> to disable L0s and L1 system-wide.
> 
> But not all BIOSes will have that option...


This is not something I can really do as ASPM makes a real difference to power consumption across the system, and I have a strict power budget to adhere to (else I will be charged more to host my servers). Disabling it for the NIC and upstream device is enough to make it stable, and doesn't increase power consumption by enough to matter.

The driver seems to disable ASPM L0s just fine, but L1s are not disabled on the NIC nor are they on the upstream device. If e1000e can't do it maybe we can do so using a PCI quirk or something?

Cheers,
Chris

-- 
Chris Boot
bootc@bootc.net


------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
