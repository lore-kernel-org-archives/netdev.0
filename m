From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH-2.4] Fix divide by 0 in vegas_cong_avoid()
Date: Wed, 30 May 2007 10:49:54 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705301010300.25173@kivilampi-30.cs.helsinki.fi>
References: <a5bf86a80705290218t5e8605d3m9750d9dae6d96112@mail.gmail.com>
 <20070529080534.5692bad8@freepuppy> <a5bf86a80705291123r7aa753besbcb1de3f13dc1b3c@mail.gmail.com>
 <20070529150216.712e422b@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Lior Dotan <liodot@gmail.com>, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36258 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbXE3Ht5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 03:49:57 -0400
In-Reply-To: <20070529150216.712e422b@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007, Stephen Hemminger wrote:

> On Tue, 29 May 2007 20:23:45 +0200
> "Lior Dotan" <liodot@gmail.com> wrote:
> 
> > NTP was not running. I'm not sure what do you mean by fixing the -1.
> > The trace shows that vegas_cong_avoid() is called with -1, and the
> > only way it can happen is from tcp_clean_rtx_queue() and the patch
> > should eliminate this. Another way of solving this is by checking
> > vegas_rtt_calc() and see if it gets -1 and handle it there.
> > Another thing that I don't understand is that some places like
> > tcp_ack() declare seq_rtt as signed and some vegas_cong_avoid()
> > declare it as unsigned. Shouldn't it be declared always as signed?
> > 
> > On 5/29/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > On Tue, 29 May 2007 12:18:19 +0300
> > > "Lior Dotan" <liodot@gmail.com> wrote:
> > >
> > > > Hi,
> > > >
> > > > I had a divide by zero on kernel 2.4.33 running with Vegas enabled.
> 
> I don't think anyone has backported the other vegas fixes from 2.6.21
> to 2.4.
> 
> 
> For 2.6.22, rtt_calc doesn't exist, instead pkts_acked is called.

I tried to figure this one out yesterday, and it seems to me that divide 
by zero should not occur with 2.6.22 (nor with 2.6.21 code), no matter
how I try to approach vegas...

> The following should be added to avoid getting bogus timestamp values 
> from retransmits.

...but this is unreliable timestamps problem is a real one that originates 
from API merge commit 164891aadf1721fca4dce473bb0e0998181537c6 of yours 
(see some though about it below). I suppose there are now similar concerns 
about timestamp validity in other cc modules than vegas too.

> --- a/net/ipv4/tcp_vegas.c	2007-05-02 12:26:35.000000000 -0700
> +++ b/net/ipv4/tcp_vegas.c	2007-05-29 14:06:26.000000000 -0700
> @@ -117,6 +117,10 @@ void tcp_vegas_pkts_acked(struct sock *s
>  	struct vegas *vegas = inet_csk_ca(sk);
>  	u32 vrtt;
>  
> +	/* Ignore retransmits */
> +	if (unlikely(cnt == 0))
> +		return;
> +
>  	/* Never allow zero rtt or baseRTT */
>  	vrtt = ktime_to_us(net_timedelta(last)) + 1;

...I don't think this works, because cnt won't be zero ever because to 
make the call some skbs were cleaned from the queue (isn't that what 
pkts_acked stands for?). There is as if (acked&FLAG_ACKED) guard before 
making the pkts_acked call to cc modules, thus delta in packets_out will 
always be greater than 0. Hmm, now that I realize this, I would say that
checks for > 0 in pkts_acked are entirely bogus (in the current code), 
hmm, that means I have more things to cleanup in tcp-2.6, at least, bic, 
cubic and westwood do them... :-).

I think the code did a right thing before your api merge, since it called 
rtt callback only if FLAG_RETRANS_DATA_ACKED was not set (and pkts_acked 
always), i.e., when TCP cannot know if it was the rexmission that 
triggered the cumulative ACK or any original transmission, no new RTT 
measurement should be made. Consider also the fact that, there might be a 
non rexmitted skb after rexmitted one, which Lior's patch doesn't do 
right way at all since the FLAG_DATA_ACKED would again get set (no 
div-by-zero would have occured then but an unreliable timestamp would
have been givento vegas in 2.4).

The number of packets that got cumulatively acked is never a right metric 
to measure whether the cumulative ACK originated from rexmitted skbs or 
not. ...Perhaps the FLAG_RETRANS_DATA_ACKED flag needs to be passed 
somehow to cc modules?


-- 
 i.
