From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Fri, 27 Jan 2017 17:31:30 -0800
Message-ID: <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
         <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-27 at 17:00 -0800, Cong Wang wrote:
> On Fri, Jan 27, 2017 at 3:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Oh well, I forgot to submit the official patch I think, Jan 9th.
> >
> > https://groups.google.com/forum/#!topic/syzkaller/BhyN5OFd7sQ
> >
> 
> Hmm, but why only fragments need skb_orphan()? It seems like
> any kfree_skb() inside a nf hook needs to have a preceding
> skb_orphan().


> 
> Also, I am not convinced it is similar to commit 8282f27449bf15548
> which is on RX path.

Well, we clearly see IPv6 reassembly being part of the equation in both
cases.

I was replying to first part of the splat [1], which was already
diagnosed and had a non official patch.

use after free is also a bug, regardless of jump label being used or
not.

I still do not really understand this nf_hook issue, I thought we were
disabling BH in netfilter.

So the in_interrupt() check in net_disable_timestamp() should trigger,
this was the intent of netstamp_needed_deferred existence.

Not sure if we can test for rcu_read_lock() as well.

[1]
 sk_destruct+0x47/0x80 net/core/sock.c:1460
 __sk_free+0x57/0x230 net/core/sock.c:1468
 sock_wfree+0xae/0x120 net/core/sock.c:1645
 skb_release_head_state+0xfc/0x200 net/core/skbuff.c:655
 skb_release_all+0x15/0x60 net/core/skbuff.c:668
 __kfree_skb+0x15/0x20 net/core/skbuff.c:684
 kfree_skb+0x16e/0x4c0 net/core/skbuff.c:705
 inet_frag_destroy+0x121/0x290 net/ipv4/inet_fragment.c:304
 inet_frag_put include/net/inet_frag.h:133 [inline]
 nf_ct_frag6_gather+0x1106/0x3840
net/ipv6/netfilter/nf_conntrack_reasm.c:617
 ipv6_defrag+0x1be/0x2b0 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:68
 nf_hook_entry_hookfn include/linux/netfilter.h:102 [inline]
 nf_hook_slow+0xc3/0x290 net/netfilter/core.c:310
 nf_hook include/linux/netfilter.h:212 [inline]
 __ip6_local_out+0x489/0x840 net/ipv6/output_core.c:160
 ip6_local_out+0x2d/0x170 net/ipv6/output_core.c:170





