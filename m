From: "Javi Roman" <javiroman@kernel-labs.org>
Subject: egress path understanding
Date: Thu, 4 Jan 2007 10:41:34 +0100
Message-ID: <12c2e32e0701040141l15fba8d7g54db1849c0abe766@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:43432 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932354AbXADJlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 04:41:42 -0500
Received: by nf-out-0910.google.com with SMTP id o25so8003685nfa
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 01:41:34 -0800 (PST)
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

(sorry for newbie question)

I'm trying to learn the networking code of an ancient 2.4.18 vanilla kernel.

I understand that the egress path of network packet (socket buffer) as
general behaviour, goes through the method hard_start_xmit() within of
the driver layer. This method is the responsible of putting the
network packet into the output buffers of the network device. When the
physical transmmission is completed the device raises an interrupt and
the interrupt handler of the device is called.

The typical interrupt handler is a function running in interrupt
context, so needs to be as quick as possible, and because this
function has to free the skb buffer (to deallocate the sk_buff
structure associated with sucessfully transmitted buffer), the task is
delegated to softirq (NET_TX_SOFTIRQ) by means of function
dev_kfree_skb_irq():

static inline void dev_kfree_skb_irq(struct sk_buff *skb)
{
        if (atomic_dec_and_test(&skb->users)) {
                int cpu =smp_processor_id();
                unsigned long flags;

#ifdef CONFIG_PROC_FS
                softirq_stats.raise_from_kfree_skb_cont++;
#endif
                local_irq_save(flags);
                skb->next = softnet_data[cpu].completion_queue;
                softnet_data[cpu].completion_queue = skb;
                cpu_raise_softirq(cpu, NET_TX_SOFTIRQ);
                local_irq_restore(flags);
        }
}

When do_softirq() is called the funcion associated with
NET_TX_SOFTIRQ, net_tx_action() is called:

static void net_tx_action(struct softirq_action *h)
{
        int cpu = smp_processor_id();

        if (softnet_data[cpu].completion_queue) {
                struct sk_buff *clist;

                local_irq_disable();
                clist = softnet_data[cpu].completion_queue;
                softnet_data[cpu].completion_queue = NULL;
                local_irq_enable();

                while (clist != NULL) {
                        struct sk_buff *skb = clist;
                        clist = clist->next;
#ifdef CONFIG_PROC_FS
                        softirq_stats.tx_completion_cont++;
#endif
                        BUG_TRAP(atomic_read(&skb->users) == 0);
                        __kfree_skb(skb);
                }
        }

..... [snip]

}

How you can see, I have put some counters in order to trace the
execution of networking code by means of the file:
/proc/net/softirq_stat. The oputput of this file is the following when
I test the kernel:

# cat /proc/net/softirq_stat
raise_from_netif_cont: 0
raise_from_kfree_skb_cont: 0
(qdisc_restart) hard_start_xmit_cont: 5869
(qdisc_restart) xmit_lock_grabbed_cont: 0
tx_completion_cont: 5869
tx_output_cont: 142

OK, the important fields of this output are tx_completion_cont and
raise_from_kfree_skb_cont. We can see that every packet passed to
hard_start_xmit_cont (in qdisc_restart) is freed with net_tx_action,
so the counter hard_start_xmit_cont and tx_completion_cont show the
same values. But I cannot understand why the counter
raise_from_kfree_skb_cont is zero!!!

I guess the code path must pass through of dev_kfree_skb_irq() in
order to raise the softirq with cpu_raise_softirq(cpu,
NET_TX_SOFTIRQ), so it's possible to execute net_tx_action() later.

I don't know if I don't understand the therory or I have an error in
the code. Please can anybody advice me about this behaviour?

Thanks a lot, and sorry for my english.

--
Javi Roman
