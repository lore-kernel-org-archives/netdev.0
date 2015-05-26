From: Ido Yariv <ido@wizery.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 13:55:40 -0400
Message-ID: <20150526175540.GB13376@WorkStation.home>
References: <1432650358-11470-1-git-send-email-ido@wizery.com>
 <1432657435.4060.267.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150526170222.GA13376@WorkStation.home>
 <1432660420.4060.271.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Yariv <idox.yariv@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432660420.4060.271.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Tue, May 26, 2015 at 10:13:40AM -0700, Eric Dumazet wrote:
> On Tue, 2015-05-26 at 13:02 -0400, Ido Yariv wrote:
> > Hi Eric,
> > 
> > On Tue, May 26, 2015 at 09:23:55AM -0700, Eric Dumazet wrote:
> > > Have you really hit an issue, or did you send this patch after all these
> > > msecs_to_jiffies() discussions on lkml/netdev ?
> > 
> > This actually fixed a specific issue I ran into. This issue caused a
> > degradation in throughput in a benchmark which sent relatively small
> > chunks of data (100KB) in a loop. The impact was quite substantial -
> > with this patch, throughput increased by up to 50% on the platform this
> > was tested on.
> 
> 
> Really ? You have more problems if your benchmark relies on TLP.
> 
> Please share your setup, because I suspect you hit other more serious
> bugs.

The platform this was tested on was an embedded platform with a wifi
module (11n, 20MHZ). The other end was a computer running Windows, and
the benchmarking software was IxChariot.
The whole setup was running in a shielded box with minimal
interferences.

As it seems, the throughput was limited by the congestion window.
Further analysis led to TLP - the fact that its timer was expiring
prematurely impacted cwnd, which in turn prevented the wireless driver
from having enough skbs to buffer and send.

Increasing the size of the chunks being sent had a similar impact on
throughput, presumably because the congestion window had enough time to
increase.

Changing the congestion window to Westwood from cubic/reno also had a
similar impact on throughput.

> > This was actually the first incarnation of this patch. However, while
> > the impact of this issue when HZ=100 is the greatest, it can also impact
> > other settings as well. For instance, if HZ=250, the timer could expire
> > after a bit over 8ms instead of 10ms, and 9ms for HZ=1000.
> > 
> > By increasing the number of jiffies, we ensure that we'll wait at least
> > 10ms but never less than that, so for HZ=1000, it'll be anywhere between
> > 10ms and 11ms instead of 9ms and 10ms.
> 
> Yes, but we do not want to blindly increase this timeout, tested few
> years ago with this exact value : between 9 and 10 ms. Not between 10
> and 11 ms, with an added 10% in max latencies.

I understand, and I also suspect that having it expire after 9ms will
have very little impact, if at all.

Since it mainly affects HZ=100 systems, we can simply go with having at
least 2 jiffies on these systems, and leave everything else as is.

However, if the 10ms has a special meaning (couldn't find reasoning for
it in the RFC), making sure this timer doesn't expire prematurely could
be beneficial. I'm afraid this was not tested on the setup mentioned
above though.

Thanks,
Ido.
