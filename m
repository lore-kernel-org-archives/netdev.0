From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/ipv4: use-after-free in add_grec
Date: Wed, 31 May 2017 17:13:42 -0700
Message-ID: <1496276022.27480.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
         <1496247154.27480.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUM+vhYXkA=ZaEg7O-hEHROPxPorS-T9nQwL6H9CLtMpA@mail.gmail.com>
         <CANn89iKC1ACPNfazjYF_jDr_Ojz6ROn3Ny_m0SHK5G+MZctDmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
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
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKC1ACPNfazjYF_jDr_Ojz6ROn3Ny_m0SHK5G+MZctDmQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-31 at 16:55 -0700, Eric Dumazet wrote:

> The issue here is the timer firing while ip_mc_clear_src() has been
> already called.
> 
> My patch should fix the problem.
> 
> Or another one using del_timer_sync() instead of del_timer() in
> igmp_stop_timer(), but such a change would be more invasive,
> since the del_timer_sync() would need to happen while im->lock
> spinlock is not held.

BTW, I guess that Andrey could try to add a delay to trigger the bug
more often.

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 44fd86de2823dd17de16276a8ec01b190e69b8b4..84fff17daab0832c470a613b29b2aaade07cec0a 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -798,7 +798,7 @@ static void igmp_timer_expire(unsigned long data)
 	}
 	im->reporter = 1;
 	spin_unlock(&im->lock);
-
+	udelay(10000);
 	if (IGMP_V1_SEEN(in_dev))
 		igmp_send_report(in_dev, im, IGMP_HOST_MEMBERSHIP_REPORT);
 	else if (IGMP_V2_SEEN(in_dev))
