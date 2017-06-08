From: Oleksij Rempel <linux@rempel-privat.de>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
Date: Thu, 8 Jun 2017 10:15:25 +0200
Message-ID: <830f8fa3-d22c-fb83-e2ed-9ef3649b592c@rempel-privat.de>
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
 <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
 <20170607001213.GC20162@yumi.tdiedrich.de>
 <92468e50-409f-c54f-8bf8-87587061d98e@rempel-privat.de>
 <20170607223913.GD20162@yumi.tdiedrich.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="cLebMpS5ECEpr9GHWbafHxusSvr7tMgl8"
To: Tobias Diedrich <ranma+ath9k_htc_fw@tdiedrich.de>,
        Nathan Royce <nroycea+kernel@gmail.com>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        ath9k_htc_fw <ath9k_htc_fw@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607223913.GD20162@yumi.tdiedrich.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cLebMpS5ECEpr9GHWbafHxusSvr7tMgl8
Content-Type: multipart/mixed; boundary="9VP7hlG7A2m9JshTxcWubMOELbO40QgeJ";
 protected-headers="v1"
From: Oleksij Rempel <linux@rempel-privat.de>
To: Tobias Diedrich <ranma+ath9k_htc_fw@tdiedrich.de>,
 Nathan Royce <nroycea+kernel@gmail.com>,
 QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
 Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 ath9k_htc_fw <ath9k_htc_fw@lists.infradead.org>
Message-ID: <830f8fa3-d22c-fb83-e2ed-9ef3649b592c@rempel-privat.de>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
 <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
 <20170607001213.GC20162@yumi.tdiedrich.de>
 <92468e50-409f-c54f-8bf8-87587061d98e@rempel-privat.de>
 <20170607223913.GD20162@yumi.tdiedrich.de>
In-Reply-To: <20170607223913.GD20162@yumi.tdiedrich.de>

--9VP7hlG7A2m9JshTxcWubMOELbO40QgeJ
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Am 08.06.2017 um 00:39 schrieb Tobias Diedrich:
> Oleksij Rempel wrote:
>> Am 07.06.2017 um 02:12 schrieb Tobias Diedrich:
>>> Oleksij Rempel wrote:
>>>> Yes, this is "normal" problem. The firmware has no error handler for=
 PCI
