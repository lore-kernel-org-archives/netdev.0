From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] fix BUG: scheduling while atomic in netlink
 broadcast
Date: Fri, 19 May 2017 13:40:49 -0700
Message-ID: <1495226449.6465.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAN-7y0oY=LyeLTxhC5L+Vjy-NivmRJSBpqPP9+NYT7a=NFV0_A@mail.gmail.com>
         <CAM_iQpXraspjEvh9Wy5jOscFz7zKS4Z3XsigxCJFJ5_RuCOnyw@mail.gmail.com>
         <CAN-7y0rZV-coOpOAzVGZoZB=Mzo4LP7Jpxx3wk+PX_jNMr_=iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Akshay Narayan <akshayn@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34483 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756744AbdESUkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:40:52 -0400
Received: by mail-pg0-f65.google.com with SMTP id u187so10767741pgb.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 13:40:52 -0700 (PDT)
In-Reply-To: <CAN-7y0rZV-coOpOAzVGZoZB=Mzo4LP7Jpxx3wk+PX_jNMr_=iA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-19 at 14:47 -0400, Akshay Narayan wrote:
> > I don't want to defend the use of yield() but it looks like there is other
> > problem.
> 
> I believe this use of yield() should be replaced with cond_resched()
> even if it turns out there is an unrelated problem.
> 
> > Does this module call netlink_broadcast() with __GFP_DIRECT_RECLAIM
> > in IRQ context? If so you should adjust the gfp flags.
> 
> The module only calls netlink_broadcast() from a pluggable TCP
> function; from my understanding this is not in the IRQ context. Full
> trace, perhaps more clear, attached below.
> 
> May 19 14:30:44 ccp kernel: [  178.885546] BUG: scheduling while
> atomic: mm-link/3105/0x00000200
> May 19 14:30:44 ccp kernel: [  178.885552] Modules linked in:
> ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
> nf_defrag_ipv4 nf_nat_ipv4 nf_nat libcrc32c xt_connmark nf_conntrack
> ccp(OE) crct10dif_pclmul crc32_pclmul
>  ghash_clmulni_intel snd_intel8x0 pcbc snd_ac97_codec joydev ac97_bus
> snd_pcm snd_seq_midi snd_seq_midi_event snd_rawmidi aesni_intel
> snd_seq aes_x86_64 crypto_simd snd_seq_device snd_timer snd input_leds
> i2c_piix4 glue_helper cryptd so
> undcore mac_hid serio_raw vboxvideo ttm drm_kms_helper drm fb_sys_fops
> syscopyarea sysfillrect sysimgblt vboxguest intel_rapl_perf parport_pc
> ppdev lp parport ip_tables x_tables autofs4 hid_generic usbhid hid
> e1000 ahci libahci psmouse
> fjes pata_acpi video
> May 19 14:30:44 ccp kernel: [  178.885665] CPU: 0 PID: 3105 Comm:
> mm-link Tainted: G        W  OE   4.10.0-21-generic #23-Ubuntu
> May 19 14:30:44 ccp kernel: [  178.885666] Hardware name: innotek GmbH
> VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
> May 19 14:30:44 ccp kernel: [  178.885667] Call Trace:
> May 19 14:30:44 ccp kernel: [  178.885674]  dump_stack+0x63/0x81
> May 19 14:30:44 ccp kernel: [  178.885678]  __schedule_bug+0x54/0x70
> May 19 14:30:44 ccp kernel: [  178.885682]  __schedule+0x536/0x6f0
> May 19 14:30:44 ccp kernel: [  178.885685]  schedule+0x36/0x80
> May 19 14:30:44 ccp kernel: [  178.885687]  sys_sched_yield+0x4f/0x60
> May 19 14:30:44 ccp kernel: [  178.885688]  yield+0x33/0x40
> May 19 14:30:44 ccp kernel: [  178.885691]
> netlink_broadcast_filtered+0x29b/0x3c0
> May 19 14:30:44 ccp kernel: [  178.885692]  netlink_broadcast+0x1d/0x20
> May 19 14:30:44 ccp kernel: [  178.885697]  nl_sendmsg+0xb8/0x664 [ccp]
> May 19 14:30:44 ccp kernel: [  178.885699]  nl_send_ack_notif+0x7d/0x90 [ccp]
> May 19 14:30:44 ccp kernel: [  178.885702]  tcp_ccp_cong_avoid+0x69/0x70 [ccp]
> May 19 14:30:44 ccp kernel: [  178.885704]  tcp_ack+0x980/0xa60
> May 19 14:30:44 ccp kernel: [  178.885708]  tcp_rcv_state_process+0x2be/0xda0
> May 19 14:30:44 ccp kernel: [  178.885712]  ? security_sock_rcv_skb+0x3b/0x50
> May 19 14:30:44 ccp kernel: [  178.885715]  ? sk_filter_trim_cap+0x3b/0x270

No idea what ccp is, it is not in upstream kernel, and it looks buggy.

Please do not send patches that are not needed in upstream kernel.
