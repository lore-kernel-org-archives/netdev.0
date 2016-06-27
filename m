From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION, bisect]cxgb4 port failure with TSO traffic after
 commit 10d3be569243def8("tcp-tso: do not split TSO packets at retransmit time")
Date: Mon, 27 Jun 2016 09:12:57 -0400
Message-ID: <CADVnQynZxphzi37PD6GRV6k=tgjHfH2HuL7GiGVjOSMOCLSOcA@mail.gmail.com>
References: <6DE8042992C3D3488ACEF3F2607097E3C4A81CA5@nice.asicdesigners.com>
 <CANn89iLpBC5tUqpdSE4jCMKFgUi=mg=2kPZtMaRh-cnBhvauNg@mail.gmail.com>
 <6DE8042992C3D3488ACEF3F2607097E3C4A82805@nice.asicdesigners.com>
 <CANn89i+ePpSDYPtQeZa=fdN84=4WKdDb88P-dOVyPyY_DMK02g@mail.gmail.com>
 <1466785507.6850.105.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160627071750.GA13304@v4.asicdesigners.com> <1467014782.6850.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160627085957.GB13319@v4.asicdesigners.com> <1467019279.6850.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160627095445.GC13319@v4.asicdesigners.com> <1467024617.6850.148.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467031616.6850.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arjun V <arjun@chelsio.com>, Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ycheng@google.com" <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35541 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcF0NN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 09:13:27 -0400
Received: by mail-oi0-f48.google.com with SMTP id r2so199536272oih.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 06:13:27 -0700 (PDT)
In-Reply-To: <1467031616.6850.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 8:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Patch would be :
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 8bd9911fdd16..3587efe22864 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2784,6 +2784,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
>                 segs = tp->snd_cwnd - tcp_packets_in_flight(tp);
>                 if (segs <= 0)
>                         return;
> +               /* In case tcp_shift_skb_data() have aggregated large skbs,
> +                * we need to make sure not sending too big TSO packets.
> +                */
> +               segs = min_t(int, segs, tp->gso_segs);
>
>                 if (fwd_rexmitting) {
>  begin_fwd:

Nice catch, Eric. What do you think about using tcp_tso_autosize()
instead of tp->gso_segs? The goal would be to get autosized skbs in
this case, instead of 64KByte skbs. In addition to helping this corner
case of SACK reneging, this might also help things in general, since
if we are retransmitting packets then the cwnd and hence pacing rate
and hence autosized skb length might be smaller now than they were
when the packets were first sent. Just a thought.

neal
