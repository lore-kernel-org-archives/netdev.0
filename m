From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/4] net: Dynamically allocate the per cpu counters for the loopback device.
Date: Thu, 27 Sep 2007 14:44:37 -0600
Message-ID: <m1ps03hm8a.fsf@ebiederm.dsl.xmission.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<20070926.220901.51682476.davem@davemloft.net>
	<m1myv8r1lb.fsf@ebiederm.dsl.xmission.com>
	<20070927.115200.56183114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:37743 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757594AbXI0UpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 16:45:00 -0400
In-Reply-To: <20070927.115200.56183114.davem@davemloft.net> (David Miller's
	message of "Thu, 27 Sep 2007 11:52:00 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 27 Sep 2007 01:48:00 -0600
>
>> I'm not doing get_cpu/put_cpu so does the comment make sense
>> in relationship to per_cpu_ptr?
>
> It is possible.  But someone would need to go check for
> sure.

Verified.

hard_start_xmit is called inside of a
rcu_read_lock_bh(),rcu_read_unlock_bh() pair.  Which means
the code will only run on one cpu.

Therefore we do not need get_cpu/put_cpu.

In addition per_cpu_ptr is valid.  As it is just a lookup
into a NR_CPUS sized array by smp_processor_id() to return
the address of the specific cpu.

The only difference between per_cpu_ptr and __get_cpu_var()
are the implementation details between statically allocated
and dynamically allocated per cpu state.

So the comment is still valid, and still interesting it just
should say per_cpu_ptr instead of __get_cpu_var.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 0f9d8c6..756e267 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -154,7 +154,7 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	dev->last_rx = jiffies;
 
-	/* it's OK to use __get_cpu_var() because BHs are off */
+	/* it's OK to use per_cpu_ptr() because BHs are off */
 	pcpu_lstats = netdev_priv(dev);
 	lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
 	lb_stats->bytes += skb->len;



