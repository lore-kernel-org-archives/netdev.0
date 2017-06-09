From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: igmp: fix a use after free
Date: Fri, 9 Jun 2017 14:35:32 -0700
Message-ID: <CAM_iQpUUYR0h7HxrBYXum-3Tij9i7VNzrv5c+jbqAajQuxf6xQ@mail.gmail.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
 <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com>
 <1496954011.736.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVu+sF4zGhGCYDV6J-+rN69zuMGGvGJpLajhYS-QfdUfQ@mail.gmail.com>
 <CADvbK_cv+yfZpa7y1+5a9mntTbkTmEu6YyR7pbHGAtH+5+RLRA@mail.gmail.com>
 <1497023774.736.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVcLiE3ru1ukq9CCTvTN_+-77XapOWT=1EgF0DgB224-w@mail.gmail.com> <CADvbK_fbxdkZUdJK=qUx+neTNfiOUJrm3-AvBa2+a4eB1b+PWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35233 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdFIVfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 17:35:54 -0400
Received: by mail-wr0-f194.google.com with SMTP id g76so9265176wrd.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 14:35:53 -0700 (PDT)
In-Reply-To: <CADvbK_fbxdkZUdJK=qUx+neTNfiOUJrm3-AvBa2+a4eB1b+PWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 11:05 AM, Xin Long <lucien.xin@gmail.com> wrote:
> On Sat, Jun 10, 2017 at 1:01 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> This is what I thought in my first response, until I realized
>> it is not pure RCU, otherwise pmc->lock should not be taken
>> in igmpv3_send_cr(). It seems the code is mixing the use
>> of spinlock and RCU.
> rcu lock is for pmc not being freed, and spinlock is for pmc's
> members' modification. is there some rule these two locks
> should be mixed?
>

This is exactly why I said we are mixing RCU and spinlock.

>
>>
>> We need RCU anyway, ip_check_mc_rcu() is the real fast
>> path where we don't take spinlock. I think we will need more
>> work.
> It seems all add_grec() callings needs spinlock, maybe  add_grec
> modifies pmc's member. it's hard to drop spinlock.
>
> from ip_check_mc_rcu you mentioned about, it should be right
> to call ip_mc_clear_src after rcu grace period, like Eric's patch.

Well, more than just that, we need to use proper RCU API for
pmc->sources and you know it is a singly linked list...

I will work on this.
