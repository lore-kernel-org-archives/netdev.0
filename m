From: Ben Greear <greearb@candelatech.com>
Subject: NAPI question
Date: Fri, 08 Nov 2002 17:33:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCC65CD.6060009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In dev.c, there is this code.  Please see my question by the ### marks.

static void net_rx_action(struct softirq_action *h)
{
	int this_cpu = smp_processor_id();
	struct softnet_data *queue = &softnet_data[this_cpu];
	unsigned long start_time = jiffies;
	int budget = netdev_max_backlog;

	br_read_lock(BR_NETPROTO_LOCK);
	local_irq_disable();

	while (!list_empty(&queue->poll_list)) {
		struct net_device *dev;

		if (budget <= 0 || jiffies - start_time > 1)
			goto softnet_break;

		local_irq_enable();

		dev = list_entry(queue->poll_list.next, struct net_device, poll_list);

		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
			local_irq_disable();
			list_del(&dev->poll_list);
			list_add_tail(&dev->poll_list, &queue->poll_list);

###  How can quota ever get negative?  In other words, why not just set it to dev->weight
###  always?  Or, if the dev didn't use up all it's quota from the last round, why not
###  increase it up to a max of 2 x weight or something like that?

			if (dev->quota < 0)
                                dev->quota += dev->weight;
                         else
                                dev->quota = dev->weight;
		} else {
			dev_put(dev);
			local_irq_disable();
		}
	}


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
