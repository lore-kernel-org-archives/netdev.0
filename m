From: Tobias Diedrich <ranma+ath9k_htc_fw-YxUgxmcw2FPQD6PfKP4TzA@public.gmane.org>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware
 panic)
Date: Wed, 7 Jun 2017 02:12:13 +0200
Message-ID: <20170607001213.GC20162@yumi.tdiedrich.de>
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
 <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="LyciRD1jyfeSSjG0"
Cc: Nathan Royce <nroycea+kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ath9k_htc_fw <ath9k_htc_fw-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <71818afe-9075-5582-bb6c-650dfa8a5363-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--LyciRD1jyfeSSjG0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Oleksij Rempel wrote:
> Yes, this is "normal" problem. The firmware has no error handler for PCI
> bus related exceptions. So if we filed to read PCI bus first time, we
> have choice to Ooops and stall or Ooops and reboot ASAP. So we reboot
> and provide an kernel "firmware panic!" message.
> Every one who can or will to fix this, is welcome.
>=20
> > *****
> > Jun 02 14:55:30 computer kernel: usb 1-1.1: ath: firmware panic!
> > exccause: 0x0000000d; pc: 0x0090ae81; badvaddr: 0x10ff4038.
[...]

>memdmp 50ae78 50ae88

50ae78: 6c10 0412 6aa2 0c02 0088 20c0 2008 1940  l...j..........@

[...copy to bin...]
$ bin/objdump -b binary -m xtensa  -D /tmp/memdump.bin=20
[..]
   0:   6c1004          entry   a1, 32
   3:   126aa2          l32r    a2, 0xfffdaa8c
   6:   0c0200          memw
   9:   8820            l32i.n  a8, a2, 0      <----------Exception cause P=
C still points at load
   b:   c020            movi.n  a2, 0
   d:   081940          extui   a9, a8, 1, 1

Judging from that it should be fairly simple to at least implement
some sort of retry, possible after triggering a PCIe link retrain?
There are some related PCIe root complex registers that may point to
what exactly failed if they were dumped.

The root complex registers live at 0x00040000 and I think match the
registers described for the root complex in the AR9344 datasheet.

PCIE_INT_MASK would map to 0x40050 and has a bit for SYS_ERR:
"A system error. The RC Core asserts CFG_SYS_ERR_RC if any device in
the hierarchy reports any of the following errors and the associated
enable bit is set in the Root Control register: ERR_COR, ERR_FATAL,
ERR_NONFATAL."

AFAICS link retrain can be done by setting bit3 (INIT_RST,
"Application request to initiate a training reset") in
PCIE_APP (0x40000).

See sboot/magpie_1_1/sboot/cmnos/eeprom/src/cmnos_eeprom.c (which
flips some bits in the RC to enable the PCIe bus for reading the
EEPROM).

The root complex pci configuration space is at 0x20000 which could
have further error details:
>memdmp 20000 20200

