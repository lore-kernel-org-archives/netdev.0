From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Check net->nfnl for NULL in ctnetlink_conntrack_event
 to, avoid Oops on container destroy
Date: Mon, 12 Sep 2011 23:40:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109122256450.1592@ja.ssi.bg>
References: <4E6E4961.9070802@canonical.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56339 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752699Ab1ILUkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Sep 2011 16:40:40 -0400
In-Reply-To: <4E6E4961.9070802@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 12 Sep 2011, Tim Gardner wrote:

> Patrick,
> 
> I received this patch from a developer that uses lxc and network name spaces.
> I don't know the locking semantics well enough for CT to judge whether this
> fix is sufficient. Bug info can be found at
> http://bugs.launchpad.net/bugs/843892 . See comment #7 for his analysis.

	We found same problems triggered by IPVS during
subsys cleanup:

http://marc.info/?l=netfilter-devel&m=130765388528399&w=2

	It is a general problem for modules that register
callbacks to the netfilter core. nfnetlink is such example
with a mix of global (ctnl_notifier) and per-net (nfnetlink_net_ops) 
registrations. During net cleanup the module must be prepared
to be called by core because the core cleanup happens later.

	So, may be rcu_dereference under rcu lock is needed for
some functions (nfnetlink_has_listeners, nfnetlink_send) but
such changes should be audited by nfnetlink developers.
Using rcu_assign_pointer for net->nfnl without corresponding 
rcu_dereference looks like a problem.

Regards

--
Julian Anastasov <ja@ssi.bg>
