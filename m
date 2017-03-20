From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: deadlock between ip_expire/sch_direct_xmit
Date: Mon, 20 Mar 2017 05:43:19 -0700
Message-ID: <1490013799.16816.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+ZrHr0Cqw5RPeZ6QW16auOPyKSCOea6AciHBswAT3t14Q@mail.gmail.com>
         <1489502504.28631.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+bLJtO55iP5uNPZV+_B+H5-Z2gOiF26sXDmWk9L0rESsw@mail.gmail.com>
         <CANn89iLO1neA3-4ipYr==n_3iDXDXgY0MCkPkp=cEf8n4w6i=g@mail.gmail.com>
         <CAM_iQpV9iyOHoYUUO=wwHWz0GpUoQzwX+f3DSxwJo54eCcqH2g@mail.gmail.com>
         <CACT4Y+a0sL_XZftyNoAyEVZEo6VHQe2wPRrPgAMnvG32VbMw6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+a0sL_XZftyNoAyEVZEo6VHQe2wPRrPgAMnvG32VbMw6g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-20 at 10:59 +0100, Dmitry Vyukov wrote:
> On Tue, Mar 14, 2017 at 5:41 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Tue, Mar 14, 2017 at 7:56 AM, Eric Dumazet <edumazet@google.com> wrote:
> >> On Tue, Mar 14, 2017 at 7:46 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> >>
> >>> I am confused. Lockdep has observed both of these stacks:
> >>>
> >>>        CPU0                    CPU1
> >>>        ----                    ----
> >>>   lock(&(&q->lock)->rlock);
> >>>                                lock(_xmit_ETHER#2);
> >>>                                lock(&(&q->lock)->rlock);
> >>>   lock(_xmit_ETHER#2);
> >>>
> >>>
> >>> So it somehow happened. Or what do you mean?
> >>>
> >>
> >> Lockdep said " possible circular locking dependency detected " .
> >> It is not an actual deadlock, but lockdep machinery firing.
> >>
> >> For a dead lock to happen, this would require that he ICMP message
> >> sent by ip_expire() is itself fragmented and reassembled.
> >> This cannot be, because ICMP messages are not candidates for
> >> fragmentation, but lockdep can not know that of course...
> >
> > It doesn't have to be ICMP, as long as get the same hash for
> > the inet_frag_queue, we will need to take the same lock and
> > deadlock will happen.
> >
> >         hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
> >
> > So it is really up to this hash function.
> 
> 
> 
> Is the following the same issue?
> It mentions dev->qdisc_tx_busylock, but I am not sure if it's relevant
> if there already a cycle between  _xmit_ETHER#2 -->
> &(&q->lock)->rlock#2.


False positive again.

veth needs to use netdev_lockdep_set_classes(), assuming you use veth ?

I will provide a patch, thanks.

cf515802043cccecfe9ab75065f8fc71e6ec9bab missed a few drivers.
