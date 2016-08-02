From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net-next] net/multicast: should not send source list records when have filter mode change
Date: Tue,  2 Aug 2016 18:02:57 +0800
Message-ID: <1470132177-22984-1-git-send-email-liuhangbin@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34188 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbcHBKDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 06:03:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so12197826pfb.1
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 03:03:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on RFC3376 5.1 and RFC3810 6.1

   If the per-interface listening change that triggers the new report is
   a filter mode change, then the next [Robustness Variable] State
   Change Reports will include a Filter Mode Change Record.  This
   applies even if any number of source list changes occur in that
   period.

   Old State         New State         State Change Record Sent
   ---------         ---------         ------------------------
   INCLUDE (A)       EXCLUDE (B)       TO_EX (B)
   EXCLUDE (A)       INCLUDE (B)       TO_IN (B)

So we should not send source-list change if there is a filter-mode change.

Here are two scenarios:
1. Group deleted and filter mode is EXCLUDE, which means we need send a
   TO_IN { }.
2. Not group deleted, but has pcm->crcount, which means we need send a
   normal filter-mode-change.

At the same time, if the type is ALLOW or BLOCK, and have psf->sf_crcount,
we stop add records and decrease sf_crcount directly

Reference: https://www.ietf.org/mail-archive/web/magma/current/msg01274.html

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/igmp.c  | 10 ++++++++++
 net/ipv6/mcast.c | 10 ++++++++++
 2 files changed, 20 insertions(+)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 9b4ca87..606cc3e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -472,6 +472,15 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 			continue;
 		}
 
+		/* Based on RFC3376 5.1. Should not send source-list change
+		 * records when there is a filter mode change.
+		 */
+		if (((gdeleted && pmc->sfmode == MCAST_EXCLUDE) ||
+		     (!gdeleted && pmc->crcount)) &&
+		    (type == IGMPV3_ALLOW_NEW_SOURCES ||
+		     type == IGMPV3_BLOCK_OLD_SOURCES) && psf->sf_crcount)
+			goto decrease_sf_crcount;
+
 		/* clear marks on query responses */
 		if (isquery)
 			psf->sf_gsresp = 0;
@@ -499,6 +508,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ip_mc_list *pmc,
 		scount++; stotal++;
 		if ((type == IGMPV3_ALLOW_NEW_SOURCES ||
 		     type == IGMPV3_BLOCK_OLD_SOURCES) && psf->sf_crcount) {
+decrease_sf_crcount:
 			psf->sf_crcount--;
 			if ((sdeleted || gdeleted) && psf->sf_crcount == 0) {
 				if (psf_prev)
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d64ee7e..75c1fc5 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1739,6 +1739,15 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 			continue;
 		}
 
+		/* Based on RFC3810 6.1. Should not send source-list change
+		 * records when there is a filter mode change.
+		 */
+		if (((gdeleted && pmc->mca_sfmode == MCAST_EXCLUDE) ||
+		     (!gdeleted && pmc->mca_crcount)) &&
+		    (type == MLD2_ALLOW_NEW_SOURCES ||
+		     type == MLD2_BLOCK_OLD_SOURCES) && psf->sf_crcount)
+			goto decrease_sf_crcount;
+
 		/* clear marks on query responses */
 		if (isquery)
 			psf->sf_gsresp = 0;
@@ -1766,6 +1775,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 		scount++; stotal++;
 		if ((type == MLD2_ALLOW_NEW_SOURCES ||
 		     type == MLD2_BLOCK_OLD_SOURCES) && psf->sf_crcount) {
+decrease_sf_crcount:
 			psf->sf_crcount--;
 			if ((sdeleted || gdeleted) && psf->sf_crcount == 0) {
 				if (psf_prev)
-- 
2.5.5
