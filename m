From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Fri, 23 May 2008 21:01:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805232043030.25097@wrl-59.cs.helsinki.fi>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
 <20080521105747.215be17d.akpm@linux-foundation.org>
 <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
 <Pine.LNX.4.64.0805212310050.7747@wrl-59.cs.helsinki.fi>
 <cf4145200805211345y3b00d209o58e11a7b553cdfc6@mail.gmail.com>
 <Pine.LNX.4.64.0805231302410.16829@wrl-59.cs.helsinki.fi>
 <cf4145200805230906k34a0452at773e840b791e6b0a@mail.gmail.com>
 <cf4145200805231024w2e735fb8ifecf7e2e1bab5957@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Brian Vowell <brian.vowell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50207 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289AbYEWSBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 14:01:30 -0400
In-Reply-To: <cf4145200805231024w2e735fb8ifecf7e2e1bab5957@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 May 2008, Brian Vowell wrote:

> I applied the ipv4 patch.  Here are two traces that just showed up:
> 
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:3297 tcp_ack+0xd58/0xeba()
> Modules linked in: dm_mirror dm_multipath dm_mod cfi_cmdset_0002 cfi_util
> button jedec_probe cfi_probe gen_probe ck804xrom i2c_nforce2 mtd chipreg
> map_funcs k8temp sg hwmon pcspkr i2c_core serio_raw pata_amd cciss
> ata_generic pata_acpi sata_nv libata sd_mod scsi_mod raid456 async_xor
> async_memcpy async_tx xor raid1 uhci_hcd ohci_hcd ssb ehci_hcd [last
> unloaded: scsi_wait_scan]
> Pid: 0, comm: swapper Not tainted 2.6.25.4 #1
> 
> Call Trace:
>  <IRQ>  [<ffffffff81034481>] warn_on_slowpath+0x51/0x63
>  [<ffffffff8128cdaf>] dev_queue_xmit+0x25b/0x284
>  [<ffffffff812ab9fa>] ip_queue_xmit+0x2cc/0x31f
>  [<ffffffff812b0e3b>] sk_stream_alloc_skb+0x2f/0xd2
>  [<ffffffff8104a1bb>] getnstimeofday+0x2f/0x83
>  [<ffffffff812bb83d>] tcp_transmit_skb+0x775/0x7a4
>  [<ffffffff812b760a>] tcp_ack+0xd58/0xeba
>  [<ffffffff812ba74b>] tcp_rcv_established+0x7b9/0x8ce
>  [<ffffffff812c05cd>] tcp_v4_do_rcv+0x2c2/0x48b
>  [<ffffffff8129a07a>] __qdisc_run+0xf6/0x1c8
>  [<ffffffff812ae376>] __inet_lookup_established+0xdf/0x17b
>  [<ffffffff812c2528>] tcp_v4_rcv+0x6a3/0x700
>  [<ffffffff812a7558>] ip_local_deliver+0xd4/0x18e
>  [<ffffffff812a7b0d>] ip_rcv+0x4fb/0x53a
>  [<ffffffff8128a2b7>] netif_receive_skb+0x351/0x372
>  [<ffffffff8124150d>] tg3_poll+0x588/0x7df
>  [<ffffffff8128c2ce>] net_rx_action+0xb6/0x1bf
>  [<ffffffff8103919b>] __do_softirq+0x65/0xce
>  [<ffffffff8100ce9c>] call_softirq+0x1c/0x28
>  [<ffffffff8100e544>] do_softirq+0x2c/0x68
>  [<ffffffff810390f2>] irq_exit+0x3f/0x83
>  [<ffffffff8100e813>] do_IRQ+0x13e/0x15f
>  [<ffffffff8100c221>] ret_from_intr+0x0/0xa
>  <EOI>  [<ffffffff8100adc8>] default_idle+0x0/0x55
>  [<ffffffff8101c138>] lapic_next_event+0x0/0xa
>  [<ffffffff8100adc8>] default_idle+0x0/0x55
>  [<ffffffff8100adf9>] default_idle+0x31/0x55
>  [<ffffffff8100adf4>] default_idle+0x2c/0x55
>  [<ffffffff8100adc8>] default_idle+0x0/0x55
>  [<ffffffff8100ae94>] cpu_idle+0x77/0x9a
> 
> ---[ end trace aae73dd976dfcd54 ]---
> TCP wq(s)  S                <
> TCP wq(h) ++h-----+-----+---<
> l0 s1 f2 p18 seq: wq1288576867, su1288576867 hs1288579763 sn1288602883

Aha, it seems you got TCP into the invalid state which I recently added 
check for :-), I'll try to figure out how that could still happen (I think 
I tried to find such code path already earlier but it seems that there's 
still something I've overlooked). Though this is not directly going to 
cause the 2539 WARNING, yet it could, after some other (probably rare 
condition) possibly lead to that as well if this invariant is assumed to 
hold while doing some state manipulation elsewhere in TCP (though I 
think that's not too likely). In case you don't see them too often, you 
can well continue with the patch in order to find the cause for 2539 as 
well (and just ignore those occassional net/ipv4/tcp_input.c:3297 ones for 
now).

Thanks,

-- 
 i.
