From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix
 sockets
Date: Tue, 27 Oct 2015 13:04:23 +0100
Message-ID: <20151027130423.63f24dbb@redhat.com>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
	<20151026131928.GA1820@netboy>
	<1445866379.133031.420389177.3AE9E175@webmail.messagingengine.com>
	<20151027101157.GA1850@netboy>
	<1445944161.1336457.421364569.5449BCCB@webmail.messagingengine.com>
	<1445944516.1337466.421368457.2463FECE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753333AbbJ0ME0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 08:04:26 -0400
In-Reply-To: <1445944516.1337466.421368457.2463FECE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 27 Oct 2015 12:15:16 +0100 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Tue, Oct 27, 2015, at 12:09, Hannes Frederic Sowa wrote:
> > Hi Richard,
> > 
> > On Tue, Oct 27, 2015, at 11:11, Richard Cochran wrote:
> > > On Mon, Oct 26, 2015 at 02:32:59PM +0100, Hannes Frederic Sowa wrote:
> > > > On Mon, Oct 26, 2015, at 14:19, Richard Cochran wrote:
> > > > > On Mon, Oct 26, 2015 at 01:51:37PM +0100, Hannes Frederic Sowa wrote:
> > > > > > netstamp_needed is toggled for all socket families if they request
> > > > > > timestamping. But some protocols don't need the lower-layer timestamping
> > > > > > code at all. This patch starts disabling it for af-unix.
> > > > > 
> > > > > What problem is this patch trying to solve?
> > > > 
> > > > netstamp_needed is a static-key which enables timestamping code in the
> > > > networking stack receive functions for every packet, while it is not
> > > > needed for AF_UNIX/LOCAL. So it is merely a small performance
> > > > enhancement.
> > > 
> > > Are there any numbers that show the effect of this enhancement?
> > 
> > I haven't personally done any performance numbers.
> > 
> > Jesper (in Cc) noticed that it showed up in perf performance reports
> > even though he used a very minimal setup. Turned out that
> > systemd-journald enables timestamping on AF_UNIX sockets which thus
> > enabled netstamps globally. I think Jesper can chime in here.

Well, it should be quite obvious that requesting a timestamp on every
packet is a fairly expensive, especially when not used for anything.

I can estimate the cost by looking at perf report, on a single-flow
IP-fwd test (1989575 pps) CPU i7-4790K @ 4.2GHz.

I quick IP-fwd test show perf top:
 1.54%  ksoftirqd/1  [kernel.vmlinux]  [k] read_tsc
 1.07%  ksoftirqd/1  [kernel.vmlinux]  [k] ktime_get_with_offset

(1/1989575*10^9)*((1.54+1.07)/100) = 13.12 nanosec

On some of my slower systems, I've seen cost of just reading TSC be
around 32 ns.

> Also counter question: why is the netstamp code protected by a
> static_key otherwise if not for trying to suppress the code path as
> often as possible if not used? ;)

Exactly ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
