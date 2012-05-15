From: Marcelo Leitner <mleitner@redhat.com>
Subject: Re: Question about be2net error field, rx_drops_no_pbuf
Date: Tue, 15 May 2012 09:45:00 -0300
Message-ID: <4FB24FCC.7000206@redhat.com>
References: <4FB17863.5020908@redhat.com> <3367B80B08154D42A3B2BC708B5D41F64580B0D945@EXMAIL.ad.emulex.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932598Ab2EOMpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 08:45:12 -0400
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F64580B0D945@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2012 01:28 AM, Sathya.Perla@Emulex.Com wrote:
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of Marcelo Leitner
>
>> What does 'rx_drops_no_pbuf' mean at be2net driver? I can see it is a
>> hardware counter for some type of error, which I would like to know
>> about. What causes it?
>>
>> All documentation I could find about it is a comment referring firmware
>> specification
>
> Brief descriptions of the counters are in be_ethtool.c:
> /* Received packets dropped due to lack of available HW packet buffers
>    * used to temporarily hold the received packets.
>    */
> {DRVSTAT_INFO(rx_drops_no_pbuf)}
>
> pbufs are HW buffers for parking incoming pkts before they are transferred to the host.
> You can see this counter go up when the transfer speed of the slot is not fast enough.
> lspci -vv?

Oh! My bad, sorry.

NIC is using MTU 9000 bytes. We were seeing a lot of rx_drops_no_frags, 
then we boosted rx_frag_size to 8192 and it solved all problems for this 
counter. Then rx_drops_no_pbuf started happening, but in much lower 
scale: ~14 counter hits for 22TiB RX traffic. It's the only error 
counter that is different from 0.

Only one port is up.

 From be_ethtool.c:
     /* Received packets dropped due to lack of available fetched buffers
      * posted by the driver.
      */
     {DRVSTAT_RX_INFO(rx_drops_no_frags)}

So both counters are related, but handling different error points, 
right? I was thinking about lowering rx-usecs-high (from 96usec to ~80) 
to make refilling more frequent. What do you think?

This is a RHEL 5.8 host, btw. lspci -nvv for the port in use:

Thanks!
Marcelo.

0b:00.1 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC (rev 02)
0b:00.1 0200: 19a2:0700 (rev 02)
         Subsystem: 103c:1747
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr+ Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin B routed to IRQ 59
         Region 1: Memory at d0308000 (32-bit, non-prefetchable) [size=16K]
         Region 2: Memory at d03a0000 (64-bit, non-prefetchable) [size=128K]
         Region 4: Memory at d03e0000 (64-bit, non-prefetchable) [size=128K]
         [virtual] Expansion ROM at e0a80000 [disabled] [size=512K]
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=375mA 
PME(D0-,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [48] MSI-X: Enable+ Count=32 Masked-
                 Vector table: BAR=1 offset=00002000
                 PBA: BAR=1 offset=00003000
         Capabilities: [c0] Express (v2) Endpoint, MSI 00
                 DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s 
<1us, L1 <16us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ 
Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- 
FLReset-
                         MaxPayload 256 bytes, MaxReadReq 4096 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr+ UnsuppReq+ 
AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s, 
Latency L0 <1us, L1 <16us
                         ClockPM- Surprise- LLActRep- BwNot-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- 
CommClk-
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
                 DevCap2: Completion Timeout: Not Supported, TimeoutDis-
                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- 
SpeedDis-, Selectable De-emphasis: -6dB
                          Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
                          Compliance De-emphasis: -6dB
                 LnkSta2: Current De-emphasis Level: -6dB
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UESvrt: DLP+ SDES+ TLP+ FCP+ CmpltTO+ CmpltAbrt+ 
UnxCmplt+ RxOF+ MalfTLP+ ECRC- UnsupReq+ ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP+ BadDLLP+ Rollover+ Timeout+ 
NonFatalErr+
                 AERCap: First Error Pointer: 00, GenCap+ CGenEn- 
ChkCap+ ChkEn-
         Capabilities: [194 v1] Device Serial Number XXXXXXXX
         Kernel driver in use: be2net
         Kernel modules: be2net
