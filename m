From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: TCP sacked_out and fackets_out inconsistency (Was: Re: BUG: unable
 to handle kernel NULL pointer dereference at 000000000000002c)
Date: Mon, 6 Feb 2012 14:47:18 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1202061151580.2966@wel-95.cs.helsinki.fi>
References: <20120201.162157.880976652659067010.davem@davemloft.net>  <4F2A87B0.6070900@profihost.ag>  <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120202.143957.2251106530056768980.davem@davemloft.net>  <20120203004228.GA23429@kroah.com>
 <4F2B8348.3090305@profihost.ag>  <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag>  <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120203155309.GB20638@kroah.com> <4F2F9784.7090203@profihost.ag>
 <1328519990.2220.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1282431918-1328521970=:2966"
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, Netdev <netdev@vger.kernel.org>,
	david@fromorbit.com, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52654 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180Ab2BFMrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 07:47:20 -0500
In-Reply-To: <1328519990.2220.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-ID: <alpine.DEB.2.00.1202061441060.2966@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1282431918-1328521970=:2966
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1202061159321.2966@wel-95.cs.helsinki.fi>

On Mon, 6 Feb 2012, Eric Dumazet wrote:

> Le lundi 06 février 2012 à 10:04 +0100, Stefan Priebe - Profihost AG a
> écrit :
> > today i've seen this:
> > [1048676.660457] ------------[ cut here ]------------
> > [1048676.688131] WARNING: at net/ipv4/tcp_input.c:2964
> > tcp_ack+0xfe1/0x2420()
> > [1048676.716291] Hardware name: X8SIL
> > [1048676.744292] Modules linked in: xt_tcpudp ipt_REJECT iptable_filter
> > ip_tables x_tables coretemp k8temp ipv6 dm_snapshot dm_mod
> > [1048676.802468] Pid: 0, comm: kworker/0:1 Not tainted 2.6.40.17.1intel #1
> > [1048676.831737] Call Trace:
> > [1048676.860455]  <IRQ>  [<ffffffff81565921>] ? tcp_ack+0xfe1/0x2420
> > [1048676.860765]  [<ffffffff81045e10>] warn_slowpath_common+0x80/0xc0
> > [1048676.860771]  [<ffffffff81045e65>] warn_slowpath_null+0x15/0x20
> > [1048676.860777]  [<ffffffff81565921>] tcp_ack+0xfe1/0x2420
> > [1048676.860784]  [<ffffffff81567060>] tcp_rcv_established+0x300/0x630
> > [1048676.860791]  [<ffffffff815708a4>] tcp_v4_do_rcv+0x154/0x2d0
> > [1048676.860796]  [<ffffffff8157111b>] tcp_v4_rcv+0x6fb/0x880
> > [1048676.860804]  [<ffffffff8154e4e7>] ip_local_deliver_finish+0x127/0x250
> > [1048676.860810]  [<ffffffff8154e69d>] ip_local_deliver+0x8d/0xa0
> > [1048676.860815]  [<ffffffff8154dda2>] ip_rcv_finish+0x172/0x340
> > [1048676.860820]  [<ffffffff8154e1e5>] ip_rcv+0x275/0x2f0
> > [1048676.860827]  [<ffffffff81523387>] __netif_receive_skb+0x427/0x4a0
> > [1048676.860832]  [<ffffffff81529148>] netif_receive_skb+0x78/0x80
> > [1048676.860837]  [<ffffffff81529280>] napi_skb_finish+0x50/0x70
> > [1048676.860842]  [<ffffffff81529735>] napi_gro_receive+0xc5/0xd0
> > [1048676.860851]  [<ffffffff81462786>] e1000_receive_skb+0x56/0x70
> > [1048676.860856]  [<ffffffff814646eb>] e1000_clean_rx_irq+0x22b/0x3d0
> > [1048676.860862]  [<ffffffff814630f2>] e1000_clean+0xb2/0x2f0
> > [1048676.860868]  [<ffffffff81054efc>] ? run_timer_softirq+0x3c/0x320
> > [1048676.860873]  [<ffffffff815298fa>] net_rx_action+0x10a/0x2b0
> > [1048676.860879]  [<ffffffff8104c300>] __do_softirq+0xd0/0x1c0
> > [1048676.860887]  [<ffffffff815eb20c>] call_softirq+0x1c/0x30
> > [1048676.860895]  [<ffffffff810047b5>] do_softirq+0x55/0x90
> > [1048676.860900]  [<ffffffff8104c0dd>] irq_exit+0xad/0xe0
> > [1048676.860905]  [<ffffffff81003f94>] do_IRQ+0x64/0xe0
> > [1048676.860910]  [<ffffffff815e9a93>] common_interrupt+0x13/0x13
> > [1048676.860913]  <EOI>  [<ffffffff8106bdff>] ?
> > notifier_call_chain+0x3f/0x80
> > [1048676.860926]  [<ffffffff813117b3>] ? intel_idle+0xb3/0x120
> > [1048676.860931]  [<ffffffff81311795>] ? intel_idle+0x95/0x120
> > [1048676.860937]  [<ffffffff814fc27c>] cpuidle_idle_call+0xdc/0x1a0
> > [1048676.860942]  [<ffffffff81002091>] cpu_idle+0xb1/0x110
> > [1048676.860948]  [<ffffffff81b0d7aa>] start_secondary+0x201/0x297
> > [1048676.860953] ---[ end trace 4d27234ace919a1b ]---
> > 
> > Any idea about that? Is it due to my custom patch being buggy or is it
> > anything you know which is missing in 3.0.X too?

This warning is known to trigger every now and then...

> Thats the tcp_fastretrans_alert()
> 
> 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
> 		tp->fackets_out = 0;
> 
> I dont know if some recent patch addressed this issue.

...the recent fix from Neal to pick correct MSS might fix this but it 
is of course hard to confirm for sure (we'll see it indirectly eventually 
if there won't be anymore these rare splats). If one has infinite time it 
would be quite simple to see if changing mss setup triggers this and if 
the Neal's fix helped or not, however, I don't consider this particular 
inconsistency worth the effort.

...What I can say for sure is at least tp->fackets_out -= min(pkts_acked, 
tp->fackets_out); seems to fail when pkts_acked (u32) underflows due to 
the mss badness we used to have. So it could actually solve this for real.

The effects of this counter inconsistency are not that devastating. 
Fackets_out mainly affect when recovery is triggered/which segments to 
mark lost in the recovery itself. Two extremes I can think of: recovery 
not triggered => RTO triggers and everyone is happy except some researcher 
who finds that odd and unwanted and needs to fix it :-); recovery in 
progress but works too much ahead, as if dupthresh (tp->reordering) would 
be slightly smaller (if in-order behavior in the network is assumed this 
is still fully safe, dupthresh is there to help in cases of minor 
reordering).


-- 
 i.
--8323329-1282431918-1328521970=:2966--
