From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Sun, 11 Jan 2009 20:39:55 -0500
Message-ID: <9108.1231724395@turing-police.cc.vt.edu>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com> <20090109.140422.60087297.davem@davemloft.net> <43805.1231672258@turing-police.cc.vt.edu> <20090111.040842.86784676.davem@davemloft.net> <1231676698.25018.147.camel@macbook.infradead.org> <1231678799.25018.195.camel@macbook.infradead.org>
            <4407.1231719036@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231724395_4327P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	David Miller <davem@davemloft.net>,
	alessandro.suardi@gmail.com, jaswinderlinux@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:42325 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbZALBkA (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 20:40:00 -0500
In-Reply-To: Your message of "Sun, 11 Jan 2009 19:10:36 EST."
             <4407.1231719036@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231724395_4327P
Content-Type: text/plain; charset=us-ascii

On Sun, 11 Jan 2009 19:10:36 EST, Valdis.Kletnieks@vt.edu said:

> In the dmesg I see during early bootup:
> 
> [    0.694230] loop: module loaded
> [    0.694249] tg3.c:v3.97 (December 10, 2008)
> [    0.694261] vendor=8086 device=27d4
> [    0.694265] tg3 0000:09:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> [    0.694274] tg3 0000:09:00.0: setting latency timer to 64
> [    0.696087] tg3 0000:09:00.0: wake-up capability disabled by ACPI
> [    0.696094] tg3 0000:09:00.0: PME# disabled
> [    0.702276] tg3 0000:09:00.0: firmware: using built-in firmware tigon/tg3_tso.bin
> [    0.702287] vendor=8086 device=27d4
> [    0.702288] tg3 0000:09:00.0: PCI INT A disabled
> [    0.702512] console [netcon0] enabled
> [    0.702515] netconsole: network logging started
> [    0.702575] Driver 'sd' needs updating - please use bus_type methods
> 
> but once we get to userspace, 'ifconfig' or 'ip link show' have *zero*
> about an eth0 device.
> 
> For comparison, the dmesg if I revert your patch:
> 
> [    0.696638] loop: module loaded
> [    0.696658] tg3.c:v3.97 (December 10, 2008)
> [    0.696670] vendor=8086 device=27d4
> [    0.696674] tg3 0000:09:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> [    0.696683] tg3 0000:09:00.0: setting latency timer to 64
> [    0.698063] tg3 0000:09:00.0: wake-up capability disabled by ACPI
> [    0.698070] tg3 0000:09:00.0: PME# disabled
> [    0.704276] tg3 0000:09:00.0: firmware: using built-in firmware tigon/tg3_tso.bin
> [    0.704445] eth0: Tigon3 [partno(BCM5752KFBG) rev 6002] (PCI Express) MAC address 00:15:c5:c8:33:4e
> [    0.704448] eth0: attached PHY is 5752 (10/100/1000Base-T Ethernet) (WireSpeed[1])
> [    0.704451] eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
> [    0.704453] eth0: dma_rwctrl[76180000] dma_mask[64-bit]
> [    0.704653] console [netcon0] enabled
> [    0.704656] netconsole: network logging started
> [    0.704718] Driver 'sd' needs updating - please use bus_type methods
> 
> So it looks like the patch is failing to finish initialization of the card.
> Damned if *I* can see what's breaking it, the conversion to use a helper
> function tg3_request_firmware seems sane enough....

Damn.  I wonder if netconsole's initialization is turning around and stomping
on everything?  This looks suspicious:

static int tg3_open(struct net_device *dev)
 {
        struct tg3 *tp = netdev_priv(dev);
        int err;
 
+       if (tp->fw_needed) {

Do we know for sure that tp-> struct is the same one we set up back in
tg3_request_firmware, *and* that tg3_open() doesn't get called before
tg3_init_one() (which would result in an uninitialized fw_needed)?

--==_Exmh_1231724395_4327P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJap9rcC3lWbTT17ARAvx6AKCuceTXvq7tuHbmoFnX0fHsAztKSwCgvlVL
kXpCi5I2KhSA3FlAusijqQs=
=mLtx
-----END PGP SIGNATURE-----

--==_Exmh_1231724395_4327P--
