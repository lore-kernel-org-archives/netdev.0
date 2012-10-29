From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Mon, 29 Oct 2012 08:41:43 +0000
Message-ID: <20121029084143.GA17442@casper.infradead.org>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
 <20121026143704.GC25087@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45553 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787Ab2J2Ilv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:41:51 -0400
Content-Disposition: inline
In-Reply-To: <20121026143704.GC25087@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/12 at 10:37am, Neil Horman wrote:
> We already have files in /proc/net/sctp to count snmp system-wide totals,
> per-endpoint totals, and per association totals.  Why do these stats differently
> instead of just adding them the per-association file?  I get that solaris does
> this, but its not codified in any of the RFC's or other standards.  I would
> really rather see something like this go into the interfaces we have, rather
> than creating a new one.

I really dislike to grow the procfs interface. I would favour a
netlink inteface but we already export all the statistics via
the socket interface so this is the most consistent choice.

> And the max observed rto stat is just odd.  Each
> transport has an rto value, not each association, and you cal already see the
> individual transport rto values in /proc/net/sctp/remaddr.

It's true that this is not found in any RFC and the request seems to
be based on the fact that Solaris provides this information already.
Recording the largest observed RTO is critical for latency sensitive
use cases. Looking at RTO in remaddr doesn't really help to figure out
the MAX(RTO) even with a very high polling frequency, something you
don't want to do on a procfs file.

> 
> > +	if (q->asoc)
> > +		q->asoc->rtxpackets++;
> > +
> > +
> This seems incorrect to me.  The packet being assembled here may have new chunks
> in it (either control or data).  Counting a packet as being retransmitted just
> because it has a retransmitted chunk in it seems wrong.  At the very least its a
> misleading/vague statistic.

I agree, this can't be done 100% accurate. I'm fine with leaving this
out and have userspace create the sum of SCTP_MIB_*_RETRANSMITS.

> > +		if (chunk->asoc)
> > +			chunk->asoc->outseqtsns++;
> This just seems wrong.  The definition states that this is counting the last TSN
> recevied (despite being name outseqtsns), yet this looks like you're:
> 1) just incrementing a counter, rather than recording the TSN value itself
> (which may or may not be what you meant, but seems to contradict what the
> comments at the definition)
> 2) Only incremanting it if the TSN is out of range, which makes very little
> sense to me.

As Vlad pointed out the name could be improved but the description
seems correct. The statistic counts the number of chunks where
TSN > expected.
