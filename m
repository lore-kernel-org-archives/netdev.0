From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Tue, 30 Oct 2012 12:52:30 +0000
Message-ID: <20121030125230.GB13450@casper.infradead.org>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
 <20121026143704.GC25087@hmsreliant.think-freely.org>
 <20121029084143.GA17442@casper.infradead.org>
 <20121029113700.GA9332@hmsreliant.think-freely.org>
 <508EE586.9060907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55698 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab2J3Mwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 08:52:39 -0400
Content-Disposition: inline
In-Reply-To: <508EE586.9060907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/12 at 04:22pm, Vlad Yasevich wrote:
> On 10/29/2012 07:37 AM, Neil Horman wrote:
> >Hm, ok, looking for the maximum rto seen is definately more efficient that a
> >high polling rate on the remaddr file.  Still can't say I really like it as a
> >statistic though.  While it helps in diagnosing a very specific type of problem
> >(applications that have a maximum allowable latency), its really not useful, and
> >potentially misleading, in the general case.  Specificaly it may show a very
> >large RTO even if that RTO was an erroneous spike in behavior earlier in the
> >lifetime of a given transport, even if that RTO is not representative of the
> >current behavior of the association.  It seems to me like this stat might be
> >better collected using a stap script or by adding a trace point to
> >sctp_transport_update_rto.  If the application needs to know this information
> >internally during its operation to take corrective action, you can already get
> >it via the SCTP_GET_PEER_ADDR_INFO socket option on a per transport basis just
> >as efficiently.

SCTP_GET_PEER_ADDR_INFO doesn't help here as the whole point of this
stat is to get max(rto) as seen by the SCTP stack.

> The max_rto is reset after each getsockopt(), so in effect, the
> application sets its own polling interval and gets the max rto
> achieved during it.  If the rto hasn't changed, then the last value
> is returned.  Not sure how much I like that.  I would rather get max
> rto achieved per polling period and upon reset, max_rto is
> accumulated again (easy way to do that is set to rto_min on reset).
> This way an monitoring thread can truly represent the max rto
> reported by association.  It should normally remain steady, but this
> will show spikes, if any.

I would still reset it to 0 but I agree that it makes more sense to
return 0 if max(rto) remains unchanged within the observation period
rather than returning the previous max(rto).
