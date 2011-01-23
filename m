From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Sun, 23 Jan 2011 12:39:02 +0200
Message-ID: <20110123103902.GA28585@redhat.com>
References: <20110114063528.GB10957@verge.net.au>
 <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
 <20110120083727.GA1807@verge.net.au>
 <20110121095929.GE26070@redhat.com>
 <20110121231149.GI2195@verge.net.au>
 <20110122215742.GC5617@redhat.com>
 <20110123063849.GB2673@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab1AWKkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 05:40:36 -0500
Content-Disposition: inline
In-Reply-To: <20110123063849.GB2673@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 23, 2011 at 05:38:49PM +1100, Simon Horman wrote:
> On Sat, Jan 22, 2011 at 11:57:42PM +0200, Michael S. Tsirkin wrote:
> > On Sat, Jan 22, 2011 at 10:11:52AM +1100, Simon Horman wrote:
> > > On Fri, Jan 21, 2011 at 11:59:30AM +0200, Michael S. Tsirkin wrote:
> > > > On Thu, Jan 20, 2011 at 05:38:33PM +0900, Simon Horman wrote:
> > > > > [ Trimmed Eric from CC list as vger was complaining that it is too long ]
> > > > > 
> > > > > On Tue, Jan 18, 2011 at 11:41:22AM -0800, Rick Jones wrote:
> > > > > > >So it won't be all that simple to implement well, and before we try,
> > > > > > >I'd like to know whether there are applications that are helped
> > > > > > >by it. For example, we could try to measure latency at various
> > > > > > >pps and see whether the backpressure helps. netperf has -b, -w
> > > > > > >flags which might help these measurements.
> > > > > > 
> > > > > > Those options are enabled when one adds --enable-burst to the
> > > > > > pre-compilation ./configure  of netperf (one doesn't have to
> > > > > > recompile netserver).  However, if one is also looking at latency
> > > > > > statistics via the -j option in the top-of-trunk, or simply at the
> > > > > > histogram with --enable-histogram on the ./configure and a verbosity
> > > > > > level of 2 (global -v 2) then one wants the very top of trunk
> > > > > > netperf from:
> > > > > 
> > > > > Hi,
> > > > > 
> > > > > I have constructed a test where I run an un-paced  UDP_STREAM test in
> > > > > one guest and a paced omni rr test in another guest at the same time.
> > > > 
> > > > Hmm, what is this supposed to measure?  Basically each time you run an
> > > > un-paced UDP_STREAM you get some random load on the network.
> > > > You can't tell what it was exactly, only that it was between
> > > > the send and receive throughput.
> > > 
> > > Rick mentioned in another email that I messed up my test parameters a bit,
> > > so I will re-run the tests, incorporating his suggestions.
> > > 
> > > What I was attempting to measure was the effect of an unpaced UDP_STREAM
> > > on the latency of more moderated traffic. Because I am interested in
> > > what effect an abusive guest has on other guests and how that my be
> > > mitigated.
> > > 
> > > Could you suggest some tests that you feel are more appropriate?
> > 
> > Yes. To refraze my concern in these terms, besides the malicious guest
> > you have another software in host (netperf) that interferes with
> > the traffic, and it cooperates with the malicious guest.
> > Right?
> 
> Yes, that is the scenario in this test.

Yes but I think that you want to put some controlled load on host.
Let's assume that we impove the speed somehow and now you can push more
bytes per second without loss.  Result might be a regression in your
test because you let the guest push "as much as it can" and suddenly it
can push more data through.  OTOH with packet loss the load on host is
anywhere in between send and receive throughput: there's no easy way to
measure it from netperf: the earlier some buffers overrun, the earlier
the packets get dropped and the less the load on host.

This is why I say that to get a specific
load on host you want to limit the sender
to a specific BW and then either
- make sure packet loss % is close to 0.
- make sure packet loss % is close to 100%.

> > IMO for a malicious guest you would send
> > UDP packets that then get dropped by the host.
> > 
> > For example block netperf in host so that
> > it does not consume packets from the socket.
> 
> I'm more interested in rate-limiting netperf than blocking it.

Well I mean netperf on host.

> But in any case, do you mean use iptables or tc based on
> classification made by net_cls?

Just to block netperf you can send it SIGSTOP :)

-- 
MST
