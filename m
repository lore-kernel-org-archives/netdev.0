From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Wed, 22 Aug 2012 10:58:30 +0200
Message-ID: <1345625910.5158.793.camel@edumazet-glaptop>
References: <503419D3.1080700@linlab.net>
	 <1345622798.5158.717.camel@edumazet-glaptop>  <50349CC5.3050601@linlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Alex Bergmann <alex@linlab.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50349CC5.3050601@linlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-22 at 10:48 +0200, Alex Bergmann wrote:
> On 08/22/2012 10:06 AM, Eric Dumazet wrote:
> >> Prior to 9ad7c049 the timeout was defined with 189secs. Now we have only
> >> a timeout of 63secs.
> >>
> >>          ((2 << 5) - 1) * 3 secs = 189 secs
> >>          ((2 << 5) - 1) * 1 secs = 63 secs
> > 
> > Strange maths ... here I have :
> > 
> > (1+2+4+8+16) * 3 = 93 secs
> > vs
> > (1+2+4+8+16) * 1 = 31 secs
> > 
> > So even before said commit, we were not rfc1122 compliant.
> > 
> > Using 7 retries would give 127 seconds, still not rfc compliant.
> 
> You're missing the timeout after the 5th SYN packet was sent. This 
> would result in another 32 seconds (96 seconds).
> 
> The timeout is calculated here:
> 
> net/ipv4/tcp_timer.c(146:150)
> 
> 	if (boundary <= linear_backoff_thresh)
> 		timeout = ((2 << boundary) - 1) * rto_base;
> 	else
> 		timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
> 			(boundary - linear_backoff_thresh) * TCP_RTO_MAX;

Thats the code yes but you miss the fact that last occurence of the
timer doesnt send a frame on the _network_

R2 is derived from the last frame sent.

Fact that the connect() is a bit long to return to user space is not
relevant. We could block the task for 2 hours and still be non RFC
compliant.

Actual 5 frames are sent, so the effective global timeout is the one I
quoted.

1 + 2 + 4 + 8 + 16   and its 31 

Just do a tcpdump and you can see it.
