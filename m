From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb:
 improved accuracy at high rates)
Date: Sun, 02 Jun 2013 14:15:55 -0700
Message-ID: <1370207755.24311.81.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41931 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498Ab3FBVP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 17:15:58 -0400
Received: by mail-pd0-f174.google.com with SMTP id 3so4690749pdj.5
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 14:15:58 -0700 (PDT)
In-Reply-To: <20130529151330.22c5c89e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-29 at 15:13 +0200, Jesper Dangaard Brouer wrote:
> I recently discovered that the (traffic control) tc linklayer
> calculations for ATM/ADSL have been broken by:
>  commit 56b765b79 (htb: improved accuracy at high rates).
> 
> Thus, people shaping on ADSL links, using e.g.:
>  tc class add ... htb rate X ceil Y linklayer atm overhead 10
> 

It seems the "overhead 10" was never reported back by 
"tc -s class show dev ... "

Also, the "linklayer atm" changes the data[] part, and this one is not
matched in qdisc_get_rtab()

So two different rate specifications, but sharing same struct
tc_ratespec could be shared... Oh well.

It seems following fix would be needed anyway ?

[PATCH] net_sched: qdisc_get_rtab() must check data[] array

qdisc_get_rtab() should check not only the keys in struct tc_ratespec,
but also the full data[] array.

"tc ... linklayer atm " only perturbs values in the 256 slots array.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_api.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2b935e7..281c1bd 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -291,17 +291,18 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct nlattr *ta
 {
 	struct qdisc_rate_table *rtab;
 
+	if (tab == NULL || r->rate == 0 || r->cell_log == 0 ||
+	    nla_len(tab) != TC_RTAB_SIZE)
+		return NULL;
+
 	for (rtab = qdisc_rtab_list; rtab; rtab = rtab->next) {
-		if (memcmp(&rtab->rate, r, sizeof(struct tc_ratespec)) == 0) {
+		if (!memcmp(&rtab->rate, r, sizeof(struct tc_ratespec)) &&
+		    !memcmp(&rtab->data, nla_data(tab), 1024)) {
 			rtab->refcnt++;
 			return rtab;
 		}
 	}
 
-	if (tab == NULL || r->rate == 0 || r->cell_log == 0 ||
-	    nla_len(tab) != TC_RTAB_SIZE)
-		return NULL;
-
 	rtab = kmalloc(sizeof(*rtab), GFP_KERNEL);
 	if (rtab) {
 		rtab->rate = *r;
