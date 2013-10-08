From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Tue, 08 Oct 2013 10:05:02 +0200
Message-ID: <5253BCAE.5060409@redhat.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <20131007164647.GA2481@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, cgroups@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131007164647.GA2481@htj.dyndns.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 10/07/2013 06:46 PM, Tejun Heo wrote:
> On Fri, Oct 04, 2013 at 08:20:55PM +0200, Daniel Borkmann wrote:
>> It would be useful e.g. in a server or desktop environment to have
>> a facility in the notion of fine-grained "per application" or "per
>> application group" firewall policies. Probably, users in the mobile/
>> embedded area (e.g. Android based) with different security policy
>> requirements for application groups could have great benefit from
>> that as well. For example, with a little bit of configuration effort,
>> an admin could whitelist well-known applications, and thus block
>> otherwise unwanted "hard-to-track" applications like [1] from a
>> user's machine.
>>
>> Implementation of PID-based matching would not be appropriate
>> as they frequently change, and child tracking would make that
>> even more complex and ugly. Cgroups would be a perfect candidate
>> for accomplishing that as they associate a set of tasks with a
>> set of parameters for one or more subsystems, in our case the
>> netfilter subsystem, which, of course, can be combined with other
>> cgroup subsystems into something more complex.
>>
>> As mentioned, to overcome this constraint, such processes could
>> be placed into one or multiple cgroups where different fine-grained
>> rules can be defined depending on the application scenario, while
>> e.g. everything else that is not part of that could be dropped (or
>> vice versa), thus making life harder for unwanted processes to
>> communicate to the outside world. So, we make use of cgroups here
>> to track jobs and limit their resources in terms of iptables
>> policies; in other words, limiting what they are allowed to
>> communicate.
>>
>> We have similar cgroup facilities in networking for traffic
>> classifier, and netprio cgroups. This feature adds a lightweight
>> cgroup id matching in terms of network security resp. network
>> traffic isolation as part of netfilter's xtables subsystem.
>
> I don't think the two net cgroups were a good idea and definitely
> don't want to continue the trend.  I think this is being done
> backwards.  Wouldn't it be more logical to implement netfilter rule to
> match the target cgroup paths?  It really doesn't make much sense to
> me to add separate controllers to just tag processes.  Please classify
> tasks in cgroup and let netfilter match the cgroups.

Thanks for your feedback!

Could you elaborate on "Wouldn't it be more logical to implement netfilter
rule to match the target cgroup paths?". I don't think (or hope) you mean
some string comparison on the dentry path here? :) With our proposal, we
have in the network stack's critical path only the following code that is
being executed here to match the cgroup ...

static bool
cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
{
	const struct xt_cgroup_info *info = par->matchinfo;

	if (skb->sk == NULL)
		return false;

	return (info->id == skb->sk->sk_cgrp_fwid) ^ info->invert;
}

... where ``info->id == skb->sk->sk_cgrp_fwid'' is the actual work, so very
lightweight, which is good for high loads (1Gbit/s, 10Gbit/s and beyond), of
course. Also, it would be intuitive for admins familiar with other subsystems
to just set up and use these cgroup ids in iptabels. I'm not yet quite sure
how your suggestion would look like, so you would need to setup some "dummy"
subgroups first just to have a path that you can match on?

Thanks,

Daniel
