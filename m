From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 11:59:36 +0200
Message-ID: <20060918095936.GA6161@outpost.ds9a.nl>
References: <20060917101101.GA30461@outpost.ds9a.nl> <20060917205351.4f691c4e@localhost.localdomain> <20060917122153.GA2932@outpost.ds9a.nl> <20060918.015130.34760190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:18382 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1751646AbWIRJ7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 05:59:38 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060918.015130.34760190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2006 at 01:51:30AM -0700, David Miller wrote:
> We created TCP_CONG_ADVANCED for a purpose.  If you turn that
> thing on, you get full control but if something breaks you get
> to keep the pieces.

But we should not try to break stuff on purpose, no matter how advanced. It
makes zero sense. To reiterate, when compiling in multiple TCP policies, a
*random* one gets enabled. This is not something we want to offer even
advanced users. It is a kernel, not an adventure course.

Please consider this near-oneliner patch which makes stuff behave more like
people expect: loading a module, or compiling in a congestion avoidance
policy only makes it available, but does not turn it on by default. 

It also cleans up two notices a bit.

I've tested this patch and it does the job for me, reno is now the default,
even when more advanced options are compiled in, but the rest is still
available.

When in doubt, consider that I discovered this because my kernel was
crashing, and that this is bound to generate heaps of annoying email
otherwise. 

Thanks.

Signed-off-by: bert hubert <bert.hubert@netherlabs.nl>

--- linux-2.6.18-rc7/net/ipv4/tcp_cong.c.org	2006-09-18 11:42:25.000000000 +0200
+++ linux-2.6.18-rc7/net/ipv4/tcp_cong.c	2006-09-18 11:43:45.000000000 +0200
@@ -45,11 +45,11 @@
 
 	spin_lock(&tcp_cong_list_lock);
 	if (tcp_ca_find(ca->name)) {
-		printk(KERN_NOTICE "TCP %s already registered\n", ca->name);
+		printk(KERN_NOTICE "TCP congestion control '%s' already registered\n", ca->name);
 		ret = -EEXIST;
 	} else {
-		list_add_rcu(&ca->list, &tcp_cong_list);
-		printk(KERN_INFO "TCP %s registered\n", ca->name);
+		list_add_tail_rcu(&ca->list, &tcp_cong_list);
+		printk(KERN_INFO "TCP congestion control '%s' registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
 
-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
