From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 7 Mar 2017 10:57:53 -0700
Message-ID: <a7329aee-7173-888f-0c8e-dc7b1055e262@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/7/17 1:43 AM, Dmitry Vyukov wrote:
> This is on c1ae3cfa0e89fa1a7ecc4c99031f5e9ae99d9201. No other kernel
> output from your patch (pr_err).
> 
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 30179 at net/ipv6/ip6_fib.c:158
> rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
> Kernel panic - not syncing: panic_on_warn set ...

you have panic_on_warn set ...

> 
> CPU: 1 PID: 30179 Comm: syz-executor3 Not tainted 4.11.0-rc1+ #310
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>  panic+0x20f/0x426 kernel/panic.c:180
>  __warn+0x1c4/0x1e0 kernel/panic.c:541
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>  rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158

and this is my WARN_ON in rt6_rcu_free which is showing an additional
change is needed

>  rt6_release+0x1ee/0x290 net/ipv6/ip6_fib.c:189
>  fib6_add_rt2node net/ipv6/ip6_fib.c:922 [inline]

in fib6_add_rt2node for the route replace path (whitespace damaged on
the copy-paste):

@@ -916,6 +919,7 @@ static int fib6_add_rt2node(struct fib6_node *fn,
struct rt6_info *rt,
                }
                nsiblings = iter->rt6i_nsiblings;
                fib6_purge_rt(iter, fn, info->nl_net);
+               iter->dst.flags &= ~DST_IN_FIB;
                rt6_release(iter);

                if (nsiblings) {
@@ -926,6 +930,7 @@ static int fib6_add_rt2node(struct fib6_node *fn,
struct rt6_info *rt,
                                if (rt6_qualify_for_ecmp(iter)) {
                                        *ins = iter->dst.rt6_next;
                                        fib6_purge_rt(iter, fn,
info->nl_net);
+                                       iter->dst.flags &= ~DST_IN_FIB;
                                        rt6_release(iter);
                                        nsiblings--;
                                } else {
