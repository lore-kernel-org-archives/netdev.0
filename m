From: Karl MacMillan <kmacmillan@tresys.com>
Subject: Re: [RFC] SECMARK 1.0
Date: Tue, 09 May 2006 09:24:45 -0400
Message-ID: <1147181085.32719.105.camel@jackjack.columbia.tresys.com>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
	 <445E288B.4040908@gentoo.org> <Pine.LNX.4.64.0605071323330.9423@d.namei>
	 <1147110088.32719.56.camel@jackjack.columbia.tresys.com>
	 <Pine.LNX.4.64.0605081719440.18947@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joshua Brindle <method@gentoo.org>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tresys.irides.com ([216.250.243.126]:61703 "EHLO
	exchange.columbia.tresys.com") by vger.kernel.org with ESMTP
	id S932514AbWEIN10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 09:27:26 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605081719440.18947@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-08 at 17:29 -0400, James Morris wrote:
> On Mon, 8 May 2006, Karl MacMillan wrote:
> 
> > Something like CONNMARK seems preferable to me (perhaps even allowing
> > type_transition rules to give the related packets a unique type). This
> > makes the labeling reflect the real security property of the packets.
> 
> That's arguable.  The real security property afaict is that the packets 
> are of some state (established or related to an existing connection).  It 
> is implicit in the mechanism that they're tracked as part of an authorized 
> connection.
> 

This loses how the connection was initiated, however. Packets that are
part of a connection that was initiated on the ftp port are different
from packets that are part of a connection initiated on the telnet port.
Now, the name_bind permissions will limit which domains can initiate
those connection, but my concern is that connection could, through error
or exploit, be passed to another domain that should not receive packets
from that type of connection (see below).

> > Yes, we are trusting the conntrack to mark the packets accurately, but
> > it makes the policy match the intent. Otherwise it is not possible to
> > reason about information flow using just the policy.
> 
> Why not?  You just state that all established and related packets reaching 
> vsftpd are valid, and that no invalid packets can deliver data to the 
> application.  You can play tricks and stick a label on a packet but that 
> doesn't change what's actually happening or your ability to reason about 
> it.  You assume conntrack works correctly (and if it doesn't, then 
> labeling connections will break, too).
> 

The use of a single related packet type loses the strong binding between
the connection type (determined on connection) and domains, most likely
because an established connection is passed to another process.

For example, for xinetd to work all of the xinetd children would be
allowed to receive all related packets (i.e., tracked_packet_t). This
means that if xinetd incorrectly passed, say, an ftp connection to
telnet it would still be allowed to receive those packets because they
would be of type tracked_packet_t. Labeling using something like
connmark seems to solve this problem. There may be other examples
relating to enforcing data separation based on other connection
information, like the network interface, but I haven't had a chance to
work through those scenarios.

Now you may be saying that it is not possible to determine with any
assurance that a related packet is related to, for example, a connection
that was initiated on the ftp port (and therefore given a different type
- related_ftp_packet_t - fixing my xinetd example). If this is the case,
your argument makes more sense to me.

Karl

-- 
Karl MacMillan
Tresys Technology
www.tresys.com

> > Are there serious downsides to this approach?
> 
> Yes, it's an ugly hack which is not needed.
> 
> > > You can always not use conntrack and emulate the existing controls, as 
> > > well.
> > 
> > Yes, but gaining connection tracking is a major advantage of this
> > approach over the existing controls.
> 
> The point is to show that this scheme provides much stonger security 
> assurrances, and that if you wished, you could easily rervert to stateless 
> filtering and have the "correct" labels on the packets; which would be 
> worse.
> 
> 
> 
> - James

