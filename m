From: Simon Kirby <sim@hostway.ca>
Subject: test
Date: Wed, 4 Nov 2009 12:27:16 -0800
Message-ID: <20091104202716.GE14821@hostway.ca>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oC1+HKm2/end4ao3"
To: netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:38107 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751361AbZKDU1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 15:27:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oC1+HKm2/end4ao3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello!

I was noticing a significant amount of what seems/seemed to be
destination lists with multiple entries with the lblcr LVS algorithm. 
While tracking it down, I think I stumbled over a mistake.  In
ip_vs_lblcr_full_check(), it appears the time check logic is reversed:

        for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
                j = (j + 1) & IP_VS_LBLCR_TAB_MASK;

                write_lock(&svc->sched_lock);
                list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
                        if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
                                       now))
                                continue;
                        
                        ip_vs_lblcr_free(en);
                        atomic_dec(&tbl->entries);
                }
                write_unlock(&svc->sched_lock);
        }

Shouldn't this be "time_before"?  It seems that it currently nukes all
recently-used entries every time this function is called, which seems to
be every 30 minutes, rather than removing the not-recently-used ones.

If my reading is correct, this patch should fix it.  Am I missing
something?

Cheers,

Simon-

--oC1+HKm2/end4ao3
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="lblcr+full_check_time_fix.patch"

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 715b57f..937743f 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -432,7 +432,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 
 		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
+			if (time_before(en->lastuse+sysctl_ip_vs_lblcr_expiration,
 				       now))
 				continue;
 

--oC1+HKm2/end4ao3--
