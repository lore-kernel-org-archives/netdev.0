From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Mon, 19 Sep 2016 18:34:28 +0200
Message-ID: <1918ef04-f22f-dce3-4bb4-1275936111d0@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
 <20160916195728.GA14736@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160916195728.GA14736-I4sfFR6g6EicJoAdRrHjTrzMkBWIpU9tytq7g7fCXyjEk0E+pv7Png@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/16/2016 09:57 PM, Sargun Dhillon wrote:
> On Wed, Sep 14, 2016 at 01:13:16PM +0200, Daniel Mack wrote:

>> I have no idea what makes you think this is limited to systemd. As I
>> said, I provided an example for userspace that works from the command
>> line. The same limitation apply as for all other users of cgroups.
>>
> So, at least in my work, we have Mesos, but on nearly every machine that Mesos 
> runs, people also have systemd. Now, there's recently become a bit of a battle 
> of ownership of things like cgroups on these machines. We can usually solve it 
> by nesting under systemd cgroups, and thus so far we've avoided making too many 
> systemd-specific concessions.
> 
> The reason this works (mostly), is because everything we touch has a sense of 
> nesting, where we can apply policy at a place lower in the hierarchy, and yet 
> systemd's monitoring and policy still stays in place. 
> 
> Now, with this patch, we don't have that, but I think we can reasonably add some 
> flag like "no override" when applying policies, or alternatively something like 
> "no new privileges", to prevent children from applying policies that override 
> top-level policy.

Yes, but the API is already guarded by CAP_NET_ADMIN. Take that
capability away from your children, and they can't tamper with the
policy. Does that work for you?

> I realize there is a speed concern as well, but I think for 
> people who want nested policy, we're willing to make the tradeoff. The cost
> of traversing a few extra pointers still outweighs the overhead of network
> namespaces, iptables, etc.. for many of us. 

Not sure. Have you tried it?

> What do you think Daniel?

I think we should look at an implementation once we really need it, and
then revisit the performance impact. In any case, this can be changed
under the hood, without touching the userspace API (except for adding
flags if we need them).

>> Not necessarily. You can as well do it the inetd way, and pass the
>> socket to a process that is launched on demand, but do SO_ATTACH_FILTER
>> + SO_LOCK_FILTER  in the middle. What happens with payload on the socket
>> is not transparent to the launched binary at all. The proposed cgroup
>> eBPF solution implements a very similar behavior in that regard.
>
> It would be nice to be able to see whether or not a filter is attached to a 
> cgroup, but given this is going through syscalls, at least introspection
> is possible as opposed to something like netlink.

Sure, there are many ways. I implemented the bpf cgroup logic using an
own cgroup controller once, which made it possible to read out the
status. But as we agreed on attaching programs through the bpf(2) system
call, I moved back to the implementation that directly stores the
pointers in the cgroup.

First enabling the controller through the fs-backed cgroup interface,
then come back through the bpf(2) syscall and then go back to the fs
interface to read out status values is a bit weird.

>> And FWIW, I agree with Thomas - there is nothing wrong with having
>> multiple options to use for such use-cases.
>
> Right now, for containers, we have netfilter and network namespaces.
> There's a lot of performance overhead that comes with this.

Out of curiosity: Could you express that in numbers? And how exactly are
you testing?

> Not only
> that, but iptables doesn't really have a simple way of usage by
> automated infrastructure. We (firewalld, systemd, dockerd, mesos)
> end up fighting with one another for ownership over firewall rules.

Yes, that's a common problem.

> Although, I have problems with this approach, I think that it's
> a good baseline where we can have top level owned by systemd,
> docker underneath that, and Mesos underneath that. We can add
> additional hooks for things like Checmate and Landlock, and
> with a little more work, we can do compositition, solving
> all of our problems.

It is supposed to be just a baseline, yes.


Thanks for your feedback,
Daniel
