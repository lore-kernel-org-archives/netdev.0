From: Jun Chen <jun.d.chen@intel.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Mon, 17 Jun 2013 13:29:50 -0400
Message-ID: <1371490190.28418.6.camel@chenjun-workstation>
References: <1371478739.10495.5.camel@chenjun-workstation>
	 <1371456935.3252.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371456935.3252.177.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-17 at 01:15 -0700, Eric Dumazet wrote:
> On Mon, 2013-06-17 at 10:18 -0400, Jun Chen wrote:
> > When search the first skb to collapse,the condition of overlap to the next one have been
> > reached,but the start is less than TCP_SKB_CB(skb)->seq at this time, then followed process
> > will trigger the BUG_ON of the offset(start - TCP_SKB_CB(skb)->seq).
> > So this patch add one check (! before(start,TCP_SKB_CB(skb)->seq)) to avoid this ipanic.
> > 
> > Signed-off-by: Chen Jun <jun.d.chen@intel.com>
> > ---
> >  net/ipv4/tcp_input.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 9c62257..4c745c5 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4465,7 +4465,8 @@ restart:
> >  		 *   overlaps to the next one.
> >  		 */
> >  		if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
> > -		    (tcp_win_from_space(skb->truesize) > skb->len ||
> > +			((tcp_win_from_space(skb->truesize) > skb->len &&
> > +			!before(start, TCP_SKB_CB(skb)->seq)) ||
> >  		     before(TCP_SKB_CB(skb)->seq, start))) {
> >  			end_of_skbs = false;
> >  			break;
> 
> Hmm... I must say I do not understand this patch.
> 
> If we find a skb with before(TCP_SKB_CB(skb)->seq, start), then the
> final condition will be true.
> 
> Let's rewrite your code to equivalent one :
> 
>  if (!tcp_hdr(skb)->syn && !tcp_hdr(skb)->fin &&
>      (before(TCP_SKB_CB(skb)->seq, start) ||
>       tcp_win_from_space(skb->truesize) > skb->len)) {
> 
> So it seems your patch would not solve the problem for all
> possible skbs (aka not bloated) ?
> 
> Please tell us how you trigger this bug, and send the stack trace.
> 
> Thanks
> 
> 
hi,
When the condition of tcp_win_from_space(skb->truesize) > skb->len is
true but the before(start, TCP_SKB_CB(skb)->seq) is also true, the final
condition will be true. The follow line:
int offset = start - TCP_SKB_CB(skb)->seq;
BUG_ON(offset < 0);
this BUG_ON will be triggered.


Follow line is my error logs:

<2>[ 7736.344508] kernel BUG
at /data/buildbot/workdir/jb/kernel/net/ipv4/tcp_input.c:4845!

<4>[ 7736.344578] invalid opcode: 0000 [#1] PREEMPT SMP 

<4>[ 7736.344883] Modules linked in: atomisp lm3559 ov9724 imx1x5
bcm4335(O) cfg80211 bcm_bt_lpm videobuf_vmalloc videobuf_core matrix(C)

<4>[ 7736.345681] 

<4>[ 7736.345748] Pid: 5189, comm: TimedEventQueue Tainted: G        WC
O 3.4.43-186445-g3ada675 #1 Intel Corporation Merrifield/SALT BAY

<4>[ 7736.346059] EIP: 0060:[<c18ad61d>] EFLAGS: 00010297 CPU: 1

<4>[ 7736.346183] EIP is at tcp_collapse+0x3bd/0x3d0

<4>[ 7736.346250] EAX: ab57d2bb EBX: df428c00 ECX: c97dcd00 EDX:
000010c0

<4>[ 7736.346372] ESI: df4289c0 EDI: fffffadb EBP: edca1d88 ESP:
edca1d60

<4>[ 7736.346441]  DS: 007b ES: 007b FS: 00d8 GS: 003b SS: 0068

<4>[ 7736.346560] CR0: 8005003b CR2: 41d310bc CR3: 2d300000 CR4:
001007d0

<4>[ 7736.346629] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3:
00000000

<4>[ 7736.346749] DR6: ffff0ff0 DR7: 00000400

<0>[ 7736.346816] Process TimedEventQueue (pid: 5189, ti=edca0000
task=dc30b660 task.ti=c9a6e000)

<0>[ 7736.346936] Stack:

<4>[ 7736.347002]  ffffffff ffffffff fffffadb c97dcd5c 00000001 c97dcd00
00000e32 c97dcd00

<4>[ 7736.347615]  c97dcd00 df428180 edca1db0 c18addd0 00000000 ab57c870
ab57f19f c97dcd00

<4>[ 7736.348175]  c97dd198 000080c0 c97dcd00 df428180 edca1df0 c18aea27
00000000 c18dc8f8

<0>[ 7736.348788] Call Trace:

<4>[ 7736.348861]  [<c18addd0>] tcp_prune_queue+0x120/0x2f0

<4>[ 7736.348984]  [<c18aea27>] tcp_data_queue+0x777/0xf00

<4>[ 7736.349055]  [<c18dc8f8>] ? ipt_do_table+0x1f8/0x480

<4>[ 7736.349126]  [<c18dc8f8>] ? ipt_do_table+0x1f8/0x480

<4>[ 7736.349196]  [<c18b2e84>] tcp_rcv_established+0x114/0x680

<4>[ 7736.349269]  [<c18bb034>] tcp_v4_do_rcv+0x164/0x350



 
 
