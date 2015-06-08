From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net v2] tcp: Force updating pcount after skb_pull()
 during mtu probing
Date: Mon, 8 Jun 2015 10:58:33 -0700
Message-ID: <20150608175833.GB390474@devbig242.prn2.facebook.com>
References: <1433551592-3596877-1-git-send-email-kafai@fb.com>
 <1433553093.1895.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Grant Zhang <gzhang@fastly.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60753 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751627AbbFHR6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 13:58:40 -0400
Content-Disposition: inline
In-Reply-To: <1433553093.1895.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2015 at 06:11:33PM -0700, Eric Dumazet wrote:
> On Fri, 2015-06-05 at 17:46 -0700, Martin KaFai Lau wrote:
> > The problem is caught by this WARN_ON(len > skb->len) in tcp_fragment():
> > 
> > [<ffffffff810510ca>] warn_slowpath_null+0x1a/0x20
> > [<ffffffff8160ec90>] tcp_fragment+0x2a0/0x2b0
> > [<ffffffff81604e06>] tcp_mark_head_lost+0x196/0x230
> > [<ffffffff8160585d>] tcp_update_scoreboard+0x4d/0x80
> > [<ffffffff8160a9ac>] tcp_fastretrans_alert+0x6ac/0xa90
> > [<ffffffff8160b834>] tcp_ack+0x9d4/0x10e0
> > [<ffffffff8160c699>] tcp_rcv_established+0x309/0x7e0
> > 
> > The WARN_ON pointed out that tcp_skb_pcount (i.e.
> > TCP_SKB_CB(skb)->tcp_gso_segs) and skb->len is inconsistent.
> > 
> > The WARN_ON stack goes away after setting net.ipv4.tcp_mtu_probing to 0.
> > 
> > v2
> > - Replace the skb slicing codes by the existing tcp_trim_head(),
> >   suggested by Eric Dumazet.
> > 
> > v1
> > - Call tcp_set_skb_tso_segs() for all slicing cases.
> > 
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > Reported-by: Grant Zhang <gzhang@fastly.com>
> > Cc: Grant Zhang <gzhang@fastly.com>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > ---
> >  net/ipv4/tcp_output.c | 12 ++----------
> >  1 file changed, 2 insertions(+), 10 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index a369e8a..4ae4f0c 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -1977,16 +1977,8 @@ static int tcp_mtu_probe(struct sock *sk)
> >  		} else {
> >  			TCP_SKB_CB(nskb)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags &
> >  						   ~(TCPHDR_FIN|TCPHDR_PSH);
> > -			if (!skb_shinfo(skb)->nr_frags) {
> > -				skb_pull(skb, copy);
> > -				if (skb->ip_summed != CHECKSUM_PARTIAL)
> > -					skb->csum = csum_partial(skb->data,
> > -								 skb->len, 0);
> > -			} else {
> > -				__pskb_trim_head(skb, copy);
> > -				tcp_set_skb_tso_segs(sk, skb, mss_now);
> > -			}
> > -			TCP_SKB_CB(skb)->seq += copy;
> > +			tcp_skb_pcount_set(skb, 0);
> > +			tcp_trim_head(sk, skb, copy);
> >  		}
> >  
> >  		len += copy;
> 
> 
> I think the invariant should be that if a packet had been never sent,
> its pcount should be already 0.
> 
> (cleared in do_tcp_sendpages() and tcp_sendmsg() : it seems we hacked
> these functions already in the past :( )
> 
> So we might need to track places where we violate this rule, then get
> rid of the tcp_skb_pcount_set(skb, 0); done in do_tcp_sendpages() and
> tcp_sendmsg().
> 
> Here, trimming a packet that was never sent (by definition) should not
> force pcount to 0, it should already be the case.
It seems the invariant does not hold at this point also.
Should the invariant fix be something for net-next? or Would you like
to post a patch for it?
