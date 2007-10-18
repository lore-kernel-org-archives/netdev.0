From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Remove lost_retrans zero special cases
Date: Thu, 18 Oct 2007 14:07:42 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710181357370.3767@kivilampi-30.cs.helsinki.fi>
References: <20071018.125045.90803775.takano@axe-inc.co.jp>
 <Pine.LNX.4.64.0710181214140.3767@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0710181314130.3767@kivilampi-30.cs.helsinki.fi>
 <20071018.195558.103454352.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1454484492-1192705662=:3767"
Cc: y-kodama@aist.go.jp, Netdev <netdev@vger.kernel.org>
To: TAKANO Ryousei <takano@axe-inc.co.jp>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51233 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbXJRLHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 07:07:45 -0400
In-Reply-To: <20071018.195558.103454352.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1454484492-1192705662=:3767
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 18 Oct 2007, TAKANO Ryousei wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Subject: [PATCH] [TCP]: Remove lost_retrans zero special cases
> Date: Thu, 18 Oct 2007 13:17:24 +0300 (EEST)
> 
> > [PATCH] [TCP]: Remove lost_retrans zero seqno special cases
> > 
> > Both high-sack detection and new lowest seq variables have
> > unnecessary zero special case which are now removed by setting
> > safe initial seqnos.
> > 
> > This also fixes problem which caused zero received_upto being
> > passed to tcp_mark_lost_retrans which confused after relations
> > within the marker loop causing incorrect TCPCB_SACKED_RETRANS
> > clearing. The problem was noticed because of a performance
> > report from TAKANO Ryousei <takano@axe-inc.co.jp>.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > ---
> >  net/ipv4/tcp_input.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 0f00966..9288220 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -1121,7 +1121,7 @@ static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
> >  	struct sk_buff *skb;
> >  	int flag = 0;
> >  	int cnt = 0;
> > -	u32 new_low_seq = 0;
> > +	u32 new_low_seq = tp->snd_nxt;
> >  
> >  	tcp_for_write_queue(skb, sk) {
> >  		u32 ack_seq = TCP_SKB_CB(skb)->ack_seq;
> > @@ -1153,7 +1153,7 @@ static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
> >  				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
> >  			}
> >  		} else {
> > -			if (!new_low_seq || before(ack_seq, new_low_seq))
> > +			if (before(ack_seq, new_low_seq))
> >  				new_low_seq = ack_seq;
> >  			cnt += tcp_skb_pcount(skb);
> >  		}
> > @@ -1242,7 +1242,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
> >  	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
> >  	int reord = tp->packets_out;
> >  	int prior_fackets;
> > -	u32 highest_sack_end_seq = 0;
> > +	u32 highest_sack_end_seq = tp->lost_retrans_low;
> >  	int flag = 0;
> >  	int found_dup_sack = 0;
> >  	int cached_fack_count;
> > -- 
> > 1.5.0.6
> 
> Thanks Ilpo! This patch solves the problem, as shown below:
> 
> iteration :001 .... done. T = 17.365902 BW = 460.672876 Mbps
> iteration :002 .... done. T = 16.456351 BW = 486.134501 Mbps
> iteration :003 .... done. T = 16.658353 BW = 480.239550 Mbps
> iteration :004 .... done. T = 16.468834 BW = 485.766026 Mbps
> iteration :005 .... done. T = 16.596055 BW = 482.042268 Mbps
> 
> Acked-by: Ryousei Takano <takano-ryousei@aist.go.jp>

Thanks for quick testing, it was actually quite bad bug. I first
thought that it's just performance issue and therefore suspected
that the problem is elsewhere until I realized that the zero can
be used as seqno.

Dave, please put this one to net-2.6 and forget the other patch with
title "[TCP]: Add highest_sack_end_seq check back...", it would just
add another (wrong) zero special case back (they won't conflict with
each other, so being this verbose here) :-).

-- 
 i.
---696243703-1454484492-1192705662=:3767--
