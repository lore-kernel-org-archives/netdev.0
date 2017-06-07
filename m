From: Oleksij Rempel <linux@rempel-privat.de>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
Date: Wed, 7 Jun 2017 09:07:33 +0200
Message-ID: <92468e50-409f-c54f-8bf8-87587061d98e@rempel-privat.de>
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
 <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
 <20170607001213.GC20162@yumi.tdiedrich.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="suLouPjIMqB14HWNuNtUHGjjKWLCOaTTc"
To: Tobias Diedrich <ranma+ath9k_htc_fw@tdiedrich.de>,
        Nathan Royce <nroycea+kernel@gmail.com>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        ath9k_htc_fw <ath9k_htc_fw@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607001213.GC20162@yumi.tdiedrich.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--suLouPjIMqB14HWNuNtUHGjjKWLCOaTTc
Content-Type: multipart/mixed; boundary="euLtQ91tjTGSiNdfbSTmJdEOFOPsToCc4";
 protected-headers="v1"
From: Oleksij Rempel <linux@rempel-privat.de>
To: Tobias Diedrich <ranma+ath9k_htc_fw@tdiedrich.de>,
 Nathan Royce <nroycea+kernel@gmail.com>,
 QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
 Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 ath9k_htc_fw <ath9k_htc_fw@lists.infradead.org>
Message-ID: <92468e50-409f-c54f-8bf8-87587061d98e@rempel-privat.de>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
 <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
 <20170607001213.GC20162@yumi.tdiedrich.de>
In-Reply-To: <20170607001213.GC20162@yumi.tdiedrich.de>

--euLtQ91tjTGSiNdfbSTmJdEOFOPsToCc4
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Am 07.06.2017 um 02:12 schrieb Tobias Diedrich:
> Oleksij Rempel wrote:
>> Yes, this is "normal" problem. The firmware has no error handler for P=
CI
>> bus related exceptions. So if we filed to read PCI bus first time, we
>> have choice to Ooops and stall or Ooops and reboot ASAP. So we reboot
>> and provide an kernel "firmware panic!" message.
>> Every one who can or will to fix this, is welcome.
>>
>>> *****
>>> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath: firmware panic!
>>> exccause: 0x0000000d; pc: 0x0090ae81; badvaddr: 0x10ff4038.
> [...]
>=20
>> memdmp 50ae78 50ae88
>=20
> 50ae78: 6c10 0412 6aa2 0c02 0088 20c0 2008 1940  l...j..........@
>=20
> [...copy to bin...]
> $ bin/objdump -b binary -m xtensa  -D /tmp/memdump.bin=20
> [..]
>    0:   6c1004          entry   a1, 32
>    3:   126aa2          l32r    a2, 0xfffdaa8c
>    6:   0c0200          memw
>    9:   8820            l32i.n  a8, a2, 0      <----------Exception cau=
se PC still points at load
>    b:   c020            movi.n  a2, 0
>    d:   081940          extui   a9, a8, 1, 1
>=20
> Judging from that it should be fairly simple to at least implement
> some sort of retry, possible after triggering a PCIe link retrain?

I assume, yes.

> There are some related PCIe root complex registers that may point to
> what exactly failed if they were dumped.
>=20
> The root complex registers live at 0x00040000 and I think match the
> registers described for the root complex in the AR9344 datasheet.

Suddenly I don't have ar7010 docs to tell..

