From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 15:31:05 +0100
Message-ID: <20080514143105.GB14987@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758695AbYENObX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514135156.GA23131@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> > For writes, Paxos is actually more or less optimal (in the non-failure 
> > cases, at least).  Reads are trickier, but there are ways to keep that 
> > fast as well.  FWIW, Ceph extends basic Paxos with a leasing mechanism to 
> > keep reads fast, consistent, and distributed.  It's only used for cluster 
> > state, though, not file data.
> 
> Well, it depends... If we are talking about single node perfromance,
> then any protocol, which requries to wait for authorization (or any
> approach, which waits for acknowledge just after data was sent) is slow.
>
> If we are talking about agregate parallel perfromance, then its basic
> protocol with 2 messages is (probably) optimal, but still I'm not
> convinced, that 2 messages case is a good choise, I want one :)

Look up "one-phase commit" or even "zero-phase commit".  (The
terminology is cheating a bit.)  As I've understood it, all commit
protocols have a step where each node guarantees it can commit if
asked and node failure at that point does not invalidate the guarantee
if the node recovers (if it can't maintain the guarantee, the node
doesn't recover in a technical sense and a higher level protocol may
reintegrate the node).  One/zero-phase commit extends that to
guaranteeing a certain amounts and types of data can be written before
it knows what the data is, so write messages within that window are
sufficient for global commits.  Guarantees can be acquired
asynchronously in advance of need, and can have time and other limits.
These guarantees are no different in principle from the 1-bit
guarantee offered by the "can you commit" phase of other commit
protocols, so they aren't as weak as they seem.

Now combine it with a quorum protocol like Paxos, you can commit with
async guarantees from a subset of nodes.  Guarantees can be
piggybacked on earlier requests.  There, single node write
performance with quorum robustness.

-- Jamie
