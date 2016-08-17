From: Daniel Mack <daniel@zonque.org>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 16:35:24 +0200
Message-ID: <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-4-git-send-email-daniel@zonque.org>
 <20160817142047.GB4021@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
	kafai@fb.com, fw@strlen.de, pablo@netfilter.org, harald@redhat.com,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47432 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556AbcHQOf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 10:35:27 -0400
In-Reply-To: <20160817142047.GB4021@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tejun,

On 08/17/2016 04:20 PM, Tejun Heo wrote:
> On Wed, Aug 17, 2016 at 04:00:46PM +0200, Daniel Mack wrote:
>> The current implementation walks the tree from the passed cgroup up
>> to the root. If there is any program of the given type installed in
>> any of the ancestors, the installation is rejected. This is because
>> programs subject to restrictions should have no way of escaping if
>> a higher-level cgroup has installed a program already. This restriction
>> can be revisited at some later point in time.
> 
> This seems a bit too restrictive to me.  Given that an entity which
> can install a bpf program can remove any programs anyway, wouldn't it
> make more sense to just execute the program on the closest ancestor to
> the cgroup?  That'd allow selectively overriding programs for specific
> subhierarchies while applying generic policies to the rest.

The idea is not to walk the cgroup tree for each packet, to avoid costs.
Which also means we don't have to be overly restrictive, yes.

>> +static int bpf_prog_attach(const union bpf_attr *attr)
>> +{
> ...
>> +		/* Reject installation of a program if any ancestor has one. */
>> +		for (pos = cgrp->self.parent; pos; pos = pos->parent) {
>> +			struct cgroup *parent;
>> +
>> +			css_get(pos);
> 
> This refcnting pattern doesn't make sense.  If @pos is already
> accessible (which it is in this case), getting an extra ref before
> accessing it doesn't do anything.  This would necessary iff the
> pointer is to be used outside the scope which is protected by the ref
> on @cgrp.

Right, that was a left-over from an older series. Will drop.

>> +			parent = container_of(pos, struct cgroup, self);
>> +
>> +			if ((is_ingress  && parent->bpf_ingress) ||
>> +			    (!is_ingress && parent->bpf_egress))
>> +				err = -EEXIST;
>> +
>> +			css_put(pos);
>> +		}
>> +
>> +		if (err < 0) {
>> +			bpf_prog_put(prog);
>> +			return err;
>> +		}
>> +
>> +		progp = is_ingress ? &cgrp->bpf_ingress : &cgrp->bpf_egress;
>> +
>> +		rcu_read_lock();
>> +		old_prog = rcu_dereference(*progp);
>> +		rcu_assign_pointer(*progp, prog);
> 
> Wouldn't it make sense to update the descendants to point to the
> programs directly so that there's no need to traverse the tree on each
> packet?  It's more state to maintain but I think it would make total
> sense given that it would reduce per-packet cost.

The idea is to only look at the actual v2 cgroup a task is in, and not
traverse in any way, to keep the per-packet cost at a minimum. That of
course means that in a deeper level of the hierarchy, the programs are
no longer executed and need to be reinstalled after a new cgroup is
created. To bring this more in line with how cgroups usually work, I
guess we should add code to copy over the bpf programs from the ancestor
once a new cgroup is instantiated.


Thanks,
Daniel
