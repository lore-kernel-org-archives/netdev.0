From: Patrick McHardy <kaber@trash.net>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: Wed, 22 Dec 2004 11:54:23 +0100
Message-ID: <41C9525F.4070805@trash.net>
References: <20041217233524.GA11202@electric-eye.fr.zoreil.com> <36901.192.102.214.6.1103535728.squirrel@webmail.wetlettuce.com> <20041220211419.GC5974@waste.org> <20041221002218.GA1487@electric-eye.fr.zoreil.com> <20041221005521.GD5974@waste.org> <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com> <20041221123727.GA13606@electric-eye.fr.zoreil.com> <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com> <20041221204853.GA20869@electric-eye.fr.zoreil.com> <20041221212737.GK5974@waste.org> <20041221225831.GA20910@electric-eye.fr.zoreil.com> <41C93FAB.9090708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Mark Broadbent <markb@wetlettuce.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261961AbULVKzW@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <41C93FAB.9090708@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Francois Romieu wrote:
> 
>> Marc, if the patch below happens to work, it should not drop messages
>> like the previous one (it is an ugly short-term suggestion).
>>
> 
>> -    spin_lock(&np->dev->xmit_lock);
>> +    while (!spin_trylock(&np->dev->xmit_lock)) {
>> +        if (np->dev->xmit_lock_owner == smp_processor_id()) {
>> +            struct Qdisc *q = dev->qdisc;
>> +
>> +            q->ops->enqueue(skb, q);
> 
> 
> Shouldn't this be requeue ?

Since the code doesn't dequeue itself, enqueue seems fine to keep
at least the queued messages ordered. But you need to grab
dev->queue_lock, otherwise you risk corrupting qdisc internal data.
You should probably also deal with the noqueue-qdisc, which doesn't
have an enqueue function. So it should look something like this:

while (!spin_trylock(&np->dev->xmit_lock)) {
	if (np->dev->xmit_lock_owner == smp_processor_id()) {
		struct Qdisc *q;

		rcu_read_lock();
		q = rcu_dereference(dev->qdisc);
		if (q->enqueue) {
			spin_lock(&dev->queue_lock);
			q->ops->enqueue(skb, q);
			spin_unlock(&dev->queue_lock);
			netif_schedule(np->dev);
		} else
			kfree_skb(skb);
		rcu_read_unlock();
		return;
	}
}

Regards
Patrick
