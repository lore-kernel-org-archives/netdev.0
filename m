From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 12:50:08 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1109281226480.21709@wel-95.cs.helsinki.fi>
References: <4E82C0DD.6010304@intel.com> <alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi> <4E82E0EE.1050600@intel.com> <4E82E5B5.1050206@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1669187797-1317203408=:21709"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37859 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907Ab1I1JuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 05:50:10 -0400
In-Reply-To: <4E82E5B5.1050206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1669187797-1317203408=:21709
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 28 Sep 2011, Yan, Zheng wrote:

> On 09/28/2011 04:55 PM, Yan, Zheng wrote:
> > On 09/28/2011 04:17 PM, Ilpo Järvinen wrote:
> >> On Wed, 28 Sep 2011, Yan, Zheng wrote:
> >>
> >>> lost_skb_hint is used by tcp_mark_head_lost() to mark the first
> >>> unhandled skb. lost_cnt_hint is the number of sacked packets before
> >>> the lost_skb_hint. tcp_shifted_skb() shouldn't increase lost_cnt_hint
> >>> when shifting a sacked skb that is before the lost_skb_hint, because
> >>> packets in it are already counted.
> >>>
> >>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> >>> ---
> >>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >>> index 21fab3e..f712ace 100644
> >>> --- a/net/ipv4/tcp_input.c
> >>> +++ b/net/ipv4/tcp_input.c
> >>> @@ -1390,9 +1390,14 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
> >>>  	BUG_ON(!pcount);
> >>>  
> >>>  	/* Tweak before seqno plays */
> >>> -	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
> >>> -	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
> >>> -		tp->lost_cnt_hint += pcount;
> >>> +	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint) {
> >>> +		if (skb == tp->lost_skb_hint)
> >>> +			tp->lost_cnt_hint += pcount;
> >>> +		else if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
> >>> +			 before(TCP_SKB_CB(skb)->seq,
> >>> +				TCP_SKB_CB(tp->lost_skb_hint)->seq))
> >>> +			tp->lost_cnt_hint += pcount;
> >>> +	}
> >>
> >> Ah right, the hole filled case which shifts not only the newly SACKed 
> >> skb but also the next, already SACKed skb?
> >>
> >> I fail to see why you needed to change !before into two checks though:
> >>  skb == tp->lost_skb_hint and before(params reversed) ? Shouldn't the 
> >> equality that is provided by the negation cover for the == check (and the 
> >> params reversion isn't necessary in any case)? In fact, isn't the skb == 
> >> tp->lost_skb_hint check strictly wrong without the same TCPCB_SACKED_ACKED 
> >> guard (though I'm not sure, I didn't check, if the hint can ever point to 
> >> such a segment in the first place)?
> > 
> > Thanks you for your reply.
> > 
> > skb == tp->lost_skb_hint is special.
> > 
> > If the skb is sacked and we shift 'pcount' packets to previous skb,
> > these packets will not be counted by future tcp_mark_head_lost() call.
> > So we should increase lost_cnt_hint.
> > 
> > If the skb is not sacked, the skb will be sacked soon by tcp_sacktag_one(),
> > So we should not increase lost_cnt_hint.
> > 
> > I didn't think out the second case. I think the correct patch should be:
> > ---
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 21fab3e..dcc2411 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -1390,9 +1390,15 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
> >  	BUG_ON(!pcount);
> >  
> >  	/* Tweak before seqno plays */
> > -	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
> > -	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
> > -		tp->lost_cnt_hint += pcount;
> > +	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint) {
> > +		if ((TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
> > +		    skb == tp->lost_skb_hint)
> > +			tp->lost_cnt_hint += pcount;
> > +		else if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
> > +			 before(TCP_SKB_CB(skb)->seq,
> > +				TCP_SKB_CB(tp->lost_skb_hint)->seq))
> > +			tp->lost_cnt_hint += pcount;
> > +	}
> >  
> >  	TCP_SKB_CB(prev)->end_seq += shifted;
> >  	TCP_SKB_CB(skb)->seq += shifted;
> > ---
> 
> Sorry, I didn't think out the "skb before lost_skb_hint" case neither.
> If the skb isn't sacked, tcp_sacktag_one() will increase the lost_cnt_hint.
> So tcp_shifted_skb() shouldn't adjust the the lost_cnt_hint.
> 
> I hope my patch is correct this time.
> 
> ---
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 21fab3e..697ce5f 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1390,8 +1390,8 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
>  	BUG_ON(!pcount);
>  
>  	/* Tweak before seqno plays */
> -	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
> -	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
> +	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint == skb &&
> +	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
>  		tp->lost_cnt_hint += pcount;
>  
>  	TCP_SKB_CB(prev)->end_seq += shifted;

Hehe, besides not spotting all this, I also made another mistake in my 
last post. It seems that this code has been quite broken from the 
beginning or we still lack some detail. ...But the latest change certainly 
seems more reasonable than the previous code of mine if I've successfully 
understood enough pieces. These hints, although providing significant 
performance benefits, are really pain to get right :-).

But is the non-SACKed case really handled right when hint == skb by the 
sacktag_one. We move the seqno in between and then before(x->newseq, 
x->newseq) check returns false?


-- 
 i.
--8323329-1669187797-1317203408=:21709--
