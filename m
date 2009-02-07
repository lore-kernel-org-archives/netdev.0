From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Sat, 7 Feb 2009 12:49:32 -0500
Message-ID: <20090207174931.GA10247@localhost.localdomain>
References: <20090206182020.GA24399@hmsreliant.think-freely.org> <20090206165736.295ec007@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34446 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbZBGRth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 12:49:37 -0500
Content-Disposition: inline
In-Reply-To: <20090206165736.295ec007@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 06, 2009 at 04:57:36PM -0800, Stephen Hemminger wrote:
> On Fri, 6 Feb 2009 13:20:20 -0500
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > Hey all-
> > 	A week or so ago I tried posting a tracepoint patch for net-next which
> > was met with some resistance, with opposing arguments circling around the lines
> > of not having an upstream user for those points, which I think is good
> > criticizm.  As such I think I've come up with a project idea here that I can
> > implement using a few tracepoints (not that that really matters in light of the
> > overall scheme of things), but I wanted to propose it here and get some feedback
> > from people on what they think might be good and bad about this.
> > 
> > 
> > Problem: 
> > Gathering information about packets that are dropped within the kernel
> > network stack.
> > 
> > Problem Backround: 
> > The Linux kernel is nominally quite good about avoid packet
> > drops whenever possible.  However, there are of course times when packet
> > processing errors, malformed frames, or other conditions result in the need to
> > abandon a packet during reception or transmission.  Savy system administrators
> > are perfectly capable of monitoring for and detecting these lost packets so that
> > possible corrective action can be taken.  However the sysadmins job here suffers
> > from three distinct shortcommings in our user space drop detection facilities:
> > 
> > 1) Fragmentation of information: Dropped packets occur at many different layers
> > of the network stack, and different mechanisms are used to access information
> > about drops in those various layers.  Statistics at various layers may require a
> > simple reading of a proc file, or it may require the use of one or more tools.
> > At minimum, by my count, at least 6 files/tools must be queried to get a
> > complete picture of where in the network stack a packet is being dropped.
> > 
> > 2) Clarity of meaning: While some statistics are clear, others may be less so.
> > Even if a sysadmin knows that there are several places to look for a dropped
> > packet, [s]he may be far less clear on which statistics in those tools/files map
> > to an actual lost packet.  For instance, does a TCP AttemptFail imply a dropped
> > packet or not?  A quick reading of the source may indicate that, but thats at
> > best a subpar solution
> > 
> > 3) Ambiguity of cause:  Even if a sysadmin correctly checks all the locations
> > for dropped packets and gleans which are the relevant stats for that purpose,
> > there is still missing information that some might enjoy.  Namely, the root
> > cause of the problem.  For example, UDPInErrors stats are incremented in several
> > places in the code, and for two primary purposes (application congestion leading
> > to a full rcvbuf, or a udp checksum error).  While the stats presented to the
> > user provide information indicating that packets were dropped in the UDP code,
> > the root cause is still a mystery.
> > 
> > Solution:
> > To solve this problem, I would like to propose the addition of a new netlink
> > protocol, NETLINK_DRPMON.  The notion is that user space applications would
> > dynamically engage this service, which would then monitor several tracepoints
> > throughout the kernel (which would in aggregate cover all the possible locations
> > from the system call to the hardware in which a network packet might be
> > dropped), these tracepoints would be hooked by the "drop monitor" to catch
> > increments in relevant statistics at these points, and, if/when they do,
> > broadcast a netlink message to listening applications to inform them a drop has
> > taken place.  This alert would include information about the location of the
> > drop (class (IPV4/IPV6/arp/hardware/etc), type (InHdrErrors, etc), and specific
> > location (function and line number)).  Using such a method, admins could then
> > use an application to reliably monitor for network packet drops in one
> > consolidated place, while keeping performance impact to a minimum (since
> > tracepoints are meant to have no impact when disabled, and very little impact
> > otherwise).  It consolidates information, provides clarity in what does and
> > doesn't constitute a drop, and provide to the line number information about
> > where the drop occured.
> > 
> > I've written some of this already, but I wanted to stop and get feedback before
> > I went any farther.  Please bear in mind that the patch below is totally
> > incomplete.  Most notably its missing most of the netlink protocol
> > implementation, and there is far from complete coverage of all the in-kernel
> > drop point locations.  But the IPv4 SNMP stats are completely covered and serve
> > as an exemplar of how I was planning on doing drop recording.  Also notably
> > missing is the user space app to listen for these messages, but if there is
> > general consensus that this is indeed a good idea, I'll get started on the
> > protocol and user app straight away.
> > 
> > So, have at it.  Good thoughts and bad all welcome.  Thanks for the interest and
> > the feedback!
> > 
> > Thanks & Regards
> > Neil
> 
> I like the concept but not really happy about the implementation. It overloads
> SNMP stats stuff which are expensive, and doesn't cover hardware or transmit
> queue droppage.
> 
Well, as I mentioned, its totally incomplete.  I only posted it, so that you
could see an exemplar of how I wanted to use tracepoints to dynamically
intercept various in kernel events so that I could gather drop notifications. Of
course several other tracepoints will be needed to capture other classes of drop
(IPv6 stats, arp queue overflows, qdisc drops, etc).

As for the expense, I'm not sure what you're referring to.  The idea was to use
tracepoints which (when disabled) provides effectively no performance penalty,
and only a minimum of penalty when enabled.  What do you see as the major
performance impact here?

Best
Neil

> 
