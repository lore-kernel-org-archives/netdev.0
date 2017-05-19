From: Akshay Narayan <akshayn@mit.edu>
Subject: [PATCH net] fix BUG: scheduling while atomic in netlink broadcast
Date: Fri, 19 May 2017 13:22:08 -0400
Message-ID: <CAN-7y0oY=LyeLTxhC5L+Vjy-NivmRJSBpqPP9+NYT7a=NFV0_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-3.mit.edu ([18.9.25.14]:50877 "EHLO
        dmz-mailsec-scanner-3.mit.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750748AbdESR1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 13:27:34 -0400
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
        by mailhub-auth-3.mit.edu (8.13.8/8.9.2) with ESMTP id v4JHMViA015827
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 13:22:31 -0400
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
        (authenticated bits=0)
        (User authenticated as akshayn@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.13.8/8.12.4) with ESMTP id v4JHMTET032404
        (version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 13:22:30 -0400
Received: by mail-oi0-f41.google.com with SMTP id l18so100146210oig.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:22:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_broadcast_filtered() calls yield() when a slow listener causes
the buffer to fill. yield() is the wrong choice here, as pointed out by
Commit 8e3fabfde4 (sched: Update yield() docs); in some cases, its use causes
"BUG: scheduling while atomic" and, when fewer cores are available,
kernel hangs:

(note: "ccp" is a kernel module which multicasts netlink messages upon
certain TCP events)
May 17 17:33:56 ccp kernel: [  394.493978] BUG: scheduling while
atomic: iperf/4744/0x00000101
May 17 17:33:56 ccp kernel: [  394.493979] Modules linked in: ccp(OE)
snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm crct10dif_pclmul
crc32_pclmul ghash_clmulni_intel snd_seq_midi snd_seq_midi_event
snd_rawmidi snd_seq joydev pcbc snd_seq
_device snd_timer snd vboxvideo aesni_intel aes_x86_64 i2c_piix4
input_leds crypto_simd glue_helper cryptd soundcore mac_hid vboxguest
intel_rapl_perf serio_raw ttm drm_kms_helper drm fb_sys_fops
syscopyarea sysfillrect sysimgblt parpor
t_pc ppdev lp parport ip_tables x_tables autofs4 hid_generic usbhid
hid psmouse ahci e1000 libahci pata_acpi fjes video [last unloaded:
ccp]
May 17 17:33:56 ccp kernel: [  394.493997] CPU: 0 PID: 4744 Comm:
iperf Tainted: G        W  OE   4.10.0-21-generic #23-Ubuntu
May 17 17:33:56 ccp kernel: [  394.493997] Hardware name: innotek GmbH
VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
May 17 17:33:56 ccp kernel: [  394.493997] Call Trace:
May 17 17:33:56 ccp kernel: [  394.493998]  <IRQ>
May 17 17:33:56 ccp kernel: [  394.494000]  dump_stack+0x63/0x81
May 17 17:33:56 ccp kernel: [  394.494001]  __schedule_bug+0x54/0x70
May 17 17:33:56 ccp kernel: [  394.494002]  __schedule+0x536/0x6f0
May 17 17:33:56 ccp kernel: [  394.494004]  schedule+0x36/0x80
May 17 17:33:56 ccp kernel: [  394.494005]  sys_sched_yield+0x4f/0x60
May 17 17:33:56 ccp kernel: [  394.494005]  yield+0x33/0x40
May 17 17:33:56 ccp kernel: [  394.494006]
netlink_broadcast_filtered+0x29b/0x3c0
May 17 17:33:56 ccp kernel: [  394.494007]  netlink_broadcast+0x1d/0x20
...
May 17 17:33:56 ccp kernel: [  394.494080] softirq: huh, entered
softirq 3 NET_RX ffffffff85fb5c60 with preempt_count 00000101, exited
with 00000000?

Changing this call to cond_resched() prevents this.
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 161b628..f70716c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1441,7 +1441,7 @@ int netlink_broadcast_filtered(struct sock *ssk,
struct sk_buff *skb, u32 portid

        if (info.delivered) {
                if (info.congested && gfpflags_allow_blocking(allocation))
-                       yield();
+                       cond_resched();
                return 0;
        }
        return -ESRCH;
