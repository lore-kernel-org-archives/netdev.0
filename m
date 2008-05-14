From: Sage Weil <sage@newdream.net>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Wed, 14 May 2008 09:09:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805140900460.23143@cobra.newdream.net>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org>
 <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
 <20080514140908.GA14987@shareable.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763473AbYENQKV@vger.kernel.org>
In-Reply-To: <20080514140908.GA14987@shareable.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 May 2008, Jamie Lokier wrote:
> > Similarly, if only 1 out of 3 replicas is surviving, most people want to 
> > be able to read their data, while Paxos demands a majority to ensure it is 
> > correct.
> 
> (Generalising to any "quorum" (majority vote) protocol).
> 
> That's true if you require that all results are guaranteed consistent
> or blocked, in the event of any kind of network failure.
> 
> But if you prefer incoherent results in the event of a network split
> (and those are often mergable later), and only want to protect against
> media/node failures to the best extent possible at any given time,
> then quorum protocols can gracefully degrade so you still have access
> without a majority of working nodes.

Right.  In my case, I require guaranteed consistent results for critical 
cluster state, and use (slightly modified) Paxos for that.  For file data, 
I leverage that cluster state to still maintain perfect consistency in 
most failure scenarios, while also degrading gracefully to a read/write 
access to a single replica.

When problem situations arise (e.g., replicating to A+B, A fails, 
read/write to just B for a while, B fails, A recovers), an administrator 
can step in and explicitly indicate we want to relax consistency to 
continue (e.g., if B is found to be unsalvageable and a stale A is the 
best we can do).

> In that model, neighbour sensing is used to find the largest coherency
> domains fitting a set of parameters (such as "replicate datum X to N
> nodes with maximum comms latency T").  If the parameters are able to
> be met, quorum gives you the desired robustness in the event of
> node/network failures.  During any time while the coherency parameters
> cannot be met, the robustness reduces to the best it can do
> temporarily, and recovers when possible later.  As a bonus, you have
> some timing guarantees if they are more important.

Anything that silently relaxes consistency like that scares me.  Does 
anybody really do that in practice?

sage
