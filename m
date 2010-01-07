From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 07 Jan 2010 00:10:24 -0500
Message-ID: <4B456CC0.1000506@majjas.com>
References: <20100105230746.GA6612@del.dom.local> <4B43F72C.9090004@majjas.com>
 <20100106072208.GA6711@ff.dom.local> <4B44E952.5000804@majjas.com>
 <20100106131044.25b4e500@nehalam> <4B451C31.3000309@majjas.com>
 <4B454A16.3030909@majjas.com> <4B455C62.6030504@majjas.com>
 <20100106205343.5460d658@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751775Ab0AGFLM@vger.kernel.org>
In-reply-to: <20100106205343.5460d658@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/6/2010 11:53 PM, Stephen Hemminger wrote:
> On Wed, 06 Jan 2010 23:00:34 -0500
> Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>> Changing MTU to 9000, everything basically breaks - Can't use X11 (local
>> or remote - get X11 screen after gdm login locally, but then goes back
>> to greeter; remote gets no greeter); ssh sessions hang; etc. This time I
>> was able to reset the MTU back to 1500 without a reboot - but I did have
>> to ifconfig eth0 down and then up. Looking at the sk98lin code, it looks
>> to me like they do a bit more work with existing buffers before
>> completing the MTU switch. Note that even doing this, X11 did not work
>> (it did with the old mtu change code). Tried changing to mtu 4500 - same
>> effect as 9000... but when I switched back to 1500, ksoftirqd started
>> spinning using 100% of one core.
>>      
> The problem is that patch was enabling scatter-gather and checksum offload
> that won't work on EC_U hardware with 9K MTU.  At least, it never worked
> for me when I tested it. So because of that it really doesn't change anything
> for the better on that chip version.
>
> What version chip is on that motherboard?  Mine is:
>   Yukon-2 EC Ultra chip revision 3
> which corresponds to B0 step.
>
> Another possibility is the PHY register which controls number of ticks
> of buffering.  The default is zero, which gives the most buffering (good),
> but the firmware could be reprogramming it (bad).  In general, the driver
> doesn't fiddle with bits that are already set correctly, because sometimes
> vendors need to tweak PCI timing in firmware/BIOS.  It seems the firmware on this
> chip is just a bunch of register setups done on power on.
>    
So at this point, things are working as mentioned - but really slow... 
at least an order of magnitude slower than with the other set of 
patches. The other set also generated errors and was not stable :( But, 
that set worked with mtu=9000, this set doesn't seem to work with 
anything over 1500. The slowdown may also be (based on earlier testing) 
attributable to Jarek's alternative #2 patch.  As to the chip, I *think* 
we have the same chip - I'm including lspci -vv - perhaps there is 
something different.

06:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E 
Gigabit Ethernet Controller (rev 14)
         Subsystem: Giga-byte Technology Device e000
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 256 bytes
         Interrupt: pin A routed to IRQ 58
         Region 0: Memory at fbdfc000 (64-bit, non-prefetchable) [size=16K]
         Region 2: I/O ports at d800 [size=256]
         Expansion ROM at fbdc0000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 3
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data
                 Product Name: Marvell Yukon 88E8056 Gigabit Ethernet 
Controller
                 Read-only fields:
                         [PN] Part number: Yukon 88E8056
                         [EC] Engineering changes: Rev. 1.4
                         [MN] Manufacture ID: 4d 61 72 76 65 6c 6c
                         [SN] Serial number: AbCdEfG001C3B
                         [CP] Extended capability: 01 10 cc 03
                         [RV] Reserved: checksum good, 9 byte(s) reserved
                 Read/write fields:
                         [RW] Read-write area: 121 byte(s) free
                 End
         Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
                 Address: 00000000fee00458  Data: 0000
         Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
unlimited, L1 unlimited
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ 
AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, 
Latency L0 <256ns, L1 unlimited
                         ClockPM+ Surprise- LLActRep- BwNot-
                 LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain- 
CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr+
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr+
                 AERCap: First Error Pointer: 1f, GenCap- CGenEn- 
ChkCap- ChkEn-
         Kernel driver in use: sky2
         Kernel modules: sky2
