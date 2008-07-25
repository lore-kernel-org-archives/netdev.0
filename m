From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Fri, 25 Jul 2008 11:29:54 +0200
Message-ID: <20080725092954.GE20815@postel.suug.ch>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com> <20080724234553.GC20815@postel.suug.ch> <6599ad830807241818k5cb288e2l3e62a01c2f102913@mail.gmail.com> <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com> <20080724234553.GC20815@postel.suug.ch> <166fe7950807241816y6bbcc17evc934524a4511f4ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, kaber@trash.net
To: Ranjit Manomohan <ranjitm@google.com>,
	Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43986 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474AbYGYJ3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 05:29:36 -0400
Content-Disposition: inline
In-Reply-To: <6599ad830807241818k5cb288e2l3e62a01c2f102913@mail.gmail.com> <166fe7950807241816y6bbcc17evc934524a4511f4ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-07-24 18:16
> I will send a follow up patch that handles ingress as well which
> should be a fairly simple addition to the current scheme.

It is not that simple, neither dst nor socket has been looked up
where netfilter gives the possibility to build a queue using ifb.
I chose to shape just before the skb is put on the socket queue
but that also required some tricks and has to be done for every
protocol separately.

> IMO it may
> be preferable not to tie the implementation to any specific dependency
> in user space leaving it maximum flexibility. Our cluster management
> component sets up these rules depending upon the configuration and we
> have this scheme working in our clusters for quite some time with no
> issues.

I never even mentioned a dependency on anything. Whether such a daemon
is being run or not is up to the user. It is absolutely irrelevant what
your cluster management component does unless you open up the code.

> In my view it is a trade off to allow more flexibility in the
> configuration. I would think someone configuring the current tc setup
> in Linux is already pretty knowledgeable about its working and can do
> this extra step without much difficulty.

The one does not exclude the other but even with good documentation,
configuring or adapting tc configurations is a heavy task for many
users and will prevent many from using this feature. Having a daemon
create and modify a tc tree does not hinder the experienced user from
making custom modifications.

> That said I will look for your alternative implementation to compare
> the benefits.

Thanks, I will post my patches as soon as the next feature window opens.

* Paul Menage <menage@google.com> 2008-07-24 21:18
> You mean as processes fork/exit or move between cgroups you have to
> update the pid->class mappings in the kernel's filter? That sounds way
> too fragile to me.

No, not at all. The classifier registers as cgroup subsystem and updates
the mappings automatically if the pid has been added by the user.

> What types of events? We discussed how to send cgroup notifications to
> userspace in the containers mini-summit on Tuesday. Netlink was one of
> the options discussed, but suffers from the problem that netlink
> sockets are tied to a particular network namespaces. The solution that
> seemed most favoured was to have pollable cgroup control files that
> represent events (and optionally support event data via a fifo).

Currently I broadcast on all namespaces by iterating over them but I may
remove them again altogether. I only use the notifications to decide
wehther a cgroup has at least one task at the moment.

> The user can use whatever middleware they want (e.g. your daemon,
> libcg, etc) to set up qdiscs and classes. I don't think that requiring
> any particular userspace implementation is the right way to go. The
> point of this patch was to provide a minimal way to tag
> sockets/packets as belonging to a particular cgroup, in order to make
> use of the existing traffic controll APIs.

This patch certainly does have value. Since it won't be a problem for
people to use one over another I see no problem it multiple solutions
to coexist.
