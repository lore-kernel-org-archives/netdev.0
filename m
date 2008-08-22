From: adobriyan@gmail.com
Subject: Re: [PATCH 1/1] icmp: icmp_sk() should not use smp_processor_id() in preemptible code
Date: Sat, 23 Aug 2008 03:21:46 +0400
Message-ID: <20080822232146.GA3371@x200.localdomain>
References: <20080821122040.GA2497@x200.localdomain> <1219413273-14281-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dlezcano@fr.ibm.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:3044 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056AbYHVXUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 19:20:19 -0400
Received: by mu-out-0910.google.com with SMTP id w8so851132mue.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 16:20:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1219413273-14281-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 05:54:33PM +0400, Denis V. Lunev wrote:
> Pass namespace into icmp_xmit_lock, obtain socket inside and return
> it as a result for caller.
> 
> Thanks Alexey Dobryan for this report:
> 
> Steps to reproduce:
> 
> 	CONFIG_PREEMPT=y
> 	CONFIG_DEBUG_PREEMPT=y
> 	tracepath <something>
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: tracepath/3205
> caller is icmp_sk+0x15/0x30
> Pid: 3205, comm: tracepath Not tainted 2.6.27-rc4 #1
> 
> Call Trace:
>  [<ffffffff8031af14>] debug_smp_processor_id+0xe4/0xf0
>  [<ffffffff80409405>] icmp_sk+0x15/0x30
>  [<ffffffff8040a17b>] icmp_send+0x4b/0x3f0
>  [<ffffffff8025a415>] ? trace_hardirqs_on_caller+0xd5/0x160
>  [<ffffffff8025a4ad>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff8023a475>] ? local_bh_enable_ip+0x95/0x110
>  [<ffffffff804285b9>] ? _spin_unlock_bh+0x39/0x40
>  [<ffffffff8025a26c>] ? mark_held_locks+0x4c/0x90
>  [<ffffffff8025a4ad>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff8025a415>] ? trace_hardirqs_on_caller+0xd5/0x160
>  [<ffffffff803e91b4>] ip_fragment+0x8d4/0x900
>  [<ffffffff803e7030>] ? ip_finish_output2+0x0/0x290
>  [<ffffffff803e91e0>] ? ip_finish_output+0x0/0x60
>  [<ffffffff803e6650>] ? dst_output+0x0/0x10
>  [<ffffffff803e922c>] ip_finish_output+0x4c/0x60
>  [<ffffffff803e92e3>] ip_output+0xa3/0xf0
>  [<ffffffff803e68d0>] ip_local_out+0x20/0x30
>  [<ffffffff803e753f>] ip_push_pending_frames+0x27f/0x400
>  [<ffffffff80406313>] udp_push_pending_frames+0x233/0x3d0
>  [<ffffffff804067d1>] udp_sendmsg+0x321/0x6f0
>  [<ffffffff8040d155>] inet_sendmsg+0x45/0x80
>  [<ffffffff803b967f>] sock_sendmsg+0xdf/0x110
>  [<ffffffff8024a100>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80257ce5>] ? validate_chain+0x415/0x1010
>  [<ffffffff8027dc10>] ? __do_fault+0x140/0x450
>  [<ffffffff802597d0>] ? __lock_acquire+0x260/0x590
>  [<ffffffff803b9e55>] ? sockfd_lookup_light+0x45/0x80
>  [<ffffffff803ba50a>] sys_sendto+0xea/0x120
>  [<ffffffff80428e42>] ? _spin_unlock_irqrestore+0x42/0x80
>  [<ffffffff803134bc>] ? __up_read+0x4c/0xb0
>  [<ffffffff8024e0c6>] ? up_read+0x26/0x30
>  [<ffffffff8020b8bb>] system_call_fastpath+0x16/0x1b

This helps.

