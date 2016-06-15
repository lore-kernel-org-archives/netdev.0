From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Wed, 15 Jun 2016 14:47:16 -0400
Message-ID: <20160615184716.GM24102@mtj.duckdns.org>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com>
 <20160609213517.GA25288@breakpoint.cc>
 <5759EBF5.4010902@iogearbox.net>
 <5759FA28.3060900@iogearbox.net>
 <2ec75506-1ba0-5b16-4cd4-7b40cc969871@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	viro@zeniv.linux.org.uk
To: Daniel Wagner <daniel.wagner@bmw-carit.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:32790 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbcFOSrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 14:47:21 -0400
Content-Disposition: inline
In-Reply-To: <2ec75506-1ba0-5b16-4cd4-7b40cc969871@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Jun 10, 2016 at 08:40:34AM +0200, Daniel Wagner wrote:
> > [ Cc'ing John, Daniel, et al ]
> > 
> > Btw, while I just looked at scm_detach_fds(), I think commits ...
> > 
> >  * 48a87cc26c13 ("net: netprio: fd passed in SCM_RIGHTS datagram not set
> > correctly")
> >  * d84295067fc7 ("net: net_cls: fd passed in SCM_RIGHTS datagram not set
> > correctly")
> > 
> > ... might not be correct, maybe I'm missing something ...? Lets say
> > process A
> > has a socket fd that it sends via SCM_RIGHTS to process B. Process A was
> > the
> > one that called sk_alloc() originally. Now in scm_detach_fds() we
> > install a new
> > fd for process B pointing to the same sock (file's private_data) and
> > above commits
> > update the cached socket cgroup data for net_cls/net_prio to the new
> > process B.
> > So, if process A for example still sends data over that socket, skbs
> > will then
> > wrongly match on B's cgroup membership instead of A's, no?
> 
> I can't remember the details right now (need to read up again but I wont
> have time till Wednesday).
> 
> From your analysis I would say that is not the desired effect. A should
> match against its own cgroup and not the one of B.

We don't have a good answer for resources which are shared across
different cgroups.  It is often too expensive to track such sharing
accurately and crude approximation (creator-owned, last-used or
whatever) is used widely even outside cgroup.  Different cgroup
controllers tried different approaches but most are settling down for
creator ownership with exceptions for high impact cases.

I don't think there's a solution which satifies all cases here.  Given
that, doing the minimum amount of work (not worrying about SCM_RIGHTS
transfers) is the right thing to do, but we've had this re-labeling
since 2012, so leaving as-is is likely the best option at this point.

Thanks.

-- 
tejun
