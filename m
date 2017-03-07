From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 7 Mar 2017 21:00:54 +0100
Message-ID: <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
 <2b60b1b8-4766-0e36-f6fb-79914bf1925d@cumulusnetworks.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com> <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 7, 2017 at 8:30 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On 3/7/17 11:13 AM, Dmitry Vyukov wrote:
>>>>> on this warning:
>>>>>
>>>>> /* dst.next really should not be set at this point */
>>>>> if (rt->dst.next && rt->dst.next->ops->family != AF_INET6) {
>>>>>         pr_warn("fib6_add: adding rt with bad next -- family %d dst
>>>>> flags %x\n",
>>>>>                 rt->dst.next->ops->family, rt->dst.next->flags);
>>>>>
>>>>>         WARN_ON(1);
>>>>> }
>>>>>
>>>>> You should have seen the pr_warn in the log preceding the WARN_ON dump.
>>>>
>>>> Right. They all have the same "IPv6: fib6_add: adding rt with bad next
>>>> -- family 2 dst flags 6"
>>>
>>> remove the previous changes and try the attached.
>>
>>
>> Doing this now.
>> FWIW I've also applied your last patch with missing "iter->dst.flags
>> &= ~DST_IN_FIB;" and restored the warning in rt6_rcu_free and it did
>> not fire (in a limited run). I only saw the "WARNING in fib6_add" that
>> I already reported.
>
>
> So far I've hit only:
> [ 1103.840031] BUG: KASAN: slab-out-of-bounds in fib6_age+0x3fd/0x480
> at addr ffff8800799d2254
> without any preceeding warnings.
> But note that since the kernel is heavily stressed I can reliably get
> any pr_err output if it happens right before BUG/WARNING. Anything
> that happens minutes before will be lots because there are tons of
> output.



So far 6 "KASAN: slab-out-of-bounds Read in fib6_age" but no other warnings.