>>>> bus related exceptions. So if we filed to read PCI bus first time, w=
e
>>>> have choice to Ooops and stall or Ooops and reboot ASAP. So we reboo=
t
>>>> and provide an kernel "firmware panic!" message.
>>>> Every one who can or will to fix this, is welcome.
>>>>
>>>>> *****
>>>>> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath: firmware panic!
>>>>> exccause: 0x0000000d; pc: 0x0090ae81; badvaddr: 0x10ff4038.
>>> [...]
>>>
>>>> memdmp 50ae78 50ae88
>>>
>>> 50ae78: 6c10 0412 6aa2 0c02 0088 20c0 2008 1940  l...j..........@
>>>
>>> [...copy to bin...]
>>> $ bin/objdump -b binary -m xtensa  -D /tmp/memdump.bin=20
>>> [..]
>>>    0:   6c1004          entry   a1, 32
>>>    3:   126aa2          l32r    a2, 0xfffdaa8c
>>>    6:   0c0200          memw
>>>    9:   8820            l32i.n  a8, a2, 0      <----------Exception c=
ause PC still points at load
>>>    b:   c020            movi.n  a2, 0
>>>    d:   081940          extui   a9, a8, 1, 1
>>>
>>> Judging from that it should be fairly simple to at least implement
>>> some sort of retry, possible after triggering a PCIe link retrain?
>>
>> I assume, yes.
>>
>>> There are some related PCIe root complex registers that may point to
>>> what exactly failed if they were dumped.
>>>
>>> The root complex registers live at 0x00040000 and I think match the
>>> registers described for the root complex in the AR9344 datasheet.
>>
>> Suddenly I don't have ar7010 docs to tell..
>>
>>> PCIE_INT_MASK would map to 0x40050 and has a bit for SYS_ERR:
>>> "A system error. The RC Core asserts CFG_SYS_ERR_RC if any device in
>>> the hierarchy reports any of the following errors and the associated
>>> enable bit is set in the Root Control register: ERR_COR, ERR_FATAL,
>>> ERR_NONFATAL."
>>>
>>> AFAICS link retrain can be done by setting bit3 (INIT_RST,
>>> "Application request to initiate a training reset") in
>>> PCIE_APP (0x40000).
>>>
>>> See sboot/magpie_1_1/sboot/cmnos/eeprom/src/cmnos_eeprom.c (which
>>> flips some bits in the RC to enable the PCIe bus for reading the
>>> EEPROM).
>>>
>>> The root complex pci configuration space is at 0x20000 which could
>>> have further error details:
>>>> memdmp 20000 20200
>>>
>>> 020000: a02a 168c 0010 0006 0000 0001 0001 0000  .*..............
>>> 020010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020020: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020030: 0000 0000 0000 0040 0000 0000 0000 01ff  .......@........
>>> 020040: 5bc3 5001 0000 0000 0000 0000 0000 0000  [.P.............
>>> 020050: 0080 7005 0000 0000 0000 0000 0000 0000  ..p.............
>>> 020060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020070: 0042 0010 0000 8701 0000 2010 0013 4411  .B............D.
>>> 020080: 3011 0000 0000 0000 00c0 03c0 0000 0000  0...............
>>> 020090: 0000 0000 0000 0010 0000 0000 0000 0000  ................
>>> 0200a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0200b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0200c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0200d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0200e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0200f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020100: 1401 0001 0000 0000 0000 0000 0006 2030  ...............0
>>> 020110: 0000 0000 0000 2000 0000 00a0 0000 0000  ................
>>> 020120: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020130: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020140: 0001 0002 0000 0000 0000 0000 0000 0000  ................
>>> 020150: 0000 0000 8000 00ff 0000 0000 0000 0000  ................
>>> 020160: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020170: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020180: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 020190: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0201a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0201b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0201c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0201d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0201e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>> 0201f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>>>
>>> Transformed into something suitable for feeding into lspci -F:
>>>
>>> 00:00.0 Description filled in by lspci
>>> 00: 8c 16 2a a0 06 00 10 00 01 00 00 00 00 00 01 00
>>> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> 20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 00 00
>>> 40: 01 50 c3 5b 00 00 00 00 00 00 00 00 00 00 00 00
>>> 50: 05 70 80 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> 70: 10 00 42 00 01 87 00 00 10 20 00 00 11 44 13 00
>>> 80: 00 00 11 30 00 00 00 00 c0 03 c0 00 00 00 00 00
>>> 90: 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00
>>> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>
>>> $ lspci -F /tmp/hexdump -vvv
>>> 00:00.0 Non-VGA unclassified device: Qualcomm Atheros Device a02a (re=
v 01)
>>>         !!! Invalid class 0000 for header type 01
>>>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- P=
arErr- Stepping- SERR- FastB2B- DisINTx-
>>>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbo=
rt- <TAbort- <MAbort- >SERR- <PERR- INTx-
>>>         Latency: 0
>>>         Interrupt: pin A routed to IRQ 255
>>>         Bus: primary=3D00, secondary=3D00, subordinate=3D00, sec-late=
ncy=3D0
>>>         I/O behind bridge: 00000000-00000fff
>>>         Memory behind bridge: 00000000-000fffff
>>>         Prefetchable memory behind bridge: 00000000-000fffff
>>>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbo=
rt- <TAbort- <MAbort- <SERR- <PERR-
>>>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-=

>>>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>>>         Capabilities: [40] Power Management version 3
>>>                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D375mA PME(D0=
+,D1+,D2-,D3hot+,D3cold-)
>>>                 Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0=
 PME-
>>>         Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable- 64bit+
>>>                 Address: 0000000000000000  Data: 0000
>>>         Capabilities: [70] Express (v2) Root Port (Slot-), MSI 00
>>>                 DevCap: MaxPayload 256 bytes, PhantFunc 0
>>>                         ExtTag- RBE+
>>>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal-=
 Unsupported-
>>>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>>>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>>>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxP=
wr- TransPend-
>>>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, E=
xit Latency L0s <1us, L1 <64us
>>>                         ClockPM- Surprise- LLActRep+ BwNot- ASPMOptCo=
mp-
>>>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk=
-
>>>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt=
-
>>>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotCl=
k+ DLActive+ BWMgmt- ABWMgmt-
>>>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEI=
ntEna- CRSVisible-
>>>                 RootCap: CRSVisible-
>>>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>>>                 DevCap2: Completion Timeout: Not Supported, TimeoutDi=
s+, LTR-, OBFF Not Supported ARIFwd-
>>>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis=
-, LTR-, OBFF Disabled ARIFwd-
>>>                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance-=
 SpeedDis-
>>>                          Transmit Margin: Normal Operating Range, Ent=
erModifiedCompliance- ComplianceSOS-
>>>                          Compliance De-emphasis: -6dB
>>>                 LnkSta2: Current De-emphasis Level: -6dB, Equalizatio=
nComplete-, EqualizationPhase1-
>>>                          EqualizationPhase2-, EqualizationPhase3-, Li=
nkEqualizationRequest-
>>>
>>
>> Looks promising :)
>>
>=20
> POC seems to work, though this may additionally need to restore wifi
> state as well, no guarantees there.

