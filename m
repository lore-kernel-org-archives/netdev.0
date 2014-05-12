From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] fq: don't allow set options to zero
Date: Mon, 12 May 2014 08:23:45 -0700
Message-ID: <1399908225.7973.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>
	 <1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5370713F.7040701@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:64355 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758554AbaELPXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 11:23:48 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so8711885pad.16
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 08:23:47 -0700 (PDT)
In-Reply-To: <5370713F.7040701@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-12 at 14:59 +0800, Yang Yingliang wrote:
> On 2014/5/12 13:58, Eric Dumazet wrote:
> > On Mon, 2014-05-12 at 12:18 +0800, Yang Yingliang wrote:
> >> Now options of fair queue can be zero but cannot be (~0U).
> >> Zero is useless, so don't allow set the options to zero.
> >> Also, maxrate cannot be reset to unlimited because it
> >> cannot be (~0U).
> >>
> >> Cc: Eric Dumazet <edumazet@google.com>
> >> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> >> ---
> >>  tc/q_fq.c | 24 ++++++++++++------------
> >>  1 file changed, 12 insertions(+), 12 deletions(-)
> > 
> > No, you are changing behavior for existing scripts.
> > 
> > If you really want to fix these cases, you need to do it properly.
> > 
> Do you mean options cannot be zero changing the behavior ?

I mean that you need to do something like the following.

diff --git a/tc/q_fq.c b/tc/q_fq.c
index c1f658e..26ecac3 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -76,7 +76,8 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	unsigned int quantum = ~0U;
 	unsigned int initial_quantum = ~0U;
 	unsigned int buckets = 0;
-	unsigned int maxrate = ~0U;
+	unsigned int maxrate;
+	int set_maxrate = 0;
 	unsigned int defrate = ~0U;
 	int pacing = -1;
 	struct rtattr *tail;
@@ -106,6 +107,7 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				fprintf(stderr, "Illegal \"maxrate\"\n");
 				return -1;
 			}
+			set_maxrate = 1;
 		} else if (strcmp(*argv, "defrate") == 0) {
 			NEXT_ARG();
 			if (get_rate(&defrate, *argv)) {
@@ -161,7 +163,7 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	if (pacing != -1)
 		addattr_l(n, 1024, TCA_FQ_RATE_ENABLE,
 			  &pacing, sizeof(pacing));
-	if (maxrate != ~0U)
+	if (set_maxrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_MAX_RATE,
 			  &maxrate, sizeof(maxrate));
 	if (defrate != ~0U)
