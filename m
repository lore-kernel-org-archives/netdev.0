From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: "tcp: refine TSO autosizing" causes performance regression on
 Xen
Date: Thu, 9 Apr 2015 17:36:47 +0100
Message-ID: <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	<xen-devel@lists.xensource.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <christoffer.dall@linaro.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>, <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Apr 2015, Eric Dumazet wrote:
> On Thu, 2015-04-09 at 16:46 +0100, Stefano Stabellini wrote:
> > Hi all,
> > 
> > I found a performance regression when running netperf -t TCP_MAERTS from
> > an external host to a Xen VM on ARM64: v3.19 and v4.0-rc4 running in the
> > virtual machine are 30% slower than v3.18.
> > 
> > Through bisection I found that the perf regression is caused by the
> > prensence of the following commit in the guest kernel:
> > 
> > 
> > commit 605ad7f184b60cfaacbc038aa6c55ee68dee3c89
> > Author: Eric Dumazet <edumazet@google.com>
> > Date:   Sun Dec 7 12:22:18 2014 -0800
> > 
> >     tcp: refine TSO autosizing
> > 
> > 
> > A simple revert would fix the issue.
> > 
> > Does anybody have any ideas on what could be the cause of the problem?
> > Suggestions on what to do to fix it?
> 
> You sent this to lkml while networking discussions are on netdev.
> 
> This topic had been discussed on netdev multiple times.

Sorry, and many thanks for the quick reply!


> This commit restored original TCP Small Queue behavior, which is the
> first step to fight bufferbloat.
> 
> Some network drivers are known to be problematic because of a delayed TX
> completion.
> 
> So far this commit did not impact max single flow throughput on 40Gb
> mlx4 NIC. (ie : line rate is possible)
> 
> Try to tweak /proc/sys/net/ipv4/tcp_limit_output_bytes to see if it
> makes a difference ?

A very big difference:

echo 262144 > /proc/sys/net/ipv4/tcp_limit_output_bytes
brings us much closer to the original performance, the slowdown is just
8%

echo 1048576 > /proc/sys/net/ipv4/tcp_limit_output_bytes
fills the gap entirely, same performance as before "refine TSO
autosizing"


What would be the next step for here?  Should I just document this as an
important performance tweaking step for Xen, or is there something else
we can do?