This probably will be next topic. Can you address some comments in the
review and create a pull request in the github repo?

>=20
>> str 40018 3
> 00040018 : 00000003
>>
> Retry(1) failed PCIe access @0x10ff4038
> Before: int_mask=3D0 app=3Dffc1 reset=3D0
> After: int_mask=3D0 app=3Dffc1 reset=3D7
> wlan int status=3D0
>=20
>> str 40018 3
> 00040018 : 00000003
>>
> Retry(1) failed PCIe access @0x10ff4038
> Before: int_mask=3D0 app=3Dffc1 reset=3D0
> After: int_mask=3D0 app=3Dffc1 reset=3D7
> wlan int status=3D0
>>
>=20
>=20
> diff --git a/target_firmware/magpie_fw_dev/target/init/app_start.c b/ta=
rget_firmware/magpie_fw_dev/target/init/app_start.c
> index 8fa9c8b..fea62c1 100644
> --- a/target_firmware/magpie_fw_dev/target/init/app_start.c
> +++ b/target_firmware/magpie_fw_dev/target/init/app_start.c
> @@ -137,6 +137,13 @@ void __section(boot) __noreturn __visible app_star=
t(void)
> =20
>  	A_PRINTF(" A_WDT_INIT()\n\r");
> =20
> +#if defined(PROJECT_MAGPIE)

please, use /**/ style comments.

> +	// For some reason needs to be called again here for the
> +	// exception handlers to work properly, at least on the XBOX
> +	// adapter.
> +	fatal_exception_func();
> +#endif
> +
>  #if defined(PROJECT_K2)
>  	save_cmnos_printf =3D fw_cmnos_printf;
>  #endif
> diff --git a/target_firmware/magpie_fw_dev/target/init/init.c b/target_=
firmware/magpie_fw_dev/target/init/init.c
> index 7484c05..cad2519 100755
> --- a/target_firmware/magpie_fw_dev/target/init/init.c
> +++ b/target_firmware/magpie_fw_dev/target/init/init.c
> @@ -212,6 +212,78 @@ LOCAL void zfGenWrongEpidEvent(uint32_t epid)
>  	mUSB_EP3_XFER_DONE();
>  }
> =20
> +static void
> +AR7010_pcie_reset(void)
> +{
> +#define PCIE_RC_ACCESS_DELAY    20
> +
> +#define PCI_RC_RESET_BIT                            BIT6
> +#define PCI_RC_PHY_RESET_BIT                        BIT7
> +#define PCI_RC_PLL_RESET_BIT                        BIT8
> +#define PCI_RC_PHY_SHIFT_RESET_BIT                  BIT10
> +
> +#define HAL_WORD_REG_WRITE(addr, val) do { *((uint32_t*)(addr)) =3D va=
l; } while (0)
> +#define HAL_WORD_REG_READ(addr) (*((uint32_t*)(addr)))

we already have iowrite32* ioread32* functions, why do we need more?

> +#define CMD_PCI_RC_RESET_ON()    HAL_WORD_REG_WRITE(MAGPIE_REG_RST_RES=
ET_ADDR,  \
> +                                    (HAL_WORD_REG_READ(MAGPIE_REG_RST_=
RESET_ADDR)|  \
> +                                        (PCI_RC_PHY_SHIFT_RESET_BIT|PC=
I_RC_PLL_RESET_BIT|PCI_RC_PHY_RESET_BIT|PCI_RC_RESET_BIT)))
> +
> +#define CMD_PCI_RC_RESET_CLR()   HAL_WORD_REG_WRITE(MAGPIE_REG_RST_RES=
ET_ADDR, \
> +                                    (HAL_WORD_REG_READ(MAGPIE_REG_RST_=
RESET_ADDR)&   \
> +                                        (~(PCI_RC_PHY_SHIFT_RESET_BIT|=
PCI_RC_PLL_RESET_BIT|PCI_RC_PHY_RESET_BIT|PCI_RC_RESET_BIT))))
> +
> +	int i;
> +
> +	CMD_PCI_RC_RESET_ON();
> +	A_DELAY_USECS(PCIE_RC_ACCESS_DELAY);
> +
> +	/* dereset the reset */
> +	CMD_PCI_RC_RESET_CLR();
> +	A_DELAY_USECS(500);
> +
> +	/* 7. set bus master and memory space enable */
> +	DEBUG_SYSTEM_STATE =3D (DEBUG_SYSTEM_STATE&(~0xff)) | 0x45;
> +	HAL_WORD_REG_WRITE(0x00020004, (HAL_WORD_REG_READ(0x00020004)|(BIT1|B=
IT2)));
> +	A_DELAY_USECS(PCIE_RC_ACCESS_DELAY);
> +
> +	/* 7.5. asser pcie_ep reset */
> +	HAL_WORD_REG_WRITE(0x00040018, (HAL_WORD_REG_READ(0x00040018) & ~(0x1=
 << 2)));
