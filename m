From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Sun, 11 Jul 2010 22:22:17 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007112214250.15736@melkinpaasi.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org>  <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>  <1278867977.2538.167.camel@edumazet-laptop>  <1278870382.2538.180.camel@edumazet-laptop> <1278872990.2538.189.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-634896392-1278876137=:15736"
Cc: Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278872990.2538.189.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-634896392-1278876137=:15736
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Sun, 11 Jul 2010, Eric Dumazet wrote:

> Le dimanche 11 juillet 2010 à 19:46 +0200, Eric Dumazet a écrit :
> > Le dimanche 11 juillet 2010 à 19:06 +0200, Eric Dumazet a écrit :
> > > Le dimanche 11 juillet 2010 à 19:09 +0300, Ilpo Järvinen a écrit :
> > > > On Thu, 8 Jul 2010, Tejun Heo wrote:
> > > > 
> > > > > We've been seeing oops in tcp_xmit_retransmit_queue() w/ 2.6.32.15.
> > > > > Please see the attached photoshoot.  This is happening on a HPC
> > > > > cluster and very interestingly caused by one particular job.  How long
> > > > > it takes isn't clear yet (at least more than a day) but when it
> > > > > happens it happens on a lot of machines in relatively short time.
> > > > > 
> > > > > With a bit of disassemblying, I've found that the oops is happening
> > > > > during tcp_for_write_queue_from() because the skb->next points to
> > > > > NULL.
> > > > > 
> > > > >  void tcp_xmit_retransmit_queue(struct sock *sk)
> > > > >  {
> > > > >  ...
> > > > > 	if (tp->retransmit_skb_hint) {
> > > > > 		skb = tp->retransmit_skb_hint;
> > > > > 		last_lost = TCP_SKB_CB(skb)->end_seq;
> > > > > 		if (after(last_lost, tp->retransmit_high))
> > > > > 			last_lost = tp->retransmit_high;
> > > > > 	} else {
> > > > > 		skb = tcp_write_queue_head(sk);
> > > > > 		last_lost = tp->snd_una;
> > > > > 	}
> > > > > 
> > > > >  =>	tcp_for_write_queue_from(skb, sk) {
> > > > > 		 __u8 sacked = TCP_SKB_CB(skb)->sacked;
> > > > > 
> > > > > 		 if (skb == tcp_send_head(sk))
> > > > > 			 break;
> > > > > 		 /* we could do better than to assign each time */
> > > > > 		 if (hole == NULL)
> > > > > 
> > > > > This can happen for one of the following reasons,
> > > > > 
> > > > > 1. tp->retransmit_skb_hint is NULL and tcp_write_queue_head() is NULL
> > > > >    too.  ie. tcp_xmit_retransmit_queue() is called on an empty write
> > > > >    queue for some reason.
> > > > > 
> > > > > 2. tp->retransmit_skb_hint is pointing to a skb which is not on the
> > > > >    write_queue.  ie. somebody forgot to update hint while removing the
> > > > >    skb from the write queue.
> > > > 
> > > > Once again I've read the unlinkers through, and only thing that could 
> > > > cause this is tcp_send_synack (others do deal with the hints) but I think 
> > > > Eric already proposed a patch to that but we never got anywhere due to 
> > > > some counterargument why it wouldn't take place (too far away for me to 
> > > > remember, see archives about the discussions). ...But if you want be dead 
> > > > sure some WARN_ON there might not hurt. Also the purging of the whole 
> > > > queue was a similar suspect I then came across (but that would only 
> > > > materialize with sk reuse happening e.g., with nfs which the other guys 
> > > > weren't using).
> > > > 
> > > 
> > > Hmm.
> > > 
> > > This sounds familiar to me, but I cannot remember the discussion you
> > > mention or the patch.
> > > 
> > > Or maybe it was the TCP transaction thing ? (including data in SYN or
> > > SYN-ACK packet)

No. That's another thing. ...I've already found it with google today but 
cannot seem to find it again. I thought I used tcp_make_synack eric but 
for some reason I only get these transaction fix hits. I'll keep looking.

> > Hmm, I cannot find where we reset restransmit_skb_hint in
> > tcp_mtu_probe(), if we call tcp_unlink_write_queue().
> > 
> > if (skb->len <= copy) {
> > 	/* We've eaten all the data from this skb.
> > 	 * Throw it away. */
> > 	TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags;
> > <<>>	tcp_unlink_write_queue(skb, sk);
> > 	sk_wmem_free_skb(sk, skb);
> > } else {
> > 
> > 
> > Sorry if this was already discussed. We might add a comment here in anycase ;)
> > 
> 
> Just in case, here is a patch for this issue, if Tejun wants to try it.
> 
> Thanks
> 
> [PATCH] tcp: tcp_mtu_probe() and retransmit hints
> 
> When removing an skb from tcp write queue, we must take care of various
> hints that could be kept on this skb. tcp_mtu_probe() misses this
> cleanup.
>
> lkml reference : http://lkml.org/lkml/2010/7/8/63
> 
> Reported-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index b4ed957..187453f 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1666,6 +1666,9 @@ static int tcp_mtu_probe(struct sock *sk)
>  			 * Throw it away. */
>  			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags;
>  			tcp_unlink_write_queue(skb, sk);
> +			tcp_clear_retrans_hints_partial(tp);
> +			if (skb == tp->retransmit_skb_hint)
> +				tp->retransmit_skb_hint = nskb;

...I think we've not sent that skb just yet, so this'll never be true (and 
the rexmit loop terminates at send_head without setting it so we should 
be safe, I'll still need to check that no other code can accidently move 
it to the send_head but I doubt it happens).

>  			sk_wmem_free_skb(sk, skb);
>  		} else {
>  			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags &
> 
> 
> 

-- 
 i.
---696250871-634896392-1278876137=:15736--
