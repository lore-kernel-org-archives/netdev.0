From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from
	unjoined groups
Date: Fri, 11 Jul 2008 13:31:25 -0400
Message-ID: <20080711173125.GB4534@hmsreliant.think-freely.org>
References: <20080711152112.GA4534@hmsreliant.think-freely.org> <20080711164801.GA31161@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	dlstevens@us.ibm.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2383 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753350AbYGKRcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 13:32:18 -0400
Content-Disposition: inline
In-Reply-To: <20080711164801.GA31161@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2008 at 08:48:01PM +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> > The current ipv4 multicast code incorrectly allows frames destined to any
> > multicast group to be received on any socket that is bound to INADDR_ANY,
> 
> Yes, it used to behave this way.
> 
Not sure what you mean here, it still does behave this way.

> And this is more fresh (than reference to practice in days of yore :-))
> rationale given by David Stevens:
> 
> 
> > Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to sockets	that
> >  are joined to group
> > From: David Stevens <dlstevens@us.ibm.com>
> > Date: Thu, 14 Sep 2006 08:39:39 -0700
> > 
> > Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote on 09/14/2006 03:30:37 AM:
> > 
> > > Hello!
> > > 
> > > >         No, it returns 1 (allow) if there are no filters to explicitly
> > > > filter it. I wrote that code. :-)
> > > 
> > > I see. It did not behave this way old times.
> > > 
> > > From your mails I understood that current behaviour matches another
> > > implementations (BSD whatever), is it true?
> > 
> > Hi, Alexey,
> > 
> > If you mean IPv6 code in current BSD derivatives, I don't know.
> > 
> > The IPv6 behaviour was different from IPv4 on Linux and was changed for
> > compatibility with IPv4 (discussion on netdev agreed that binding
> > should determine socket delivery, not group membership, or simply
> > that there was no reason to be different from long-standing IPv4 
> > practice).
> > 
> > The IPv4 code is that way for compatibility with everything else since
> > about ~4.3BSD (with the possible exception of Solaris 8, apparently).
> > 
> > FWIW, I think Deering's original interpretation is correct. Adding
> > a multicast address to an interface by joining a group is little
> > different from adding a unicast address via SIOCSIFADDR, which
> > certainly does affect packets delivered to the machine and to any
> > INADDR_ANY-bound socket. Binding to the multicast address and not
> > INADDR_ANY will give you only packets for that group, if that's
> > what you want, just as in the unicast address-specific bind.
> > 
> >                                                         +-DLS

I see what David is trying to say, but
there is still a bug here.  in ip_mc_sf_allow, we scan the mc_list for the
passed in inet_dev looking for a match, if we find a match we check it to see if
the sfmode matches the mode of the source filter list, and we return accept or
deny based on that information.  The problem arises when there is no match on
the mc_list.  The mc_list represents mcast groups that the interface has joined.
currently in ip_mc_sf_allow we assume that we need to allow the frame if no
match is found, but that has the affect of causing frames to be received for
groups a socket hasn't joined.  I asked david aobut this specifically.

I can see how semantically for a source filter we might want to return allow for
no match in the mc_list, but the code just doesn't seem to allow for that.  In
udp_v4_mcast_next, we return a socket if (among other tests) ip_mc_sf_allow
returns 1, and we're universally returning 1 if the received packet has a
multicast destination address that doesn't appear on the source interfaces
mc_list.

David, can you provide insight here?

Regards
Neil

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
