From: Bernhard Walle <bwalle@suse.de>
Subject: r8169: Crash after reloading driver if network hangs
Date: Sun, 28 Jan 2007 19:02:21 +0100
Message-ID: <20070128180221.GB2285@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:56695 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbXA1SCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jan 2007 13:02:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

also after applying the latest patch that was posted on that mailing
list, I have still the problem described in
http://bugzilla.kernel.org/show_bug.cgi?id=5137.

So after a network hang with several 

        NETDEV WATCHDOG: eth0: transmit timed out

in the kernel log, I removed the driver ('rmmod r8169') and wanted to
reload the driver ('modprobe r8169'). Now the system crashed:

    kernel BUG at kernel/timer.c:407!
    invalid opcode: 0000 [1] SMP 
    CPU 1 
    Modules linked in: r8169 i915 drm deflate zlib_deflate twofish twofish_common serpent blowfi
    sh des cbc ecb blkcipher aes xcbc sha256 w83627ehf hwmon i2c_isa sha1 ipv6 md5 eeprom crypto
    _null af_key snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device nfs lockd nfs_acl sunrpc af_pa
    cket cpufreq_conservative cpufreq_ondemand cpufreq_userspace cpufreq_powersave acpi_cpufreq 
    freq_table button battery ac loop rfcomm hidp l2cap hci_usb bluetooth dm_mod usb_storage fus
    e snd_hda_intel snd_hda_codec snd_pcm iTCO_wdt ehci_hcd uhci_hcd intel_agp i2c_i801 i2c_core
     snd_timer snd soundcore snd_page_alloc iTCO_vendor_support usbcore floppy lp parport_pc ppd
    ev parport ext3 mbcache jbd sg sr_mod cdrom edd fan ata_piix libata piix thermal processor s
    d_mod scsi_mod ide_disk ide_core
    Pid: 5724, comm: modprobe Not tainted 2.6.20-rc6-default #1
    RIP: 0010:[<ffffffff80241dfe>]  [<ffffffff80241dfe>] mod_timer+0x7/0x22
    RSP: 0018:ffff8100566c9c20  EFLAGS: 00010246
    RAX: 0000000000000006 RBX: ffff810061d8c000 RCX: 0000000000000001
    RDX: 00000000000003e8 RSI: 00000000ffffa58a RDI: ffff810061d8d1e0
    RBP: ffff810061d8c4c0 R08: ffffc20000022000 R09: ffff810061d8c4c0
    R10: 0000000000000046 R11: 0000000000000202 R12: 0000000000000000
    R13: 00000000ffffff01 R14: ffff8100566c03e8 R15: ffff810061d8c000
    FS:  00002b38153566f0(0000) GS:ffff81007db9abc0(0000) knlGS:0000000000000000
    CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
    CR2: 00005555557fc870 CR3: 00000000540af000 CR4: 00000000000006e0
    Process modprobe (pid: 5724, threadinfo ffff8100566c8000, task ffff810037fde850)
    Stack:  ffffffff881b6d8b 0000000000000064 ffff810061d8c4c0 ffffc20000022000
     ffffffff881b88ef ffffffff000000ff ffffffff000000ff ffff8100000000ff<6>r8169: eth1: link up

     ffff8100000000ff ffff810000000011 ffff81007d0079c8 0000000000000296
    Call Trace:
     [<ffffffff881b6d8b>] :r8169:rtl8169_set_speed+0x4b/0x53
     [<ffffffff881b88ef>] :r8169:rtl8169_init_one+0x954/0x9c4
     [<ffffffff8031b440>] pci_device_probe+0xe5/0x151
     [<ffffffff8036d620>] really_probe+0x87/0x106
     [<ffffffff8036d83f>] __driver_attach+0x6f/0xaf
     [<ffffffff8036d7d0>] __driver_attach+0x0/0xaf
     [<ffffffff8036d7d0>] __driver_attach+0x0/0xaf
     [<ffffffff8036cb86>] bus_for_each_dev+0x43/0x6e
     [<ffffffff8036ce7c>] bus_add_driver+0x6b/0x18d
     [<ffffffff8031b63b>] __pci_register_driver+0x75/0xaa
     [<ffffffff80298300>] sys_init_module+0x1793/0x1900
     [<ffffffff8025511e>] system_call+0x7e/0x83


    Code: 0f 0b eb fe 48 39 77 10 75 06 48 83 3f 00 75 05 e9 73 85 fd 
    RIP  [<ffffffff80241dfe>] mod_timer+0x7/0x22
     RSP <ffff8100566c9c20>

netif_running(dev) returns true although open() hasn't been called that sets
the function of the timer. dev->state is 6 (I checked that).

Simple fix is attached. Although that seems to fix the symptom and not
the cause, please apply it if you don't have a better solution.


---
 r8169.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/net/r8169.c	2007-01-28 18:19:56.000000000 +0100
+++ b/drivers/net/r8169.c	2007-01-28 18:22:50.000000000 +0100
@@ -810,7 +810,8 @@ static int rtl8169_set_speed(struct net_
 
 	ret = tp->set_speed(dev, autoneg, speed, duplex);
 
-	if (netif_running(dev) && (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
+	if (netif_running(dev) && tp->timer.function &&
+			(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
 
 	return ret;


