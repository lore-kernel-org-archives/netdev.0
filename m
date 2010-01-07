From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: rps: some comments
Date: Thu, 07 Jan 2010 18:42:41 +0100
Message-ID: <4B461D11.6050603@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120154046.67252d23@nehalam>	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com>	 <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>	 <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <65634d661001061454v389d311fjb245de21e0ab8092@mail.gmail.com> <4B45A623.7070507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43183 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab0AGRmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 12:42:49 -0500
In-Reply-To: <4B45A623.7070507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom

1) netif_receive_skb() might enqueue skb instead of handling them directly.

int netif_receive_skb(struct sk_buff *skb)
{
        int cpu = get_rps_cpu(skb->dev, skb);

        if (cpu < 0)
                return __netif_receive_skb(skb);
        else
                return enqueue_to_backlog(skb, cpu);
}

If get_rps_cpu() happens to select the current cpu, we enqueue to backlog the
skb instead of directly calling __netif_receive_skb().

One way to solve this is to make get_rps_cpu() returns -1 in this case :

...
if (cpu == smp_processor_id() || !cpu_online(cpu))
	cpu = -1;

done:
	rcu_read_unlock();
	return cpu;
} /* get_rps_cpu() */


2) RPS_MAP_SIZE might be too expensive to use in fast path, on big (NR_CPUS=4096) machines :
 num_possible_cpus() has to count all bits set in a bitmap.

#define MAX_RPS_CPUS (num_possible_cpus() < 256 ? num_possible_cpus() : 256)
#define RPS_MAP_SIZE (sizeof(struct rps_map) + (MAX_RPS_CPUS * sizeof(u16))

You can use nr_cpu_ids, or even better a new variable, that you init _once_ to

unsigned int rps_map_size = sizeof(struct rps_map) + (min(256, nr_cpu_ids) * sizeof(u16));


3) cpu hotplug.

I cannot find how cpu unplug can be safe.

if (!cpu_online(cpu))
	cpu = -1;
rcu_read_unlock();
...
cpu_set(cpu, __get_cpu_var(rps_remote_softirq_cpus));
...
__smp_call_function_single(cpu, &queue->csd, 0);

Thanks

