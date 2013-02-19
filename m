From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Mon, 18 Feb 2013 21:17:13 -0800
Message-ID: <1361251033.19353.120.camel@edumazet-glaptop>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:44400 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab3BSFRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:17:16 -0500
In-Reply-To: <20130219040557.GB4778@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-18 at 20:05 -0800, Marc MERLIN wrote:
> On Mon, Jul 16, 2012 at 06:21:57PM +0200, Eric Dumazet wrote:
> > > No, it's atually when I'm 'uploading' from my laptop to my server.
> > > One interesting thing is that my server is running lvm2 with snapshots,
> > > which makes writes slower than my laptop can push data over the network, so
> > > it's definitely causing buffers to fill up.
> > > I just did a download test and got 4.5MB/s sustained without problems.
> > 
> > Hmm, nfs apparently is able to push lot of data, try to reduce
> > rsize/wsize to sane values, like 32K instead of 512K ?
> > 
> > gargamel:/mnt/dshelf2/ /net/gargamel/mnt/dshelf2 nfs4
> > rw,nosuid,nodev,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.205.7,local_lock=none,addr=192.168.205.3 0 0
> > 
> > You could trace svc_sock_setbufsize() and check how large is set
> > sk_sndbuf
> 
> My apologies, I totally dropped the ball on this.
> 
> So, the problem was still there in more recent kernels.
> 
> TL;DR:
> - reducing nfs buffers removes the full hang
> - iwlwifi has a problem where lack of pages causes the whoe machine to hang
> - NFS copies out, even with buffers down to 32K is very wonky and cp does not
>   return until over 2mn after the copy is actually finished.
>   (I have a trace of what's hung in cp/nfs when this happens)
> 
> 
> Details:
> 
> It's still pretty severe because whatever blocks doesn't just end up
> blocking disk IO, but actually blocking interrupts altogether since my mouse
> can't move for a minute or more until some buffer flushes.
> 
> The last trace I got during this (I can't do sysrq because I have a broken 
> Lenovo T530 without a sysrq key, and typing doesn't really work when
> interrupts aren't firing).
> 
> Not sure if it's useful. First chrome had an issue, and then iwlwifi
> 
> chrome: page allocation failure: order:1, mode:0x4020
> Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
> Call Trace:
>  <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
>  [<ffffffff810d8cfd>] __alloc_pages_nodemask+0x66a/0x702
>  [<ffffffff8108a948>] ? arch_local_irq_save+0x15/0x1b
>  [<ffffffff811064af>] alloc_pages_current+0xcd/0xee
>  [<ffffffffa039b579>] iwl_rx_allocate+0x8c/0x271 [iwlwifi]
>  [<ffffffffa039c24e>] iwl_irq_tasklet+0x7e5/0x91c [iwlwifi]
>  [<ffffffff8104805e>] tasklet_action+0x80/0xd2
>  [<ffffffff81047c99>] __do_softirq+0xdf/0x1c5
>  [<ffffffff814c1ed6>] ? _raw_spin_lock+0x1b/0x1f
>  [<ffffffff810a7f37>] ? handle_irq_event+0x4d/0x62
>  [<ffffffff814c7f5c>] call_softirq+0x1c/0x30
>  [<ffffffff8101104e>] do_softirq+0x41/0x7f
>  [<ffffffff81047e52>] irq_exit+0x3f/0xa7
>  [<ffffffff81010d40>] do_IRQ+0x88/0x9f
>  [<ffffffff814c246d>] common_interrupt+0x6d/0x6d
>  <EOI> Mem-Info:

You could try to load iwlwifi with amsdu_size_8K set to 0 (disable)

It should hopefully use order-0 pages

Some drivers cant fallback to low order page allocations.

mlx4 is another example (it uses order-2 pages )
