From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and devices
 (v5)
Date: Mon, 08 Mar 2010 13:36:52 -0500
Message-ID: <4B9543C4.4000508@cs.columbia.edu>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>	<1267130595-23637-3-git-send-email-danms@us.ibm.com>	<4B91D1A3.9030404@cs.columbia.edu>	<87bpf1idic.fsf@caffeine.danplanet.com>	<4B92D574.1090006@cs.columbia.edu> <871vfuiul6.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, den@openvz.org, netdev@vger.kernel.org,
	davem@davemloft.net, ebiederm@xmission.com, benjamin.thery@bull.net
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brinza.cc.columbia.edu ([128.59.29.8]:52505 "EHLO
	brinza.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729Ab0CHSga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 13:36:30 -0500
In-Reply-To: <871vfuiul6.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> I'm confused: in checkpoint_ns() inside the for_each_netdev() loop
> OL> you first test for dev->netdev_ops->ndo_checkpoint and then call
> OL> checkpoint_obj(... CKPT_OBJ_NETDEV) - which in turn will call
> OL> checkpoint_netdev(), which will again test for
> dev-> netdev_ops->ndo_checkpoint ...  am I reading it wrongly ?
> 
> In the case of veth, yes.  It goes something like this:
> 
> checkpoint_netns() {
>   foreach netdev in netns {
>     checkpoint_netdev {
>       if netdev is veth {
>         checkpoint_peer(); // Will call checkpoint_netdev again
>       }
>     }
>   }
> }
> 
> It shouldn't happen, but it seems like since we could potentially add
> another checkpoint_obj(mydev) somewhere other than in
> checkpoint_netdev(), it is reasonable to check that there is actually
> something to call before we call it.
> 
> Would you prefer a BUG()?

Ok.. so this is solved over IRC - the test was redundant :)

> 
> OL> How about this - to me it feels simpler:
> 
> OL> 	dev = rtnl_newlink(veth_new_link_msg, &veth, this_name);
> OL> 	if (IS_ERR(dev))
> OL> 		return dev;
> 
> OL> 	peer = dev_get_by_name(current->nsproxy->net_ns, peer_name);
> OL> 	if (!peer) {
> OL> 		ret = -EINVAL;
> OL> 		goto err_dev;
> OL> 	}
> OL> 	ret = ckpt_obj_insert(ctx, peer, h->veth.peer_ref,
> OL> 			      CKPT_OBJ_NETDEV);
> OL> 	if (ret < 0)
> OL> 		goto err_peer;
> 
> OL> 	dev_put(peer);
> 
> OL> 	dq.dev = dev;
> OL> 	dq.peer = peer;
> OL> 	ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
> OL> 			     netdev_noop, netdev_cleanup);
> OL> 	if (ret)
> OL> 		goto err_peer;
> 
> If you fail here you need to unregister_netdev() because the dev_put()
> that the objhash will not cause it to happen.  Unless we add something
> to allow you to remove your object from the hash, you can't prevent
> that final put, so you have to have it in the deferqueue for
> later.  You can't check the refcount in the objhash function because it
> will differ depending on the number of addresses and protocols the
> device has, and those don't get released until unregister_netdev()
> which will block if you call it before you've released all of your
> references.  If the objhash put function could examine ctx->errno,
> then it could drop its reference and then call unregister_netdev(),
> but that would involve changing all the drop functions.  What am I
> missing?
> 

Oh ..  I see - I missed that point that a ref is taken once it's
inserted to the objhash, so insert must be preceeded by the call
to deferqueue. Thanks for the explanation.

It still makes sense to have a single call to deferqueue that
relates to both the veth and the peer, instead of two separate
calls, no ?

Oren.
