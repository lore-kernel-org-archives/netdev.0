From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 16:10:37 -0700
Message-ID: <1473721837.18970.95.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
         <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
         <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
         <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
         <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34769 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbcILXKj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:10:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id g202so8711545pfb.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:10:39 -0700 (PDT)
In-Reply-To: <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 19:02 -0400, Jamal Hadi Salim wrote:
> On 16-09-12 06:26 PM, Eric Dumazet wrote:
> > On Mon, 2016-09-12 at 18:14 -0400, Jamal Hadi Salim wrote:
> >
> >> I noticed some very weird issues when I took that out.
> >> Running sufficiently large amount of traffic (ping -f is sufficient)
> >> I saw that when i did a dump it took anywhere between 6-15 seconds.
> >> With the read_lock in place response was immediate.
> >> I can go back and run things to verify - but it was very odd.
> >
> > This was on uni processor ?
> >
> 
> It was a VM.
> 
> > Looks like typical starvation caused by aggressive softirq.
> >
> 
> Well, then it is strange that in one case a tc dump of the rule
> was immediate and in the other case it was consistent for 5-15
> seconds.
> 

This needs investigation ;)

One possible loop under high stress would be possible in
__gnet_stats_copy_basic(), since we might restart the loop if we are
really really unlucky, but this would have nothing with your patches.



diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 508e051304fb62627e61b5065b2325edd1b84f2e..dc9dd8ae7d5405f76c775278dac7689655b21041 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -142,10 +142,14 @@ __gnet_stats_copy_basic(const seqcount_t *running,
 		return;
 	}
 	do {
-		if (running)
+		if (running) {
+			local_bh_disable();
 			seq = read_seqcount_begin(running);
+		}
 		bstats->bytes = b->bytes;
 		bstats->packets = b->packets;
+		if (running)
+			local_bh_enable();
 	} while (running && read_seqcount_retry(running, seq));
 }
 EXPORT_SYMBOL(__gnet_stats_copy_basic);
