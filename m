From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/5] Fix deadlock in bonding driver resulting from
 internal locking when using netpoll
Date: Wed, 13 Oct 2010 06:51:25 -0400
Message-ID: <20101013105125.GA31379@hmsreliant.think-freely.org>
References: <1286920552-2173-1-git-send-email-nhorman@tuxdriver.com>
 <1286920552-2173-3-git-send-email-nhorman@tuxdriver.com>
 <4CB51D27.8030703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40864 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab0JMKve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 06:51:34 -0400
Content-Disposition: inline
In-Reply-To: <4CB51D27.8030703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 13, 2010 at 10:44:55AM +0800, Cong Wang wrote:
> On 10/13/10 05:55, nhorman@tuxdriver.com wrote:
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -76,6 +76,7 @@
> >  #include<linux/if_vlan.h>
> >  #include<linux/if_bonding.h>
> >  #include<linux/jiffies.h>
> >+#include<linux/preempt.h>
> >  #include<net/route.h>
> >  #include<net/net_namespace.h>
> >  #include<net/netns/generic.h>
> >@@ -169,6 +170,35 @@ MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link
> >
> >  /*----------------------------- Global variables ----------------------------*/
> >
> >+#ifdef CONFIG_NET_POLL_CONTROLLER
> >+static cpumask_var_t netpoll_block_tx;
> >+
> >+static inline void block_netpoll_tx(void
> >+{
> >+	preempt_disable();
> >+	BUG_ON(cpumask_test_and_set_cpu(smp_processor_id(),
> >+					netpoll_block_tx));
> >+}
> >+
> >+static inline void unblock_netpoll_tx(void)
> >+{
> >+	BUG_ON(!cpumask_test_and_clear_cpu(smp_processor_id(),
> >+					  netpoll_block_tx));
> >+	preempt_enable();
> >+}
> >+
> >+static inline int is_netpoll_tx_blocked(struct net_device *dev)
> >+{
> >+	if (unlikely(dev->priv_flags&  IFF_IN_NETPOLL))
> >+		return cpumask_test_cpu(smp_processor_id(), netpoll_block_tx);
> >+	return 0;
> >+}
> >+#else
> >+#define block_netpoll_tx()
> >+#define unblock_netpoll_tx()
> >+#define is_netpoll_tx_blocked(dev)
> >+#endif
> >+
> 
> These should go to netpoll.h, IMHO.
> 

Doh, you're right, they should.  Particularly because I just noticed there are
a few paths through sysfs for bonding that can recurse the same way the
monitoring code can.  I'll respin this shortly, thanks.
Neil

