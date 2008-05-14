From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 15:09:08 +0100
Message-ID: <20080514140908.GA14987@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:45162 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbYENOJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 10:09:17 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sage Weil wrote:
> I think the larger issue with Paxos is that I've yet to meet anyone who 
> wants their data replicated 3 ways (this despite newfangled 1TB+ disks not 
> having enough bandwidth to actualy _use_ the data they store).

For critical metadata which is needed to access a lot of data, it's
done: even ext3 replicates superblocks.

These days there are content and search indexes, and journals.  They
aren't replication but are related in some ways since parts of the
data are duplicated and voting protocols can feed into that.

There's also RAID6 and similar parity/coding.  The data is not fully
replicated, saving space, but the coordination is similar to N>=3 way
replication.  Now apply that over a network.  Or even local disks, if
you were looking to boost RAID write-commit performance.

> Similarly, if only 1 out of 3 replicas is surviving, most people want to 
> be able to read their data, while Paxos demands a majority to ensure it is 
> correct.

(Generalising to any "quorum" (majority vote) protocol).

That's true if you require that all results are guaranteed consistent
or blocked, in the event of any kind of network failure.

But if you prefer incoherent results in the event of a network split
(and those are often mergable later), and only want to protect against
media/node failures to the best extent possible at any given time,
then quorum protocols can gracefully degrade so you still have access
without a majority of working nodes.

That is a very useful property.  (I think it more closely mimics the
way some human organisations work too: we try to coordinate, but when
communications are down, we do the best we can and sync up later.)

In that model, neighbour sensing is used to find the largest coherency
domains fitting a set of parameters (such as "replicate datum X to N
nodes with maximum comms latency T").  If the parameters are able to
be met, quorum gives you the desired robustness in the event of
node/network failures.  During any time while the coherency parameters
cannot be met, the robustness reduces to the best it can do
temporarily, and recovers when possible later.  As a bonus, you have
some timing guarantees if they are more important.

This is pretty much the same as RAID durability.  You have robustness
against failures, still have access in the event of disk failures, and
degraded robustness (and performance) temporarily while awaiting a new
disk and resynchronising it.

-- Jamie
