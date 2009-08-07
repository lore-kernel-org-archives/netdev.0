From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: fix missing destroy of percpu counter variable in sctp_proc_exit()
Date: Fri,  7 Aug 2009 11:17:17 -0400
Message-ID: <1249658237-9031-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, Rafael Laufer <rlaufer@cisco.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:18753 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757537AbZHGPRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 11:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael Laufer <rlaufer@cisco.com>

Commit 1748376b6626acf59c24e9592ac67b3fe2a0e026,
	net: Use a percpu_counter for sockets_allocated

added percpu_counter function calls to sctp_proc_init code path, but
forgot to add them to sctp_proc_exit().  This resulted in a following
Ooops when performing this test
	# modprobe sctp
	# rmmod -f sctp
	# modprobe sctp

[  573.862512] BUG: unable to handle kernel paging request at f8214a24
[  573.862518] IP: [<c0308b8f>] __percpu_counter_init+0x3f/0x70
[  573.862530] *pde = 37010067 *pte = 00000000
[  573.862534] Oops: 0002 [#1] SMP
[  573.862537] last sysfs file: /sys/module/libcrc32c/initstate
[  573.862540] Modules linked in: sctp(+) crc32c libcrc32c binfmt_misc bridge
stp bnep lp snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep
snd_pcm_oss snd_mixer_oss arc4 joydev snd_pcm ecb pcmcia snd_seq_dummy
snd_seq_oss iwlagn iwlcore snd_seq_midi snd_rawmidi snd_seq_midi_event
yenta_socket rsrc_nonstatic thinkpad_acpi snd_seq snd_timer snd_seq_device
mac80211 psmouse sdhci_pci sdhci nvidia(P) ppdev video snd soundcore serio_raw
pcspkr iTCO_wdt iTCO_vendor_support led_class ricoh_mmc pcmcia_core intel_agp
nvram agpgart usbhid parport_pc parport output snd_page_alloc cfg80211 btusb
ohci1394 ieee1394 e1000e [last unloaded: sctp]
[  573.862589]
[  573.862593] Pid: 5373, comm: modprobe Tainted: P  R        (2.6.31-rc3 #6)
7663B15
[  573.862596] EIP: 0060:[<c0308b8f>] EFLAGS: 00010286 CPU: 1
[  573.862599] EIP is at __percpu_counter_init+0x3f/0x70
[  573.862602] EAX: f8214a20 EBX: f80faa14 ECX: c48c0000 EDX: f80faa20
[  573.862604] ESI: f80a7000 EDI: 00000000 EBP: f69d5ef0 ESP: f69d5eec
[  573.862606]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  573.862610] Process modprobe (pid: 5373, ti=f69d4000 task=c2130c70
task.ti=f69d4000)
[  573.862612] Stack:
[  573.862613]  00000000 f69d5f18 f80a70a8 f80fa9fc 00000000 fffffffc f69d5f30
c018e2d4
[  573.862619] <0> 00000000 f80a7000 00000000 f69d5f88 c010112b 00000000
c07029c0 fffffffb
[  573.862626] <0> 00000000 f69d5f38 c018f83f f69d5f54 c0557cad f80fa860
00000001 c07010c0
[  573.862634] Call Trace:
[  573.862644]  [<f80a70a8>] ? sctp_init+0xa8/0x7d4 [sctp]
[  573.862650]  [<c018e2d4>] ? marker_update_probe_range+0x184/0x260
[  573.862659]  [<f80a7000>] ? sctp_init+0x0/0x7d4 [sctp]
[  573.862662]  [<c010112b>] ? do_one_initcall+0x2b/0x160
[  573.862666]  [<c018f83f>] ? tracepoint_module_notify+0x2f/0x40
[  573.862671]  [<c0557cad>] ? notifier_call_chain+0x2d/0x70
[  573.862678]  [<c01588fd>] ? __blocking_notifier_call_chain+0x4d/0x60
[  573.862682]  [<c016b2f1>] ? sys_init_module+0xb1/0x1f0
[  573.862686]  [<c0102ffc>] ? sysenter_do_call+0x12/0x28
[  573.862688] Code: 89 48 08 b8 04 00 00 00 e8 df aa ec ff ba f4 ff ff ff 85
c0 89 43 14 74 31 b8 b0 18 71 c0 e8 19 b9 24 00 a1 c4 18 71 c0 8d 53 0c <89> 50
04 89 43 0c b8 b0 18 71 c0 c7 43 10 c4 18 71 c0 89 15 c4
[  573.862725] EIP: [<c0308b8f>] __percpu_counter_init+0x3f/0x70 SS:ESP
0068:f69d5eec
[  573.862730] CR2: 00000000f8214a24
[  573.862734] ---[ end trace 39c4e0b55e7cf54d ]---

Signed-off-by: Rafael Laufer <rlaufer@cisco.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/protocol.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 79cbd47..a76da65 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -160,6 +160,7 @@ static void sctp_proc_exit(void)
 		remove_proc_entry("sctp", init_net.proc_net);
 	}
 #endif
+	percpu_counter_destroy(&sctp_sockets_allocated);
 }
 
 /* Private helper to extract ipv4 address and stash them in
-- 
1.5.4.3

