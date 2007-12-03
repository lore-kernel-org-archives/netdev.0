From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Mon, 3 Dec 2007 15:06:02 -0800
Message-ID: <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
	 <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>
	 <20071128154725.29af2852@freepuppy.rosehill>
	 <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
	 <474E0B33.2060108@linux-foundation.org>
	 <001b01c83248$604f4120$20edc360$@edu>
	 <20071203145207.40e4ac57@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shaoliu@princeton.edu, "David S. Miller" <davem@davemloft.net>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Douglas Leith" <doug.leith@nuim.ie>,
	"Robert Shorten" <robert.shorten@nuim.ie>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:26395 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbXLCXGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 18:06:04 -0500
Received: by py-out-1112.google.com with SMTP id u77so6752934pyb
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2007 15:06:03 -0800 (PST)
In-Reply-To: <20071203145207.40e4ac57@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings Stephen,

Thanks.  We'll have to play with the rate of ageing.  I used the slower ageing

	if (ca->cnt_rtt > 3) {
		u64 mean_rtt = ca->sum_rtt;
		do_div (mean_rtt, ca->cnt_rtt);

		if (ca->max_rtt > mean_rtt)
			ca->max_rtt -= (ca->max_rtt - mean_rtt) >> 9;
	}

and still found that the max_rtt drops considerably within a congestion epoch.

What would also really help would be getting rid of RTT outliers
somehow.  I ignore RTT measurements when SACK is active:
       if (ca->max_rtt < rtt) {
	    struct tcp_sock *tp = tcp_sk(sk);
	    if (! tp->sacked_out )	// SACKs cause hi-CPU/hi-RTT. ignore
		ca->max_rtt = rtt;
	}
which helps a lot, but still gets some outliers.  Would it be possible
to time-stamp packets in the hardware interrupt handler, instead of
waiting for the post-processing stage?

Cheers,
Lachlan

On 03/12/2007, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Wed, 28 Nov 2007 21:26:12 -0800
> "Shao Liu" <shaoliu@Princeton.EDU> wrote:
>
> > Hi Stephen and Lachlan,
> >
> > Thanks for pointing out and fixing this bug.
> >
> > For the max RTT problem, I have considered it also and I have some idea on
> > improve it. I also have some other places to improve. I will summarize all
> > my new ideas and send you an update. For me to change it, could you please
> > give me a link to download to latest source codes for the whole congestion
> > control module in Linux implementation, including the general module for all
> > algorithms, and the implementation for specific algorithms like TCP-Illinois
> > and H-TCP?
> >
> > Thanks for the help!
> > -Shao
> >
> >
> >
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@linux-foundation.org]
> > Sent: Wednesday, November 28, 2007 4:44 PM
> > To: Lachlan Andrew
> > Cc: David S. Miller; Herbert Xu; shaoliu@Princeton.EDU; Douglas Leith;
> > Robert Shorten; netdev@vger.kernel.org
> > Subject: Re: [PATCH] tcp-illinois: incorrect beta usage
> >
> > Lachlan Andrew wrote:
> > > Thanks Stephen.
> > >
> > > A related problem (largely due to the published algorithm itself) is
> > > that Illinois is very aggressive when it over-estimates the maximum
> > > RTT.
> > >
> > > At high load (say 200Mbps and 200ms RTT), a backlog of packets builds
> > > up just after a loss, causing the RTT estimate to become large.  This
> > > makes Illinois think that *all* losses are due to corruption not
> > > congestion, and so only back off by 1/8 instead of 1/2.
> > >
> > > I can't think how to fix this except by better RTT estimation, or
> > > changes to Illinois itself.  Currently, I ignore RTT measurements when
> > >    sacked_out != 0    and have a heuristic "RTT aging" mechanism, but
> > > that's pretty ugly.
> > >
> > > Cheers,
> > > Lachlan
> > >
> > >
> > Ageing the RTT estimates needs to be done anyway.
> > Maybe something can be reused from H-TCP. The two are closely related.
> >
>
> The following adds gradual aging of max RTT.
>
> --- a/net/ipv4/tcp_illinois.c   2007-11-29 08:58:35.000000000 -0800
> +++ b/net/ipv4/tcp_illinois.c   2007-11-29 09:37:33.000000000 -0800
> @@ -63,7 +63,10 @@ static void rtt_reset(struct sock *sk)
>         ca->cnt_rtt = 0;
>         ca->sum_rtt = 0;
>
> -       /* TODO: age max_rtt? */
> +       /* add slowly fading memory for maxRTT to accommodate routing changes */
> +       if (ca->max_rtt > ca->base_rtt)
> +               ca->max_rtt = ca->base_rtt
> +                       + (((ca->max_rtt - ca->base_rtt) * 31) >> 5);
>  }
>
>  static void tcp_illinois_init(struct sock *sk)
>


-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
