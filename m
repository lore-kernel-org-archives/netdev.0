From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 22:19:40 +0100
Message-ID: <20080514211940.GA23758@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514140908.GA14987@shareable.org> <Pine.LNX.4.64.0805140900460.23143@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805140900460.23143@cobra.newdream.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sage Weil wrote:
> > In that model, neighbour sensing is used to find the largest coherency
> > domains fitting a set of parameters (such as "replicate datum X to N
> > nodes with maximum comms latency T").  If the parameters are able to
> > be met, quorum gives you the desired robustness in the event of
> > node/network failures.  During any time while the coherency parameters
> > cannot be met, the robustness reduces to the best it can do
> > temporarily, and recovers when possible later.  As a bonus, you have
> > some timing guarantees if they are more important.
> 
> Anything that silently relaxes consistency like that scares me.  Does 
> anybody really do that in practice?

I'm doing it on a 2000 node system across a country.  There are so
many links down at any given time, we have to handle long stretches of
inconsistency, and have strategies for merging local changes when
possible to reduce manual overhead.  But we like opportunistic
consistency so that people at site A can phone people at site B and
view/change the same things in real time if a path between them is up
and fast enough (great for support and demos), otherwise their actions
are queued or refused depending on policy.

It makes sense to configure which data and/or operations require
global consistency or block, and which data it's ok to modify locally
and merge automatically in a netsplit scenario.  Think DVCS during
splits and coherent when possible.

E.g. as a filesystem, during netsplits you might configure the system
to allow changes to /home/* locally if global coherency is down.  If
all changes (or generally, transaction traces) to /home/user1 are in
just one coherent subgroup, on recovery they can be distributed
silently to the others, unaffected by changes to /home/user2
elsewhere.  But if multiple separated coherent subgroups all change
/home/user1, recovery might be configured to flag them as conflicts,
queue them for manual inspection, and maybe have a policy for the
values used until a person gets involved.

Or instead of paths you might distinguish on user ids, or by explicit
flags in requests (you should really allow that anyway).  Or by
tracing causal relationships requiring programs to follow some rules
(see "virtual synchrony"; the rule is "don't depend on hidden
communications").

That's a policy choice, but in some systems, typically those with many
nodes and fluctuating communications, it's really worth it.  It
increases some kinds of robustness, at cost of others.

-- Jamie
