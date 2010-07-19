From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
Date: Mon, 19 Jul 2010 20:25:06 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007192013010.30181@melkinpaasi.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org>  <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>  <4C3EF7EA.2040900@nets.rwth-aachen.de>  <1279195528.2496.2.camel@edumazet-laptop>  <4C3F053F.7090704@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>  <4C404FC5.6040107@nets.rwth-aachen.de>  <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi>  <4C440771.7080107@nets.rwth-aachen.de>  <alpine.DEB.2.00.1007191319010.13002@wel-95.cs.helsinki.fi>
 <1279548555.2553.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-1543959423-1279560307=:30181"
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279548555.2553.51.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-1543959423-1279560307=:30181
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Mon, 19 Jul 2010, Eric Dumazet wrote:

> Le lundi 19 juillet 2010 à 14:16 +0300, Ilpo Järvinen a écrit :
> 
> > Thanks for testing.
> > 
> > DaveM, I think this oops was introduced for 2.6.28 (in 
> > 08ebd1721ab8fd362e90ae17b461c07b23fa2824 it seems, to be exact) so to 
> > stables it should go too please. I've only tweaked the message (so no need 
> > for Lennart to retest v2 :-)).
> > 
> > --
> > [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
> > 
> > It can happen that there are no packets in queue while calling
> > tcp_xmit_retransmit_queue(). tcp_write_queue_head() then returns
> > NULL and that gets deref'ed to get sacked into a local var.
> > 
> > There is no work to do if no packets are outstanding so we just
> > exit early.
> > 
> > This oops was introduced by 08ebd1721ab8fd (tcp: remove tp->lost_out
> > guard to make joining diff nicer).
> > 
> 
> But prior to commit 08ebd1721ab8fd3, we were not testing
> tp->packets_out, but tp->lost_out

That's right, but back then we were not testing it for the same purpose.
 
> if it was 0, we were not doing the tcp_for_write_queue_from() loop.

This invariant _should_ be true all the time:
 lost_out <= packets_out

...and if it's not we would get Leak printouts every now and then. Thus is 
packets_out is zero no NULL defer with the if lost_out either. The other 
loop too (in pre 08eb kernels) will work because of earlier mentioned 
send_head check side-effects.

> Not sure it makes a difference ?

This difference is well thought and intentional, I didn't use different 
one by accident. We want to make sure we won't use NULL from 
tcp_write_queue_head() while the pre 08ebd1721ab8fd3 kernels was 
interested mainly whether the first loop should run or not (and of course 
ends up avoid the null deref too but it's more optimization like 
thing in there, ie., if there's no lost packets no work to-do). The deref 
could have been fixed by moving TCP_SKB_CB(skb)->sacked a bit later but 
that would again make us depend on the side-effect of the send_head check 
(in the case of packets_out being zero and wq empty) which is something I 
don't like too much.

-- 
 i.
---696250871-1543959423-1279560307=:30181--
