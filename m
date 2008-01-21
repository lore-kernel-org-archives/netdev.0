From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix kernel panic while received AUTH chunk while enabled
 auth
Date: Tue, 22 Jan 2008 01:15:23 +0900
Message-ID: <4794C51B.8040904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49584 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755142AbYAUQQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 11:16:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If STCP is started while /proc/sys/net/sctp/auth_enable is set 0 and 
association is established between endpoints. Then if 
/proc/sys/net/sctp/auth_enable is set 1, a received AUTH chunk will 
cause kernel panic.

Test as following:
step 1: echo 0> /proc/sys/net/sctp/auth_enable
step 2:

    SCTP client                  SCTP server
       INIT          --------->
                     <---------   INIT-ACK
       COOKIE-ECHO   --------->
                     <---------   COOKIE-ACK
step 3:
     echo 1> /proc/sys/net/sctp/auth_enable
step 4:
    SCTP client                  SCTP server
        AUTH        ----------->

Then kernel panic.

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
printing eip: c8a8a266 *pde = 047d4067 *pte = 00000000
Oops: 0000 [#1] SMP
Modules linked in: md5 sctp ipv6 dm_mirror dm_mod sbs sbshc battery lp snd_ens1371 gameport snd_rawmidi sg snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss floppy snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss ide_cd snd_mixer_oss cdrom serio_raw snd_pcm snd_timer ac parport_pc snd parport button soundcore pcne t32 snd_page_alloc mii i2c_piix4 i2c_core pcspkr mptspi mptscsih mptbase scsi_tr ansport_spi sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd

Pid: 0, comm: swapper Not tainted (2.6.24-rc8 #1)
EIP: 0060:[<c8a8a266>] EFLAGS: 00010202 CPU: 0
EIP is at sctp_auth_calculate_hmac+0xd9/0x126 [sctp]
EAX: 00000000 EBX: c7ade000 ECX: 00000002 EDX: 00000001
ESI: 00000000 EDI: c0756d14 EBP: c7ac2c40 ESP: c0756cf4
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0756000 task=c06d63a0 task.ti=c070f000)
Stack: c04058c0 c0756d04 00010246 00000000 c10f5842 00000c40 00000000 0000001c
       0000007b 0000007b 00000014 c7ac2c48 c7ac2c5c c34a9820 c8a72157 00000020
       c7ade000 c34aabc0 c7ade000 c0756da8 c7ac2c44 c8a76068 c34aabc0 c8a8fd04
Call Trace:
 [<c04058c0>] apic_timer_interrupt+0x28/0x30
 [<c8a72157>] sctp_sf_authenticate+0x126/0x160 [sctp]
 [<c8a76068>] sctp_sf_eat_auth+0x13c/0x159 [sctp]
 [<c8a89390>] sctp_cname+0x0/0x38 [sctp]
 [<c8a76835>] sctp_do_sm+0xb4/0x103f [sctp]
 [<c8a7a639>] sctp_assoc_bh_rcv+0xc1/0xf4 [sctp]
 [<c8a7ebdb>] sctp_inq_push+0x2a/0x2d [sctp]
 [<c8a892af>] sctp_rcv+0x5c3/0x6a4 [sctp]
 [<c0425241>] try_to_wake_up+0x3bb/0x3c5
 [<c042256f>] find_busiest_group+0x204/0x5f3
 [<c042147d>] enqueue_task+0x49/0x54
 [<c05dd7be>] ip_local_deliver_finish+0xda/0x17d
 [<c05dd6c5>] ip_rcv_finish+0x2c5/0x2e4
 [<c05dd91d>] ip_rcv+0x0/0x237
 [<c05c13f1>] netif_receive_skb+0x328/0x392
 [<c05c37c4>] process_backlog+0x5c/0x9a
 [<c05c32d2>] net_rx_action+0x8d/0x163
 [<c0432db7>] run_timer_softirq+0x2f/0x156
 [<c042fdd3>] __do_softirq+0x5d/0xc1
 [<c0406f38>] do_softirq+0x59/0xa8
 [<c042cb0c>] profile_tick+0x43/0x5e
 [<c0441e6b>] tick_handle_periodic+0x17/0x5c
 [<c04546c7>] handle_fasteoi_irq+0x0/0xa6
 [<c0407044>] do_IRQ+0xbd/0xd1
 [<c041ae2a>] smp_apic_timer_interrupt+0x74/0x80
 [<c0403c87>] default_idle+0x0/0x3e
 [<c0405803>] common_interrupt+0x23/0x28
 [<c0403c87>] default_idle+0x0/0x3e
 [<c0403cb3>] default_idle+0x2c/0x3e
 [<c0403571>] cpu_idle+0x92/0xab
 [<c07148ea>] start_kernel+0x2f7/0x2ff
 [<c07140e0>] unknown_bootoption+0x0/0x195
 =======================
Code: 0b eb fe 83 e1 02 29 ea 09 c8 89 44 24 10 89 e8 25 ff 0f 00 00 89 54 24 1c                                              0f b7 54 24 0a 89 44 24 14 8b 43 58 8b 80 ac 00 00 00 <8b> 1c 90 8d 56 08 c7 44                                              24 24 00 00 00 00 89 5c 24 20 8b 4e 04
EIP: [<c8a8a266>] sctp_auth_calculate_hmac+0xd9/0x126 [sctp] SS:ESP 0068:c0756cf                                             4
Kernel panic - not syncing: Fatal exception in interrupt


This patch fix this probleam to treat AUTH chunk as unknow chunk if peer 
has initialized with no auth capable.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/sctp/sm_statefuns.c	2008-01-21 00:03:25.000000000 -0500
+++ b/net/sctp/sm_statefuns.c	2008-01-21 05:14:08.000000000 -0500
@@ -3785,6 +3785,10 @@ sctp_disposition_t sctp_sf_eat_auth(cons
 	struct sctp_chunk *err_chunk;
 	sctp_ierror_t error;
 
+	/* Make sure that the peer has AUTH capable */
+	if (!asoc->peer.auth_capable)
+		return sctp_sf_unk_chunk(ep, asoc, type, arg, commands);
+
 	if (!sctp_vtag_verify(chunk, asoc)) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_REPORT_BAD_TAG,
 				SCTP_NULL());



