From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix kernel panic while received AUTH chunk with BAD
 shared key identifier
Date: Tue, 22 Jan 2008 17:29:20 +0900
Message-ID: <4795A960.7000700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:32935 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbYAVIai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 03:30:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If SCTP-AUTH is enabled, received AUTH chunk with BAD shared key 
identifier will cause kernel panic.

Test as following:
step1: enabled /proc/sys/net/sctp/auth_enable
step 2:  connect  to SCTP server with auth capable. Association is 
established between endpoints. Then send a AUTH chunk with a bad 
shareid, SCTP server will kernel panic after received that AUTH chunk.

SCTP client                   SCTP server
  INIT         ---------->   
    (with auth capable)
               <----------    INIT-ACK
                              (with auth capable)
  COOKIE-ECHO  ---------->
               <----------    COOKIE-ACK
  AUTH         ---------->


AUTH chunk is like this:
  AUTH chunk
    Chunk type: AUTH (15)
    Chunk flags: 0x00
    Chunk length: 28
    Shared key identifier: 10
    HMAC identifier: SHA-1 (1)
    HMAC: 0000000000000000000000000000000000000000

kernel panic message:

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000005
printing eip: c8f5de2e *pde = 07bc6067 *pte = 00000000
Oops: 0000 [#1] SMP
Modules linked in: sha256_generic md5 sctp ipv6 dm_mirror dm_mod sbs sbshc battery lp snd_ens1371 sg gameport snd_rawmidi snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss floppy snd_mixer_oss ide_cd snd_pcm cdrom serio_raw ac snd_timer snd button pcnet32 soundcore mii snd_page_alloc parport_pc parport i2c_piix4 i2c_core pcspkr mptspi mptscsih mptbase scsi_transport_spi sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd

Pid: 0, comm: swapper Not tainted (2.6.24-rc8 #1)
EIP: 0060:[<c8f5de2e>] EFLAGS: 00010202 CPU: 0
EIP is at sctp_auth_asoc_create_secret+0xe9/0x1a1 [sctp]
EAX: 00000056 EBX: c701a940 ECX: c701ab00 EDX: 00000001
ESI: c7ae9444 EDI: fffffffe EBP: c701a940 ESP: c0756cc0
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0756000 task=c06d63a0 task.ti=c070f000)
Stack: 00000020 00000020 c7ae9444 c701ab00 c701ab00 c701a940 c0756da8 c701a948
       c7ae8000 c7ad1e48 c7bee300 c7ad1e40 c8f5e183 c04058c0 c38b9bc0 00010246
       c7ad1e48 c7ad1e48 c0756da8 00000014 c0460992 0000007b 0000007b 00000014
Call Trace:
 [<c8f5e183>] sctp_auth_calculate_hmac+0x5a/0x126 [sctp]
 [<c04058c0>] apic_timer_interrupt+0x28/0x30
 [<c0460992>] kmemdup+0x14/0x33
 [<c8f46157>] sctp_sf_authenticate+0x126/0x160 [sctp]
 [<c8f4a068>] sctp_sf_eat_auth+0x13c/0x159 [sctp]
 [<c8f5d32c>] sctp_cname+0x0/0x38 [sctp]
 [<c8f4a835>] sctp_do_sm+0xb4/0x103f [sctp]
 [<c8f4e639>] sctp_assoc_bh_rcv+0xc1/0xf4 [sctp]
 [<c8f52b77>] sctp_inq_push+0x2a/0x2d [sctp]
 [<c8f5d24b>] sctp_rcv+0x5c3/0x6a4 [sctp]
 [<c0425241>] try_to_wake_up+0x3bb/0x3c5
 [<c042256f>] find_busiest_group+0x204/0x5f3
 [<c05dd7be>] ip_local_deliver_finish+0xda/0x17d
 [<c05dd6c5>] ip_rcv_finish+0x2c5/0x2e4
 [<c05dd91d>] ip_rcv+0x0/0x237
 [<c05c13f1>] netif_receive_skb+0x328/0x392
 [<c05c37c4>] process_backlog+0x5c/0x9a
 [<c05c32d2>] net_rx_action+0x8d/0x163
 [<c0432db7>] run_timer_softirq+0x2f/0x156
 [<c042fdd3>] __do_softirq+0x5d/0xc1
 [<c0406f38>] do_softirq+0x59/0xa8
 [<c0441e6b>] tick_handle_periodic+0x17/0x5c
 [<c041ae2a>] smp_apic_timer_interrupt+0x74/0x80
 [<c0403c87>] default_idle+0x0/0x3e
 [<c0403c87>] default_idle+0x0/0x3e
 [<c04058c0>] apic_timer_interrupt+0x28/0x30
 [<c0403c87>] default_idle+0x0/0x3e
 [<c0403cb3>] default_idle+0x2c/0x3e
 [<c0403571>] cpu_idle+0x92/0xab
 [<c07148ea>] start_kernel+0x2f7/0x2ff
 [<c07140e0>] unknown_bootoption+0x0/0x195
 =======================
Code: 89 6c 24 14 89 54 24 10 78 08 89 6c 24 10 89 54 24 14 8b 74 24 08 8b 4c 24 10 8b 5c 24 14 8b 56 0c 8b 41 04 03 43 04 85 d2 74 03 <03> 42 04 8b 54 24 04 e8 eb fe ff ff 85 c0 89 44 24 18 0f 84 84
EIP: [<c8f5de2e>] sctp_auth_asoc_create_secret+0xe9/0x1a1 [sctp] SS:ESP 0068:c0756cc0
Kernel panic - not syncing: Fatal exception in interrupt


This patch fix this problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/sctp/auth.c	2008-01-21 00:03:25.000000000 -0500
+++ b/net/sctp/auth.c	2008-01-21 21:31:47.000000000 -0500
@@ -420,15 +420,15 @@ struct sctp_shared_key *sctp_auth_get_sh
 				const struct sctp_association *asoc,
 				__u16 key_id)
 {
-	struct sctp_shared_key *key = NULL;
+	struct sctp_shared_key *key;
 
 	/* First search associations set of endpoint pair shared keys */
 	key_for_each(key, &asoc->endpoint_shared_keys) {
 		if (key->key_id == key_id)
-			break;
+			return key;
 	}
 
-	return key;
+	return NULL;
 }
 
 /*


