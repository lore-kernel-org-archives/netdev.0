From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/14]: Make packet scheduler multiqueue aware.
Date: Tue, 15 Jul 2008 02:25:32 +0200
Message-ID: <487BEE7C.6080300@trash.net>
References: <20080714.155908.174564017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36432 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756560AbYGOAbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 20:31:10 -0400
In-Reply-To: <20080714.155908.174564017.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> My next plans are:
>
> 1) Integrate the feedback received over the weekend which I
>    didn't have time to process yet.
>
> 2) Respin the tree against a fresh net-next-2.6
>
> 3) Implement "QUEUE_NUM" netlink attribute so that the user can
>    request that packet scheduler operations apply to a specific
>    queue only.

I've looked over the API changes and a few qdiscs and everything
looks good to me. My only concern is the automatic replication
when using non-work-conserving qdiscs. They usually enforce an
upper rate to keep control of the queue in software. Replicating
them and distributing packets over multiple queues in combination
with automatic enabling of driver multiqueue features will break
existing configs.

Fundamentally I don't think transparent replication of non-work-
conserving qdiscs is the right thing to do since the only way
they can work correctly is when the administrator explicitly
assigns a smaller amount of bandwidth to the individual queues.
Unfortunately its a bit tricky to determine whether a qdisc is
non-work-conserving since at least HFSC can work in both modes,
and its depends on how the root class is configured (with or
without upper limit service curve).

Actually on second thought, it will even have unexpected effects
on work-conserving qdiscs since the device's queue classifier
(or simple_tx_hash) effectively overrides the manually configured
classifiers by distributing over multiple device qdiscs first.
Which means that for example in a configuration that previously
had certain packets sharing a qdisc, they might now end up in
different replications.

Unfortunately that seems to imply that anything but the really
simple qdiscs can't be used transparently in combination with
multiqueue without breaking configurations.


