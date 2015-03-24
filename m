From: "Zhu, Yanjun" <Yanjun.Zhu@windriver.com>
Subject: RE: [PATCH for kernel 3.4.x 1/1] net: neighbour: Add
 mcast_resolicit to configure the number of multicast resolicitations in
 PROBE state
Date: Tue, 24 Mar 2015 09:51:56 +0000
Message-ID: <E66F6C44A7A6EA49ABFC80EA526506DF6A474235@ALA-MBA.corp.ad.wrs.com>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>,<1427190355-1216-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "lizefan@huawei.com" <lizefan@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ulf.samuelsson@ericsson.com" <ulf.samuelsson@ericsson.com>,
	"hideaki.yoshifuji@miraclelinux.com"
	<hideaki.yoshifuji@miraclelinux.com>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"Dietsch, Alexandre" <Alexandre.Dietsch@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42261 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbbCXJwZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 05:52:25 -0400
In-Reply-To: <1427190355-1216-2-git-send-email-Yanjun.Zhu@windriver.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Ulf && YOSHIFUJI Hideaki

This patch is needed in linux kernel 3.4.106. I made a new patch based on linux kernel 3.4.106. Please let me know your advice.

Thanks a lot.
Zhu Yanjun

________________________________________
From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] on behalf of Zhu Yanjun [Yanjun.Zhu@windriver.com]
Sent: Tuesday, March 24, 2015 2:45 AM
To: lizefan@huawei.com; netdev@vger.kernel.org; ulf.samuelsson@ericsson.com; hideaki.yoshifuji@miraclelinux.com; yoshfuji@linux-ipv6.org; Dietsch, Alexandre
Subject: [PATCH for kernel 3.4.x 1/1] net: neighbour: Add mcast_resolicit to configure the number of multicast resolicitations in PROBE state

We send unicast neighbor (ARP or NDP) solicitations ucast_probes
times in PROBE state.  Zhu Yanjun reported that some implementation
does not reply against them and the entry will become FAILED, which
is undesirable.

We had been dealt with such nodes by sending multicast probes mcast_
solicit times after unicast probes in PROBE state.  In 2003, I made
a change not to send them to improve compatibility with IPv6 NDP.

Let's introduce per-protocol per-interface sysctl knob "mcast_
reprobe" to configure the number of multicast (re)solicitation for
reconfirmation in PROBE state.  The default is 0, since we have
been doing so for 10+ years.

Reported-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
CC: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
[Zhu Yanjun: since kernel 3.4.x is different from mainline kernel(kernel 4.0-rcX).
This patch is modified a lot.]
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
---
 include/linux/neighbour.h |  1 +
 include/net/neighbour.h   |  1 +
 net/core/neighbour.c      | 20 +++++++++++++++++---
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index b188f68..6945f4f 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -112,6 +112,7 @@ enum {
        NDTPA_APP_PROBES,               /* u32 */
        NDTPA_UCAST_PROBES,             /* u32 */
        NDTPA_MCAST_PROBES,             /* u32 */
+       NDTPA_MCAST_REPROBES,           /* u32 */
        NDTPA_ANYCAST_DELAY,            /* u64, msecs */
        NDTPA_PROXY_DELAY,              /* u64, msecs */
        NDTPA_PROXY_QLEN,               /* u32 */
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 34c996f..a2d9407 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -63,6 +63,7 @@ struct neigh_parms {
        int     ucast_probes;
        int     app_probes;
        int     mcast_probes;
+       int     mcast_reprobes;
        int     anycast_delay;
        int     proxy_delay;
        int     proxy_qlen;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ebd4b21..eb573cf 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -843,9 +843,9 @@ next_elt:
 static __inline__ int neigh_max_probes(struct neighbour *n)
 {
        struct neigh_parms *p = n->parms;
-       return (n->nud_state & NUD_PROBE) ?
-               p->ucast_probes :
-               p->ucast_probes + p->app_probes + p->mcast_probes;
+
+       return p->ucast_probes + p->app_probes +
+               (n->nud_state & NUD_PROBE) ? p->mcast_reprobes : p->mcast_probes;
 }

 static void neigh_invalidate(struct neighbour *neigh)
@@ -982,6 +982,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
                goto out_unlock_bh;

        if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
+               /* We are in (NUD_NONE | NUD_FAILED) */
                if (neigh->parms->mcast_probes + neigh->parms->app_probes) {
                        unsigned long next, now = jiffies;

@@ -1783,6 +1784,7 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
        NLA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
        NLA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
        NLA_PUT_U32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes);
+       NLA_PUT_U32(skb, NDTPA_MCAST_REPROBES, parms->mcast_reprobes);
        NLA_PUT_MSECS(skb, NDTPA_REACHABLE_TIME, parms->reachable_time);
        NLA_PUT_MSECS(skb, NDTPA_BASE_REACHABLE_TIME,
                      parms->base_reachable_time);
@@ -1932,6 +1934,7 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
        [NDTPA_APP_PROBES]              = { .type = NLA_U32 },
        [NDTPA_UCAST_PROBES]            = { .type = NLA_U32 },
        [NDTPA_MCAST_PROBES]            = { .type = NLA_U32 },
+       [NDTPA_MCAST_REPROBES]          = { .type = NLA_U32 },
        [NDTPA_BASE_REACHABLE_TIME]     = { .type = NLA_U64 },
        [NDTPA_GC_STALETIME]            = { .type = NLA_U64 },
        [NDTPA_DELAY_PROBE_TIME]        = { .type = NLA_U64 },
@@ -2023,6 +2026,9 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
                        case NDTPA_MCAST_PROBES:
                                p->mcast_probes = nla_get_u32(tbp[i]);
                                break;
+                       case NDTPA_MCAST_REPROBES:
+                               p->mcast_reprobes = nla_get_u32(tbp[i]);
+                               break;
                        case NDTPA_BASE_REACHABLE_TIME:
                                p->base_reachable_time = nla_get_msecs(tbp[i]);
                                break;
@@ -2773,6 +2779,7 @@ enum {
        NEIGH_VAR_MCAST_PROBE,
        NEIGH_VAR_UCAST_PROBE,
        NEIGH_VAR_APP_PROBE,
+       NEIGH_VAR_MCAST_REPROBE,
        NEIGH_VAR_RETRANS_TIME,
        NEIGH_VAR_BASE_REACHABLE_TIME,
        NEIGH_VAR_DELAY_PROBE_TIME,
@@ -2804,6 +2811,12 @@ static struct neigh_sysctl_table {
                        .mode           = 0644,
                        .proc_handler   = proc_dointvec,
                },
+               [NEIGH_VAR_MCAST_REPROBE] = {
+                       .procname       = "mcast_resolicit",
+                       .maxlen         = sizeof(int),
+                       .mode           = 0644,
+                       .proc_handler   = proc_dointvec,
+               },
                [NEIGH_VAR_UCAST_PROBE] = {
                        .procname       = "ucast_solicit",
                        .maxlen         = sizeof(int),
@@ -2940,6 +2953,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
                goto err;

        t->neigh_vars[NEIGH_VAR_MCAST_PROBE].data  = &p->mcast_probes;
+       t->neigh_vars[NEIGH_VAR_MCAST_REPROBE].data  = &p->mcast_reprobes;
        t->neigh_vars[NEIGH_VAR_UCAST_PROBE].data  = &p->ucast_probes;
        t->neigh_vars[NEIGH_VAR_APP_PROBE].data  = &p->app_probes;
        t->neigh_vars[NEIGH_VAR_RETRANS_TIME].data  = &p->retrans_time;
--
1.9.1
