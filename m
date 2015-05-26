From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 10:13:40 -0700
Message-ID: <1432660420.4060.271.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432650358-11470-1-git-send-email-ido@wizery.com>
	 <1432657435.4060.267.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150526170222.GA13376@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Yariv <idox.yariv@intel.com>
To: Ido Yariv <ido@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150526170222.GA13376@WorkStation.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 13:02 -0400, Ido Yariv wrote:
> Hi Eric,
> 
> On Tue, May 26, 2015 at 09:23:55AM -0700, Eric Dumazet wrote:
> > On Tue, 2015-05-26 at 10:25 -0400, Ido Yariv wrote:
> > > The Tail Loss Probe RFC specifies that the PTO value should be set to
> > > max(2 * SRTT, 10ms), where SRTT is the smoothed round-trip time.
> > > 
> > > The PTO value is converted to jiffies, so the timer might expire
> > > prematurely. This is especially problematic on systems in which HZ=100.
> > > 
> > > To work around this issue, increase the number of jiffies by one,
> > > ensuring that the timeout won't expire in less than 10ms.
> > > 
> > > Signed-off-by: Ido Yariv <idox.yariv@intel.com>
> > > ---
> > >  net/ipv4/tcp_output.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > > index 534e5fd..6f57d3d 100644
> > > --- a/net/ipv4/tcp_output.c
> > > +++ b/net/ipv4/tcp_output.c
> > > @@ -2207,7 +2207,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
> > >  	if (tp->packets_out == 1)
> > >  		timeout = max_t(u32, timeout,
> > >  				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
> > > -	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
> > > +	timeout = max_t(u32, timeout, msecs_to_jiffies(10) + 1);
> > >  
> > >  	/* If RTO is shorter, just schedule TLP in its place. */
> > >  	tlp_time_stamp = tcp_time_stamp + timeout;
> > 
> > Have you really hit an issue, or did you send this patch after all these
> > msecs_to_jiffies() discussions on lkml/netdev ?
> 
> This actually fixed a specific issue I ran into. This issue caused a
> degradation in throughput in a benchmark which sent relatively small
> chunks of data (100KB) in a loop. The impact was quite substantial -
> with this patch, throughput increased by up to 50% on the platform this
> was tested on.


Really ? You have more problems if your benchmark relies on TLP.

Please share your setup, because I suspect you hit other more serious
bugs.



> This was actually the first incarnation of this patch. However, while
> the impact of this issue when HZ=100 is the greatest, it can also impact
> other settings as well. For instance, if HZ=250, the timer could expire
> after a bit over 8ms instead of 10ms, and 9ms for HZ=1000.
> 
> By increasing the number of jiffies, we ensure that we'll wait at least
> 10ms but never less than that, so for HZ=1000, it'll be anywhere between
> 10ms and 11ms instead of 9ms and 10ms.

Yes, but we do not want to blindly increase this timeout, tested few
years ago with this exact value : between 9 and 10 ms. Not between 10
and 11 ms, with an added 10% in max latencies.
