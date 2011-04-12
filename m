From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Race condition when creating multiple namespaces?
Date: Mon, 11 Apr 2011 17:27:35 -0700
Message-ID: <m1ei58co08.fsf@fess.ebiederm.org>
References: <201104112301.46776.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@free.fr>
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35284 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756467Ab1DLA1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 20:27:48 -0400
In-Reply-To: <201104112301.46776.hans@schillstrom.com> (Hans Schillstrom's
	message of "Mon, 11 Apr 2011 23:01:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans@schillstrom.com> writes:

> Hello
> I'v been strugling with this for some time now
>
> When creating multiple namespaces using lxc-start,  un-initialized network namespace parts will be called by the new process in the namespace.
> ex. when using conntrack or ipvsadm to quickly,  (a sleep 2 "solves" the problem).
> (From what I can see syscall clone() is used in lx-start  i.e. do_fork will be called later on.)
> Actually I was debugging ip_vs when closing multiple ns  when I fell into this one.
>
> I have a loop that create 33 containers whith lxc-start ... -- test.sh
> the first thing the new conatiner does in test.sh is
> #!/bin/bash
> iptables -t mangle -A PREROUTING -m conntrack --ctstate RELATED,ESTABLISHED -j CONNMARK --restore-mark
> nc -l -p1234
>
> This results in NULL ptr in ip_conntrack_net_init(struct *net)

Ouch!

> and in anoither test test.sh looks like this
> #!/bin/bash
> ipvsadm --start-daemon=master --mcast-interface=lo
> nc -l -p1234
>
> And this results in an uniitialized spinlock in ip_vs_sync
>
> I put a printk in nsproxy: copy_namespaces() and could see a dozens of them
> before anything appears from ipvs or conntrack.
>
> My feeling is that when you start up user processes in a new name space, 
> all kernel related init should have been done (you should not need to add a sleep to get it working)
>
> All test  made by using todays net-next-2.6 (2.6.39-rc1)
>
> Note:
> That neither conntrack or ip_vs modules where loaded,
> if modules where loaded before creating new namespaces it all works...
>
> Finally the question,
> Should it really work to load modules within a namespace , 
> that is a part of netns ?

>From an implementation point of view kernel modules are not in a
namespace, so there should be no difference between being in a namespace
and loading a kernel networking module and not being in a namespace and
loading in a kernel module.

It does sound like you have hit a module loading race, and perhaps
a race that is confined to network namespaces.

My head is in another problem so I won't be able to look at this for
a bit.  But if you are getting into ip_conntrack_net_init with
a NULL network namespace something spectacularly bad is happening.

In particular it looks like you must be hitting a bug in for_each_net.
Which would pretty much have to be a race in adding or removing from
net_namespace_list.

I took a quick skim through the code and whenever we modify the
net_namespace we hold but the net_mutex and inside it the rtnl_lock so I
don't immediate see how you could be getting a NULL net into
ip_conntrack_net_init.

Is there a codepath besides register_pernet_subsys that is calling
ip_conntrack_net_init?

Do you have any local modifications that could be messing up register_pernet_subsys?

Eric
