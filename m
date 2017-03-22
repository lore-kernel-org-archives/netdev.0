From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: race condition in kernel/padata.c
Date: Thu, 23 Mar 2017 00:03:43 +0100
Message-ID: <CAHmME9oLWiprOyZXo7zvGm7xq+1Kchw9ybLS_TM-9xDyHF0mxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: WireGuard mailing list <wireguard@lists.zx2c4.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
 Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>
Return-path: <wireguard-bounces@lists.zx2c4.com>
List-Unsubscribe: <https://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <https://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

Hey Steffen,

WireGuard makes really heavy use of padata, feeding it units of work
from different cores in different contexts all at the same time. For
the most part, everything has been fine, but one particular user has
consistently run into mysterious bugs. He's using a rather old dual
core CPU, which have a tendency to bring out race conditions
sometimes. After struggling with getting a good backtrace, we finally
managed to extract this from list debugging:

[87487.298728] WARNING: CPU: 1 PID: 882 at lib/list_debug.c:33
__list_add+0xae/0x130
[87487.301868] list_add corruption. prev->next should be next
(ffffb17abfc043d0), but was ffff8dba70872c80. (prev=ffff8dba70872b00).
[87487.339011]  [<ffffffff9a53d075>] dump_stack+0x68/0xa3
[87487.342198]  [<ffffffff99e119a1>] ? console_unlock+0x281/0x6d0
[87487.345364]  [<ffffffff99d6b91f>] __warn+0xff/0x140
[87487.348513]  [<ffffffff99d6b9aa>] warn_slowpath_fmt+0x4a/0x50
[87487.351659]  [<ffffffff9a58b5de>] __list_add+0xae/0x130
[87487.354772]  [<ffffffff9add5094>] ? _raw_spin_lock+0x64/0x70
[87487.357915]  [<ffffffff99eefd66>] padata_reorder+0x1e6/0x420
[87487.361084]  [<ffffffff99ef0055>] padata_do_serial+0xa5/0x120

padata_reorder calls list_add_tail with the list to which its adding
locked, which seems correct:

spin_lock(&squeue->serial.lock);
list_add_tail(&padata->list, &squeue->serial.list);
spin_unlock(&squeue->serial.lock);

This therefore leaves only place where such inconsistency could occur:
if padata->list is added at the same time on two different threads.
This pdata pointer comes from the function call to
padata_get_next(pd), which has in it the following block:

next_queue = per_cpu_ptr(pd->pqueue, cpu);
padata = NULL;
reorder = &next_queue->reorder;
if (!list_empty(&reorder->list)) {
       padata = list_entry(reorder->list.next,
                           struct padata_priv, list);
       spin_lock(&reorder->lock);
       list_del_init(&padata->list);
       atomic_dec(&pd->reorder_objects);
       spin_unlock(&reorder->lock);

       pd->processed++;

       goto out;
}
out:
return padata;

I strongly suspect that the problem here is that two threads can race
on reorder list. Even though the deletion is locked, call to
list_entry is not locked, which means it's feasible that two threads
pick up the same padata object and subsequently call list_add_tail on
them at the same time. The fix would thus be to hoist that lock
outside of that block.

This theory is unconfirmed at the moment, but I'll be playing with
some patches to see if this fixes the issue and then I'll get back to
you. In the meantime, if you have any insight before I potentially
waste some time, I'm all ears.

Thanks,
Jason
