From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: net/atm: warning in alloc_tx/__might_sleep
Date: Tue, 10 Jan 2017 23:47:23 +0100
Message-ID: <20170110224722.GA21775@electric-eye.fr.zoreil.com>
References: <CAAeHK+yZ16SKcmJbv2ARafGgAuX2wwQNE0HGdiFy1WgqPjxLMg@mail.gmail.com>
 <CAM_iQpWaHX_orHbFjKcjBZL67b6LUAmOfvS1SQP13VPZDo-69w@mail.gmail.com>
 <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANn89iLxQPAt0e5Yc0yYFFQtoQwuRsdAwH9m1d4oqWQ3W=DZTQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <edumazet@google.com> :
> On Tue, Jan 10, 2017 at 9:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Mon, Jan 9, 2017 at 9:20 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> >
> > The fix should be straight-forward. Mind to try the attached patch?
> 
> 
> You forgot to remove schedule() ?

It may be clearer to split alloc_tx in two parts: only the unsleepable
"if (sk_wmem_alloc_get(sk) && !atm_may_send(vcc, size)) {" part of it
contributes to the inner "while (!(skb = alloc_tx(vcc, eff))) {" block.

See net/atm/common.c
[...]
static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
{
        struct sk_buff *skb;
        struct sock *sk = sk_atm(vcc);

        if (sk_wmem_alloc_get(sk) && !atm_may_send(vcc, size)) {
                pr_debug("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
                         sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
                return NULL;
        }
        while (!(skb = alloc_skb(size, GFP_KERNEL)))
                schedule();
        pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
        atomic_add(skb->truesize, &sk->sk_wmem_alloc);
        return skb;
}

The waiting stuff is related to vcc drain but the code makes it look as
if it were also related to skb alloc (it isn't).

It may be obvious for you but it took me a while to figure what the
code is supposed to achieve.

-- 
Ueimor
