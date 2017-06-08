From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: igmp: fix a use after free
Date: Thu, 08 Jun 2017 13:33:31 -0700
Message-ID: <1496954011.736.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
         <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
         <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34282 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdFHUde (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:33:34 -0400
Received: by mail-pf0-f194.google.com with SMTP id u1so6319835pfg.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 13:33:34 -0700 (PDT)
In-Reply-To: <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-09 at 02:22 +0800, Xin Long wrote:
> On Thu, Jun 8, 2017 at 9:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Andrey reported a use-after-free in add_grec(), courtesy of syzkaller.
> >
> > Problem here is that igmp_stop_timer() uses a del_timer(), so we can not
> > guarantee that another cpu is not servicing the timer.
> >
> > Therefore, if igmp_group_dropped() call from ip_mc_dec_group() is
> > immediately followed by ip_mc_clear_src(), ip_mc_clear_src() might free
> > memory that could be used by the other cpu servicing the timer.
> >
> > To fix this issue, we should defer the memory freeing
> > (ip_mc_clear_src()) to the point all references to (struct
> > ip_mc_list)->refcnt have been released.
> > This happens in ip_ma_put()
> >
> >
> > ==================================================================
> > BUG: KASAN: use-after-free in add_grec+0x101e/0x1090 net/ipv4/igmp.c:473
> > Read of size 8 at addr ffff88003053c1a0 by task swapper/0/0
> >
> > CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.12.0-rc3+ #370
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> > Call Trace:
> >  <IRQ>
> >  __dump_stack lib/dump_stack.c:16 [inline]
> >  dump_stack+0x292/0x395 lib/dump_stack.c:52
> >  print_address_description+0x73/0x280 mm/kasan/report.c:252
> >  kasan_report_error mm/kasan/report.c:351 [inline]
> >  kasan_report+0x22b/0x340 mm/kasan/report.c:408
> >  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:429
> >  add_grec+0x101e/0x1090 net/ipv4/igmp.c:473
> >  igmpv3_send_cr net/ipv4/igmp.c:663 [inline]
> >  igmp_ifc_timer_expire+0x46d/0xa80 net/ipv4/igmp.c:768
> the call trace is igmp_ifc_timer_expire -> igmpv3_send_cr -> add_grec
> and the timer should be in_dev->mr_ifc_timer.
> but igmp_stop_timer you mentioned is used to stop im->timer
> 
> It's possible that ip_mc_clear_src is done in ip_ma_put()
> while igmp_ifc_timer_expire is still using ip_mc_list under
> rcu_read_lock(). no ?

You might be right. I looked at the freeing side 

>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  ip_mc_clear_src+0x69/0x1c0 net/ipv4/igmp.c:2078
>  ip_mc_dec_group+0x19a/0x470 net/ipv4/igmp.c:1618
>  ip_mc_drop_socket+0x145/0x230 net/ipv4/igmp.c:2609
>  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:411
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1072

Then I tried to catch a problem happening on another cpu, and found one.

I mentioned (in https://lkml.org/lkml/2017/5/31/619 ) that we might need
to defer freeing after rcu grace period but for some reason decided it
was not needed.

What about :

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 44fd86de2823dd17de16276a8ec01b190e69b8b4..80932880af861046849d7dbac5f5aa0a1117f166 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -171,12 +171,20 @@ static void ip_mc_clear_src(struct ip_mc_list *pmc);
 static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 			 int sfcount, __be32 *psfsrc, int delta);
 
+
+static void ip_mc_list_reclaim(struct rcu_head *head)
+{
+	struct ip_mc_list *im = container_of(head, struct ip_mc_list, rcu);
+
+	ip_mc_clear_src(im);
+	in_dev_put(im->interface);
+	kfree(im);
+}
+
 static void ip_ma_put(struct ip_mc_list *im)
 {
-	if (atomic_dec_and_test(&im->refcnt)) {
-		in_dev_put(im->interface);
-		kfree_rcu(im, rcu);
-	}
+	if (atomic_dec_and_test(&im->refcnt))
+		call_rcu(&im->rcu, ip_mc_list_reclaim);
 }
 
 #define for_each_pmc_rcu(in_dev, pmc)				\
@@ -1615,7 +1623,6 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 				*ip = i->next_rcu;
 				in_dev->mc_count--;
 				igmp_group_dropped(i);
-				ip_mc_clear_src(i);
 
 				if (!in_dev->dead)
 					ip_rt_multicast_event(in_dev);
