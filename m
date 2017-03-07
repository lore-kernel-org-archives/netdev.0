From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: BUG in unix_notinflight
Date: Tue, 7 Mar 2017 14:04:38 -0800
Message-ID: <CAM_iQpWQogVishsmVWckbcJpKKFfjKVDoDMH1MT1a24_M_5u-Q@mail.gmail.com>
References: <CACT4Y+b5_zcRVrq5yRmtkVUgnzOmq55upA_QCoLrkSDnT0cLHA@mail.gmail.com>
 <CACT4Y+bCvPdn3i-nuBCbPyHUuOjyh83KyLFzWR+8JDGqM0F2ww@mail.gmail.com>
 <CAM_iQpWePCJ3oyOf8xRdJ5CtPMR6UNvNKs7t=MabtL=obGoSxg@mail.gmail.com> <CACT4Y+Zkz7C5C2xokZ7kN7q26UD41PCR62_L=YX_DK2pyW1zKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Zkz7C5C2xokZ7kN7q26UD41PCR62_L=YX_DK2pyW1zKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 7, 2017 at 12:37 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, Mar 6, 2017 at 11:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> The problem here is there is no lock protecting concurrent unix_detach_fds()
>> even though unix_notinflight() is already serialized, if we call
>> unix_notinflight()
>> twice on the same file pointer, we trigger this bug...
>>
>> I don't know what is the right lock here to serialize it.
>
>
> What exactly here needs to be protected?
>
> 1484 static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
> 1485 {
> 1486         int i;
> 1487
> 1488         scm->fp = UNIXCB(skb).fp;
> 1489         UNIXCB(skb).fp = NULL;
> 1490
> 1491         for (i = scm->fp->count-1; i >= 0; i--)
> 1492                 unix_notinflight(scm->fp->user, scm->fp->fp[i]);
> 1493 }
>
> Whole unix_notinflight happens under global unix_gc_lock.
>
> Is it that 2 threads call unix_detach_fds for the same skb, and then
> call unix_notinflight for the same fd twice?

Not the same skb, but their UNIXCB(skb).fp points to the same place,
therefore we call unix_notinflight() twice on the same fp->user and
fp->fp[i], although we have refcounting but still able to trigger this
warning.