020000: a02a 168c 0010 0006 0000 0001 0001 0000  .*..............
020010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020020: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020030: 0000 0000 0000 0040 0000 0000 0000 01ff  .......@........
020040: 5bc3 5001 0000 0000 0000 0000 0000 0000  [.P.............
020050: 0080 7005 0000 0000 0000 0000 0000 0000  ..p.............
020060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020070: 0042 0010 0000 8701 0000 2010 0013 4411  .B............D.
020080: 3011 0000 0000 0000 00c0 03c0 0000 0000  0...............
020090: 0000 0000 0000 0010 0000 0000 0000 0000  ................
0200a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0200b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0200c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0200d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0200e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0200f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020100: 1401 0001 0000 0000 0000 0000 0006 2030  ...............0
020110: 0000 0000 0000 2000 0000 00a0 0000 0000  ................
020120: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020130: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020140: 0001 0002 0000 0000 0000 0000 0000 0000  ................
020150: 0000 0000 8000 00ff 0000 0000 0000 0000  ................
020160: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020170: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020180: 0000 0000 0000 0000 0000 0000 0000 0000  ................
020190: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0201a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0201b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0201c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0201d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0201e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0201f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................

Transformed into something suitable for feeding into lspci -F:

00:00.0 Description filled in by lspci
00: 8c 16 2a a0 06 00 10 00 01 00 00 00 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 ff 01 00 00
40: 01 50 c3 5b 00 00 00 00 00 00 00 00 00 00 00 00
50: 05 70 80 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 10 00 42 00 01 87 00 00 10 20 00 00 11 44 13 00
80: 00 00 11 30 00 00 00 00 c0 03 c0 00 00 00 00 00
90: 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

$ lspci -F /tmp/hexdump -vvv
00:00.0 Non-VGA unclassified device: Qualcomm Atheros Device a02a (rev 01)
        !!! Invalid class 0000 for header type 01
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-=
 Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 255
        Bus: primary=3D00, secondary=3D00, subordinate=3D00, sec-latency=3D0
        I/O behind bridge: 00000000-00000fff
        Memory behind bridge: 00000000-000fffff
        Prefetchable memory behind bridge: 00000000-000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <T=
Abort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2- AuxCurrent=3D375mA PME(D0+,D1+,=
D2-,D3hot+,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 PME-
        Capabilities: [50] MSI: Enable- Count=3D1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [70] Express (v2) Root Port (Slot-), MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0
                        ExtTag- RBE+
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsup=
ported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- Tr=
ansPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exit La=
tency L0s <1us, L1 <64us
                        ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLA=
ctive+ BWMgmt- ABWMgmt-
                RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna-=
 CRSVisible-
                RootCap: CRSVisible-
                RootSta: PME ReqID 0000, PMEStatus- PMEPending-
                DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LT=
R-, OBFF Not Supported ARIFwd-
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR=
-, OBFF Disabled ARIFwd-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- Speed=
Dis-
                         Transmit Margin: Normal Operating Range, EnterModi=
fiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB, EqualizationCompl=
ete-, EqualizationPhase1-
                         EqualizationPhase2-, EqualizationPhase3-, LinkEqua=
lizationRequest-


> > Jun 02 14:55:30 computer kernel: usb 1-1.1: ath9k_htc: Transferred FW:
> > ath9k_htc/htc_7010-1.4.0.fw, size: 72812

$ ls -l /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw
-rw-r--r-- 1 root root 72812 Dec 14 04:59 /lib/firmware/ath9k_htc/htc_7010-=
1.4.0.fw
$ sha1sum /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw
959cb6550930de2882e12b9a549c3cf0c9bf51ac /lib/firmware/ath9k_htc/htc_7010-1=
=2E4.0.fw



--=20
Tobias						PGP: http://8ef7ddba.uguu.de

--LyciRD1jyfeSSjG0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJZN0TcAAoJELTTNy6O9926MgQP/j6CJcU5RNrwPkiq6tgs6dT2
cWXYZMC0j5lpga/Py2EOrSvcBKN+YlDtuZJDR9anK1tNyoT1yBMwZSQx+0eAOuzZ
pS97e9+cVdkVOhOIftjOOMzrVLs/cAHh5k2HqIq4KNM9Qx5kLebi+elRJNT5mbfH
LZRtkVwQvhyIiLV2Z7+nKf8yYAiLgUnbBP7U40kJoHQdj4bq/UN3szHMwwzQasPn
ptXL1npGgF4ysjZ4pcvw8v7meekIsHeVSleqbgPUdPndmrEPt+h20dFgsDidMkkc
nzvmZz2+l+YfCTF8vPHP/qGanOQKYv6ALB+Xc673nNznfBKBVnOLV4L3d9q3ZAju
7SBwVQ7nw2Jk1RC83WoR/jVPFSyWe8Xez+2lRQLujZJBL6SZXNIbKKnTL6PWZli4
G3EuWqGxNRUjkd5/hOMnrigxvu1ZqGguXHVx2aHjObN7n2LUZKENIOm/07GQw66d
TjlVUJV781M9TayXZsAcwcvNAAHOth3dD9wJ6F7pwuMroAu4EF5FIpE9FcnWKNjp
8OqPRaWwFfecqLhXSCrAgtpEDFLl8ozC+ii8P5aowjixQqRkHeZSXhHs4DR41Q8e
DDAuc0G0W6IIb26XjKlGlpkW8ybseYiIvnQX3hOeP68vMsGPDDo+YF4vdcEW/2RD
Wgc1X1VefJq6hsV9Ar5c
=c+nB
-----END PGP SIGNATURE-----

--LyciRD1jyfeSSjG0--
