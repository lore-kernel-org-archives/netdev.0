From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Thu, 31 Mar 2016 18:45:17 -0700
Message-ID: <20160401014516.GA11017@ast-mbp.thefacebook.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33236 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757526AbcDABpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 21:45:22 -0400
Received: by mail-pa0-f53.google.com with SMTP id zm5so78816183pac.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 18:45:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2016 at 06:19:52PM -0700, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 02:21 +0200, Hannes Frederic Sowa wrote:
> 
> > 
> > [   31.064029] ===============================
> > [   31.064030] [ INFO: suspicious RCU usage. ]
> > [   31.064032] 4.5.0+ #13 Not tainted
> > [   31.064033] -------------------------------
> > [   31.064034] include/net/sock.h:1594 suspicious 
> > rcu_dereference_check() usage!
> > [   31.064035]
> >                 other info that might help us debug this:
> > 
> > [   31.064041]
> >                 rcu_scheduler_active = 1, debug_locks = 1
> > [   31.064042] no locks held by ssh/817.
> > [   31.064043]
> >                 stack backtrace:
> > [   31.064045] CPU: 0 PID: 817 Comm: ssh Not tainted 4.5.0+ #13
> > [   31.064046] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
> > BIOS 1.8.2-20150714_191134- 04/01/2014
> > [   31.064047]  0000000000000286 000000006730b46b ffff8800badf7bd0 
> > ffffffff81442b33
> > [   31.064050]  ffff8800b8c78000 0000000000000001 ffff8800badf7c00 
> > ffffffff8110ae75
> > [   31.064052]  ffff880035ea2f00 ffff8800b8e28000 0000000000000003 
> > 00000000000004c4
> > [   31.064054] Call Trace:
> > [   31.064058]  [<ffffffff81442b33>] dump_stack+0x85/0xc2
> > [   31.064062]  [<ffffffff8110ae75>] lockdep_rcu_suspicious+0xc5/0x100
> > [   31.064064]  [<ffffffff8173bf57>] __sk_dst_check+0x77/0xb0
> > [   31.064066]  [<ffffffff8182e502>] inet6_sk_rebuild_header+0x52/0x300
> > [   31.064068]  [<ffffffff813bb61e>] ? selinux_skb_peerlbl_sid+0x5e/0xa0
> > [   31.064070]  [<ffffffff813bb69e>] ? 
> > selinux_inet_conn_established+0x3e/0x40
> > [   31.064072]  [<ffffffff817c2bad>] tcp_finish_connect+0x4d/0x270
> > [   31.064074]  [<ffffffff817c33f7>] tcp_rcv_state_process+0x627/0xe40
> > [   31.064076]  [<ffffffff81866584>] tcp_v6_do_rcv+0xd4/0x410
> > [   31.064078]  [<ffffffff8173bc65>] release_sock+0x85/0x1c0
> > [   31.064079]  [<ffffffff817e9983>] __inet_stream_connect+0x1c3/0x340
> > [   31.064081]  [<ffffffff8173b089>] ? lock_sock_nested+0x49/0xb0
> > [   31.064083]  [<ffffffff81100270>] ? abort_exclusive_wait+0xb0/0xb0
> > [   31.064084]  [<ffffffff817e9b38>] inet_stream_connect+0x38/0x50
> > [   31.064086]  [<ffffffff8173794f>] SYSC_connect+0xcf/0xf0
> > [   31.064088]  [<ffffffff8110d069>] ? trace_hardirqs_on_caller+0x129/0x1b0
> > [   31.064090]  [<ffffffff8100301b>] ? trace_hardirqs_on_thunk+0x1b/0x1d
> > [   31.064091]  [<ffffffff8173854e>] SyS_connect+0xe/0x10
> > [   31.064094]  [<ffffffff818a0e7c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
> > 
> > Bye,
> > Hannes
> 
> Thanks.
> 
> As you can see, release_sock() messes badly lockdep (once your other
> patches are in )
> 
> Once we properly fix release_sock() and/or __release_sock(), all these
> false positives disappear.

+1. Nice catch.

Eric, what's your take on Hannes's patch 2 ?
Is it more accurate to ask lockdep to check for actual lock
or lockdep can rely on owned flag?
Potentially there could be races between setting the flag and
actual lock... but that code is contained, so unlikely.
Will we find the real issues with this 'stronger' check or
just spend a ton of time adapting to new model like your other
patch for release_sock and whatever may need to come next...
