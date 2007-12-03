From: "Shao Liu" <shaoliu@Princeton.EDU>
Subject: RE: [RFC] TCP illinois max rtt aging
Date: Mon, 3 Dec 2007 15:59:23 -0800
Message-ID: <002f01c83608$8a2fb600$9e8f2200$@edu>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com> <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu> <20071128154725.29af2852@freepuppy.rosehill> <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com> <474E0B33.2060108@linux-foundation.org> <001b01c83248$604f4120$20edc360$@edu> <20071203145207.40e4ac57@freepuppy.rosehill> <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
Reply-To: <shaoliu@Princeton.EDU>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	"'Herbert Xu'" <herbert@gondor.apana.org.au>,
	"'Douglas Leith'" <doug.leith@nuim.ie>,
	"'Robert Shorten'" <robert.shorten@nuim.ie>,
	<netdev@vger.kernel.org>
To: "'Lachlan Andrew'" <lachlan.andrew@gmail.com>,
	"'Stephen Hemminger'" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice04.Princeton.EDU ([128.112.131.112]:39033 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752088AbXLCX7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 18:59:53 -0500
In-Reply-To: <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen and Lachlan,

Thanks for the discussion. The gradual aging is surely an option. And
another possibility is that, we compute the RTT just before congestion
notification, which ideally, represent the full queueing delay + propagation
delay. We can compute the average of the last M such values, and either use
the average as maxRTT, or use it as a benchmark to judge whether a sample is
outlier. How do you think of this idea?

And also a question, why the samples when SACK is active are outliers? 

For the accuracy of time stamping, I am not very familiar with the
implementation details. But I can think of two ways, 1) do time stamp in as
low layer as possible; 2) use as high priority thread to do it as possible.
For 2), we can use separate threads to do time stamp and to process packets.

Thanks and I will let you know more of my thoughts after I go over the
entire code space!
-Shao 


-----Original Message-----
From: Lachlan Andrew [mailto:lachlan.andrew@gmail.com] 
Sent: Monday, December 03, 2007 3:06 PM
To: Stephen Hemminger
Cc: shaoliu@Princeton.EDU; David S. Miller; Herbert Xu; Douglas Leith;
Robert Shorten; netdev@vger.kernel.org
Subject: Re: [RFC] TCP illinois max rtt aging

Greetings Stephen,

Thanks.  We'll have to play with the rate of ageing.  I used the slower
ageing

	if (ca->cnt_rtt > 3) {
		u64 mean_rtt = ca->sum_rtt;
		do_div (mean_rtt, ca->cnt_rtt);

		if (ca->max_rtt > mean_rtt)
			ca->max_rtt -= (ca->max_rtt - mean_rtt) >> 9;
	}

and still found that the max_rtt drops considerably within a congestion
epoch.

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
> > For the max RTT problem, I have considered it also and I have some idea
on
> > improve it. I also have some other places to improve. I will summarize
all
> > my new ideas and send you an update. For me to change it, could you
please
> > give me a link to download to latest source codes for the whole
congestion
> > control module in Linux implementation, including the general module for
all
> > algorithms, and the implementation for specific algorithms like
TCP-Illinois
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
> +       /* add slowly fading memory for maxRTT to accommodate routing
changes */
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

