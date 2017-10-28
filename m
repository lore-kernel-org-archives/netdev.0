From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [RFC] please clarify local_irq_disable() in
 pcpu_freelist_populate()
Date: Fri, 27 Oct 2017 19:18:40 -0700
Message-ID: <72432216-c082-2f79-65bd-ee082fa369dc@fb.com>
References: <20171027222354.bf3wv4ldnrmc5pbx@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <tglx@linutronix.de>, <peterz@infradead.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59546 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751025AbdJ1CTf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 22:19:35 -0400
In-Reply-To: <20171027222354.bf3wv4ldnrmc5pbx@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/17 3:23 PM, Sebastian Andrzej Siewior wrote:
> Hi,
>
> while looking at other things here I stumbled at this in
> kernel/bpf/percpu_freelist.c:
>
> |void pcpu_freelist_populate(struct pcpu_freelist *s, void *buf, u32 elem_size,
> |                            u32 nr_elems)
> |{
> …
> |        /* disable irq to workaround lockdep false positive
> |         * in bpf usage pcpu_freelist_populate() will never race
> |         * with pcpu_freelist_push()
> |         */
> |        local_irq_save(flags);
> |        for_each_possible_cpu(cpu) {
> |again:
> |                head = per_cpu_ptr(s->freelist, cpu);
> |                __pcpu_freelist_push(head, buf);
> …
> |        }
> |        local_irq_restore(flags);
> |}
>
> and then we have
>
> | static inline void __pcpu_freelist_push(struct pcpu_freelist_head *head,
> |                                         struct pcpu_freelist_node *node)
> | {
> |         raw_spin_lock(&head->lock);
> |         node->next = head->first;
> |         head->first = node;
> |         raw_spin_unlock(&head->lock);
> | }
>
> I don't see how any of this can race with pcpu_freelist_push():
>
> |void pcpu_freelist_push(struct pcpu_freelist *s,
> |                        struct pcpu_freelist_node *node)
> |{
> |        struct pcpu_freelist_head *head = this_cpu_ptr(s->freelist);
> |
> |        __pcpu_freelist_push(head, node);
> |}
>
> I *think* the problem is using this_cpu_ptr() in non-atomic context

pcpu_freelist_push() is called by bpf programs from atomic context.

> which splats a warning CONFIG_DEBUG_PREEMPT and has nothing todo with
> lockdep. However pcpu_freelist_populate() is not using
> pcpu_freelist_push() so I remain clueless.
> __pcpu_freelist_push() adds an item (node) to the list head (head) and
> this head is protected with a spin_lock.

lockdep thinks that __pcpu_freelist_push() can be called recursively
in the middle of pcpu_freelist_populate's loop and will deadlock
which is not the case here. That's why local_irq_save() is there.
Just to silence lockdep.

> I *think* pcpu_freelist_push() can use raw_cpu_ptr() instead and the
> local_irq_save() can go away (with __pcpu_freelist_push() using a
> raw_spin_lock_irqsafe() instead).

that won't be correct.

> On the other hand, using llist instead would probably eliminate the need
> for the lock in ->head since llist_add() and llist_del_first() is
> lockless and serve the same purpose.

While developing pcpu_freelist I've benchmarked many different
approaches. Some of the numbers are in
commit 6c9059817432 ("bpf: pre-allocate hash map elements")
iirc I passed on llist, since llist_del_first still needs a lock,
so doesn't really help.
