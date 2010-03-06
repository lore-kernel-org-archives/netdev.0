From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and devices
	(v5)
Date: Sat, 06 Mar 2010 17:21:40 -0500
Message-ID: <4B92D574.1090006@cs.columbia.edu>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>	<1267130595-23637-3-git-send-email-danms@us.ibm.com>	<4B91D1A3.9030404@cs.columbia.edu>
	<87bpf1idic.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bpf1idic.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



Dan Smith wrote:
> OL> What about leak detection ?
> OL> Aren't we missing {netns,netdev}_users()?
> 
> This is something I need to give more thought to, but it's not as easy
> as it sounds.  Network devices aren't released at the last put() like
> a lot of other things, and my initial attempts to reconcile the
> refcount after a checkpoint operation have not been successful.
> 
> However, I'm not sure that it's as important here, because AFAIK, a
> network device can only exist in one network namespace at a time.  If
> we're checkpointing a netdev, it's because we are checkpointing the
> namespace that it lives in.  Making sure the netns isn't leaked out of
> the process tree would be much easier and just as effective, no?

We should guarantee that neither netns nor netdev leaks outside
the container; currently none is. If a netdev can only belong to
a single netns, then it suffices to only care about netns.

> 
>>> +config CHECKPOINT_NETNS
>>> +       bool
>>> +       default y if NET && NET_NS && CHECKPOINT
>>> +
> 
> OL> Did you mean this to be visible (settable) by the user ?
> 
> No, it was specifically supposed to enable itself when those other
> items are enabled, but not be a user adjustable toggle.  I had a
> discussion with Serge about it and we came to this as a solution,
> although I don't remember what the problem we started with was.  I'll
> dig through my IRC logs to see if I can figure it out.

Duh.. my bad, I misinterpreted the code. That's fine.

BTW, there is a similar SYSVIPC_CHECKPOINT - we should decide
if we do X_CHECKPOINT or CHECKPOINT_X for a subsystem X, and
stick to that convention. I prefer the latter - what you did...

> 
>>> + retry:
>>> +	if (++pages > 4) {
>>> +		addrs = -E2BIG;
>>> +		goto out;
>>> +	}
> 
> OL> Why 4 ?
> 
> It's just a sanity limit.

Hmm... let me be more explicit:  why not keep trying until it
realloc fails ?  or switch to vmalloc() at some point ?

> 
> OL> Do we really need this special case ?  I'd be happy with a ckpt_err()
> OL> for any error - and the actual error number would be useful to tell
> OL> which case it was.
> 
> Unless I'm missing something, you asked for this specifically:
> 
> https://lists.linux-foundation.org/pipermail/containers/2010-February/022844.html

Lol .. that was me :o  But looking at the code it feels wrong,
because the errno already reveals the type of the problem.

I'm thinking - wouldn't it make sense to do error reporting
in checkpoint_netdev() if the call to ->ndo_checkpoint() fails ?

> 
> OL> Isn't this check redundant ?  I expect it to fail promptly in
> OL> checkpoint_netdev() above.
> 
> No, as I've said a couple of times previously, this isn't the only way
> we can arrive at a netdev for checkpointing.  This case is the one
> where we're marching through the netns and find a netdev that is not
> supported.  The other is where we arrive at a device as a peer of
> another device, so the other check may come into play at times where
> this one doesn't and vice versa.

I'm confused: in checkpoint_ns() inside the for_each_netdev()
loop you first test for dev->netdev_ops->ndo_checkpoint and
then call checkpoint_obj(... CKPT_OBJ_NETDEV) - which in turn
will call checkpoint_netdev(), which will again test for
dev->netdev_ops->ndo_checkpoint ...  am I reading it wrongly ?

> 
> OL> This may be a bit simpler if you move the first deferqueue_add()
> OL> forward to just before the other one. Or better: change dq_netdev
> OL> to have two pointers, dev and peer (if any is null, the cleanup
> OL> function will skip).
> 
> The reason it is this messy is because of the way network devices are
> deallocated.  Since they don't destroy themselves on the final put(),
> we have to explicitly call unregister_netdev() on them when we know
> they're no longer used (else we block).  Once we've added them to the
> deferqueue, we can no longer destroy them here because a reference is
> held and the deferqueue will run afterwards.
> 
> The ordering of this is a result of me injecting failures at each step
> and working it out until I got it to not block on unregistering either
> of the devices in all of the error paths.  That's not to say it's the
> best way, but there is a reason it's ordered the way it is.
> 

How about this - to me it feels simpler:

	dev = rtnl_newlink(veth_new_link_msg, &veth, this_name);
	if (IS_ERR(dev))
		return dev;

	peer = dev_get_by_name(current->nsproxy->net_ns, peer_name);
	if (!peer) {
		ret = -EINVAL;
		goto err_dev;
	}
	ret = ckpt_obj_insert(ctx, peer, h->veth.peer_ref,
			      CKPT_OBJ_NETDEV);
	if (ret < 0)
		goto err_peer;

	dev_put(peer);

	dq.dev = dev;
	dq.peer = peer;
	ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
			     netdev_noop, netdev_cleanup);
	if (ret)
		goto err_peer;

(yes, you need to adjust struct dq_netdev and netdev_cleanup).

BTW, the variable "didreg" should disappear from restore_veth().

Oren.
