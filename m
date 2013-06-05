From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Wed, 5 Jun 2013 13:57:57 +0100
Message-ID: <1370437077.4021.15.camel@deadeye.wl.decadent.org.uk>
References: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
	 <1370245762-5126-2-git-send-email-tparkin@katalix.com>
	 <1370270652.1918.14.camel@bwh-desktop.uk.level5networks.com>
	 <20130605094111.GB2522@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jchapman@katalix.com>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42914 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034Ab3FEM6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 08:58:05 -0400
In-Reply-To: <20130605094111.GB2522@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 10:41 +0100, Tom Parkin wrote:
> On Mon, Jun 03, 2013 at 03:44:12PM +0100, Ben Hutchings wrote:
> > On Mon, 2013-06-03 at 08:49 +0100, Tom Parkin wrote:
> > > Hardware offload for UDP datagram checksum calculation doesn't work with
> > > fragmented IP packets -- the device will note the fragmentation and leave the
> > > UDP checksum well alone.
> > > 
> > > As such, if we expect the L2TP packet to be fragmented by the IP layer we need
> > > to perform the UDP checksum ourselves in software (ref: net/ipv4/udp.c).
> > >
> > > This change modifies the L2TP xmit path to fallback to software checksum
> > > calculation if the L2TP packet + IP header exceeds the tunnel device MTU.
> > [...]
> > 
> > Surely this should be done in the IP stack when fragmenting, not in any
> > particular client?
> > 
> 
> Hmm, that's a good question.
> 
> I'm not sure it makes sense to push this down into the IP layer, though.  Since 
> it's the UDP checksum we're calculating, it seems reasonable to handle it at 
> the UDP layer (which is where L2TP sits when using UDP encapsulation).

TCP, UDP and similar checksums can be handled generically, e.g. if
dev_hard_start_xmit() finds the device doesn't actually do checksum
offload then it calls skb_checksum_help() to fill it in.  I was thinking
that since the IP layer makes the decision to fragment then it should
also be responsible for filling in the checksum before doing so.  Why
should the transport layer protocol have to guess?

> If you're worried about reproducing similar code in both UDP and L2TP
> I can see where you're coming from, but since UDP uses corking and
> L2TP doesn't the data transmit path is quite dissimilar.  We could
> probably do some work to share the code, but it doesn't seem worth it
> for the amount of sharing we'd be able to achieve.

OK, so long as you've thought about the options.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
