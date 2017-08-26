From: Ido Schimmel <idosch@idosch.org>
Subject: Re: mlxsw and rtnl lock
Date: Sat, 26 Aug 2017 20:04:18 +0300
Message-ID: <20170826170418.GA22324@shredder>
References: <dccefbeb-b5c3-14ed-05d3-07d464989708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mlxsw@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:38957 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751062AbdHZREY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 13:04:24 -0400
Content-Disposition: inline
In-Reply-To: <dccefbeb-b5c3-14ed-05d3-07d464989708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 01:26:07PM -0700, David Ahern wrote:
> Jiri / Ido:
> 
> I was looking at the mlxsw driver and the places it holds the rtnl lock.
> There are a lot of them and from an admittedly short review it seems
> like the rtnl is protecting changes to mlxsw data structures as opposed
> to calling into the core networking stack. This is going to have huge
> impacts on scalability when both the kernel programming (user changes)
> and the hardware programming require the rtnl.

I'm aware of the problem and I intend to look into it. When we started
working on mlxsw about two years ago all the operations were serialized
by rtnl_lock, so when we had to add processing in a different context,
we ended up taking the same lock to protect against changes. But it can
impact scalability as you mentioned.

> With regards to the FIB notifier, why add the fib events to a work queue
> that is processed asynchronously if processing the work queue requires
> the rtnl lock? What is gained by deferring the work since a major side
> effect of the work queue is the loss of error propagation back to the
> user on the a failure. That is, if the FIB add/replace/append fails in
> the h/w for any reason, offload is silently aborted (an entry in the
> kernel log is still a silent abort).

FIB events are received in an atomic context and therefore must be
deferred to a workqueue. The chain was initially blocking, but this had
to change in commit d3f706f68e2f ("ipv4: fib: Convert FIB notification
chain to be atomic") to support dumping of IPv4 routes under RCU. IPv6
events are always sent in an atomic context.

Regarding the silent abort, that's intentional. You can look at the same
code in v4.9 - when the chain was still blocking - and you'll see that
we didn't propagate the error even then. This was discussed in the past
and the conclusion was that user doesn't expect to operation to fail. If
hardware resources are exceeded, we let the kernel take care of the
forwarding instead.
