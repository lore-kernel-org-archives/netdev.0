From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 22 Apr 2009 11:49:50 -0700
Message-ID: <49EF66CE.10800@hp.com>
References: <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam>	<65634d660904211152l6c17aa6dpf7e626474acfe499@mail.gmail.com> <20090422.022120.211323498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, shemminger@vyatta.com, dada1@cosmosbay.com,
	andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:26871 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbZDVStz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 14:49:55 -0400
In-Reply-To: <20090422.022120.211323498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 21 Apr 2009 11:52:07 -0700
> 
> 
>>That is possible and don't think the design of our patch would
>>preclude it, but I am worried that each time the mapping from a
>>connection to a CPU changes this could cause of out of order
>>packets.  I suppose this is similar problem to changing the RSS hash
>>mappings in a device.
> 
> 
> Yes, out of order packet processing is a serious issue.
> 
> There are some things I've been brainstorming about.
> 
> One thought I keep coming back to is the hack the block layer
> is using right now.  It remembers which CPU a block I/O request
> comes in on, and it makes sure the completion runs on that
> cpu too.
> 
> We could remember the cpu that the last socket level operation
> occurred upon, and use that as a target for packets.  This requires a
> bit of work.
> 
> First we'd need some kind of pre-demux at netif_receive_skb()
> time to look up the cpu target, and reference this blob from
> the socket somehow, and keep it uptodate at various specific
> locations (read/write/poll, whatever...).

Does poll on the socket touch all that many cachelines, or are you thinking of it 
as being a predictor of where read/write will be called?

> 
> Or we could pre-demux the real socket.  That could be exciting.
> 
> But then we come back to the cpu number changing issue.  There is a
> cool way to handle this, because it seems that we can just keep
> queueing to the previous cpu and it can check the socket cpu cookie.
> If that changes, the old target can push the rest of it's queue to
> that cpu and then update the cpu target blob.
> 
> Anyways, just some ideas.

For what it is worth, at the 5000 foot description level that is exactly what 
HP-UX 11.X does and calls TOPS (Thread Optimized Packet Scheduling).  Where the 
socket was last accessed is stashed away (in the socket/stream structure) and 
that is looked-up when the driver hands the packet up the stack.  It was done 
that way in HP-UX 11.X because we found that simply hashing the headers (what 
HP-UX 10.20 called "Inbound Packet Scheduling" or IPS) while fine for discrete 
netperf TCP_RR tests, wasn't really what one wanted when a single thread of 
execution was servicing more than one connection/flow.

The TOPS patches were added to HP-UX 11.0 ca 1998 and while there have been some 
issues (as you surmise, and others thanks to Streams being involved :) it appears 
to have worked rather well these last ten years.  So, at least in the abstract 
what is proposed above has at least a little pre-validation.  TOPS can be 
disabled/enabled via an ndd (ie sysctl) setting for those cases when the number 
of NICs (back then they were all single-queue) or now queues is a reasonable 
fraction of the number of cores and  the administrator can/wants to silo things.

rick jones
