From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/5] Add checkpoint support for veth devices (v2)
Date: Mon, 22 Feb 2010 14:57:38 -0600
Message-ID: <20100222205738.GA18038@us.ibm.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
 <1266336187-19105-4-git-send-email-danms@us.ibm.com>
 <20100222195647.GB13135@us.ibm.com>
 <87sk8t6msb.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47068 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab0BVU5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 15:57:54 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1MKnDJS008111
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:49:13 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1MKveh0118376
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:57:45 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1MKvdG2001173
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:57:40 -0700
Content-Disposition: inline
In-Reply-To: <87sk8t6msb.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> >> +	else if (!ckpt_obj_lookup(ctx, peer->nd_net, CKPT_OBJ_NET_NS)) {
> >> +		ret = -EINVAL;
> >> +		ckpt_err(ctx, ret,
> >> +			 "Peer %s of %s not in checkpointed namespaces\n",
> >> +			 peer->name, dev->name);
> 
> SH> I'm not sure this check does what you think it does: note that
> SH> ckpt_netdev_base(), defined in the previous patch, and called
> SH> higher up in this function, is going to checkpoint peer->nd_net.
> SH> :)
> 
> Actually, no, ckpt_netdev_base() can't checkpoint peer->nd_net because
> it's device-agnostic and has no knowledge of dev->peer.

Oh, ok.

> The idea here was that we checkpoint a netns when we arrive at it via
> nsproxy.  Doing that, we checkpoint the devices within.  We encounter
> a veth device, which has a peer, so we decide if:
> 
>  1. We won't arrive at the peer later because it is in the init
>     namespace, so we checkpoint it now.
>  2. We will arrive at it later because the peer's netns is in the list
>     we've already collected, so checkpoint the peer with its namespace
>  3. Neither are true and we won't arrive at it later and therefore we
>     can't allow checkpoint to continue
> 
> #2 depends on the collect process having put all the task's netns' in
>  the hash ahead of time.

Right, that was what I was originally starting to hunt down when I
thought I saw ckpt_netdev_base() checkpointing peer's netns.

So do you actually know that the peer's netns will have been
checkpointed?  I'm a little fuzzy about where netns and netdevs
are checkpointed.  If you have two private netns's in a container,
with a veth connecting them, and you checkpoint a task in netns 1,
will you fail bc netns 2 hasn't been checkpointed yet bc no task in
it has been checkpointed yet?

-serge
