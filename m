From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH 2/2] Remove /proc/net/ip_vs_lblcr
Date: Tue, 30 Oct 2007 16:12:57 +0300
Message-ID: <20071030131257.GB6210@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:6768 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682AbXJ3NNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 09:13:00 -0400
Received: from sw.ru ([192.168.0.16])
	by relay.sw.ru (8.13.4/8.13.4) with SMTP id l9UDCvfM019544
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 16:12:58 +0300 (MSK)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's under CONFIG_IP_VS_LBLCR_DEBUG option which never existed.

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 I can convert it to seq_file if anyone is secretly using it.

 net/ipv4/ipvs/ip_vs_lblcr.c |   76 --------------------------------------------
 1 file changed, 76 deletions(-)

--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -48,8 +48,6 @@
 /* for sysctl */
 #include <linux/fs.h>
 #include <linux/sysctl.h>
-/* for proc_net_create/proc_net_remove */
-#include <linux/proc_fs.h>
 #include <net/net_namespace.h>
 
 #include <net/ip_vs.h>
@@ -547,71 +545,6 @@ static void ip_vs_lblcr_check_expire(unsigned long data)
 	mod_timer(&tbl->periodic_timer, jiffies+CHECK_EXPIRE_INTERVAL);
 }
 
-
-#ifdef CONFIG_IP_VS_LBLCR_DEBUG
-static struct ip_vs_lblcr_table *lblcr_table_list;
-
-/*
- *	/proc/net/ip_vs_lblcr to display the mappings of
- *                  destination IP address <==> its serverSet
- */
-static int
-ip_vs_lblcr_getinfo(char *buffer, char **start, off_t offset, int length)
-{
-	off_t pos=0, begin;
-	int len=0, size;
-	struct ip_vs_lblcr_table *tbl;
-	unsigned long now = jiffies;
-	int i;
-	struct ip_vs_lblcr_entry *en;
-
-	tbl = lblcr_table_list;
-
-	size = sprintf(buffer, "LastTime Dest IP address  Server set\n");
-	pos += size;
-	len += size;
-
-	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
-		read_lock_bh(&tbl->lock);
-		list_for_each_entry(en, &tbl->bucket[i], list) {
-			char tbuf[16];
-			struct ip_vs_dest_list *d;
-
-			sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(en->addr));
-			size = sprintf(buffer+len, "%8lu %-16s ",
-				       now-en->lastuse, tbuf);
-
-			read_lock(&en->set.lock);
-			for (d=en->set.list; d!=NULL; d=d->next) {
-				size += sprintf(buffer+len+size,
-						"%u.%u.%u.%u ",
-						NIPQUAD(d->dest->addr));
-			}
-			read_unlock(&en->set.lock);
-			size += sprintf(buffer+len+size, "\n");
-			len += size;
-			pos += size;
-			if (pos <= offset)
-				len=0;
-			if (pos >= offset+length) {
-				read_unlock_bh(&tbl->lock);
-				goto done;
-			}
-		}
-		read_unlock_bh(&tbl->lock);
-	}
-
-  done:
-	begin = len - (pos - offset);
-	*start = buffer + begin;
-	len -= begin;
-	if(len>length)
-		len = length;
-	return len;
-}
-#endif
-
-
 static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 {
 	int i;
@@ -650,9 +583,6 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	tbl->periodic_timer.expires = jiffies+CHECK_EXPIRE_INTERVAL;
 	add_timer(&tbl->periodic_timer);
 
-#ifdef CONFIG_IP_VS_LBLCR_DEBUG
-	lblcr_table_list = tbl;
-#endif
 	return 0;
 }
 
@@ -843,18 +773,12 @@ static int __init ip_vs_lblcr_init(void)
 {
 	INIT_LIST_HEAD(&ip_vs_lblcr_scheduler.n_list);
 	sysctl_header = register_sysctl_table(lblcr_root_table);
-#ifdef CONFIG_IP_VS_LBLCR_DEBUG
-	proc_net_create(&init_net, "ip_vs_lblcr", 0, ip_vs_lblcr_getinfo);
-#endif
 	return register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 }
 
 
 static void __exit ip_vs_lblcr_cleanup(void)
 {
-#ifdef CONFIG_IP_VS_LBLCR_DEBUG
-	proc_net_remove(&init_net, "ip_vs_lblcr");
-#endif
 	unregister_sysctl_table(sysctl_header);
 	unregister_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 }

