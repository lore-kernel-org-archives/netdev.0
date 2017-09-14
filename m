From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH] net/packet: fix race condition between fanout_add and __unregister_prot_hook
Date: Thu, 14 Sep 2017 07:22:02 -0400
Message-ID: <CAF=yD-J=JtkaShSDfqNPu=sxGnzna1pTM13dr509dQm4XZ-MbA@mail.gmail.com>
References: <20170914024046.92505-1-nixiaoming@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, waltje@uwalt.nl.mugnet.org,
        gw4pts@gw4pts.ampr.org, Andrey Konovalov <andreyknvl@google.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        philip.pettersson@gmail.com,
        Alexander Potapenko <glider@google.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, dede.wu@huawei.com
To: nixiaoming <nixiaoming@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170914024046.92505-1-nixiaoming@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 13, 2017 at 10:40 PM, nixiaoming <nixiaoming@huawei.com> wrote:
> If fanout_add is preempted after running po-> fanout = match
> and before running __fanout_link,
> it will cause BUG_ON when __unregister_prot_hook call __fanout_unlink
>
> so, we need add mutex_lock(&fanout_mutex) to __unregister_prot_hook
> or add spin_lock(&po->bind_lock) before po-> fanout = match
>
> test on linux 4.1.42:
> ./trinity -c setsockopt -C 2 -X &
>
> BUG: failure at net/packet/af_packet.c:1414/__fanout_unlink()!
> Kernel panic - not syncing: BUG!
> CPU: 2 PID: 2271 Comm: trinity-c0 Tainted: G        W  O    4.1.12 #1
> Hardware name: Hisilicon PhosphorHi1382 FPGA (DT)
> Call trace:
> [<ffffffc000209414>] dump_backtrace+0x0/0xf8
> [<ffffffc00020952c>] show_stack+0x20/0x28
> [<ffffffc000635574>] dump_stack+0xac/0xe4
> [<ffffffc000633fb8>] panic+0xf8/0x268
> [<ffffffc0005fa778>] __unregister_prot_hook+0xa0/0x144
> [<ffffffc0005fba48>] packet_set_ring+0x280/0x5b4
> [<ffffffc0005fc33c>] packet_setsockopt+0x320/0x950
> [<ffffffc000554a04>] SyS_setsockopt+0xa4/0xd4
>
> Signed-off-by: nixiaoming <nixiaoming@huawei.com>
> Tested-by: wudesheng <dede.wu@huawei.com>
> ---
>  net/packet/af_packet.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 008a45c..0300146 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -365,10 +365,12 @@ static void __unregister_prot_hook(struct sock *sk, bool sync)
>
>         po->running = 0;
>
> +       mutex_lock(&fanout_mutex);
>         if (po->fanout)
>                 __fanout_unlink(sk, po);
>         else
>                 __dev_remove_pack(&po->prot_hook);
> +       mutex_unlock(&fanout_mutex);
>
>         __sock_put(sk);

I happened to be looking at the same or a very similar race, courtesy
of syzkaller. packet_set_ring and fanout_add can race.

I believe that one bug is in fanout_add removing the socket
protocol hook and adding the fanout protocol hook without holding
po->bind_lock.

That lock ensures atomic updates to po->running and the actual
protocol hook. fanout_add tests po->running without holding the lock

       if (!po->running)
                goto out;

and later unconditionally unbinds the socket protocol hook and binds
the fanout group protocol hook:

               if (refcount_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
                        __dev_remove_pack(&po->prot_hook);
                        po->fanout = match;
                        refcount_set(&match->sk_ref,
refcount_read(&match->sk_ref) + 1);
                        __fanout_link(sk, po);
                        err = 0;
                }

This can happen after packet_set_ring has already removed the
protocol hook, causing the socket to be added to the fanout list
twice.

Testing po->running again, this time while holding the bind_lock,
ensures that packet_set_ring cannot have dropped it in between:

+                       spin_lock(&po->bind_lock);
+                       if (!po->running) {
+                               net_err_ratelimited("fanout add, but
unbound sock");
+                               err = -EFAULT;
+                               spin_unlock(&po->bind_lock);
+                               goto out;
+                       }
+                       __dev_remove_pack(&po->prot_hook));
                        po->fanout = match;
                        refcount_set(&match->sk_ref,
refcount_read(&match->sk_ref) + 1);
                        __fanout_link(sk, po);
+                       spin_unlock(&po->bind_lock);

I verified that the reproducer logs plenty of "fanout add, but unbound
sock" messages.

I intend to send this fix after cleaning it up a bit. Will take a
closer look at your patch to see whether these are indeed the
same bug report.