> +	A_DELAY_USECS(PCIE_RC_ACCESS_DELAY);
> +
> +	/* 7.5. de-asser pcie_ep reset */
> +	HAL_WORD_REG_WRITE(0x00040018, (HAL_WORD_REG_READ(0x00040018)|(0x1 <<=
 2)));
> +	A_DELAY_USECS(PCIE_RC_ACCESS_DELAY);
> +
> +	/* 8. set app_ltssm_enable */
> +	DEBUG_SYSTEM_STATE =3D (DEBUG_SYSTEM_STATE&(~0xff)) | 0x46;
> +	HAL_WORD_REG_WRITE(0x00040000, (HAL_WORD_REG_READ(0x00040000)|0xffc1)=
);
> +
> +	/*!
> +	 * Receive control (PCIE_RESET),
> +	 *  0x40018, BIT0: LINK_UP, PHY Link up -PHY Link up/down indicator
> +	 *  in case the link up is not ready and we access the 0x14000000,
> +	 *  vmc will hang here
> +	 */
> +
> +	/* poll 0x40018/bit0 (1000 times) until it turns to 1 */
> +	i =3D 10000;
> +	while(i-->0)
> +	{
> +		uint32_t reg_value =3D HAL_WORD_REG_READ(0x00040018);
> +		if( reg_value & BIT0 )
> +			break;
> +		A_DELAY_USECS(PCIE_RC_ACCESS_DELAY);
> +	}
> +
> +	HAL_WORD_REG_WRITE(0x14000004, (HAL_WORD_REG_READ(0x14000004)|0x116))=
;
> +	A_DELAY_USECS(PCIE_RC_ACCESS_DELAY);
> +
> +	HAL_WORD_REG_WRITE(0x14000010, (HAL_WORD_REG_READ(0x14000010)|EEPROM_=
CTRL_BASE));
> +}
> +
> +static int exception_retries =3D 0;
> +
>  void
>  AR6002_fatal_exception_handler_patch(CPU_exception_frame_t *exc_frame)=

>  {
> @@ -226,6 +298,32 @@ AR6002_fatal_exception_handler_patch(CPU_exception=
_frame_t *exc_frame)
>  	dump.pc                     =3D exc_frame->xt_pc;
>  	dump.assline                =3D 0;

i would prefer to put it in to separate function. may be, complete pci
code in a separate file?

> +	if (dump.badvaddr >=3D 0x10000000 &&
> +	    dump.badvaddr <  0x18000000) {

if (!bla)
  return;

> +		// Exception while accessing PCIe memory space.
> +		volatile uint32_t *pcie_app =3D (uint32_t*) 0x40000;
> +		volatile uint32_t *pcie_reset =3D (uint32_t*) 0x40018;
> +		volatile uint32_t *pcie_int_mask =3D (uint32_t*) 0x40050;

magic values should be replaced.

> +		// Maybe retry.
> +		if (++exception_retries < 2) {

if (!bla)
  return;

> +			A_PRINTF("\nRetry(%d) failed PCIe access @0x%x\n",
> +				exception_retries, dump.badvaddr);
> +			A_PRINTF("Before: int_mask=3D%x app=3D%x reset=3D%x\n", *pcie_int_m=
ask, *pcie_app, *pcie_reset);
> +
> +			AR7010_pcie_reset();
> +
> +			A_PRINTF("After: int_mask=3D%x app=3D%x reset=3D%x\n", *pcie_int_ma=
sk, *pcie_app, *pcie_reset);
> +
> +			// This should recurse if we failed to recover.
> +			A_PRINTF("wlan int status=3D%x\n", HAL_WORD_REG_READ(0x10ff4038));
> +
> +			// Reset retry counter.
> +			exception_retries =3D 0;
> +			return;
> +		}
> +	}
> +
>  	zfGenExceptionEvent(dump.exc_frame.xt_exccause, dump.pc, dump.badvadd=
r);
> =20
>  #if SYSTEM_MODULE_PRINT

I'm exciting to see it mainline. Thank you for your work!

--=20
Regards,
Oleksij


--9VP7hlG7A2m9JshTxcWubMOELbO40QgeJ--

--cLebMpS5ECEpr9GHWbafHxusSvr7tMgl8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF4EAREIAAYFAlk5B50ACgkQHwImuRkmbWn6ZQD/e0A0BtBf340aplv6mATMixjY
0j2X6wDYg7ADvCSJo3IA/RzofFw8k3y+umDQrSM82QCGT3PfmoMrUq334g/lOLIG
=cY9A
-----END PGP SIGNATURE-----

--cLebMpS5ECEpr9GHWbafHxusSvr7tMgl8--
