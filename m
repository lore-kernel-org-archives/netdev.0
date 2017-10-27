From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [RFC] please clarify local_irq_disable() in pcpu_freelist_populate()
Date: Sat, 28 Oct 2017 00:23:55 +0200
Message-ID: <20171027222354.bf3wv4ldnrmc5pbx@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: tglx@linutronix.de, peterz@infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:36177 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751976AbdJ0WYL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 18:24:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while looking at other things here I stumbled at this in
kernel/bpf/percpu_freelist.c:

|void pcpu_freelist_populate(struct pcpu_freelist *s, void *buf, u32 elem_size,
|                            u32 nr_elems)
|{
…
|        /* disable irq to workaround lockdep false positive
|         * in bpf usage pcpu_freelist_populate() will never race
|         * with pcpu_freelist_push()
|         */
|        local_irq_save(flags); 
|        for_each_possible_cpu(cpu) {
|again:
|                head = per_cpu_ptr(s->freelist, cpu);
|                __pcpu_freelist_push(head, buf); 
…
|        }
|        local_irq_restore(flags);
|}

and then we have

| static inline void __pcpu_freelist_push(struct pcpu_freelist_head *head,
|                                         struct pcpu_freelist_node *node)
| {
|         raw_spin_lock(&head->lock);
|         node->next = head->first;
|         head->first = node;
|         raw_spin_unlock(&head->lock);
| }

I don't see how any of this can race with pcpu_freelist_push():

|void pcpu_freelist_push(struct pcpu_freelist *s,
|                        struct pcpu_freelist_node *node)
|{
|        struct pcpu_freelist_head *head = this_cpu_ptr(s->freelist);
|
|        __pcpu_freelist_push(head, node);
|}

I *think* the problem is using this_cpu_ptr() in non-atomic context
which splats a warning CONFIG_DEBUG_PREEMPT and has nothing todo with
lockdep. However pcpu_freelist_populate() is not using
pcpu_freelist_push() so I remain clueless.
__pcpu_freelist_push() adds an item (node) to the list head (head) and
this head is protected with a spin_lock.

I *think* pcpu_freelist_push() can use raw_cpu_ptr() instead and the
local_irq_save() can go away (with __pcpu_freelist_push() using a
raw_spin_lock_irqsafe() instead).

On the other hand, using llist instead would probably eliminate the need
for the lock in ->head since llist_add() and llist_del_first() is
lockless and serve the same purpose.

Sebastian
