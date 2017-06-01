From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv4: use-after-free in add_grec
Date: Thu, 1 Jun 2017 14:01:17 +0200
Message-ID: <CAAeHK+yxSkYQ9n31umnHorecHYsuFovyOww9ByT8FgoGJOM+tw@mail.gmail.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
 <1496247154.27480.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUM+vhYXkA=ZaEg7O-hEHROPxPorS-T9nQwL6H9CLtMpA@mail.gmail.com>
 <CANn89iKC1ACPNfazjYF_jDr_Ojz6ROn3Ny_m0SHK5G+MZctDmQ@mail.gmail.com> <1496276022.27480.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f172.google.com ([209.85.213.172]:36144 "EHLO
        mail-yb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdFAMBT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 08:01:19 -0400
Received: by mail-yb0-f172.google.com with SMTP id 130so10228541ybl.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 05:01:18 -0700 (PDT)
In-Reply-To: <1496276022.27480.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 2:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-05-31 at 16:55 -0700, Eric Dumazet wrote:
>
>> The issue here is the timer firing while ip_mc_clear_src() has been
>> already called.
>>
>> My patch should fix the problem.
>>
>> Or another one using del_timer_sync() instead of del_timer() in
>> igmp_stop_timer(), but such a change would be more invasive,
>> since the del_timer_sync() would need to happen while im->lock
>> spinlock is not held.
>
> BTW, I guess that Andrey could try to add a delay to trigger the bug
> more often.

Applied, now testing with your patch.

Thanks!

>
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 44fd86de2823dd17de16276a8ec01b190e69b8b4..84fff17daab0832c470a613b29b2aaade07cec0a 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -798,7 +798,7 @@ static void igmp_timer_expire(unsigned long data)
>         }
>         im->reporter = 1;
>         spin_unlock(&im->lock);
> -
> +       udelay(10000);
>         if (IGMP_V1_SEEN(in_dev))
>                 igmp_send_report(in_dev, im, IGMP_HOST_MEMBERSHIP_REPORT);
>         else if (IGMP_V2_SEEN(in_dev))
>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
