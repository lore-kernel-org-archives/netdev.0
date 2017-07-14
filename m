From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] ipv6: initialize treq->txhash in cookie_v6_check()
Date: Fri, 14 Jul 2017 15:05:40 -0400
Message-ID: <CADVnQy=LQ_6ak+Ub-pAc1d+mHvNP5WVCb4Cjv7+f47VVRBCcPw@mail.gmail.com>
References: <20170714165453.112098-1-glider@google.com> <CADVnQynZUh+4kU9Fdq8crAmi-j8BbErid=mJQ6B-WVXDGU2VQA@mail.gmail.com>
 <CAG_fn=XZVGc6Viw2ngQp7kMZ50PK5se_PXynjVKYr9cLywU58g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG_fn=XZVGc6Viw2ngQp7kMZ50PK5se_PXynjVKYr9cLywU58g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 1:35 PM, Alexander Potapenko <glider@google.com> wrote:
> On Fri, Jul 14, 2017 at 7:04 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Fri, Jul 14, 2017 at 12:54 PM, Alexander Potapenko <glider@google.com> wrote:
>>> KMSAN reported use of uninitialized memory in skb_set_hash_from_sk(),
>>> which originated from the TCP request socket created in
>>> cookie_v6_check():
>> ...
>>> --- a/net/ipv6/syncookies.c
>>> +++ b/net/ipv6/syncookies.c
>>> @@ -216,6 +216,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
>>>         treq->rcv_isn = ntohl(th->seq) - 1;
>>>         treq->snt_isn = cookie;
>>>         treq->ts_off = 0;
>>> +       treq->txhash = 0;
>>>
>>>         /*
>>>          * We need to lookup the dst_entry to get the correct window size.
>>
>> I would have thought that the same fix is needed in the corresponding
>> line in cookie_v4_check() in net/ipv4/syncookies.c? (I do not see
>> txhash being initialized for the IPv4 side.) If it's not needed for
>> some reason, then it would be worth a comment in the commit
>> description to explain why not.
> Most certainly it is needed. I haven't seen reports for that in the
> wild and couldn't forge a repro triggering the bug in IPv4, but I'll
> give it another shot.

If you force syncookies to be used, with:

  sysctl -q net.ipv4.tcp_syncookies=2

then every passive IPv4 TCP connection that is accepted by a TCP
server app should be using that uninitialized memory, I would think
(and thus should be liable to fire the KMSAN use of uninitialized
memory warning).

Does that work?

neal
