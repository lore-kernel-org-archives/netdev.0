From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 8 Oct 2008 14:10:17 +0200
Message-ID: <20081008121017.GA28783@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <20081008135402.7b837992@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4651 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbYJHMKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 08:10:23 -0400
Content-Disposition: inline
In-Reply-To: <20081008135402.7b837992@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Wed, Oct 08, 2008 at 01:54:02PM +0200, Stephen Hemminger wrote:
> On Wed, 8 Oct 2008 10:11:09 +0200
> Willy Tarreau <w@1wt.eu> wrote:
> 
> > Hi David,
> > 
> > I hope you had a pleasant journey in Paris last week. It was nice to meet you.
> > 
> > In 2005, I submitted a patch for 2.6.11 which we finally did not decide
> > on, it was about the ability to disable TCP simultaneous connection open.
> > 
> > For the last few years, we've been bothered several times by newbies
> > reading "TCP/IP for dummies" then trying to get a name by discovering
> > the ultimate vulnerability which will get a lot of press coverage. Of
> > course those attacks are often pointless or just proofs of concepts
> > with no application in real life, but it's nonetheless annoying to have
> > to deal with the issues, especially to explain to customers why they
> > shouldn't have to worry.
> > 
> > I would not be surprized that a next one will exploit TCP's ability to
> > perform simultaneous connections between two clients. It's very easy
> > to trigger, there's no SEQ to guess, just a port, and the effect is
> > simply a poor DoS on the service trying to connect outside. In other
> > times we would have found it very minor, but judging by the consideration
> > given to harder and less effective "attacks" these days, this trivial
> > one may finally get picked and annoy us again.
> > 
> > As a reminder (especially for those who are not aware of this feature),
> > it is possible with TCP to connect two clients together if both send
> > crossed SYNs, then SYN-ACKs, then ACKs. This implies that each side
> > accepts the sequence number of the other one without any ability to
> > check that it matches its SYN. So it's trivial for an attacker to
> > prevent one client from establishing a connection from a known port
> > to a known address/port by sending it a SYN to that port. The client
> > will then send a SYN-ACK and will not accept the expected server's
> > SYN-ACK because the SYN SEQ will be different. The server might also
> > send an RST on the client's SYN-ACK if it's not firewalled. The
> > connection will eventually timeout in a SYN-RECV state or simply be
> > aborted.
> > 
> > The theorical DoS effect on some predictable address/port destinations
> > is easy to understand. Services with very few destination IP/ports such
> > as software/signature updates, SMTP relaying, DNS clients for zone
> > transfers, or SSH remote accesses are easy targets. In practice, the
> > SYN would have to be sent after the client's SYN and before the server's
> > SYN-ACK, which leaves a small time window limiting the attack to far
> > remote, unfirewalled communications.
> > 
> > This is very easy to test, I'm used to do it between two netcats, and
> > preventing the initial RST by unplugging the cable before sending the
> > connects. I remember it also worked on Solaris 8, and I don't remember
> > about BSDs (though I would not be surprized they support it too).
> > 
> > IMHO this feature is totally useless nowadays, because :
> >   - if one of the machines is firewalled, the firewall will block it
> >     (none of the firewalls I've tested among Netfilter, Checkpoint,
> >      Cisco, Fortinet, Juniper supports simultaneous connect, and it
> >      would cause a big security issue).
> > 
> >   - if neither machines are firewalled, then the SYN to a closed port
> >     will immediately trigger an RST, making it very difficult to
> >     establish a working connection.
> > 
> > For this reason, I'd like that we plan on merging the attached patch
> > (or any variant) for 2.6.28 or 2.6.29 before a new random junkie comes
> > aroung screaming loud he uncovered a big DoS hole in Linux TCP stack. The
> > patch provides a sysctl allowing the user to enable or disable the feature.
> > I've been running all my kernels with the code ifdef'ed out for the last
> > 4-5 years, but I certainly can understand that some people want to be able
> > to enable it for any reason (even for educationnal purposes), hence the
> > sysctl.
> > 
> > I have rediffed the patch for 2.6.27-rc9 and successfully tested it (both
> > with feature enabled and disabled). It disables the feature by default,
> > but I have no problem with leaving it on and expecting that distros will
> > ship it off.
> > 
> > By the way, during the tests I noticed something strange. While the
> > socket is in SYN_RECV on the first side to receive the other one's
> > SYN, it has a huge receive queue :
> > 
> > Active Internet connections (servers and established)
> > Proto Recv-Q     Send-Q Local Address        Foreign Address      State
> > tcp   3964220580      1 192.32.189.160:12346 192.32.189.228:4000  SYN_RECV
> > 
> > The value corresponds to the ACK value emitted, which is equal to the
> > other end's SYN+1. I don't know if this is just an artefact of the way
> > the queue size is reported (probably because the first ACK has not yet
> > been considered since we're not in ESTABLISHED state) or if this can
> > have any further impact (eg: unexpected memory freeing on termination,
> > etc...).
> > 
> > Best regards,
> > Willy
> 
> Does this break NAT traversal via STUNT used by applications like Skype?

Not IMHO. I've seen UDP-based protocols used for NAT traversal, since it's
stateless and the firewall is not able to perform much control, but TCP
would not work with most firewalls (starting with netfilter) because the
firewall will not accept a SYN in return to a SYN.

Regards,
Willy

