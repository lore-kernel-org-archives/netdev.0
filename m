From: Ben Greear <greearb@candelatech.com>
Subject: Re: deadlock in 2.6.18.2 related to bridging?
Date: Wed, 14 Feb 2007 13:26:08 -0800
Message-ID: <45D37E70.9090304@candelatech.com>
References: <45D26479.7030103@candelatech.com> <20070214131205.1ace04ba@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:46855 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932636AbXBNV0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Feb 2007 16:26:46 -0500
In-Reply-To: <20070214131205.1ace04ba@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> The bug is in r8139too.c driver. It calls flush_scheduled_work
> with RTNL mutex held, so any other work using it will get stuck.

It looks like a fairly common problem, as tg3 has the same issue
(though it seems someone tried to hack around one particular case):

static int tg3_close(struct net_device *dev)
{
         struct tg3 *tp = netdev_priv(dev);

         /* Calling flush_scheduled_work() may deadlock because
          * linkwatch_event() may be on the workqueue and it will try to get
          * the rtnl_lock which we are holding.
          */
         while (tp->tg3_flags & TG3_FLAG_IN_RESET_TASK)
                 msleep(1);

         netif_stop_queue(dev);


e1000 appears clean, at least, but there are a lot of other
drivers that are calling that method (I didn't check to see
if they might be holding rtnl when called.)


Thanks,
Ben




> 
>> Has this been fixed in later releases?
> 
> No but a different race (with device removal) has been fixed.
> 
> 
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

