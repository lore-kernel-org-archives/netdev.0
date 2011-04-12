From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: Race condition when creating multiple namespaces?
Date: Tue, 12 Apr 2011 06:56:53 +0200
Message-ID: <201104120656.54281.hans@schillstrom.com>
References: <201104112301.46776.hans@schillstrom.com> <m1ei58co08.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@free.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:35280 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab1DLE45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 00:56:57 -0400
In-Reply-To: <m1ei58co08.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday, April 12, 2011 02:27:35 Eric W. Biederman wrote:
> Hans Schillstrom <hans@schillstrom.com> writes:
> 
> > Hello
> > I'v been strugling with this for some time now
> >
> > When creating multiple namespaces using lxc-start,  un-initialized network namespace parts will be called by the new process in the namespace.
> > ex. when using conntrack or ipvsadm to quickly,  (a sleep 2 "solves" the problem).
> > (From what I can see syscall clone() is used in lx-start  i.e. do_fork will be called later on.)
> > Actually I was debugging ip_vs when closing multiple ns  when I fell into this one.
> >
> > I have a loop that create 33 containers whith lxc-start ... -- test.sh
> > the first thing the new conatiner does in test.sh is
> > #!/bin/bash
> > iptables -t mangle -A PREROUTING -m conntrack --ctstate RELATED,ESTABLISHED -j CONNMARK --restore-mark
> > nc -l -p1234
> >
> > This results in NULL ptr in ip_conntrack_net_init(struct *net)
> 
> Ouch!
> 
> > and in anoither test test.sh looks like this
> > #!/bin/bash
> > ipvsadm --start-daemon=master --mcast-interface=lo
> > nc -l -p1234
> >
> > And this results in an uniitialized spinlock in ip_vs_sync
> >
> > I put a printk in nsproxy: copy_namespaces() and could see a dozens of them
> > before anything appears from ipvs or conntrack.
> >
> > My feeling is that when you start up user processes in a new name space, 
> > all kernel related init should have been done (you should not need to add a sleep to get it working)
> >
> > All test  made by using todays net-next-2.6 (2.6.39-rc1)
> >
> > Note:
> > That neither conntrack or ip_vs modules where loaded,
> > if modules where loaded before creating new namespaces it all works...
> >
> > Finally the question,
> > Should it really work to load modules within a namespace , 
> > that is a part of netns ?
> 
> >From an implementation point of view kernel modules are not in a
> namespace, so there should be no difference between being in a namespace
> and loading a kernel networking module and not being in a namespace and
> loading in a kernel module.
> 
> It does sound like you have hit a module loading race, and perhaps
> a race that is confined to network namespaces.
> 
> My head is in another problem so I won't be able to look at this for
> a bit.  But if you are getting into ip_conntrack_net_init with
> a NULL network namespace something spectacularly bad is happening.

OK I'll continue to dig into this.

> 
> In particular it looks like you must be hitting a bug in for_each_net.
> Which would pretty much have to be a race in adding or removing from
> net_namespace_list.

It was further down in proc_net_fops_create()

> 
> I took a quick skim through the code and whenever we modify the
> net_namespace we hold but the net_mutex and inside it the rtnl_lock so I
> don't immediate see how you could be getting a NULL net into
> ip_conntrack_net_init.

I do had the same problem in ip_vs  a couple of times, but at that time I thought it was my changes...
In the ip_vs case it seems to be more like a race or a missing lock one core reach a "not fully" initialized ipvs struct.
That could be my fault like bad order when calling register_pernet_subsys...

> 
> Is there a codepath besides register_pernet_subsys that is calling
> ip_conntrack_net_init?

Not what I can see...
> 
> Do you have any local modifications that could be messing up register_pernet_subsys?

Not right now (I took them away, a clean git clone)

> 
> Eric
> 

I will continue with this today 

Thanks a lot
Hans
