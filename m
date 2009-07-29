From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Wed, 29 Jul 2009 00:28:41 +0000
Message-ID: <1248827321.7249.38.camel@Maple>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	 <1246994776-1882-3-git-send-email-danms@us.ibm.com>
	 <1248555754.16746.55.camel@merlyn>  <874oswer21.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f184.google.com ([209.85.216.184]:39861 "EHLO
	mail-px0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbZG2A2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 20:28:46 -0400
Received: by pxi14 with SMTP id 14so267958pxi.33
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 17:28:45 -0700 (PDT)
In-Reply-To: <874oswer21.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-28 at 09:00 -0700, Dan Smith wrote:
> I think that we need to increment timers like this on restore anyway,
> which should make sure that the TIME_WAIT timers run for the same
> amount of wall-clock time regardless of how much time was spent in the
> process of migration, right?

Agreed.

> Since checkpoint is not aware of a potential migration, a regular
> (i.e. not intended for migration) checkpoint operation on a task
> running in the init netns will leave the TIME_WAIT socket in place
> until the timer expires.

Can this relationship be counted on--that checkpoints in the init
namespace will be stored indefinitely, and that otherwise the
checkpointed tree will be migrated in a bounded amount of time?  I think
you'll need to differentiate the two cases to get proper network
behavior, so there needs to be some reliable and documented indicator.

Or should this be an advise option?

> >> +		if (h->sock.state == TCP_LISTEN) {
> >> +			ret = socket->ops->listen(socket, h->sock.backlog);
> >> +			ckpt_debug("inet listen: %i", ret);
> >> +			if (ret < 0)
> >> +				goto out;
> >> +
> >> +			ret = sock_add_parent(ctx, socket->sk);
> >> +			if (ret < 0)
> >> +				goto out;
> 
> JD> So this is just dummied off as a proof-of-concept for LISTEN?
> 
> I'm not sure what you mean...

It's not as functional as the rest of the code.  The listening address
is hardwired and you're not restoring the socket state.  I'm assuming
that was intended as a development step.

> JD> At a minimum, you'll want to start the TCP retransmit timer if there is
> JD> unacknowledged data outstanding.  And other timers for other states, as
> JD> they're supported.
> 
> JD> And you probably do want to do slow-start again--disregard my babbling
> JD> from yesterday. 

It seems there's a wide range of requirements here.  A tree migrating
within a rack doesn't want to do slow-start again, nor restart its RTT
metrics.  But in the general case, you do need to.  Maybe the scaling of
congestion window and RTT on restore should be a tunable.

> JD>         	ret = sock_create(h->sock_common.family, h->sock.type, 0, &socket);
> JD>         	if (ret < 0)
> JD>         		return ERR_PTR(ret);
>         
> 
> JD> You _really_ want to pass the actual protocol number to sock_create().
> JD> The size of the sk it creates depends on this.  You'll quickly be in
> JD> memory corruption hell without it.
> 
> You mean I need to verify that the protocol is one of IPPROTO_TCP,
> IPPROTO_UDP, or PF_UNIX, right?

Right now, you're passing zero.  For inet and inet6 sockets, you want to
pass field num out of ckpt_hdr_socket_inet.  

> JD> Network sockets also use sk->sk_wmem_alloc to track references to
> JD> the sock from egress skb's
> 
> IIUC, this function is part of the framework's leak detection.  That
> code looks to make sure objects don't gain any additional users
> between the start and end of the checkpoint operation.  I think the
> sk_refcnt satisfies that requirement here, no?

As long as the function is only used for this, you're fine.  But it's
named very generally, and if it get used in the future for something
else, there might be a hole.

  --  John

