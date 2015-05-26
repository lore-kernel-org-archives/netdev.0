From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Mon, 25 May 2015 22:52:50 -0400
Message-ID: <1432608770.32671.122.camel@jasiiieee.pacifera.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:64579 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbbEZCw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 22:52:59 -0400
In-Reply-To: <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 15:31 -0700, Eric Dumazet wrote:
> On Mon, 2015-05-25 at 16:05 -0400, John A. Sullivan III wrote:
> > Hello, all.  One one of our connections we are doing intensive traffic
> > shaping with tc.  We are using ifb interfaces for shaping ingress
> > traffic and we also use ifb interfaces for egress so that we can apply
> > the same set of rules to multiple interfaces (e.g., tun and eth
> > interfaces operating on the same physical interface).
> > 
> > These are running on very powerful gateways; I have watched them
> > handling 16 Gbps with CPU utilization at a handful of percent.  Yet, I
> > am seeing drops on the ifb interfaces when I do a tc -s qdisc show.
> > 
> > Why would this be? I would expect if there was some kind of problem that
> > it would manifest as drops on the physical interfaces and not the IFB
> > interface.  We have played with queue lengths in both directions.  We
> > are using HFSC with SFQ leaves so I would imagine this overrides the
> > very short qlen on the IFB interfaces (32).  These are drops and not
> > overlimits.
> 
> IFB is single threaded and a serious bottleneck.
> 
> Don't use this on egress, this destroys multiqueue capaility.
> 
> And SFQ is pretty limited (127 packets)
> 
> You might try to change your NIC to have a single queue for RX,
> so that you have a single cpu feeding your IFB queue.
> 
> (ethtool -L eth0 rx 1)
> 
> 
> 
> 
> 
Hmm . . . I've been thinking about that SFQ leaf qdisc.  I see that
newer kernels allow a much higher "limit" than 127 but it still seems
that the queue depth limit for any one flow is still 127.  When we do
something like GRE/IPSec, I think the decrypted GRE traffic will
distribute across the queues but the IPSec traffic will collapse all the
packets initially into one queue.  At 80ms RTT a 1 Gbps wire speed, I
would need a queue of around 7500.  Thus, can one say that SFQ is almost
useless for high BDP connections?

Is there a similar round-robin type qdisc that does not have this
limitation?

If I recall correctly, if one does not attach a qdisc explicitly to a
class, it defaults to pfifo_fast.  Is that correct? Thanks - John
