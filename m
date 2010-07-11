From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Sun, 11 Jul 2010 22:44:37 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007112230460.15736@melkinpaasi.cs.helsinki.fi>
References: <4C358AAA.9080400@kernel.org>  <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>  <1278867977.2538.167.camel@edumazet-laptop>  <1278870382.2538.180.camel@edumazet-laptop> <1278872990.2538.189.camel@edumazet-laptop>
 <alpine.DEB.2.00.1007112214250.15736@melkinpaasi.cs.helsinki.fi> <alpine.DEB.2.00.1007112224110.15736@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-1941238658-1278877477=:15736"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007112224110.15736@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-1941238658-1278877477=:15736
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Sun, 11 Jul 2010, Ilpo Järvinen wrote:

> On Sun, 11 Jul 2010, Ilpo Järvinen wrote:
> 
> > On Sun, 11 Jul 2010, Eric Dumazet wrote:
> > 
> > > Le dimanche 11 juillet 2010 à 19:46 +0200, Eric Dumazet a écrit :
> > > > Le dimanche 11 juillet 2010 à 19:06 +0200, Eric Dumazet a écrit :
> > > > > Le dimanche 11 juillet 2010 à 19:09 +0300, Ilpo Järvinen a écrit :
> > > > > > On Thu, 8 Jul 2010, Tejun Heo wrote:
> > > > > > 
> > > > > > > We've been seeing oops in tcp_xmit_retransmit_queue() w/ 2.6.32.15.
> > > > > > > Please see the attached photoshoot.  This is happening on a HPC
> > > > > > > cluster and very interestingly caused by one particular job.  How long
> > > > > > > it takes isn't clear yet (at least more than a day) but when it
> > > > > > > happens it happens on a lot of machines in relatively short time.
> > > > > > > 
> > > > > > > With a bit of disassemblying, I've found that the oops is happening
> > > > > > > during tcp_for_write_queue_from() because the skb->next points to
> > > > > > > NULL.
> > > > > > > 
> > > > > > >  void tcp_xmit_retransmit_queue(struct sock *sk)
> > > > > > >  {
> > > > > > >  ...
> > > > > > > 	if (tp->retransmit_skb_hint) {
> > > > > > > 		skb = tp->retransmit_skb_hint;
> > > > > > > 		last_lost = TCP_SKB_CB(skb)->end_seq;
> > > > > > > 		if (after(last_lost, tp->retransmit_high))
> > > > > > > 			last_lost = tp->retransmit_high;
> > > > > > > 	} else {
> > > > > > > 		skb = tcp_write_queue_head(sk);
> > > > > > > 		last_lost = tp->snd_una;
> > > > > > > 	}
> > > > > > > 
> > > > > > >  =>	tcp_for_write_queue_from(skb, sk) {
> > > > > > > 		 __u8 sacked = TCP_SKB_CB(skb)->sacked;
> > > > > > > 
> > > > > > > 		 if (skb == tcp_send_head(sk))
> > > > > > > 			 break;
> > > > > > > 		 /* we could do better than to assign each time */
> > > > > > > 		 if (hole == NULL)
> > > > > > > 
> > > > > > > This can happen for one of the following reasons,
> > > > > > > 
> > > > > > > 1. tp->retransmit_skb_hint is NULL and tcp_write_queue_head() is NULL
> > > > > > >    too.  ie. tcp_xmit_retransmit_queue() is called on an empty write
> > > > > > >    queue for some reason.
> > > > > > > 
> > > > > > > 2. tp->retransmit_skb_hint is pointing to a skb which is not on the
> > > > > > >    write_queue.  ie. somebody forgot to update hint while removing the
> > > > > > >    skb from the write queue.
> > > > > > 
> > > > > > Once again I've read the unlinkers through, and only thing that could 
> > > > > > cause this is tcp_send_synack (others do deal with the hints) but I think 
> > > > > > Eric already proposed a patch to that but we never got anywhere due to 
> > > > > > some counterargument why it wouldn't take place (too far away for me to 
> > > > > > remember, see archives about the discussions). ...But if you want be dead 
> > > > > > sure some WARN_ON there might not hurt. Also the purging of the whole 
> > > > > > queue was a similar suspect I then came across (but that would only 
> > > > > > materialize with sk reuse happening e.g., with nfs which the other guys 
> > > > > > weren't using).
> > > > > > 
> > > > > 
> > > > > Hmm.
> > > > > 
> > > > > This sounds familiar to me, but I cannot remember the discussion you
> > > > > mention or the patch.
> > > > > 
> > > > > Or maybe it was the TCP transaction thing ? (including data in SYN or
> > > > > SYN-ACK packet)
> > 
> > No. That's another thing. ...I've already found it with google today but 
> > cannot seem to find it again. I thought I used tcp_make_synack eric but 
> > for some reason I only get these transaction fix hits. I'll keep looking.
> 
> Right, this one:
> 
> http://kerneltrap.org/mailarchive/linux-netdev/2009/10/29/6259073

Hmm, another idea... It might be useful to try to disable 
tcp_retrans_try_collapse in tcp_retransmit_skb as a test. I think that it 
might be possible that tcp_xmit_retransmit_queue might end up holding 
a stale reference either in hole or skb. Kind of shot into the dark still, 
no actual theory on how that could happen but that 
tcp_xmit_retransmit_queue logic is rather tricky because of returning to 
the first hole if such exists so that I couldn't immediately rule out the 
possibility.

-- 
 i.
---696250871-1941238658-1278877477=:15736--
