From: Karl MacMillan <kmacmillan@tresys.com>
Subject: Re: [RFC] SECMARK 1.0
Date: Tue, 09 May 2006 13:06:39 -0400
Message-ID: <1147194399.32719.148.camel@jackjack.columbia.tresys.com>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
	 <445E288B.4040908@gentoo.org> <Pine.LNX.4.64.0605071323330.9423@d.namei>
	 <1147110088.32719.56.camel@jackjack.columbia.tresys.com>
	 <Pine.LNX.4.64.0605081719440.18947@d.namei>
	 <1147181085.32719.105.camel@jackjack.columbia.tresys.com>
	 <Pine.LNX.4.64.0605091229190.25948@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joshua Brindle <method@gentoo.org>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tresys.irides.com ([216.250.243.126]:59930 "EHLO
	exchange.columbia.tresys.com") by vger.kernel.org with ESMTP
	id S1750756AbWEIRJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 13:09:19 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605091229190.25948@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-09 at 12:40 -0400, James Morris wrote:
> On Tue, 9 May 2006, Karl MacMillan wrote:
> 
> > those connection, but my concern is that connection could, through error
> > or exploit, be passed to another domain that should not receive packets
> > from that type of connection (see below).
> 
> Connection passing or inheritence should be subject to kernel MAC controls 
> anyway (also see below).
> 

It is, but with no differentiation to how the connection was initially
established (continue to see below).

> > The use of a single related packet type loses the strong binding between
> > the connection type (determined on connection) and domains, most likely
> > because an established connection is passed to another process.
> > 
> > For example, for xinetd to work all of the xinetd children would be
> > allowed to receive all related packets (i.e., tracked_packet_t). This
> > means that if xinetd incorrectly passed, say, an ftp connection to
> > telnet it would still be allowed to receive those packets because they
> > would be of type tracked_packet_t. Labeling using something like
> > connmark seems to solve this problem.
> 
> My understanding of xinetd is that it execs server applications, which 
> inherit the connection fd.  In this case, flush_unauthorized_files() will 
> ensure that the new domain is authorized to access the fd.
> 
> Stephen, can you confirm this?
> 

It doesn't matter whether the fd is inherited or passed over a unix
domain socket, the problem is the same. The fd and the underlying socket
will have the type of the creating process. So, yes there is control but
there is no differentiation; either a child can inherit/receive the
existing connection from xinetd or it cannot, regardless of how the
connection was initiated.

Another way of looking at this is that if a single type is used for all
related packets the network controls that we can place on, for example,
ftpd depend on whether it listens directly to the ftp port or it runs
through xinetd. This seems unfortunate.

> > There may be other examples relating to enforcing data separation based 
> > on other connection information, like the network interface, but I 
> > haven't had a chance to work through those scenarios.
> 
> I'm not sure exactly what you mean here, but the idea of this scheme is 
> that you can create new types to represent arbitrary combinations of 
> security-relevant properites of a packet.
> 
> e.g. extif_ftp_packet_t for ftp packets over an external interface.
> 

Right, I understand that, but it seems that much of that granularity is
lost when connection tracking is used.

For example, if we have a xinetd execute the ftp daemon in different
domains based on the network interface, originating ip address, etc.
(presumably for confidentiality reasons). With the single related packet
type we must completely trust xinetd to pass the correct connections to
the ftp daemon in the correct domain: the related packets that the ftpd
will be the same regardless of whether the initial packets where
extif_ftp_packet_t or intern_ftp_packet_t.

If the security context of the related packets is the same as the
packets for the connection establishment we no longer have to trust
xinetd.

> > Now you may be saying that it is not possible to determine with any
> > assurance that a related packet is related to, for example, a connection
> > that was initiated on the ftp port (and therefore given a different type
> > - related_ftp_packet_t - fixing my xinetd example). If this is the case,
> > your argument makes more sense to me.
> 
> This is not the case.  The problem is adding a secmark field to the 
> connection tracking system, and then having to implement several rules for 
> each labeling intent.  The conntrack is first labeled from the initial 
> packet, then tracked packets are labeled from the conntrack label.  It's 
> ugly.
> 

Ok - I obviously don't have the expertise to judge how ugly the code to
do this is. It becomes a question of whether the feature is compelling
enough.

Karl

-- 
Karl MacMillan
Tresys Technology
www.tresys.com

> 
> - James

