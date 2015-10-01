From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Thu, 1 Oct 2015 11:04:32 +0200
Message-ID: <560CF720.9060301@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc> <560B8E25.7050801@zonque.org>
 <20150930214852.GA8443@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: pablo@netfilter.org, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	balazs.scheidler@balabit.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49383 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933027AbbJAJEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 05:04:35 -0400
In-Reply-To: <20150930214852.GA8443@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 09/30/2015 11:48 PM, Florian Westphal wrote:
> Daniel Mack <daniel@zonque.org> wrote:
>> Of course you can drop certain packets at this point, depending on other
>> details. Say, for instance, you want to match all packets that are
>> received by a certain task and that are originated from IP addresses of
>> a specific subnet, and drop the rest. Rather than adding matches to your
>> global firewall configuration for all the ports that tasks may or may
>> not listen on, you can just do it on a higher level, from the
>> perspective of an administrator. If you decide to let your web server
>> listen on another port as well, no firewall rule configuration change is
>> needed at all.
> 
> We don't have per application configurations, not even with these
> patches...?
> The configuration is still global/per netns?

The configuration is per net_cls ID, and with a cgroup manager that
assigns unique IDs to each application/service/task, this effectively
becomes a per-application setting (or anything else for that matter, see
below).

> Application level firewall makes me think of proxies.
> What exactly are we talking about?
> Can you provide examples?

Ok, so the term is misleading, I agree. I am talking about a possibility
for userspace to install netfilter rules that match packets sent to or
sent by a task, or a set of tasks (you may call that an application or
service).

So for example, I want a way to redirect netfilter decisions that are
about tasks in net_cls cgroup 23 to a dedicated chain, so the admin can
configure rules that only apply to a certain service or application.

>> I really don't know if this approach is intrusive enough to make it
>> qualify as sledgehammer. I'd like to see some real-world benchmarks and
>> have proof there is a performance decrease for setups that don't use
>> such chains.
> 
> We have static keys for nf hooks so there is no performance decrease if
> no netfilter hooks are active.
> 
> HOWEVER, this discussion seems to hint at the opposite, namely that this
> will turn into a mandatory or at least auto-enabled feature.
>
> But regardless, I called it a sledgehammer not because of performance
> concerns but because just to get this proposed socket matching facility we
> now have to put hooks into all protocol handlers and commit to keeping them
> there forever.

Sure, but why is that a problem exactly? I still don't understand your
technical concerns.

> Also, some time ago Eric suggested to allow binding to tcp ports
> from packet sockets to implement userspace-driven TCP stacks (i.e.
> kernel would just queue raw frames for the given quadruple withput
> caring about ordering etc).
>
> If we allow this proposed change, we'd also have to extend that
> with these hooks.

In that case, the receiver socket would be the one of that
userspace-driven TCP stack, and the same rules apply. The feature might
not make much sense in such setups though, but that's not an issue.

> Next time someone mentions that we don't have application matching
> but only sk/cgroup tests. Are we then going to consider doing task lookups?

cgroups are the most comprehensive notion the kernel has about a group
of tasks, which may be called a service or an application. By allowing
users to make netfilter rules specific to a setting in a cgroup
controller, we open the doors for supporting a lot of interesting use
cases. Which tasks to put into a cgroup with a certain net_cls setting
is up to userspace, but it would be possible to group everything the OS
considers an 'application'.

>> Why so? For deterministic ingress filtering of traffic directed to a
>> local socket, you can as well rely on information associated with that
>> socket. And this is what application-level firewall rule sets are all about.
> 
> Application not running -> different behaviour.  I'm sure thats obvious
> to you, but I'm not sure if its obvious to users that their
> 'match on net clsid 42' won't work anymore when that service isn't running.

That's a matter of explaining that fact in the documentation, I'd say :)

In a sense, what happens is comparable to rules that are specific to an
ingress interface. Depending on whether that interface is up or down,
these netfilter rules are iterated or they aren't, right?

Anyway, note that socket uid/gid and cgroup matches already exist for
ingress today, so the exact same change in behavior that you describe is
in place since a number of releases. It's just that right now, what the
kernel does is to only match packets that had early demux treatment,
which makes it largely unusable for users. So, what this patch set aims
for is to make an existing feature actually usable.

I'm open to other approaches, as long as it allows us to install
netfilter rules that match against net_cls IDs. The demux target would
probably be another option, but I'm not convinced yet that would be any
better from a technical perspective.

Pablo, what do you think?



Thanks,
Daniel