> PCIE_INT_MASK would map to 0x40050 and has a bit for SYS_ERR:
> "A system error. The RC Core asserts CFG_SYS_ERR_RC if any device in
> the hierarchy reports any of the following errors and the associated
> enable bit is set in the Root Control register: ERR_COR, ERR_FATAL,
> ERR_NONFATAL."
>=20
> AFAICS link retrain can be done by setting bit3 (INIT_RST,
> "Application request to initiate a training reset") in
> PCIE_APP (0x40000).
>=20
> See sboot/magpie_1_1/sboot/cmnos/eeprom/src/cmnos_eeprom.c (which
> flips some bits in the RC to enable the PCIe bus for reading the
> EEPROM).
>=20
> The root complex pci configuration space is at 0x20000 which could
> have further error details:
>> memdmp 20000 20200
>=20
> 020000: a02a 168c 0010 0006 0000 0001 0001 0000  .*..............
> 020010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020020: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020030: 0000 0000 0000 0040 0000 0000 0000 01ff  .......@........
> 020040: 5bc3 5001 0000 0000 0000 0000 0000 0000  [.P.............
> 020050: 0080 7005 0000 0000 0000 0000 0000 0000  ..p.............
> 020060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020070: 0042 0010 0000 8701 0000 2010 0013 4411  .B............D.
> 020080: 3011 0000 0000 0000 00c0 03c0 0000 0000  0...............
> 020090: 0000 0000 0000 0010 0000 0000 0000 0000  ................
> 0200a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0200b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0200c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0200d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0200e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0200f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020100: 1401 0001 0000 0000 0000 0000 0006 2030  ...............0
> 020110: 0000 0000 0000 2000 0000 00a0 0000 0000  ................
> 020120: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020130: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020140: 0001 0002 0000 0000 0000 0000 0000 0000  ................
> 020150: 0000 0000 8000 00ff 0000 0000 0000 0000  ................
> 020160: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020170: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020180: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 020190: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0201a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0201b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0201c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0201d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0201e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0201f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
>=20
> Transformed into something suitable for feeding into lspci -F:
>=20
> 00:00.0 Description filled in by lspci
> 00: 8c 16 2a a0 06 00 10 00 01 00 00 00 00 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 00 00
> 40: 01 50 c3 5b 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 05 70 80 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 10 00 42 00 01 87 00 00 10 20 00 00 11 44 13 00
> 80: 00 00 11 30 00 00 00 00 c0 03 c0 00 00 00 00 00
> 90: 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>=20
> $ lspci -F /tmp/hexdump -vvv
> 00:00.0 Non-VGA unclassified device: Qualcomm Atheros Device a02a (rev =
01)
>         !!! Invalid class 0000 for header type 01
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- Par=
Err- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 255
>         Bus: primary=3D00, secondary=3D00, subordinate=3D00, sec-latenc=
y=3D0
>         I/O behind bridge: 00000000-00000fff
>         Memory behind bridge: 00000000-000fffff
>         Prefetchable memory behind bridge: 00000000-000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort=
- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Power Management version 3
>                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D375mA PME(D0+,=
D1+,D2-,D3hot+,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
>         Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable- 64bit+
>                 Address: 0000000000000000  Data: 0000
>         Capabilities: [70] Express (v2) Root Port (Slot-), MSI 00
>                 DevCap: MaxPayload 256 bytes, PhantFunc 0
>                         ExtTag- RBE+
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- U=
nsupported-
>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr=
- TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exi=
t Latency L0s <1us, L1 <64us
>                         ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp=
-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+=
 DLActive+ BWMgmt- ABWMgmt-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEInt=
Ena- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>                 DevCap2: Completion Timeout: Not Supported, TimeoutDis+=
, LTR-, OBFF Not Supported ARIFwd-
>                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-,=
 LTR-, OBFF Disabled ARIFwd-
>                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- S=
peedDis-
>                          Transmit Margin: Normal Operating Range, Enter=
ModifiedCompliance- ComplianceSOS-
>                          Compliance De-emphasis: -6dB
>                 LnkSta2: Current De-emphasis Level: -6dB, EqualizationC=
omplete-, EqualizationPhase1-
>                          EqualizationPhase2-, EqualizationPhase3-, Link=
EqualizationRequest-
>=20

Looks promising :)

>>> Jun 02 14:55:30 computer kernel: usb 1-1.1: ath9k_htc: Transferred FW=
:
>>> ath9k_htc/htc_7010-1.4.0.fw, size: 72812
>=20
> $ ls -l /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw
> -rw-r--r-- 1 root root 72812 Dec 14 04:59 /lib/firmware/ath9k_htc/htc_7=
010-1.4.0.fw
> $ sha1sum /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw
> 959cb6550930de2882e12b9a549c3cf0c9bf51ac /lib/firmware/ath9k_htc/htc_70=
10-1.4.0.fw

--=20
Regards,
Oleksij


--euLtQ91tjTGSiNdfbSTmJdEOFOPsToCc4--

--suLouPjIMqB14HWNuNtUHGjjKWLCOaTTc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF4EAREIAAYFAlk3pjUACgkQHwImuRkmbWlUfwEAgY31DLMCLPKmp/fFF+NbtZAO
GternFq9OqKzOMDz4LsA/A6eCdpRgaHIdpGKP/Uqa7+774w0KPOI3g0fr4vuGeJD
=/Scg
-----END PGP SIGNATURE-----

--suLouPjIMqB14HWNuNtUHGjjKWLCOaTTc--
