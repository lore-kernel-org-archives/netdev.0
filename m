From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v2 2/6] cgroup: add support for eBPF programs
Date: Thu, 25 Aug 2016 00:30:47 +0200
Message-ID: <616bcf67-314a-c943-8177-7e04021e89bb@zonque.org>
References: <1472070263-29988-1-git-send-email-daniel@zonque.org>
 <1472070263-29988-3-git-send-email-daniel@zonque.org>
 <20160824215450.GA13455@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, pablo@netfilter.org, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me
To: Tejun Heo <htejun@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49491 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754502AbcHXW4f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 18:56:35 -0400
In-Reply-To: <20160824215450.GA13455@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tejun,

On 08/24/2016 11:54 PM, Tejun Heo wrote:
> On Wed, Aug 24, 2016 at 10:24:19PM +0200, Daniel Mack wrote:
>> +void cgroup_bpf_free(struct cgroup *cgrp)
>> +{
>> +	unsigned int type;
>> +
>> +	rcu_read_lock();
>> +
>> +	for (type = 0; type < __MAX_BPF_ATTACH_TYPE; type++) {
>> +		if (!cgrp->bpf.prog[type])
>> +			continue;
>> +
>> +		bpf_prog_put(cgrp->bpf.prog[type]);
>> +		static_branch_dec(&cgroup_bpf_enabled_key);
>> +	}
>> +
>> +	rcu_read_unlock();
> 
> These rcu locking seem suspicious to me.  RCU locking on writer side
> is usually bogus.  We sometimes do it to work around locking
> assertions in accessors but it's a better idea to make the assertions
> better in those cases - e.g. sth like assert_mylock_or_rcu_locked().

Right, in this case, it is unnecessary, as the bpf.prog[] is not under RCU.

>> +void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
>> +{
>> +	unsigned int type;
>> +
>> +	rcu_read_lock();
> 
> Ditto.
> 
>> +	for (type = 0; type < __MAX_BPF_ATTACH_TYPE; type++)
>> +		rcu_assign_pointer(cgrp->bpf.prog_effective[type],
>> +			rcu_dereference(parent->bpf.prog_effective[type]));

Okay, yes. We're under cgroup_mutex write-path protection here, so
that's unnecessary too.

>> +void __cgroup_bpf_update(struct cgroup *cgrp,
>> +			 struct cgroup *parent,
>> +			 struct bpf_prog *prog,
>> +			 enum bpf_attach_type type)
>> +{
>> +	struct bpf_prog *old_prog, *effective;
>> +	struct cgroup_subsys_state *pos;
>> +
>> +	rcu_read_lock();
> 
> Ditto.

Yes, agreed, as above.

>> +	old_prog = xchg(cgrp->bpf.prog + type, prog);
>> +	if (old_prog) {
>> +		bpf_prog_put(old_prog);
>> +		static_branch_dec(&cgroup_bpf_enabled_key);
>> +	}
>> +
>> +	if (prog)
>> +		static_branch_inc(&cgroup_bpf_enabled_key);
> 
> Minor but probably better to inc first and then dec so that you can
> avoid unnecessary enabled -> disabled -> enabled sequence.

Good point. Will fix.

>> +	rcu_read_unlock();
>> +
>> +	css_for_each_descendant_pre(pos, &cgrp->self) {
> 
> On the other hand, this walk actually requires rcu read locking unless
> you're holding cgroup_mutex.

I am - this function is always called with cgroup_mutex held through the
wrapper in kernel/cgroup.c.

Thanks a lot - will put all that changes in v3.


Daniel
