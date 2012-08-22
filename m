From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dev: fix the incorrect hold of net namespace's lo
 device
Date: Wed, 22 Aug 2012 13:24:27 +0200
Message-ID: <1345634667.5158.1114.camel@edumazet-glaptop>
References: <1345624262-6554-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1345624786.5158.759.camel@edumazet-glaptop>
	 <5034BBBB.6080307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49080 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608Ab2HVLYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 07:24:32 -0400
Received: by bkwj10 with SMTP id j10so253518bkw.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 04:24:31 -0700 (PDT)
In-Reply-To: <5034BBBB.6080307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 19:00 +0800, Gao feng wrote:

> Hi Eric
> 
> I saw your patch and think this patch is clear and doesn't change too much logic.
> 
> I test your patch, it not fix this problem.
> 
> In my test case,when moving a net device to another net namespace,
> Because you patch delete NETDEV_UNREGISTER event from dst_dev_event,
> we will just put dst entries into the dst garbage list in event
> NETDEV_DOWN,without call dst_ifdown to change these dst entries' device
> to the lo device,and now this net device belongs to the new net namespace.
> 

Then fix the "moving a net device to another net namespace", instead
of slowing down other common operations.

dev_change_net_namespace() is probably a better place to put your patch

> After the net device beeing moved to another net namespace, I rmmod this
> net device's driver,this will trigger the new added event NETDEV_UNREGISTER_FINISH,
> so in dst_dev_event,we will change these dst entries's device to the new net
> namespace's lo device,and this will make the referenct count of the new net namespace's
> lo device incorrect. when we exit the new net namespace,this emg message is still exist.
> 
> Message from syslogd@Donkey at Aug 22 18:50:13 ...
>  kernel:[ 1161.979036] unregister_netdevice: waiting for lo to become free. Usage count = 1
> 
> And because net_mutex is locked here,so we can't create new net namespace.
> 
> > rcu_barrier() at this place will kill some workloads.
> > 
> 
> I think this will only add some workloads when unregister a net device.
> Do I miss something?

Yes, rcu_barrier() at this point is killing performance, because we hold
RTNL.

We worked hard to batch things, your patch is a huge step backward.
