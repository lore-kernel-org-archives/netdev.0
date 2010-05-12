From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-05-11 - dies in pm_qos_update_request()
Date: Wed, 12 May 2010 15:52:42 -0400
Message-ID: <5525.1273693962@localhost>
References: <201005120149.o4C1n7P4002637@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1273693962_3904P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 11 May 2010 18:21:22 PDT."
             <201005120149.o4C1n7P4002637@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1273693962_3904P
Content-Type: text/plain; charset=us-ascii

On Tue, 11 May 2010 18:21:22 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-05-11-18-20 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Dell Latitude E6500, x86_64 kernel.

Died a horrid death at boot in the e1000e driver.  Seems to be
something in linux-next.patch. Didn't get a netconsole trace for obvious
reasons...

Copied-by-hand traceback:
pm_qos_update_request()+0x22
e1000_configure+0x478
e1000_open_device+0xee
? _raw_notifier_call_chain+0xf
__dev_open+0xec
dev_open+0x1b
netpoll_setup+0x28b
init_netconsole+0xbc

I suspect this commit:

commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
Author: Rafael J. Wysocki <rjw@sisk.pl>
Date:   Sun Mar 14 14:35:17 2010 +0000

    e1000e / PCI / PM: Add basic runtime PM support (rev. 4)

    Use the PCI runtime power management framework to add basic PCI
    runtime PM support to the e1000e driver.  Namely, make the driver
    suspend the device when the link is off and set it up for generating
    a wakeup event after the link has been detected again.  [This
    feature is disabled until the user space enables it with the help of
    the /sys/devices/.../power/contol device attribute.]

Not sure how to reconcile "this feature is disabled until" with my
traceback, since userspace hasn't even started when init_netconsole is
happening.

        /*
         * Enable early receives on supported devices, only takes effect when
         * packet size is equal or larger than the specified value (in 8 byte
         * units), e.g. using jumbo frames when setting to E1000_ERT_2048
         */
        if (adapter->flags & FLAG_HAS_ERT) {

How the heck did FLAG_HAS_ERT get set, we can't call pm_qos_update_request()
otherwise?

Aha.  Over in ich8lan.c, we have:

struct e1000_info e1000_ich9_info = {
        .mac                    = e1000_ich9lan,
        .flags                  = FLAG_HAS_JUMBO_FRAMES
                                  | FLAG_IS_ICH
                                  | FLAG_HAS_WOL
                                  | FLAG_RX_CSUM_ENABLED
                                  | FLAG_HAS_CTRLEXT_ON_LOAD
                                  | FLAG_HAS_AMT
                                  | FLAG_HAS_ERT
                                  | FLAG_HAS_FLASH
                                  | FLAG_APME_IN_WUC,

And lspci says:
00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory Controller Hub (rev 07)
00:01.0 PCI bridge: Intel Corporation Mobile 4 Series Chipset PCI Express Graphics Port (rev 07)
00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network Connection (rev 03)
00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4 (rev 03)
00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5 (rev 03)
00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 03)
00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2 (rev 03)
00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio Controller (rev 03)
00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 03)
00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 2 (rev 03)
00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 3 (rev 03)
00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 4 (rev 03)
00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 03)
00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 03)
00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 03)
00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 03)
00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93)
00:1f.0 ISA bridge: Intel Corporation ICH9M-E LPC Interface Controller (rev 03)
00:1f.2 RAID bus controller: Intel Corporation Mobile 82801 SATA RAID Controller (rev 03)
00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 03)
01:00.0 VGA compatible controller: nVidia Corporation G98M [Quadro NVS 160M] (rev a1)
03:01.0 CardBus bridge: Ricoh Co Ltd RL5c476 II (rev ba)
03:01.1 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller (rev 04)
03:01.2 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro Host Adapter (rev 21)
0c:00.0 Network controller: Intel Corporation Wireless WiFi Link 5100

I see a lot of ICH9 listed there, guess a Mobile 4 is ICH9-ish enough...

Unfortunately, that's the limit of my ability to chase this down.






--==_Exmh_1273693962_3904P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL6wcKcC3lWbTT17ARAkHJAJ9aQT0+oD8cpzt7h32A3NVuFdHolACfSwnN
6E2ndQzNArI7uGCg+fzRhZc=
=gZw/
-----END PGP SIGNATURE-----

--==_Exmh_1273693962_3904P--
