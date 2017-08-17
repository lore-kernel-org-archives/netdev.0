From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] neigh: initialize neigh entry correctly during arp processing
Date: Wed, 16 Aug 2017 17:02:51 -0700
Message-ID: <20170817000251.38469-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Reshetova Elena <elena.reshetova@intel.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Florian Westphal <fw@strlen.de>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Ihar Hrachyshka <ihrachys@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36539 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdHQAC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:02:59 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so6925078pgy.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 17:02:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

If the ARP processing creates a neigh entry, it's immediately marked
as STALE without timer and stays that way in that state as long as
host do not send traffic to that neighbour.

I observed this on hosts which are in IPv6 environment, where there is
very little to no IPv4 traffic and neigh-entries are stuck in STALE
mode. Ideally, the host should have PROBEd these neighbours before it
can send the first packet out.

It happens as a result of following call sequence in an environment
where host is mostly quiet as far as IPv4 traffic but few connected
hosts/gateways are sending ARPs.

   arp_process()
     neigh_event_ns()
       neigh_lookup()
         neigh_create()
           neigh_alloc()
             nud_state=NUD_NONE
     neigh_update(nud_state=NUD_STALE)

In the above scenario, the neighbour entry does not get a chance to get
PROBEd as subsequent call to neigh_update() marks  this entry STALE.
This patch initializes the neigh-entry correctly if it was created as a
result of neigh_lookup instead of just updating it in neigh_event_ns()
right after creating it.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/core/neighbour.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 16a1a4c4eb57..d8a35db6c43b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1300,9 +1300,13 @@ struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 {
 	struct neighbour *neigh = __neigh_lookup(tbl, saddr, dev,
 						 lladdr || !dev->addr_len);
-	if (neigh)
-		neigh_update(neigh, lladdr, NUD_STALE,
-			     NEIGH_UPDATE_F_OVERRIDE, 0);
+	if (neigh) {
+		if (neigh->nud_state & NUD_VALID)
+			neigh_update(neigh, lladdr, NUD_STALE,
+				     NEIGH_UPDATE_F_OVERRIDE, 0);
+		else
+			neigh_event_send(neigh, NULL);
+	}
 	return neigh;
 }
 EXPORT_SYMBOL(neigh_event_ns);
-- 
2.14.1.480.gb18f417b89-goog
