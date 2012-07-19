From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: [PATCH] Crash in tun
Date: Thu, 19 Jul 2012 03:12:13 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1207190213001.16299@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Maxim Krasnyansky <maxk@qualcomm.com>, vtun@office.satix.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from artax.karlin.mff.cuni.cz ([195.113.26.195]:48085 "EHLO
	artax.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab2GSBUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 21:20:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I want to report a crash when using the tun driver. The crash can be 
reproduced by starting and stopping miredo in the loop:

while ! dmesg | grep -q BUG; do
	/etc/init.d/miredo start;/etc/init.d/miredo stop
done

The crash happens in iput_final because inode->i_sb->s_op is NULL.

The crash happens in 3.4, 3.4.5, 3.5-rc7. The crash does not happen in 
3.3. When I attempted to bisect, unrelated changes in completely different 
driver regarding memory allocation triggered the crash --- so it is 
likely buggy even in 3.3 and before, it just didn't show up.


What is obviously wrong:
in the tun driver "struct socket" is embedded in "struct tun_struct".

The backtrace goes through:
netdev_run_todo -> tun_free_netdev -> sk_release_kernel -> sock_release.

sock_release calls iput(SOCK_INODE(sock)). SOCK_INODE assumes that struct 
socket is embedded in "struct socket_alloc" (which is not true, it is 
embedded in "struct tun_struct"), gets a pointer to non-existing inode --- 
and there goes the crash.


The crash can be fixed by writing any non-NULL value to tun->socket.file 
to prevent sock_release from calling iput(SOCK_INODE(sock)). Or maybe you 
come up with a better fix.


Note another bug - when you are repeatedly starting and stopping miredo, 
even if it doesn't crash, the value "sockets: used" in 
/proc/*/net/sockstat keeps on decreasing. That's because sock_release 
decrements sockets_in_use, but there was no sock_alloc to increment it.


Mikulas

---

Signed-off-by: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>

---
 drivers/net/tun.c |    2 ++
 net/socket.c      |    4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: linux-3.4.5-fast/drivers/net/tun.c
===================================================================
--- linux-3.4.5-fast.orig/drivers/net/tun.c	2012-07-19 02:42:56.000000000 +0200
+++ linux-3.4.5-fast/drivers/net/tun.c	2012-07-19 02:50:13.000000000 +0200
@@ -358,6 +358,8 @@ static void tun_free_netdev(struct net_d
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
+	/* Prevent the code in sock_release from calling iput. */
+	tun->socket.file = (void *)1;
 	sk_release_kernel(tun->socket.sk);
 }
 
Index: linux-3.4.5-fast/net/socket.c
===================================================================
--- linux-3.4.5-fast.orig/net/socket.c	2012-07-19 03:00:30.000000000 +0200
+++ linux-3.4.5-fast/net/socket.c	2012-07-19 03:05:36.000000000 +0200
@@ -522,7 +522,9 @@ void sock_release(struct socket *sock)
 	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
 
-	percpu_sub(sockets_in_use, 1);
+	/* a hack - sockets_in_use should not be decremented when tun calls this */
+	if (sock->file != (void *)1)
+		percpu_sub(sockets_in_use, 1);
 	if (!sock->file) {
 		iput(SOCK_INODE(sock));
 		return;
 
--- 

BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
IP: [<ffffffff81113246>] iput+0x76/0x230
PGD 43e5e9067 PUD 4468d5067 PMD 0
Oops: 0000 [#1] PREEMPT SMP
CPU 1
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables 
ebtable_nat ebtables x_tables kvm_amd kvm tun cpufreq_userspace 
cpufreq_stats cpufreq_powersave cpufreq_ondemand cpufreq_conservative ipv6 
fuse raid0 md_mod lm85 hwmon_vid snd_usb_audio snd_pcm_oss snd_mixer_oss 
snd_pcm snd_timer snd_page_alloc snd_hwdep snd_usbmidi_lib snd_rawmidi snd 
soundcore ide_cd_mod cdrom ohci_hcd sata_svw libata serverworks ide_core 
powernow_k8 ehci_hcd usbcore tg3 usb_common floppy freq_table e100 skge 
mii i2c_piix4 libphy mperf k10temp rtc_cmos processor button hwmon 
microcode unix

Pid: 10826, comm: miredo Not tainted 3.4.5 #85 empty empty/S3992-E
RIP: 0010:[<ffffffff81113246>]  [<ffffffff81113246>] iput+0x76/0x230
RSP: 0018:ffff88043dc73e48  EFLAGS: 00010246
RAX: 0000000000000001 RBX: ffff88023eba3f20 RCX: ffff880447d80000
RDX: 0000000000000001 RSI: ffff88023eba3f98 RDI: ffff88023eba3f98
RBP: ffff88023eba3f98 R08: ffffffff814804d8 R09: 0000000000000000
R10: 0000000000000096 R11: dead000000100100 R12: ffff88023eba3f48
R13: 0000000000000000 R14: ffff88043dc73e88 R15: 00000000ffffad3a
FS:  00007fe71bbb9700(0000) GS:ffff880247c80000(0000) 
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000020 CR3: 000000043dcf0000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process miredo (pid: 10826, threadinfo ffff88043dc72000, task 
ffff88043dc1b8d0) Stack:
 ffff88043dc73e88 ffff88023efef000 ffff88023eba3800 ffff88023eba3c00
 ffff88024749ecc0 ffffffff81281d93 ffff88023e8fa500 ffffffff81295438
 ffff88043dc73e88 ffff88043dc73e88 ffff88023eba38f8 ffff88023e8fa500
Call Trace:
 [<ffffffff81281d93>] ? sk_release_kernel+0x23/0x40
 [<ffffffff81295438>] ? netdev_run_todo+0x1a8/0x260
 [<ffffffffa02522a3>] ? tun_chr_close+0x93/0xb0 [tun]
 [<ffffffff810fc3ed>] ? fput+0xdd/0x260
 [<ffffffff810f8aff>] ? filp_close+0x5f/0x90
 [<ffffffff810f8bc7>] ? sys_close+0x97/0x100
 [<ffffffff81311f22>] ? system_call_fastpath+0x16/0x1b
Code: 6c 24 10 4c 8b 64 24 18 4c 8b 6c 24 20 48 83 c4 28 c3 0f 1f 00 f6 83 
90 00 00 00 08 4c 8b 63 28 4d 8b 6c 24 30 0f 85 7d 01 00 00 <49> 8b 45 20 
48 85 c0 0f 84 9d 00 00 00 48 89 df ff d0 85 c0 0f
RIP  [<ffffffff81113246>] iput+0x76/0x230
 RSP <ffff88043dc73e48>
CR2: 0000000000000020
---[ end trace 6bd5160ffd3ba7a2 ]---
note: miredo[10826] exited with preempt_count 1
