From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix wraparound issue in tcp_lp
Date: Mon, 01 May 2017 18:04:47 -0700
Message-ID: <1493687087.31837.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493677788.31837.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170501165643.698aa0b5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33725 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdEBBEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 21:04:51 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so6733625pgc.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 18:04:51 -0700 (PDT)
In-Reply-To: <20170501165643.698aa0b5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-01 at 16:56 -0700, Stephen Hemminger wrote:
> On Mon, 01 May 2017 15:29:48 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Be careful when comparing tcp_time_stamp to some u32 quantity,
> > otherwise result can be surprising.
> > 
> > Fixes: 7c106d7e782b ("[TCP]: TCP Low Priority congestion control")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/ipv4/tcp_lp.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
> > index 046fd3910873306d74207615d6997e1c847ea361..d6fb6c067af4641f232b94e7c590c212648e8173 100644
> > --- a/net/ipv4/tcp_lp.c
> > +++ b/net/ipv4/tcp_lp.c
> > @@ -264,13 +264,15 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
> >  {
> >  	struct tcp_sock *tp = tcp_sk(sk);
> >  	struct lp *lp = inet_csk_ca(sk);
> > +	u32 delta;
> >  
> >  	if (sample->rtt_us > 0)
> >  		tcp_lp_rtt_sample(sk, sample->rtt_us);
> >  
> >  	/* calc inference */
> > -	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
> > -		lp->inference = 3 * (tcp_time_stamp - tp->rx_opt.rcv_tsecr);
> > +	delta = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
> > +	if ((s32)delta > 0)
> > +		lp->inference = 3 * delta;
> 
> Agreed time wraparound would cause problems.
> But why not use existing time_after() macro here?
> 

Simply to not perform (tcp_time_stamp - tp->rx_opt.rcv_tsecr) twice.

jiffies being volatile, this can not be optimized by the compiler.

I have a patch series (for linux-4.13) that will switch TCP stack to 1ms
TS options, regardless of CONFIG_HZ value, and when cooking it I found
this bug.
