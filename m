From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 12:03:35 -0400
Message-ID: <1309104215.5134.37.camel@mojatatu>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
	 <1309102334.5134.31.camel@mojatatu>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-r0uWZ58ILMRXlHNpH9VH"
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51929 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab1FZQDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 12:03:38 -0400
Received: by iwn6 with SMTP id 6so3524200iwn.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 09:03:38 -0700 (PDT)
In-Reply-To: <1309102334.5134.31.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-r0uWZ58ILMRXlHNpH9VH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit


Updated version of the patch with feedback from Ben and Eric.

cheers,
jamal


--=-r0uWZ58ILMRXlHNpH9VH
Content-Disposition: attachment; filename="pns-3"
Content-Type: text/plain; name="pns-3"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit e8d4d1ef0584b1a9e7e3890f298da7aad7b7d111
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Jun 26 11:51:04 2011 -0400

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
    
    3.0-rc4      (plain)
    cpu         Pkt run1        Pkt run2        Pkt run3
    ================================================
    cpu0        21853354        21598183        22199900
    cpu1          431058          473476          393159
    cpu2          481975          477529          458466
    cpu3        23261406        23412299        22894315
    avg         11506948        11490372        11486460
    
    3.0-rc4 with patch and default weight 64
    cpu Pkt run1        Pkt run2        Pkt run3
    ================================================
    cpu0        13205312        13109359        13132333
    cpu1        10189914        10159127        10122270
    cpu2        10213871        10124367        10168722
    cpu3        13165760        13164767        13096705
    avg         11693714        11639405        11630008
    
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
index b4c6809..64195d0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -190,14 +190,18 @@ static inline int qdisc_restart(struct Qdisc *q)
 void __qdisc_run(struct Qdisc *q)
 {
 	unsigned long start_time = jiffies;
+	int quota = weight_p;
+	int work = 0;
 
 	while (qdisc_restart(q)) {
+		work++;
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
+		if (work >= quota || need_resched()) {
 			__netif_schedule(q);
 			break;
 		}

--=-r0uWZ58ILMRXlHNpH9VH--

