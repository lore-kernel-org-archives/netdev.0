From: "Baicar, Tyler" <tbaicar@codeaurora.org>
Subject: Re: [Intel-wired-lan] [PATCH v2] e1000e: free IRQ regardless of
 __E1000_DOWN
Date: Tue, 15 Nov 2016 14:50:04 -0700
Message-ID: <c182b3a5-3765-cb75-0540-411a1d662ad0@codeaurora.org>
References: <1478727681-16505-1-git-send-email-tbaicar@codeaurora.org>
 <42e53bc2-0361-e7b7-1093-4e095aa56955@intel.com>
 <dff136c7-cb6a-8a61-d311-01959bac16b9@codeaurora.org>
 <3914adae-91b2-7b74-02bc-579b3e32d143@intel.com>
 <70121f26-2d5a-528f-04f5-30a97b93a585@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Neftin, Sasha" <sasha.neftin@intel.com>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        okaya@codeaurora.org, timur@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <70121f26-2d5a-528f-04f5-30a97b93a585@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2016 2:25 AM, Neftin, Sasha wrote:
> On 11/13/2016 10:34 AM, Neftin, Sasha wrote:
>> On 11/11/2016 12:35 AM, Baicar, Tyler wrote:
>>> Hello Sasha,
>>>
>>> On 11/9/2016 11:19 PM, Neftin, Sasha wrote:
>>>> On 11/9/2016 11:41 PM, Tyler Baicar wrote:
>>>>> Move IRQ free code so that it will happen regardless of the
>>>>> __E1000_DOWN bit. Currently the e1000e driver only releases its IRQ
>>>>> if the __E1000_DOWN bit is cleared. This is not sufficient because
>>>>> it is possible for __E1000_DOWN to be set without releasing the IRQ.
>>>>> In such a situation, we will hit a kernel bug later in e1000_remove
>>>>> because the IRQ still has action since it was never freed. A
>>>>> secondary bus reset can cause this case to happen.
>>>>>
>>>>> Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
>>>>> ---
>>>>>    drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>>>>>    1 file changed, 2 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
>>>>> b/drivers/net/ethernet/intel/e1000e/netdev.c
>>>>> index 7017281..36cfcb0 100644
>>>>> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>>>>> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>>>>> @@ -4679,12 +4679,13 @@ int e1000e_close(struct net_device *netdev)
>>>>>          if (!test_bit(__E1000_DOWN, &adapter->state)) {
>>>>>            e1000e_down(adapter, true);
>>>>> -        e1000_free_irq(adapter);
>>>>>              /* Link status message must follow this format */
>>>>>            pr_info("%s NIC Link is Down\n", adapter->netdev->name);
>>>>>        }
>>>>>    +    e1000_free_irq(adapter);
>>>>> +
>>>>>        napi_disable(&adapter->napi);
>>>>>          e1000e_free_tx_resources(adapter->tx_ring);
>>>>>
>>>> I would like not recommend insert this change. This change related
>>>> driver state machine, we afraid from lot of synchronization problem and
>>>> issues.
>>>> We need keep e1000_free_irq in loop and check for 'test_bit' ready.
>>> What do you mean here? There is no loop. If __E1000_DOWN is set then we
>>> will never free the IRQ.
>>>
>>>> Another point, does before execute secondary bus reset your SW back up
>>>> pcie configuration space as properly?
>>> After a secondary bus reset, the link needs to recover and go back to a
>>> working state after 1 second.
>>>
>>>  From the callstack, the issue is happening while removing the endpoint
>>> from the system, before applying the secondary bus reset.
>>>
>>> The order of events is
>>> 1. remove the drivers
>>> 2. cause a secondary bus reset
>>> 3. wait 1 second
>> Actually, this is too much, usually link up in less than 100ms.You can
>> check Data Link Layer indication.
>>> 4. recover the link
>>>
>>> callstack:
>>> free_msi_irqs+0x6c/0x1a8
>>> pci_disable_msi+0xb0/0x148
>>> e1000e_reset_interrupt_capability+0x60/0x78
>>> e1000_remove+0xc8/0x180
>>> pci_device_remove+0x48/0x118
>>> __device_release_driver+0x80/0x108
>>> device_release_driver+0x2c/0x40
>>> pci_stop_bus_device+0xa0/0xb0
>>> pci_stop_bus_device+0x3c/0xb0
>>> pci_stop_root_bus+0x54/0x80
>>> acpi_pci_root_remove+0x28/0x64
>>> acpi_bus_trim+0x6c/0xa4
>>> acpi_device_hotplug+0x19c/0x3f4
>>> acpi_hotplug_work_fn+0x28/0x3c
>>> process_one_work+0x150/0x460
>>> worker_thread+0x50/0x4b8
>>> kthread+0xd4/0xe8
>>> ret_from_fork+0x10/0x50
>>>
>>> Thanks,
>>> Tyler
>>>
>> Hello Tyler,
>> Okay, we need consult more about this suggestion.
>> May I ask what is setup you run? Is there NIC or on board LAN? I would
>> like try reproduce this issue in our lab's too.
>> Also, is same issue observed with same scenario and others NIC's too?
>> Sasha
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@lists.osuosl.org
>> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
>>
> Please, specify what is device used.
Hello Sasha,
This was on a QDF2432 using an Intel PRO/1000 PT Dual Port server 
adapter. I have not tried
other e1000e PCIe cards, but have not seen any similar issues with 
Mellanox cards. I'm able to
reproduce it with just pulling the card out. Here is the lspci -vvv 
output for this card:

0004:00:00.0 PCI bridge: Airgo Networks, Inc. Device 0400 (prog-if 00 
[Normal decode])
         Physical Slot: 5
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin A routed to IRQ 297
         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
         I/O behind bridge: 00002000-00002fff
         Memory behind bridge: 00100000-002fffff
         Prefetchable memory behind bridge: 
00000c0400000000-00000c04001fffff
         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold-)
                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
                 Address: 00000000397f0040  Data: 0000
         Capabilities: [70] Express (v2) Root Port (Slot+), MSI 00
                 DevCap: MaxPayload 512 bytes, PhantFunc 0
                         ExtTag- RBE+
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ 
Unsupported+
                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 256 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- 
AuxPwr- TransPend-
                 LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1, 
Exit Latency L0s <1us, L1 <16us
                         ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp+
                 LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- CommClk-
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ 
DLActive+ BWMgmt- ABWMgmt-
                 SltCap: AttnBtn+ PwrCtrl+ MRL+ AttnInd+ PwrInd+ 
HotPlug+ Surprise+
                         Slot #5, PowerLimit 75.000W; Interlock+ NoCompl-
                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- 
HPIrq- LinkChg-
                         Control: AttnInd Off, PwrInd Off, Power- Interlock-
                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- 
PresDet- Interlock-
                         Changed: MRL- PresDet- LinkState-
                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- 
PMEIntEna+ CRSVisible-
                 RootCap: CRSVisible-
                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                 DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, 
LTR+, OBFF Not Supported ARIFwd+
                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, 
LTR-, OBFF Disabled ARIFwd-
                 LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- 
SpeedDis-
                          Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
                          Compliance De-emphasis: -6dB
                 LnkSta2: Current De-emphasis Level: -3.5dB, 
EqualizationComplete-, EqualizationPhase1-
                          EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
         Capabilities: [100 v2] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr+
                 AERCap: First Error Pointer: 00, GenCap+ CGenEn+ 
ChkCap+ ChkEn+
         Capabilities: [178 v1] #19
         Kernel driver in use: pcieport

0004:01:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit 
Ethernet Controller (rev 06)
         Subsystem: Intel Corporation PRO/1000 PT Dual Port Server Adapter
         Physical Slot: 5-1
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 128 bytes
         Interrupt: pin A routed to IRQ 299
         Region 0: Memory at c0100100000 (32-bit, non-prefetchable) 
[size=128K]
         Region 1: Memory at c0100120000 (32-bit, non-prefetchable) 
[size=128K]
         Region 2: I/O ports at 1000 [size=32]
         Expansion ROM at c0100140000 [disabled] [size=128K]
         Capabilities: [c8] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                 Address: 00000000397f0040  Data: 0000
         Capabilities: [e0] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s 
<512ns, L1 <64us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ 
Unsupported+
                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 256 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- 
AuxPwr+ TransPend-
                 LnkCap: Port #8, Speed 2.5GT/s, Width x4, ASPM L0s, 
Exit Latency L0s <4us, L1 <64us
                         ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 AERCap: First Error Pointer: 14, GenCap- CGenEn- 
ChkCap- ChkEn-
         Capabilities: [140 v1] Device Serial Number 68-05-ca-ff-ff-3e-5b-7a
         Kernel driver in use: e1000e

0004:01:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit 
Ethernet Controller (rev 06)
         Subsystem: Intel Corporation PRO/1000 PT Dual Port Server Adapter
         Physical Slot: 5-1
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 128 bytes
         Interrupt: pin B routed to IRQ 301
         Region 0: Memory at c0100160000 (32-bit, non-prefetchable) 
[size=128K]
         Region 1: Memory at c0100180000 (32-bit, non-prefetchable) 
[size=128K]
         Region 2: I/O ports at 1020 [size=32]
         Expansion ROM at c01001a0000 [disabled] [size=128K]
         Capabilities: [c8] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                 Address: 00000000397f0040  Data: 0000
         Capabilities: [e0] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s 
<512ns, L1 <64us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ 
Unsupported+
                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 256 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- 
AuxPwr+ TransPend-
                 LnkCap: Port #8, Speed 2.5GT/s, Width x4, ASPM L0s, 
Exit Latency L0s <4us, L1 <64us
                         ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- 
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- 
NonFatalErr-
                 AERCap: First Error Pointer: 14, GenCap- CGenEn- 
ChkCap- ChkEn-
         Capabilities: [140 v1] Device Serial Number 68-05-ca-ff-ff-3e-5b-7a
         Kernel driver in use: e1000e

Thanks,
Tyler

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
