From: jamal <hadi@cyberus.ca>
Subject: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 10:07:34 -0400
Message-ID: <1309097254.5134.24.camel@mojatatu>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YhK1Eoj96NAgec7cJoLl"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64883 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab1FZOHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 10:07:37 -0400
Received: by iyb12 with SMTP id 12so3456202iyb.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 07:07:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YhK1Eoj96NAgec7cJoLl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit


Got the 10G intel cards installed finally and repeated
the tests on both dummy and Ixgbe. The unfairness was much 
higher with 10G than with dummy. The logs contain the results.

I could send another patch with stats gathering. 
The best place seems to be in net/softnet_stat re-using
the fast route entries.

cheers,
jamal

--=-YhK1Eoj96NAgec7cJoLl
Content-Disposition: attachment; filename="pns-1"
Content-Type: text/plain; name="pns-1"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit e7fbab65da4db8d2ef1a61c915dfa8c96c2e0368
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Sun Jun 26 09:19:48 2011 -0400

    [PATCH] net_sched: fix dequeuer fairness
    
    Results on dummy device can be seen in my netconf 2011
    slides. These results are for a 10Gige IXGBE intel
    nic - on another i5 machine, very similar specs to
    the one used in the netconf2011 results.
    It turns out - this is a hell lot worse than dummy
    and so this patch is even more beneficial for 10G.
    
    Test setup:
    ----------
    
    System under test sending packets out.
    Additional box connected directly dropping packets.
    Installed prio qdisc on the eth device and default
    netdev default length of 1000 used as is.
    The 3 prio bands each were set to 100 (didnt factor in
    the results).
    
    5 packet runs were made and the middle 3 picked.
    
    results
    -------
    
    The "cpu" column indicates the which cpu the sample
    was taken on,
    The "Pkt runx" carries the number of packets a cpu
    dequeued when forced to be in the "dequeuer" role.
    The "avg" for each run is the number of times each
    cpu should be a "dequeuer" if the system was fair.
    
    3.0-rc4	 (plain)
    cpu	Pkt run1	Pkt run2	Pkt run3
    ================================================
    cpu0	21853354	21598183	22199900
    cpu1	  431058	  473476	  393159
    cpu2	  481975	  477529	  458466
    cpu3	23261406	23412299	22894315
    avg	11506948	11490372	11486460
    
    3.0-rc4 with patch and default weight 64
    cpu	Pkt run1	Pkt run2	Pkt run3
    ================================================
    cpu0	13205312	13109359	13132333
    cpu1	10189914	10159127	10122270
    cpu2	10213871	10124367	10168722
    cpu3	13165760	13164767	13096705
    avg	11693714	11639405	11630008
    
    As you can see the system is still not perfect but
    is a lot better than what it was before...
    
    At the moment we use the old backlog weight, weight_p
    which is 64 packets. It seems to be reasonably fine
    with that value.
    The system could be made more fair if we reduce the
    weight_p (as per my presentation), but we are going
    to affect the shared backlog weight. Unless deemed
    necessary, I think the default value is fine. If not
    we could add yet another knob.
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b4c6809..578269e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -190,14 +190,18 @@ static inline int qdisc_restart(struct Qdisc *q)
 void __qdisc_run(struct Qdisc *q)
 {
 	unsigned long start_time = jiffies;
+	int quota = 0;
+	int work = weight_p;
 
 	while (qdisc_restart(q)) {
+		quota++;
 		/*
-		 * Postpone processing if
-		 * 1. another process needs the CPU;
-		 * 2. we've been doing it for too long.
+		 * Ordered by possible occurrence: Postpone processing if
+		 * 1. we've exceeded packet quota
+		 * 2. another process needs the CPU;
+		 * 3. we've been doing it for too long.
 		 */
-		if (need_resched() || jiffies != start_time) {
+		if (quota >= work || need_resched() || jiffies != start_time) {
 			__netif_schedule(q);
 			break;
 		}

--=-YhK1Eoj96NAgec7cJoLl--

