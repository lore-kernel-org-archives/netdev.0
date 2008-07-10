From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 10 Jul 2008 23:23:24 +0200
Message-ID: <20080710212324.GA22521@orion.carnet.hr>
References: <4863DA40.9050508@broadcom.com> <20080709164619.GA26098@orion.carnet.hr> <1215622625.5532.43.camel@dell> <20080709.164659.157912631.davem@davemloft.net> <1215723617.6901.3.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"billfink@mindspring.com" <billfink@mindspring.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:59461 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651AbYGJVX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:23:29 -0400
Content-Disposition: inline
In-Reply-To: <1215723617.6901.3.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 02:00:17PM -0700, Michael Chan wrote:
> On Wed, 2008-07-09 at 16:46 -0700, David Miller wrote:
> > Actually I went investigating this and all the code paths check for
> > skb_cloned() and if true they make a copy of the data area (and thus
> > the skb_shared_info()) and this should ensure that the driver doesn't
> > see changing nr_frags values.
> 
> Since Josip can readily reproduce this problem, let's confirm if the SKB
> is split while it is cloned.  Please try this debug patch:
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5c459f2..03ec3b8 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1960,6 +1960,10 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
>  {
>  	int pos = skb_headlen(skb);
>  
> +	if (skb_cloned(skb)) {
> +		printk(KERN_ALERT "Splitting cloned skb\n")
> +		dump_stack();
> +	}
>  	if (len < pos)	/* Split line is inside header. */
>  		skb_split_inside_header(skb, skb1, len, pos);
>  	else		/* Second chunk has no header, nothing to copy. */
> 

I'll try it - but just as I was reading this e-mail, the machine managed to
crash :(

The log was:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000b8
IP: [<ffffffff8807ad7e>] :bnx2:bnx2_tx_int+0x7e/0x3f0
PGD 22bdaf067 PUD 221fef067 PMD 0
Oops: 0000 [1] SMP
CPU 7
Modules linked in: bnx2 zlib_inflate crc32 ipmi_devintf nfs lockd nfs_acl sunrpc fan ac battery cls_u32 sch_sfq sch_htb ip6t_R
EJECT ip6t_LOG ip6table_filter ip6_tables ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables ipv6 dm_snapshot dm_mirror dm
_mod usbhid ehci_hcd ipmi_si uhci_hcd ipmi_msghandler thermal usbcore shpchp container button processor [last unloaded: crc32]
Pid: 0, comm: swapper Not tainted 2.6.25.6 #1
RIP: 0010:[<ffffffff8807ad7e>]  [<ffffffff8807ad7e>] :bnx2:bnx2_tx_int+0x7e/0x3f0
RSP: 0018:ffff81022fa0fd10  EFLAGS: 00010286
RAX: 0000000000000620 RBX: ffff810100427260 RCX: 0000000000010002
RDX: 0000000000000001 RSI: ffff810043c3c000 RDI: ffff8101cb537858
RBP: 00000000000000c4 R08: ffff81022a6ba100 R09: ffff8101005999a8
R10: 0000000000000000 R11: ffffffff80419a50 R12: 00000000000000c4
R13: 00000000fbbffbc4 R14: 0000000000000000 R15: ffff810015c80700
FS:  0000000000000000(0000) GS:ffff81022f9877c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000b8 CR3: 000000022602d000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff81022fa0a000, task ffff81022f9997d0)
Stack:  ffff810100540000 000000004909a600 ffff810015c80800 fbc3ffff880d7767
 0000000200000002 ffff810015c80800 0000000000000040 0000000000000000
 ffff810015c80700 0000000000000000 000000000000012c ffffffff8807b5b4
Call Trace:
 <IRQ>  [<ffffffff8807b5b4>] ? :bnx2:bnx2_poll+0xd4/0x1330
 [<ffffffff8025e52a>] ? handle_edge_irq+0x7a/0x150
 [<ffffffff8020ec10>] ? do_IRQ+0x80/0x100
 [<ffffffff8025e52a>] ? handle_edge_irq+0x7a/0x150
 [<ffffffff88065a5f>] ? :ipmi_si:kcs_event+0x13f/0x800
 [<ffffffff8023e7a4>] ? lock_timer_base+0x34/0x70
 [<ffffffff80220fd6>] ? send_IPI_self+0x6/0x30
 [<ffffffff803edaa8>] ? net_rx_action+0xf8/0x200
 [<ffffffff8023a5b9>] ? __do_softirq+0x69/0xe0
 [<ffffffff8020c4ac>] ? call_softirq+0x1c/0x30
 [<ffffffff8020e995>] ? do_softirq+0x35/0x70
 [<ffffffff8020ec10>] ? do_IRQ+0x80/0x100
 [<ffffffff8020a410>] ? mwait_idle+0x0/0x50
 [<ffffffff8020b831>] ? ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff80419a50>] ? tcp_poll+0x0/0x180
 [<ffffffff8020a451>] ? mwait_idle+0x41/0x50
 [<ffffffff8020a378>] ? cpu_idle+0x48/0x90


Code: 24 02 00 00 45 0f b6 e5 41 0f b7 ec 48 8d 04 ed 00 00 00 00 48 89 eb 48 c1 e3 05 48 29 c3 49 03 9f e0 02 00 00 4c 8b 33
8b 53 10 <41> 8b 8e b8 00 00 00 49 8b be c0 00 00 00 89 c8 8b 44 07 04 66
RIP  [<ffffffff8807ad7e>] :bnx2:bnx2_tx_int+0x7e/0x3f0
 RSP <ffff81022fa0fd10>
CR2: 00000000000000b8
---[ end trace 786b1aa9b912c54e ]---
Kernel panic - not syncing: Aiee, killing interrupt handler!

Hope that helps. I'll go reboot it and apply the new patch.

-- 
Josip Rodin
mirrors@debian.org
