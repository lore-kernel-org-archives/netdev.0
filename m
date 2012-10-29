From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Mon, 29 Oct 2012 07:37:00 -0400
Message-ID: <20121029113700.GA9332@hmsreliant.think-freely.org>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
 <20121026143704.GC25087@hmsreliant.think-freely.org>
 <20121029084143.GA17442@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53347 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932329Ab2J2LhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 07:37:20 -0400
Content-Disposition: inline
In-Reply-To: <20121029084143.GA17442@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 29, 2012 at 08:41:43AM +0000, Thomas Graf wrote:
> On 10/26/12 at 10:37am, Neil Horman wrote:
> > We already have files in /proc/net/sctp to count snmp system-wide totals,
> > per-endpoint totals, and per association totals.  Why do these stats differently
> > instead of just adding them the per-association file?  I get that solaris does
> > this, but its not codified in any of the RFC's or other standards.  I would
> > really rather see something like this go into the interfaces we have, rather
> > than creating a new one.
> 
> I really dislike to grow the procfs interface. I would favour a
> netlink inteface but we already export all the statistics via
> the socket interface so this is the most consistent choice.
> 
I'm not sure what statistics you are referring to here.  The only stats I see
exported (save for association setting exported via SCTP_STATUS on the socket
interface), are done via proc.  I agree that proc stinks out loud, but my first
though when seeing stats exported via an interface in which you need to provide
process specific data (in this case the socket and association id), is that the
very next thing that someone will ask for is the ability for these stats to be
visible from outside the process, so an external tool can monitor them.  I guess
I'm ok with this approach, since its more efficient than polling proc (as per
your needs below), but maybe its time to start looking at implementing a
NETLINK_STATS interface so that we can have the best of both worlds.


> > And the max observed rto stat is just odd.  Each
> > transport has an rto value, not each association, and you cal already see the
> > individual transport rto values in /proc/net/sctp/remaddr.
> 
> It's true that this is not found in any RFC and the request seems to
> be based on the fact that Solaris provides this information already.
> Recording the largest observed RTO is critical for latency sensitive
> use cases. Looking at RTO in remaddr doesn't really help to figure out
> the MAX(RTO) even with a very high polling frequency, something you
> don't want to do on a procfs file.
> 
Hm, ok, looking for the maximum rto seen is definately more efficient that a
high polling rate on the remaddr file.  Still can't say I really like it as a
statistic though.  While it helps in diagnosing a very specific type of problem
(applications that have a maximum allowable latency), its really not useful, and
potentially misleading, in the general case.  Specificaly it may show a very
large RTO even if that RTO was an erroneous spike in behavior earlier in the
lifetime of a given transport, even if that RTO is not representative of the
current behavior of the association.  It seems to me like this stat might be
better collected using a stap script or by adding a trace point to
sctp_transport_update_rto.  If the application needs to know this information
internally during its operation to take corrective action, you can already get
it via the SCTP_GET_PEER_ADDR_INFO socket option on a per transport basis just
as efficiently.

> > 
> > > +	if (q->asoc)
> > > +		q->asoc->rtxpackets++;
> > > +
> > > +
> > This seems incorrect to me.  The packet being assembled here may have new chunks
> > in it (either control or data).  Counting a packet as being retransmitted just
> > because it has a retransmitted chunk in it seems wrong.  At the very least its a
> > misleading/vague statistic.
> 
> I agree, this can't be done 100% accurate. I'm fine with leaving this
> out and have userspace create the sum of SCTP_MIB_*_RETRANSMITS.
> 
Thank you, I agree.

> > > +		if (chunk->asoc)
> > > +			chunk->asoc->outseqtsns++;
> > This just seems wrong.  The definition states that this is counting the last TSN
> > recevied (despite being name outseqtsns), yet this looks like you're:
> > 1) just incrementing a counter, rather than recording the TSN value itself
> > (which may or may not be what you meant, but seems to contradict what the
> > comments at the definition)
> > 2) Only incremanting it if the TSN is out of range, which makes very little
> > sense to me.
> 
> As Vlad pointed out the name could be improved but the description
> seems correct. The statistic counts the number of chunks where
> TSN > expected.
> 
I'll look at it again, but the comments really suggested to me that this was
mean to be a counter of the last transmitted tsn value, not the number of tsn's
that were received out of the windowed range.

Neil
