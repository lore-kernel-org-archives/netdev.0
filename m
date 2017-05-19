From: Akshay Narayan <akshayn@mit.edu>
Subject: Re: [PATCH net] fix BUG: scheduling while atomic in netlink broadcast
Date: Fri, 19 May 2017 14:47:01 -0400
Message-ID: <CAN-7y0rZV-coOpOAzVGZoZB=Mzo4LP7Jpxx3wk+PX_jNMr_=iA@mail.gmail.com>
References: <CAN-7y0oY=LyeLTxhC5L+Vjy-NivmRJSBpqPP9+NYT7a=NFV0_A@mail.gmail.com>
 <CAM_iQpXraspjEvh9Wy5jOscFz7zKS4Z3XsigxCJFJ5_RuCOnyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-6.mit.edu ([18.7.68.35]:63258 "EHLO
        dmz-mailsec-scanner-6.mit.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755966AbdESSw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 14:52:28 -0400
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
        by mailhub-auth-1.mit.edu (8.13.8/8.9.2) with ESMTP id v4JIlO16026700
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 14:47:25 -0400
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
        (authenticated bits=0)
        (User authenticated as akshayn@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.13.8/8.12.4) with ESMTP id v4JIlMqo028866
        (version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 14:47:23 -0400
Received: by mail-oi0-f41.google.com with SMTP id l18so102778257oig.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 11:47:23 -0700 (PDT)
In-Reply-To: <CAM_iQpXraspjEvh9Wy5jOscFz7zKS4Z3XsigxCJFJ5_RuCOnyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't want to defend the use of yield() but it looks like there is other
> problem.

I believe this use of yield() should be replaced with cond_resched()
even if it turns out there is an unrelated problem.

> Does this module call netlink_broadcast() with __GFP_DIRECT_RECLAIM
> in IRQ context? If so you should adjust the gfp flags.

The module only calls netlink_broadcast() from a pluggable TCP
function; from my understanding this is not in the IRQ context. Full
trace, perhaps more clear, attached below.

May 19 14:30:44 ccp kernel: [  178.885546] BUG: scheduling while
atomic: mm-link/3105/0x00000200
May 19 14:30:44 ccp kernel: [  178.885552] Modules linked in:
ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat libcrc32c xt_connmark nf_conntrack
ccp(OE) crct10dif_pclmul crc32_pclmul
 ghash_clmulni_intel snd_intel8x0 pcbc snd_ac97_codec joydev ac97_bus
snd_pcm snd_seq_midi snd_seq_midi_event snd_rawmidi aesni_intel
snd_seq aes_x86_64 crypto_simd snd_seq_device snd_timer snd input_leds
i2c_piix4 glue_helper cryptd so
undcore mac_hid serio_raw vboxvideo ttm drm_kms_helper drm fb_sys_fops
syscopyarea sysfillrect sysimgblt vboxguest intel_rapl_perf parport_pc
ppdev lp parport ip_tables x_tables autofs4 hid_generic usbhid hid
e1000 ahci libahci psmouse
fjes pata_acpi video
May 19 14:30:44 ccp kernel: [  178.885665] CPU: 0 PID: 3105 Comm:
mm-link Tainted: G        W  OE   4.10.0-21-generic #23-Ubuntu
May 19 14:30:44 ccp kernel: [  178.885666] Hardware name: innotek GmbH
VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
May 19 14:30:44 ccp kernel: [  178.885667] Call Trace:
May 19 14:30:44 ccp kernel: [  178.885674]  dump_stack+0x63/0x81
May 19 14:30:44 ccp kernel: [  178.885678]  __schedule_bug+0x54/0x70
May 19 14:30:44 ccp kernel: [  178.885682]  __schedule+0x536/0x6f0
May 19 14:30:44 ccp kernel: [  178.885685]  schedule+0x36/0x80
May 19 14:30:44 ccp kernel: [  178.885687]  sys_sched_yield+0x4f/0x60
May 19 14:30:44 ccp kernel: [  178.885688]  yield+0x33/0x40
May 19 14:30:44 ccp kernel: [  178.885691]
netlink_broadcast_filtered+0x29b/0x3c0
May 19 14:30:44 ccp kernel: [  178.885692]  netlink_broadcast+0x1d/0x20
May 19 14:30:44 ccp kernel: [  178.885697]  nl_sendmsg+0xb8/0x664 [ccp]
May 19 14:30:44 ccp kernel: [  178.885699]  nl_send_ack_notif+0x7d/0x90 [ccp]
May 19 14:30:44 ccp kernel: [  178.885702]  tcp_ccp_cong_avoid+0x69/0x70 [ccp]
May 19 14:30:44 ccp kernel: [  178.885704]  tcp_ack+0x980/0xa60
May 19 14:30:44 ccp kernel: [  178.885708]  tcp_rcv_state_process+0x2be/0xda0
May 19 14:30:44 ccp kernel: [  178.885712]  ? security_sock_rcv_skb+0x3b/0x50
May 19 14:30:44 ccp kernel: [  178.885715]  ? sk_filter_trim_cap+0x3b/0x270
May 19 14:30:44 ccp kernel: [  178.885717]  tcp_v4_do_rcv+0xb2/0x200
May 19 14:30:44 ccp kernel: [  178.885719]  tcp_v4_rcv+0x90a/0xa00
May 19 14:30:44 ccp kernel: [  178.885722]  ip_local_deliver_finish+0x96/0x1c0
May 19 14:30:44 ccp kernel: [  178.885725]  ip_local_deliver+0x6f/0xe0
May 19 14:30:44 ccp kernel: [  178.885727]  ? ip_rcv_finish+0x3f0/0x3f0
May 19 14:30:44 ccp kernel: [  178.885730]  ip_rcv_finish+0x118/0x3f0
May 19 14:30:44 ccp kernel: [  178.885732]  ip_rcv+0x282/0x390
May 19 14:30:44 ccp kernel: [  178.885735]  ? inet_del_offload+0x40/0x40
May 19 14:30:44 ccp kernel: [  178.885737]  __netif_receive_skb_core+0x514/0xa40
May 19 14:30:44 ccp kernel: [  178.885740]  ? __check_object_size+0x10/0x1d7
May 19 14:30:44 ccp kernel: [  178.885742]  __netif_receive_skb+0x18/0x60
May 19 14:30:44 ccp kernel: [  178.885744]  netif_receive_skb_internal+0x32/0xa0
May 19 14:30:44 ccp kernel: [  178.885746]  netif_receive_skb+0x1c/0x70
May 19 14:30:44 ccp kernel: [  178.885749]  tun_get_user+0x425/0x800
May 19 14:30:44 ccp kernel: [  178.885751]  tun_chr_write_iter+0x57/0x70
May 19 14:30:44 ccp kernel: [  178.885752]  new_sync_write+0xd5/0x130
May 19 14:30:44 ccp kernel: [  178.885754]  __vfs_write+0x26/0x40
May 19 14:30:44 ccp kernel: [  178.885756]  vfs_write+0xb5/0x1a0
May 19 14:30:44 ccp kernel: [  178.885757]  SyS_write+0x55/0xc0
May 19 14:30:44 ccp kernel: [  178.885760]  entry_SYSCALL_64_fastpath+0x1e/0xad
May 19 14:30:44 ccp kernel: [  178.885762] RIP: 0033:0x7f8d9abbf670
May 19 14:30:44 ccp kernel: [  178.885763] RSP: 002b:00007ffc2f16d8b8
EFLAGS: 00000246 ORIG_RAX: 0000000000000001
May 19 14:30:44 ccp kernel: [  178.885765] RAX: ffffffffffffffda RBX:
00007ffc2f16dde0 RCX: 00007f8d9abbf670
May 19 14:30:44 ccp kernel: [  178.885767] RDX: 0000000000000038 RSI:
0000557403fd86e0 RDI: 0000000000000008
May 19 14:30:44 ccp kernel: [  178.885768] RBP: 00007ffc2f16dcd0 R08:
0000557403fd8d40 R09: 0000557403fd8690
May 19 14:30:44 ccp kernel: [  178.885769] R10: 000e20d41e89a5c5 R11:
0000000000000246 R12: 0000000000000108
May 19 14:30:44 ccp kernel: [  178.885770] R13: 000000000000145c R14:
00007ffc2f16dd98 R15: 0000000000000003
