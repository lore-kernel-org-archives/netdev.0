From: Ceriel Jacobs <linux-ide@crashplan.pro>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware: does the patch below against current kernel make a difference?
 Yes, it does
Date: Fri, 10 Oct 2014 13:09:40 +0200
Message-ID: <5437BE74.2010301@crashplan.pro>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com> <54359E9C.7060704@crashplan.pro> <20141008221726.GA25515@electric-eye.fr.zoreil.com> <5435BEC3.6080200@crashplan.pro> <20141008232655.GA26561@electric-eye.fr.zoreil.com> <54367965.7010301@crashplan.pro> <20141009221458.GA20126@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:51123 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaJJLJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 07:09:46 -0400
In-Reply-To: <20141009221458.GA20126@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ASPM is enabled in the BIOS as far as possible.
ASPM is also enabled using kernel parameters:
1. pcie_aspm.policy=powersave
2. pcie_aspm=force

Despite the result for 03:00.0 (and 2 other PCIe devices) is:
LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+


I have filed a bug report for that at:
https://bugzilla.kernel.org/show_bug.cgi?id=85621


In my testing before, I did manually enable L0s L1 ASPM after login 
prompt using:
# setpci -s 03:00.0 0x80.B=0x43 (also for 3 other ASPM PCIe devices)

=============================
Now back to your Realtek test request
=============================
For your information: I am running all testing remote via SSH over the 
Realtek NIc.

=======
L0s and L1 = PC6
=======
# setpci -s 03:00.0 0x80.B=0x43
# lspci -vvvv -s 03:00.0 | grep LnkCtl:
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- ...

PC6 reached in 1 powertop screen update (5 second interval)
C3 (pc3)   21.0%    | C3 (cc3)    0.0%    | C3-HSW      0.0%    0.0 ms
C6 (pc6)   76.0%    | C6 (cc6)   99.9%    | C6-HSW     99.9%  198.1 ms

=======
L1 only = no PC6
=======
# setpci -s 03:00.0 0x80.B=0x42
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+

C3 (pc3)   99.8%    | C3 (cc3)    0.0%    | C3-HSW      0.0%    0.0 ms
C6 (pc6)    0.0%    | C6 (cc6)   99.9%    | C6-HSW    100.0%  206.4 ms

=======
L0s only = PC6 !!
=======
# setpci -s 03:00.0 0x80.B=0x41
		LnkCtl:	ASPM L0s Enabled; RCB 64 bytes Disabled- ...

C3 (pc3)   10.6%    | C3 (cc3)    0.0%    | C3-HSW      0.0%    0.0 ms
C6 (pc6)   89.1%    | C6 (cc6)   99.9%    | C6-HSW     99.9%  210.7 ms

=======
Disabled = no PC6
=======
# setpci -s 03:00.0 0x80.B=0x40
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+

C3 (pc3)   99.8%    | C3 (cc3)    0.0%    | C3-HSW      0.0%    0.0 ms
C6 (pc6)    0.0%    | C6 (cc6)   99.9%    | C6-HSW     99.9%  230.1 ms

Now I am wondering whether it is by design or a bug that PC6 is not 
reached when only L1 ASPM is activated

An applause for:
1. saving "polar bears",
2. letting me test a little more,
3. realtime behavior changing (no module unloading and loading to active 
ASPM, just set the config space registers).

Francois Romieu schreef op 10-10-14 om 00:14:
> Ceriel Jacobs <linux-ide@crashplan.pro> :
>> Francois Romieu schreef op 07-10-14 om 00:13:
>>> Ceriel, does the patch below against current kernel make a difference?
> [...]
>> New r8169 "powertop" result (even without --auto-tune):
>> C2 (pc2)    0.0%    |                     |
>> C3 (pc3)    9.9%    | C3 (cc3)    0.7%    | C3-HSW      0.7%   16.4 ms
>> C6 (pc6)   89.9%    | C6 (cc6)   99.2%    | C6-HSW     99.2%  223.2 ms
>> ---
>
> Fine (almost: I hope that ASPM was enabled from bios or during boot
> behind your back).
>
> Remember your "lspci -nnkvv -s 03:00.0" ?
>
> 03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168] (rev 11)
> [...]
>          Capabilities: [70] Express (v2) Endpoint, MSI 01
>                  DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
>                          ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>                  DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                          RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                          MaxPayload 128 bytes, MaxReadReq 4096 bytes
>                  DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
>                  LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s unlimited, L1 <64us
>                     	ClockPM+ Surprise- LLActRep- BwNot-
>                  LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
>                          ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>
> It should now look like:
> [...]
>                  LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+
>
> Let's temporarily disable it and see if powertop notices a difference.
>
> <full disclosure>
>
> "Capabilities: [70]" above gives you the offset of the relevant registers:
> # lspci -xxx -s 03:00.0
> [...]
> 70: .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. ..
> ^^ -> "[70]"
>
> You are interested in the Link Control register, aka PCI_EXP_LNKCTL in
> /usr/include/pci/header.h (devel part of pciutils) or kernel's
> include/uapi/linux/pci_regs.h. It's 16 bytes further, thus
> [...]
> 70: .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. ..
> 80: 42 .. .. .. .. .. .. .. .. .. .. .. .. .. .. ..
>      ^^
>
> 0x42 matches "LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch-" built from above. There may be differences but the 3 lower
> weight binary digits in 0x42 encode ASPM control (0=nada, 1=L0, 2=L1,
> see PCI_EXP_LNKCTL_ASPxyz in include/uapi/linux/pci_regs.h). Mask these
> out (0x42 & ~0x03) and feed the resulting value back into the Link
> Control register:
>
> # setpci -s 03:00.0 CAP_EXP+10.b=0x40
>
> (CAP_EXP is pciutils's alias for the PCI Express capability block, see
> PCI_CAP_ID_EXP in kernel's include/uapi/linux/pci_regs.h)
>
> If you are not too sure about the 0x40 value, you can retrieve it with
> lspci and an unpatched r8169 driver.
>
> </full disclosure>
>
> If I have understood Hayes correctly and he got my question right, lspci
> should now tell that ASPM is disabled. C6 should not be reached anymore.
>
> ASPM could thus be enabled unconditionally at the driver level, then
> controled through the PCI config registers. Kernel r8169 driver would
> thus protect polar bears as Realtek's own r8168 driver already does.
>
> I can't exclude that it will fail miserably in a firework of smelly
> smoke though.
>
