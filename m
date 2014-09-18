From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 08:42:31 -0700
Message-ID: <1411054951.7106.272.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917152653.1c824a22@redhat.com>
	 <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5419A1E7.8040109@intel.com> <20140918085640.0815df6d@redhat.com>
	 <1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411047689.7106.258.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:56365 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504AbaIRPmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 11:42:33 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so633030pdi.2
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 08:42:33 -0700 (PDT)
In-Reply-To: <1411047689.7106.258.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 06:41 -0700, Eric Dumazet wrote:

> Last but not least, there is the fact that networking stacks use
> mod_timer() to arm timers, and that by default, timer migration is on 
> ( cf /proc/sys/kernel/timer_migration )
> 
> We probably should use mod_timer_pinned(), but I could not really see
> any difference.

Hmm... actually its quite noticeable :

# ./super_netperf 500 --google-pacing-rate 3000000 -H lpaa24 -l 1000 &
...
# echo 1 >/proc/sys/kernel/timer_migration
# vmstat 5
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0      0 261178336  15812 1001880    0    0     5     1  185  217  0  4 96  0
 0  0      0 261173456  15812 1001884    0    0     0     0 1548055 35472  0 15 85  0
 2  0      0 261174880  15812 1001888    0    0     0     0 1533309 35163  0 15 85  0
 3  0      0 261176768  15812 1001896    0    0     0     0 1533442 35694  0 15 85  0
 2  0      0 261173584  15812 1001912    0    0     0     3 1524024 35489  0 16 83  0
 3  0      0 261173344  15812 1001912    0    0     0     4 1525034 35392  0 15 85  0
 2  0      0 261175840  15812 1001920    0    0     0     0 1545652 35772  0 15 84  0
 3  0      0 261176800  15812 1001920    0    0     0     0 1513413 35703  0 15 85  0
 0  0      0 261175136  15812 1001920    0    0     0     2 1528775 35639  0 15 85  0
 1  0      0 261176480  15812 1001924    0    0     0     0 1510346 35364  0 15 85  0
 0  0      0 261174624  15812 1001924    0    0     0     0 1523893 35669  0 15 85  0
 0  0      0 261175568  15812 1001928    0    0     0     5 1524099 35605  0 15 85  0
 2  0      0 261175776  15812 1001932    0    0     0     5 1510481 35631  0 15 85  0
 2  0      0 261173776  15812 1001932    0    0     0     0 1528381 36127  0 15 84  0
 3  0      0 261175424  15812 1001932    0    0     0     0 1508722 35402  0 15 85  0
 1  0      0 261176048  15812 1001932    0    0     0     0 1495438 35280  0 15 85  0
^C
# echo 0 >/proc/sys/kernel/timer_migration
# vmstat 5
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0      0 261172784  15812 1001936    0    0     5     1  165  228  0  5 95  0
 1  0      0 261175776  15812 1001940    0    0     0     0 1187446 32238  0 12 88  0
 2  0      0 261172752  15812 1001940    0    0     0     3 1166697 32060  0 12 88  0
 1  0      0 261174528  15812 1001944    0    0     0     3 1156846 32048  0 12 88  0
 1  0      0 261172688  15812 1001944    0    0     0     0 1152953 32048  0 12 88  0
 0  0      0 261169888  15812 1001952    0    0     0     0 1143630 32710  0 12 88  0
 2  0      0 261159936  15812 1001748    0    0     0  1016 1153256 32616  0 12 88  0
 2  0      0 261162128  15812 1001936    0    0     0     0 1153065 32689  0 12 88  0
 1  0      0 261171984  15812 1001936    0    0     0     3 1164407 32041  0 12 88  0
 2  0      0 261169552  15812 1001936    0    0     0     5 1162068 31917  0 12 88  0

I am tempted to simply :

diff --git a/net/core/sock.c b/net/core/sock.c
index 9c3f823e76a9..868c6bcd7221 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2288,10 +2288,10 @@ void sk_send_sigurg(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_send_sigurg);
 
-void sk_reset_timer(struct sock *sk, struct timer_list* timer,
+void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 		    unsigned long expires)
 {
-	if (!mod_timer(timer, expires))
+	if (!mod_timer_pinned(timer, expires))
 		sock_hold(sk);
 }
 EXPORT_SYMBOL(sk_reset_timer);
