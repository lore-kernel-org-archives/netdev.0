From: Jiri Bohac <jbohac@suse.cz>
Subject: ip6_rt_gc_elasticity and ip6_rt_gc_min_interval race in
 rt6_alloc_cow() ?
Date: Fri, 30 Nov 2012 19:43:36 +0100
Message-ID: <20121130184336.GB7113@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mkubecek@suse.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46861 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031365Ab2K3Snk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 13:43:40 -0500
Received: from relay1.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id BCEEEA5239
	for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 19:43:38 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I came across this code in rt6_alloc_cow():


	if (rt6_bind_neighbour(rt, rt->dst.dev)) {
		struct net *net = dev_net(rt->dst.dev);
		int saved_rt_min_interval =
			net->ipv6.sysctl.ip6_rt_gc_min_interval;
		int saved_rt_elasticity =
			net->ipv6.sysctl.ip6_rt_gc_elasticity;

		if (attempts-- > 0) {
			net->ipv6.sysctl.ip6_rt_gc_elasticity = 1;
			net->ipv6.sysctl.ip6_rt_gc_min_interval = 0;

			ip6_dst_gc(&net->ipv6.ip6_dst_ops);

			net->ipv6.sysctl.ip6_rt_gc_elasticity =
				saved_rt_elasticity;
			net->ipv6.sysctl.ip6_rt_gc_min_interval =
				saved_rt_min_interval;
			goto retry;
		}

		net_warn_ratelimited("Neighbour table overflow\n");
		dst_free(&rt->dst);
		return NULL;
	}

I believe there is a race condition in the setting of
ip6_rt_gc_elasticity and ip6_rt_gc_min_interval. I have not seen
happen, though:

1) a setting made by the user via sysctl while ip6_dst_gc() is
   running will get lost

2) another instance of rt6_alloc_cow() may save the temporary
   values in the saved_* variables, making those permanent.

Am I overlooking some synchronization or should I send a
patch to fix this?


Thanks,


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
