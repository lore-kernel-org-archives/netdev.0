From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Fri, 11 May 2012 11:58:12 +0100
Message-ID: <1336733892.23818.69.camel@zakaz.uk.xensource.com>
References: <cover.1336397823.git.mst@redhat.com>
	 <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
	 <1336671977.14220.26.camel@zakaz.uk.xensource.com>
	 <20120510184246.GE14647@redhat.com>
	 <1336726800.23818.33.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:48617 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474Ab2EKK6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 06:58:21 -0400
In-Reply-To: <1336726800.23818.33.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 10:00 +0100, Ian Campbell wrote:
> I'm seeing copy_ubufs called in my remote NFS test, which I don't
> think I expected -- I'll investigate why this is happening today. 

It's tcp_transmit_skb which can (conditionally) call skb_clone
(backtrace below)

I suspect this means that the existing SKBTX_DEV_ZEROCOPY semantics are
a superset of what we need to consider for the destructor case. I'm
assuming here that the existing SKBTX_DEV_ZEROCOPY is copying aside
exactly the right amount and isn't conservatively coying more often than
necessary.

shinfo->tx_flags are pretty scarce -- can we afford a new one for this
usecase?

Or perhaps this is actually a function of the callsite not the of
individual skb and we want to have some concept of "deep" and "shallow"
clones combined with SKBTX_DEV_ZEROCOPY to decide when to copy_ubufs or
not? e.g. deep clone => always copy if SKBTX_DEV_ZEROCOPY and shallow
clone => only copy if SKBTX_DEV_ZEROCOPY && destructor_arg!=NULL
(neither copy if !SKBTX_DEV_ZEROCOPY).

Oh, I suppose that reintroduces the copy_ubufs under a (shallow) cloned
skb race if one of those skbs eventually finds itself in a situation
where a skb_frag_orphan is required doesn't it. Hrm :-/

Will have to have a think...

Ian.

[  109.680828] ------------[ cut here ]------------
[  109.685440] WARNING: at /local/scratch/ianc/devel/kernels/linux/include/linux/skbuff.h:1732 skb_clone+0xe6/0xf0()
[  109.695678] Hardware name:
[  109.699162] ORPHANING
[  109.701434] Modules linked in:
[  109.704495] Pid: 10, comm: kworker/0:1 Tainted: G        W    3.4.0-rc4-x86_64-native+ #186
[  109.712830] Call Trace:
[  109.715278]  [<ffffffff8107edfa>] warn_slowpath_common+0x7a/0xb0
[  109.721273]  [<ffffffff8107eed1>] warn_slowpath_fmt+0x41/0x50
[  109.727007]  [<ffffffff8170feea>] ? tcp_transmit_skb+0x9a/0x8f0
[  109.732914]  [<ffffffff8169b2d6>] skb_clone+0xe6/0xf0
[  109.737957]  [<ffffffff8170feea>] tcp_transmit_skb+0x9a/0x8f0
[  109.743694]  [<ffffffff81712d7a>] tcp_write_xmit+0x1ea/0x9c0
[  109.749343]  [<ffffffff8171357b>] tcp_push_one+0x2b/0x40
[  109.754648]  [<ffffffff81705b2b>] tcp_sendpage+0x64b/0x6d0
[  109.760126]  [<ffffffff8172785d>] inet_sendpage+0x4d/0xf0
[  109.765518]  [<ffffffff817afed7>] xs_sendpages+0x117/0x2a0
[  109.770996]  [<ffffffff817ad3f0>] ? xprt_reserve+0x2d0/0x2d0
[  109.776647]  [<ffffffff817b0178>] xs_tcp_send_request+0x58/0x110
[  109.782644]  [<ffffffff817ad5bb>] xprt_transmit+0x6b/0x2d0
[  109.788123]  [<ffffffff817aa9a0>] ? call_transmit_status+0xd0/0xd0
[  109.794293]  [<ffffffff817aab70>] call_transmit+0x1d0/0x290
[  109.799857]  [<ffffffff817aa9a0>] ? call_transmit_status+0xd0/0xd0
[  109.806029]  [<ffffffff817b3725>] __rpc_execute+0x65/0x260
[  109.811505]  [<ffffffff817b3920>] ? __rpc_execute+0x260/0x260
[  109.817241]  [<ffffffff817b3930>] rpc_async_schedule+0x10/0x20
[  109.823066]  [<ffffffff81098fff>] process_one_work+0x11f/0x460
[  109.828895]  [<ffffffff8109b0b3>] worker_thread+0x173/0x3f0
[  109.834459]  [<ffffffff8109af40>] ? manage_workers+0x210/0x210
[  109.840283]  [<ffffffff8109fa26>] kthread+0x96/0xa0
[  109.845179]  [<ffffffff81861654>] kernel_thread_helper+0x4/0x10
[  109.851092]  [<ffffffff8109f990>] ? kthread_freezable_should_stop+0x70/0x70
[  109.858053]  [<ffffffff81861650>] ? gs_change+0xb/0xb
[  109.863087] ---[ end trace 3e3acdb7cc57c191 ]---
