From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: kmemleak complaints in ip6mr.c
Date: Wed, 30 Jan 2013 08:22:15 +0000 (UTC)
Message-ID: <keal7n$mi4$1@ger.gmane.org>
References: <20130129185127.GA31811@raven>
 <20130129.135906.1332264867631483230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:47672 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754092Ab3A3IWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 03:22:37 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U0SwR-0003mY-9T
	for netdev@vger.kernel.org; Wed, 30 Jan 2013 09:22:47 +0100
Received: from 60.160.70.124 ([60.160.70.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 09:22:47 +0100
Received: from xiyou.wangcong by 60.160.70.124 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 09:22:47 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jan 2013 at 18:59 GMT, David Miller <davem@davemloft.net> wrote:
> From: Tom Parkin <tparkin@katalix.com>
> Date: Tue, 29 Jan 2013 18:51:27 +0000
>
>> I've discovered what may be a memory leak in ip6mr when using network
>> namespaces.  Here's the kmemleak backtrace:
>> 
>> 
>> unreferenced object 0xf0d4a180 (size 96):
>>   comm "ip", pid 6735, jiffies 4294949643 (age 73.268s)
>>   hex dump (first 32 bytes):
>>     68 a1 d4 f0 00 02 20 00 01 00 00 00 00 00 00 00  h..... .........
>>     00 00 00 00 00 00 00 00 00 00 00 00 ff 7f 00 00  ................
>>   backtrace:
>>     [<c159b50c>] kmemleak_alloc+0x2c/0x60
>>     [<c1139c23>] __kmalloc+0x1c3/0x240
>>     [<c14e2627>] fib_default_rule_add+0x27/0x70
>>     [<c157f8df>] ip6mr_net_init+0x6f/0x140
>>     [<c14c4129>] ops_init+0x39/0x110
>>     [<c14c425f>] setup_net+0x5f/0xf0
>>     [<c14c46e4>] copy_net_ns+0x74/0xf0
>>     [<c105fc81>] create_new_namespaces+0xd1/0x160
>>     [<c105fedf>] unshare_nsproxy_namespaces+0x5f/0xa0
>>     [<c1038a94>] sys_unshare+0x114/0x280
>>     [<c15b7ecd>] sysenter_do_call+0x12/0x28
>>     [<ffffffff>] 0xffffffff
>
> How is this memory unreferenced?  fib_rule_default_add() adds
> the allocated object to the ops->rules_list as it's very last
> action.

Perhaps we miss a synchronize_rcu() here...

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 58a4ba2..7b53f4a 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -176,6 +176,7 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
        spin_unlock(&net->rules_mod_lock);
	 
         call_rcu(&ops->rcu, fib_rules_put_rcu);
 +       synchronize_rcu();
  }
  EXPORT_SYMBOL_GPL(fib_rules_unregister);
		    
		    
