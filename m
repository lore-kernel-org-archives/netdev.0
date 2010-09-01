From: Dan Kruchinin <dkruchinin@acm.org>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Wed, 1 Sep 2010 15:29:25 +0400
Message-ID: <20100901152925.05374fd1@leibniz>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com>
	<20100831210101.3c059a91@leibniz>
	<4C7D5EBD.103@gmail.com>
	<AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com>
	<20100831214808.GA32141@ms2.inr.ac.ru>
	<20100831223402.GA7101@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f66.google.com ([74.125.82.66]:33298 "EHLO
	mail-ww0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab0IAL3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 07:29:32 -0400
Received: by wwb31 with SMTP id 31so1986646wwb.1
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 04:29:31 -0700 (PDT)
In-Reply-To: <20100831223402.GA7101@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Alexey.

On Wed, 1 Sep 2010 02:34:02 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> Hmm. Seems, you are right and I was wrong all these years.
> Somehow, I did wrong calculation once and this rustied to the brains.
> After some thinking the calulation is obviously wrong: no matter what,
> in steady state tbf queue is processed with rate R. What a stupid mistake... :-)
> 
> Please, also think how to fix the second part of calculation which deals
> with peak rate. IMHO (for now :-)) it does not even contribute to latency
> and should be deleted.

I absolutely agree about latency option. As I understood from http://www.docum.org/docum.org/docs/other/tbf02_kw.ps
latency should affect only limit. It has not any sense in context of peakrate. So I think that limit calculation
by latency _and_ peakrate should be removed from tc code because limit is clearly determined by latency and rate.
So here is a patch that(I hope) fixes it(please correct me if I'm wrong):

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index dc556fe..643c1e0 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -178,12 +178,10 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
        }
 
        if (opt.limit == 0) {
-               double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
-               if (opt.peakrate.rate) {
-                       double lim2 = opt.peakrate.rate*(double)latency/TIME_UNITS_PER_SEC + mtu;
-                       if (lim2 < lim)
-                               lim = lim2;
-               }
+               double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC;
+               if (opt.peakrate.rate && (lim < mtu))
+                       lim = mtu;
+
                opt.limit = lim;
        }
 
@@ -263,12 +261,7 @@ static int tbf_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
        if (show_raw)
                fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));
 
-       latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate) - tc_core_tick2time(qopt->buffer);
-       if (qopt->peakrate.rate) {
-               double lat2 = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->peakrate.rate) - tc_core_tick2time(qopt->mtu);
-               if (lat2 > latency)
-                       latency = lat2;
-       }
+       latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate);
        fprintf(f, "lat %s ", sprint_time(latency, b1));
 
        if (qopt->rate.overhead) {

> 
> To Jarek: about the scripts. I do not think something will be broken
> by fixing this error. Eventually, if someone used "latency", he meant
> something about real latency. And even if the value was generated
> using the same wrong logic as tc did, using correct formula would just
> increase limit setting.
> 
> Alexey



-- 
W.B.R.
Dan Kruchinin
