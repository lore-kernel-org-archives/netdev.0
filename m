From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/8][ATM]: [lec] indent, comment and whitespace cleanup [continued]
Date: Fri, 29 Sep 2006 12:38:23 -0400
Message-ID: <200609291638.k8TGcNY7025509@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:51932 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161202AbWI2Qjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:39:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] indent, comment and whitespace cleanup [continued]

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 55300d040155e883eb8d3dd39d381c95080719e6
tree 6b38906d8d9f3ec0313defc0ac7268afb1c72bbd
parent e2ba85c2acb966a41127dbb72c37f91e82a0725a
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:18:21 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:18:21 -0400

 net/atm/lec.c | 1783 +++++++++++++++++++++++++++++----------------------------
 1 files changed, 899 insertions(+), 884 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index c981dbf..13aeacf 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1418,7 +1418,6 @@ #endif
  *
  * lec_arpc.c was added here when making
  * lane client modular. October 1997
- *
  */
 
 #include <linux/types.h>
@@ -1429,7 +1428,6 @@ #include <asm/atomic.h>
 #include <linux/inetdevice.h>
 #include <net/route.h>
 
-
 #if 0
 #define DPRINTK(format,args...)
 /*
@@ -1452,296 +1450,294 @@ #define HASH(ch) (ch & (LEC_ARP_TABLE_SI
 /*
  * Initialization of arp-cache
  */
-static void 
-lec_arp_init(struct lec_priv *priv)
+static void lec_arp_init(struct lec_priv *priv)
 {
-        unsigned short i;
+	unsigned short i;
 
-        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-                priv->lec_arp_tables[i] = NULL;
-        }        
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		priv->lec_arp_tables[i] = NULL;
+	}
 	spin_lock_init(&priv->lec_arp_lock);
-        init_timer(&priv->lec_arp_timer);
-        priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
-        priv->lec_arp_timer.data = (unsigned long)priv;
-        priv->lec_arp_timer.function = lec_arp_check_expire;
-        add_timer(&priv->lec_arp_timer);
+	init_timer(&priv->lec_arp_timer);
+	priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
+	priv->lec_arp_timer.data = (unsigned long)priv;
+	priv->lec_arp_timer.function = lec_arp_check_expire;
+	add_timer(&priv->lec_arp_timer);
 }
 
-static void
-lec_arp_clear_vccs(struct lec_arp_table *entry)
+static void lec_arp_clear_vccs(struct lec_arp_table *entry)
 {
-        if (entry->vcc) {
+	if (entry->vcc) {
 		struct atm_vcc *vcc = entry->vcc;
 		struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
-		struct net_device *dev = (struct net_device*) vcc->proto_data;
+		struct net_device *dev = (struct net_device *)vcc->proto_data;
 
-                vcc->pop = vpriv->old_pop;
+		vcc->pop = vpriv->old_pop;
 		if (vpriv->xoff)
 			netif_wake_queue(dev);
 		kfree(vpriv);
 		vcc->user_back = NULL;
-                vcc->push = entry->old_push;
+		vcc->push = entry->old_push;
 		vcc_release_async(vcc, -EPIPE);
-                vcc = NULL;
-        }
-        if (entry->recv_vcc) {
-                entry->recv_vcc->push = entry->old_recv_push;
+		vcc = NULL;
+	}
+	if (entry->recv_vcc) {
+		entry->recv_vcc->push = entry->old_recv_push;
 		vcc_release_async(entry->recv_vcc, -EPIPE);
-                entry->recv_vcc = NULL;
-        }        
+		entry->recv_vcc = NULL;
+	}
 }
 
 /*
  * Insert entry to lec_arp_table
  * LANE2: Add to the end of the list to satisfy 8.1.13
  */
-static inline void 
+static inline void
 lec_arp_add(struct lec_priv *priv, struct lec_arp_table *to_add)
 {
-        unsigned short place;
-        struct lec_arp_table *tmp;
-
-        place = HASH(to_add->mac_addr[ETH_ALEN-1]);
-        tmp = priv->lec_arp_tables[place];
-        to_add->next = NULL;
-        if (tmp == NULL)
-                priv->lec_arp_tables[place] = to_add;
-  
-        else {  /* add to the end */
-                while (tmp->next)
-                        tmp = tmp->next;
-                tmp->next = to_add;
-        }
-
-        DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-                0xff&to_add->mac_addr[0], 0xff&to_add->mac_addr[1],
-                0xff&to_add->mac_addr[2], 0xff&to_add->mac_addr[3],
-                0xff&to_add->mac_addr[4], 0xff&to_add->mac_addr[5]);
+	unsigned short place;
+	struct lec_arp_table *tmp;
+
+	place = HASH(to_add->mac_addr[ETH_ALEN - 1]);
+	tmp = priv->lec_arp_tables[place];
+	to_add->next = NULL;
+	if (tmp == NULL)
+		priv->lec_arp_tables[place] = to_add;
+
+	else {			/* add to the end */
+		while (tmp->next)
+			tmp = tmp->next;
+		tmp->next = to_add;
+	}
+
+	DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
+		0xff & to_add->mac_addr[0], 0xff & to_add->mac_addr[1],
+		0xff & to_add->mac_addr[2], 0xff & to_add->mac_addr[3],
+		0xff & to_add->mac_addr[4], 0xff & to_add->mac_addr[5]);
 }
 
 /*
  * Remove entry from lec_arp_table
  */
-static int 
-lec_arp_remove(struct lec_priv *priv,
-               struct lec_arp_table *to_remove)
+static int
+lec_arp_remove(struct lec_priv *priv, struct lec_arp_table *to_remove)
 {
-        unsigned short place;
-        struct lec_arp_table *tmp;
-        int remove_vcc=1;
-
-        if (!to_remove) {
-                return -1;
-        }
-        place = HASH(to_remove->mac_addr[ETH_ALEN-1]);
-        tmp = priv->lec_arp_tables[place];
-        if (tmp == to_remove) {
-                priv->lec_arp_tables[place] = tmp->next;
-        } else {
-                while(tmp && tmp->next != to_remove) {
-                        tmp = tmp->next;
-                }
-                if (!tmp) {/* Entry was not found */
-                        return -1;
-                }
-        }
-        tmp->next = to_remove->next;
-        del_timer(&to_remove->timer);
-  
-        /* If this is the only MAC connected to this VCC, also tear down
-           the VCC */
-        if (to_remove->status >= ESI_FLUSH_PENDING) {
-                /*
-                 * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
-                 */
-                for(place = 0; place < LEC_ARP_TABLE_SIZE; place++) {
-                        for(tmp = priv->lec_arp_tables[place]; tmp != NULL; tmp = tmp->next) {
-                                if (memcmp(tmp->atm_addr, to_remove->atm_addr,
-                                           ATM_ESA_LEN)==0) {
-                                        remove_vcc=0;
-                                        break;
-                                }
-                        }
-                }
-                if (remove_vcc)
-                        lec_arp_clear_vccs(to_remove);
-        }
-        skb_queue_purge(&to_remove->tx_wait); /* FIXME: good place for this? */
-
-        DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-                0xff&to_remove->mac_addr[0], 0xff&to_remove->mac_addr[1],
-                0xff&to_remove->mac_addr[2], 0xff&to_remove->mac_addr[3],
-                0xff&to_remove->mac_addr[4], 0xff&to_remove->mac_addr[5]);
-        return 0;
+	unsigned short place;
+	struct lec_arp_table *tmp;
+	int remove_vcc = 1;
+
+	if (!to_remove) {
+		return -1;
+	}
+	place = HASH(to_remove->mac_addr[ETH_ALEN - 1]);
+	tmp = priv->lec_arp_tables[place];
+	if (tmp == to_remove) {
+		priv->lec_arp_tables[place] = tmp->next;
+	} else {
+		while (tmp && tmp->next != to_remove) {
+			tmp = tmp->next;
+		}
+		if (!tmp) {	/* Entry was not found */
+			return -1;
+		}
+	}
+	tmp->next = to_remove->next;
+	del_timer(&to_remove->timer);
+
+	/* If this is the only MAC connected to this VCC, also tear down
+	   the VCC */
+	if (to_remove->status >= ESI_FLUSH_PENDING) {
+		/*
+		 * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
+		 */
+		for (place = 0; place < LEC_ARP_TABLE_SIZE; place++) {
+			for (tmp = priv->lec_arp_tables[place]; tmp != NULL;
+			     tmp = tmp->next) {
+				if (memcmp
+				    (tmp->atm_addr, to_remove->atm_addr,
+				     ATM_ESA_LEN) == 0) {
+					remove_vcc = 0;
+					break;
+				}
+			}
+		}
+		if (remove_vcc)
+			lec_arp_clear_vccs(to_remove);
+	}
+	skb_queue_purge(&to_remove->tx_wait);	/* FIXME: good place for this? */
+
+	DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
+		0xff & to_remove->mac_addr[0], 0xff & to_remove->mac_addr[1],
+		0xff & to_remove->mac_addr[2], 0xff & to_remove->mac_addr[3],
+		0xff & to_remove->mac_addr[4], 0xff & to_remove->mac_addr[5]);
+	return 0;
 }
 
 #if DEBUG_ARP_TABLE
-static char*
-get_status_string(unsigned char st)
+static char *get_status_string(unsigned char st)
 {
-        switch(st) {
-        case ESI_UNKNOWN:
-                return "ESI_UNKNOWN";
-        case ESI_ARP_PENDING:
-                return "ESI_ARP_PENDING";
-        case ESI_VC_PENDING:
-                return "ESI_VC_PENDING";
-        case ESI_FLUSH_PENDING:
-                return "ESI_FLUSH_PENDING";
-        case ESI_FORWARD_DIRECT:
-                return "ESI_FORWARD_DIRECT";
-        default:
-                return "<UNKNOWN>";
-        }
+	switch (st) {
+	case ESI_UNKNOWN:
+		return "ESI_UNKNOWN";
+	case ESI_ARP_PENDING:
+		return "ESI_ARP_PENDING";
+	case ESI_VC_PENDING:
+		return "ESI_VC_PENDING";
+	case ESI_FLUSH_PENDING:
+		return "ESI_FLUSH_PENDING";
+	case ESI_FORWARD_DIRECT:
+		return "ESI_FORWARD_DIRECT";
+	default:
+		return "<UNKNOWN>";
+	}
 }
 #endif
 
-static void
-dump_arp_table(struct lec_priv *priv)
+static void dump_arp_table(struct lec_priv *priv)
 {
 #if DEBUG_ARP_TABLE
-        int i,j, offset;
-        struct lec_arp_table *rulla;
-        char buf[1024];
-        struct lec_arp_table **lec_arp_tables =
-                (struct lec_arp_table **)priv->lec_arp_tables;
-        struct lec_arp_table *lec_arp_empty_ones =
-                (struct lec_arp_table *)priv->lec_arp_empty_ones;
-        struct lec_arp_table *lec_no_forward =
-                (struct lec_arp_table *)priv->lec_no_forward;
-        struct lec_arp_table *mcast_fwds = priv->mcast_fwds;
-
-
-        printk("Dump %p:\n",priv);
-        for (i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                rulla = lec_arp_tables[i];
-                offset = 0;
-                offset += sprintf(buf,"%d: %p\n",i, rulla);
-                while (rulla) {
-                        offset += sprintf(buf+offset,"Mac:");
-                        for(j=0;j<ETH_ALEN;j++) {
-                                offset+=sprintf(buf+offset,
-                                                "%2.2x ",
-                                                rulla->mac_addr[j]&0xff);
-                        }
-                        offset +=sprintf(buf+offset,"Atm:");
-                        for(j=0;j<ATM_ESA_LEN;j++) {
-                                offset+=sprintf(buf+offset,
-                                                "%2.2x ",
-                                                rulla->atm_addr[j]&0xff);
-                        }      
-                        offset+=sprintf(buf+offset,
-                                        "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
-                                        rulla->vcc?rulla->vcc->vpi:0, 
-                                        rulla->vcc?rulla->vcc->vci:0,
-                                        rulla->recv_vcc?rulla->recv_vcc->vpi:0,
-                                        rulla->recv_vcc?rulla->recv_vcc->vci:0,
-                                        rulla->last_used,
-                                        rulla->timestamp, rulla->no_tries);
-                        offset+=sprintf(buf+offset,
-                                        "Flags:%x, Packets_flooded:%x, Status: %s ",
-                                        rulla->flags, rulla->packets_flooded, 
-                                        get_status_string(rulla->status));
-                        offset+=sprintf(buf+offset,"->%p\n",rulla->next);
-                        rulla = rulla->next;
-                }
-                printk("%s",buf);
-        }
-        rulla = lec_no_forward;
-        if (rulla)
-                printk("No forward\n");  
-        while(rulla) {
-                offset=0;
-                offset += sprintf(buf+offset,"Mac:");
-                for(j=0;j<ETH_ALEN;j++) {
-                        offset+=sprintf(buf+offset,"%2.2x ",
-                                        rulla->mac_addr[j]&0xff);
-                }
-                offset +=sprintf(buf+offset,"Atm:");
-                for(j=0;j<ATM_ESA_LEN;j++) {
-                        offset+=sprintf(buf+offset,"%2.2x ",
-                                        rulla->atm_addr[j]&0xff);
-                }      
-                offset+=sprintf(buf+offset,
-                                "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
-                                rulla->vcc?rulla->vcc->vpi:0, 
-                                rulla->vcc?rulla->vcc->vci:0, 
-                                rulla->recv_vcc?rulla->recv_vcc->vpi:0,
-                                rulla->recv_vcc?rulla->recv_vcc->vci:0,
-                                rulla->last_used, 
-                                rulla->timestamp, rulla->no_tries);
-                offset+=sprintf(buf+offset,
-                                "Flags:%x, Packets_flooded:%x, Status: %s ",
-                                rulla->flags, rulla->packets_flooded, 
-                                get_status_string(rulla->status));
-                offset+=sprintf(buf+offset,"->%lx\n",(long)rulla->next);
-                rulla = rulla->next;
-                printk("%s",buf);
-        }
-        rulla = lec_arp_empty_ones;
-        if (rulla)
-                printk("Empty ones\n");  
-        while(rulla) {
-                offset=0;
-                offset += sprintf(buf+offset,"Mac:");
-                for(j=0;j<ETH_ALEN;j++) {
-                        offset+=sprintf(buf+offset,"%2.2x ",
-                                        rulla->mac_addr[j]&0xff);
-                }
-                offset +=sprintf(buf+offset,"Atm:");
-                for(j=0;j<ATM_ESA_LEN;j++) {
-                        offset+=sprintf(buf+offset,"%2.2x ",
-                                        rulla->atm_addr[j]&0xff);
-                }      
-                offset+=sprintf(buf+offset,
-                                "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
-                                rulla->vcc?rulla->vcc->vpi:0, 
-                                rulla->vcc?rulla->vcc->vci:0, 
-                                rulla->recv_vcc?rulla->recv_vcc->vpi:0,
-                                rulla->recv_vcc?rulla->recv_vcc->vci:0,
-                                rulla->last_used, 
-                                rulla->timestamp, rulla->no_tries);
-                offset+=sprintf(buf+offset,
-                                "Flags:%x, Packets_flooded:%x, Status: %s ",
-                                rulla->flags, rulla->packets_flooded, 
-                                get_status_string(rulla->status));
-                offset+=sprintf(buf+offset,"->%lx\n",(long)rulla->next);
-                rulla = rulla->next;
-                printk("%s",buf);
-        }
-
-        rulla = mcast_fwds;
-        if (rulla)
-                printk("Multicast Forward VCCs\n");  
-        while(rulla) {
-                offset=0;
-                offset += sprintf(buf+offset,"Mac:");
-                for(j=0;j<ETH_ALEN;j++) {
-                        offset+=sprintf(buf+offset,"%2.2x ",
-                                        rulla->mac_addr[j]&0xff);
-                }
-                offset +=sprintf(buf+offset,"Atm:");
-                for(j=0;j<ATM_ESA_LEN;j++) {
-                        offset+=sprintf(buf+offset,"%2.2x ",
-                                        rulla->atm_addr[j]&0xff);
-                }      
-                offset+=sprintf(buf+offset,
-                                "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
-                                rulla->vcc?rulla->vcc->vpi:0, 
-                                rulla->vcc?rulla->vcc->vci:0, 
-                                rulla->recv_vcc?rulla->recv_vcc->vpi:0,
-                                rulla->recv_vcc?rulla->recv_vcc->vci:0,
-                                rulla->last_used, 
-                                rulla->timestamp, rulla->no_tries);
-                offset+=sprintf(buf+offset,
-                                "Flags:%x, Packets_flooded:%x, Status: %s ",
-                                rulla->flags, rulla->packets_flooded, 
-                                get_status_string(rulla->status));
-                offset+=sprintf(buf+offset,"->%lx\n",(long)rulla->next);
-                rulla = rulla->next;
-                printk("%s",buf);
-        }
+	int i, j, offset;
+	struct lec_arp_table *rulla;
+	char buf[1024];
+	struct lec_arp_table **lec_arp_tables =
+	    (struct lec_arp_table **)priv->lec_arp_tables;
+	struct lec_arp_table *lec_arp_empty_ones =
+	    (struct lec_arp_table *)priv->lec_arp_empty_ones;
+	struct lec_arp_table *lec_no_forward =
+	    (struct lec_arp_table *)priv->lec_no_forward;
+	struct lec_arp_table *mcast_fwds = priv->mcast_fwds;
+
+	printk("Dump %p:\n", priv);
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		rulla = lec_arp_tables[i];
+		offset = 0;
+		offset += sprintf(buf, "%d: %p\n", i, rulla);
+		while (rulla) {
+			offset += sprintf(buf + offset, "Mac:");
+			for (j = 0; j < ETH_ALEN; j++) {
+				offset += sprintf(buf + offset,
+						  "%2.2x ",
+						  rulla->mac_addr[j] & 0xff);
+			}
+			offset += sprintf(buf + offset, "Atm:");
+			for (j = 0; j < ATM_ESA_LEN; j++) {
+				offset += sprintf(buf + offset,
+						  "%2.2x ",
+						  rulla->atm_addr[j] & 0xff);
+			}
+			offset += sprintf(buf + offset,
+					  "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
+					  rulla->vcc ? rulla->vcc->vpi : 0,
+					  rulla->vcc ? rulla->vcc->vci : 0,
+					  rulla->recv_vcc ? rulla->recv_vcc->
+					  vpi : 0,
+					  rulla->recv_vcc ? rulla->recv_vcc->
+					  vci : 0, rulla->last_used,
+					  rulla->timestamp, rulla->no_tries);
+			offset +=
+			    sprintf(buf + offset,
+				    "Flags:%x, Packets_flooded:%x, Status: %s ",
+				    rulla->flags, rulla->packets_flooded,
+				    get_status_string(rulla->status));
+			offset += sprintf(buf + offset, "->%p\n", rulla->next);
+			rulla = rulla->next;
+		}
+		printk("%s", buf);
+	}
+	rulla = lec_no_forward;
+	if (rulla)
+		printk("No forward\n");
+	while (rulla) {
+		offset = 0;
+		offset += sprintf(buf + offset, "Mac:");
+		for (j = 0; j < ETH_ALEN; j++) {
+			offset += sprintf(buf + offset, "%2.2x ",
+					  rulla->mac_addr[j] & 0xff);
+		}
+		offset += sprintf(buf + offset, "Atm:");
+		for (j = 0; j < ATM_ESA_LEN; j++) {
+			offset += sprintf(buf + offset, "%2.2x ",
+					  rulla->atm_addr[j] & 0xff);
+		}
+		offset += sprintf(buf + offset,
+				  "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
+				  rulla->vcc ? rulla->vcc->vpi : 0,
+				  rulla->vcc ? rulla->vcc->vci : 0,
+				  rulla->recv_vcc ? rulla->recv_vcc->vpi : 0,
+				  rulla->recv_vcc ? rulla->recv_vcc->vci : 0,
+				  rulla->last_used,
+				  rulla->timestamp, rulla->no_tries);
+		offset += sprintf(buf + offset,
+				  "Flags:%x, Packets_flooded:%x, Status: %s ",
+				  rulla->flags, rulla->packets_flooded,
+				  get_status_string(rulla->status));
+		offset += sprintf(buf + offset, "->%lx\n", (long)rulla->next);
+		rulla = rulla->next;
+		printk("%s", buf);
+	}
+	rulla = lec_arp_empty_ones;
+	if (rulla)
+		printk("Empty ones\n");
+	while (rulla) {
+		offset = 0;
+		offset += sprintf(buf + offset, "Mac:");
+		for (j = 0; j < ETH_ALEN; j++) {
+			offset += sprintf(buf + offset, "%2.2x ",
+					  rulla->mac_addr[j] & 0xff);
+		}
+		offset += sprintf(buf + offset, "Atm:");
+		for (j = 0; j < ATM_ESA_LEN; j++) {
+			offset += sprintf(buf + offset, "%2.2x ",
+					  rulla->atm_addr[j] & 0xff);
+		}
+		offset += sprintf(buf + offset,
+				  "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
+				  rulla->vcc ? rulla->vcc->vpi : 0,
+				  rulla->vcc ? rulla->vcc->vci : 0,
+				  rulla->recv_vcc ? rulla->recv_vcc->vpi : 0,
+				  rulla->recv_vcc ? rulla->recv_vcc->vci : 0,
+				  rulla->last_used,
+				  rulla->timestamp, rulla->no_tries);
+		offset += sprintf(buf + offset,
+				  "Flags:%x, Packets_flooded:%x, Status: %s ",
+				  rulla->flags, rulla->packets_flooded,
+				  get_status_string(rulla->status));
+		offset += sprintf(buf + offset, "->%lx\n", (long)rulla->next);
+		rulla = rulla->next;
+		printk("%s", buf);
+	}
+
+	rulla = mcast_fwds;
+	if (rulla)
+		printk("Multicast Forward VCCs\n");
+	while (rulla) {
+		offset = 0;
+		offset += sprintf(buf + offset, "Mac:");
+		for (j = 0; j < ETH_ALEN; j++) {
+			offset += sprintf(buf + offset, "%2.2x ",
+					  rulla->mac_addr[j] & 0xff);
+		}
+		offset += sprintf(buf + offset, "Atm:");
+		for (j = 0; j < ATM_ESA_LEN; j++) {
+			offset += sprintf(buf + offset, "%2.2x ",
+					  rulla->atm_addr[j] & 0xff);
+		}
+		offset += sprintf(buf + offset,
+				  "Vcc vpi:%d vci:%d, Recv_vcc vpi:%d vci:%d Last_used:%lx, Timestamp:%lx, No_tries:%d ",
+				  rulla->vcc ? rulla->vcc->vpi : 0,
+				  rulla->vcc ? rulla->vcc->vci : 0,
+				  rulla->recv_vcc ? rulla->recv_vcc->vpi : 0,
+				  rulla->recv_vcc ? rulla->recv_vcc->vci : 0,
+				  rulla->last_used,
+				  rulla->timestamp, rulla->no_tries);
+		offset += sprintf(buf + offset,
+				  "Flags:%x, Packets_flooded:%x, Status: %s ",
+				  rulla->flags, rulla->packets_flooded,
+				  get_status_string(rulla->status));
+		offset += sprintf(buf + offset, "->%lx\n", (long)rulla->next);
+		rulla = rulla->next;
+		printk("%s", buf);
+	}
 
 #endif
 }
@@ -1749,177 +1745,168 @@ #endif
 /*
  * Destruction of arp-cache
  */
-static void
-lec_arp_destroy(struct lec_priv *priv)
+static void lec_arp_destroy(struct lec_priv *priv)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry, *next;
-        int i;
+	struct lec_arp_table *entry, *next;
+	int i;
+
+	del_timer_sync(&priv->lec_arp_timer);
 
-        del_timer_sync(&priv->lec_arp_timer);
-        
-        /*
-         * Remove all entries
-         */
+	/*
+	 * Remove all entries
+	 */
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-                for(entry = priv->lec_arp_tables[i]; entry != NULL; entry=next) {
-                        next = entry->next;
-                        lec_arp_remove(priv, entry);
-                        kfree(entry);
-                }
-        }
-        entry = priv->lec_arp_empty_ones;
-        while(entry) {
-                next = entry->next;
-                del_timer_sync(&entry->timer);
-                lec_arp_clear_vccs(entry);
-                kfree(entry);
-                entry = next;
-        }
-        priv->lec_arp_empty_ones = NULL;
-        entry = priv->lec_no_forward;
-        while(entry) {
-                next = entry->next;
-                del_timer_sync(&entry->timer);
-                lec_arp_clear_vccs(entry);
-                kfree(entry);
-                entry = next;
-        }
-        priv->lec_no_forward = NULL;
-        entry = priv->mcast_fwds;
-        while(entry) {
-                next = entry->next;
-                /* No timer, LANEv2 7.1.20 and 2.3.5.3 */
-                lec_arp_clear_vccs(entry);
-                kfree(entry);
-                entry = next;
-        }
-        priv->mcast_fwds = NULL;
-        priv->mcast_vcc = NULL;
-        memset(priv->lec_arp_tables, 0, 
-               sizeof(struct lec_arp_table *) * LEC_ARP_TABLE_SIZE);
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (entry = priv->lec_arp_tables[i]; entry != NULL;
+		     entry = next) {
+			next = entry->next;
+			lec_arp_remove(priv, entry);
+			kfree(entry);
+		}
+	}
+	entry = priv->lec_arp_empty_ones;
+	while (entry) {
+		next = entry->next;
+		del_timer_sync(&entry->timer);
+		lec_arp_clear_vccs(entry);
+		kfree(entry);
+		entry = next;
+	}
+	priv->lec_arp_empty_ones = NULL;
+	entry = priv->lec_no_forward;
+	while (entry) {
+		next = entry->next;
+		del_timer_sync(&entry->timer);
+		lec_arp_clear_vccs(entry);
+		kfree(entry);
+		entry = next;
+	}
+	priv->lec_no_forward = NULL;
+	entry = priv->mcast_fwds;
+	while (entry) {
+		next = entry->next;
+		/* No timer, LANEv2 7.1.20 and 2.3.5.3 */
+		lec_arp_clear_vccs(entry);
+		kfree(entry);
+		entry = next;
+	}
+	priv->mcast_fwds = NULL;
+	priv->mcast_vcc = NULL;
+	memset(priv->lec_arp_tables, 0,
+	       sizeof(struct lec_arp_table *) * LEC_ARP_TABLE_SIZE);
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
-
 /* 
  * Find entry by mac_address
  */
-static struct lec_arp_table*
-lec_arp_find(struct lec_priv *priv,
-             unsigned char *mac_addr)
+static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
+					  unsigned char *mac_addr)
 {
-        unsigned short place;
-        struct lec_arp_table *to_return;
-
-        DPRINTK("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-                mac_addr[0]&0xff, mac_addr[1]&0xff, mac_addr[2]&0xff, 
-                mac_addr[3]&0xff, mac_addr[4]&0xff, mac_addr[5]&0xff);
-        place = HASH(mac_addr[ETH_ALEN-1]);
-  
-        to_return = priv->lec_arp_tables[place];
-        while(to_return) {
-                if (!compare_ether_addr(mac_addr, to_return->mac_addr)) {
-                        return to_return;
-                }
-                to_return = to_return->next;
-        }
-        return NULL;
+	unsigned short place;
+	struct lec_arp_table *to_return;
+
+	DPRINTK("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
+		mac_addr[0] & 0xff, mac_addr[1] & 0xff, mac_addr[2] & 0xff,
+		mac_addr[3] & 0xff, mac_addr[4] & 0xff, mac_addr[5] & 0xff);
+	place = HASH(mac_addr[ETH_ALEN - 1]);
+
+	to_return = priv->lec_arp_tables[place];
+	while (to_return) {
+		if (!compare_ether_addr(mac_addr, to_return->mac_addr)) {
+			return to_return;
+		}
+		to_return = to_return->next;
+	}
+	return NULL;
 }
 
-static struct lec_arp_table*
-make_entry(struct lec_priv *priv, unsigned char *mac_addr)
+static struct lec_arp_table *make_entry(struct lec_priv *priv,
+					unsigned char *mac_addr)
 {
-        struct lec_arp_table *to_return;
-
-        to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
-        if (!to_return) {
-                printk("LEC: Arp entry kmalloc failed\n");
-                return NULL;
-        }
-        memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
-        init_timer(&to_return->timer);
-        to_return->timer.function = lec_arp_expire_arp;
-        to_return->timer.data = (unsigned long) to_return;
-        to_return->last_used = jiffies;
-        to_return->priv = priv;
-        skb_queue_head_init(&to_return->tx_wait);
-        return to_return;
+	struct lec_arp_table *to_return;
+
+	to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
+	if (!to_return) {
+		printk("LEC: Arp entry kmalloc failed\n");
+		return NULL;
+	}
+	memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
+	init_timer(&to_return->timer);
+	to_return->timer.function = lec_arp_expire_arp;
+	to_return->timer.data = (unsigned long)to_return;
+	to_return->last_used = jiffies;
+	to_return->priv = priv;
+	skb_queue_head_init(&to_return->tx_wait);
+	return to_return;
 }
 
-/*
- *
- * Arp sent timer expired
- *
- */
-static void
-lec_arp_expire_arp(unsigned long data)
+/* Arp sent timer expired */
+static void lec_arp_expire_arp(unsigned long data)
 {
-        struct lec_arp_table *entry;
-
-        entry = (struct lec_arp_table *)data;
-
-        DPRINTK("lec_arp_expire_arp\n");
-        if (entry->status == ESI_ARP_PENDING) {
-                if (entry->no_tries <= entry->priv->max_retry_count) {
-                        if (entry->is_rdesc)
-                                send_to_lecd(entry->priv, l_rdesc_arp_xmt, entry->mac_addr, NULL, NULL);
-                        else
-                                send_to_lecd(entry->priv, l_arp_xmt, entry->mac_addr, NULL, NULL);
-                        entry->no_tries++;
-                }
-                mod_timer(&entry->timer, jiffies + (1*HZ));
-        }
+	struct lec_arp_table *entry;
+
+	entry = (struct lec_arp_table *)data;
+
+	DPRINTK("lec_arp_expire_arp\n");
+	if (entry->status == ESI_ARP_PENDING) {
+		if (entry->no_tries <= entry->priv->max_retry_count) {
+			if (entry->is_rdesc)
+				send_to_lecd(entry->priv, l_rdesc_arp_xmt,
+					     entry->mac_addr, NULL, NULL);
+			else
+				send_to_lecd(entry->priv, l_arp_xmt,
+					     entry->mac_addr, NULL, NULL);
+			entry->no_tries++;
+		}
+		mod_timer(&entry->timer, jiffies + (1 * HZ));
+	}
 }
 
-/*
- *
- * Unknown/unused vcc expire, remove associated entry
- *
- */
-static void
-lec_arp_expire_vcc(unsigned long data)
+/* Unknown/unused vcc expire, remove associated entry */
+static void lec_arp_expire_vcc(unsigned long data)
 {
 	unsigned long flags;
-        struct lec_arp_table *to_remove = (struct lec_arp_table*)data;
-        struct lec_priv *priv = (struct lec_priv *)to_remove->priv;
-        struct lec_arp_table *entry = NULL;
+	struct lec_arp_table *to_remove = (struct lec_arp_table *)data;
+	struct lec_priv *priv = (struct lec_priv *)to_remove->priv;
+	struct lec_arp_table *entry = NULL;
 
-        del_timer(&to_remove->timer);
+	del_timer(&to_remove->timer);
 
-        DPRINTK("LEC_ARP %p %p: lec_arp_expire_vcc vpi:%d vci:%d\n",
-                to_remove, priv, 
-                to_remove->vcc?to_remove->recv_vcc->vpi:0,
-                to_remove->vcc?to_remove->recv_vcc->vci:0);
-        DPRINTK("eo:%p nf:%p\n",priv->lec_arp_empty_ones,priv->lec_no_forward);
+	DPRINTK("LEC_ARP %p %p: lec_arp_expire_vcc vpi:%d vci:%d\n",
+		to_remove, priv,
+		to_remove->vcc ? to_remove->recv_vcc->vpi : 0,
+		to_remove->vcc ? to_remove->recv_vcc->vci : 0);
+	DPRINTK("eo:%p nf:%p\n", priv->lec_arp_empty_ones,
+		priv->lec_no_forward);
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        if (to_remove == priv->lec_arp_empty_ones)
-                priv->lec_arp_empty_ones = to_remove->next;
-        else {
-                entry = priv->lec_arp_empty_ones;
-                while (entry && entry->next != to_remove)
-                        entry = entry->next;
-                if (entry)
-                        entry->next = to_remove->next;
-        }
-        if (!entry) {
-                if (to_remove == priv->lec_no_forward) {
-                        priv->lec_no_forward = to_remove->next;
-                } else {
-                        entry = priv->lec_no_forward;
-                        while (entry && entry->next != to_remove)
-                                entry = entry->next;
-                        if (entry)
-                                entry->next = to_remove->next;
-                }
+	if (to_remove == priv->lec_arp_empty_ones)
+		priv->lec_arp_empty_ones = to_remove->next;
+	else {
+		entry = priv->lec_arp_empty_ones;
+		while (entry && entry->next != to_remove)
+			entry = entry->next;
+		if (entry)
+			entry->next = to_remove->next;
+	}
+	if (!entry) {
+		if (to_remove == priv->lec_no_forward) {
+			priv->lec_no_forward = to_remove->next;
+		} else {
+			entry = priv->lec_no_forward;
+			while (entry && entry->next != to_remove)
+				entry = entry->next;
+			if (entry)
+				entry->next = to_remove->next;
+		}
 	}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
-        lec_arp_clear_vccs(to_remove);
-        kfree(to_remove);
+	lec_arp_clear_vccs(to_remove);
+	kfree(to_remove);
 }
 
 /*
@@ -1938,64 +1925,68 @@ lec_arp_expire_vcc(unsigned long data)
  *       to ESI_FORWARD_DIRECT. This causes the flush period to end
  *       regardless of the progress of the flush protocol.
  */
-static void
-lec_arp_check_expire(unsigned long data)
+static void lec_arp_check_expire(unsigned long data)
 {
 	unsigned long flags;
-        struct lec_priv *priv = (struct lec_priv *)data;
-        struct lec_arp_table *entry, *next;
-        unsigned long now;
-        unsigned long time_to_check;
-        int i;
-
-        DPRINTK("lec_arp_check_expire %p\n",priv);
-        DPRINTK("expire: eo:%p nf:%p\n",priv->lec_arp_empty_ones,
-                priv->lec_no_forward);
+	struct lec_priv *priv = (struct lec_priv *)data;
+	struct lec_arp_table *entry, *next;
+	unsigned long now;
+	unsigned long time_to_check;
+	int i;
+
+	DPRINTK("lec_arp_check_expire %p\n", priv);
+	DPRINTK("expire: eo:%p nf:%p\n", priv->lec_arp_empty_ones,
+		priv->lec_no_forward);
 	now = jiffies;
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-	for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for(entry = priv->lec_arp_tables[i]; entry != NULL; ) {
-			if ((entry->flags) & LEC_REMOTE_FLAG && 
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (entry = priv->lec_arp_tables[i]; entry != NULL;) {
+			if ((entry->flags) & LEC_REMOTE_FLAG &&
 			    priv->topology_change)
 				time_to_check = priv->forward_delay_time;
 			else
 				time_to_check = priv->aging_time;
 
 			DPRINTK("About to expire: %lx - %lx > %lx\n",
-				now,entry->last_used, time_to_check);
-			if( time_after(now, entry->last_used+
-			   time_to_check) && 
-			    !(entry->flags & LEC_PERMANENT_FLAG) &&
-			    !(entry->mac_addr[0] & 0x01) ) { /* LANE2: 7.1.20 */
+				now, entry->last_used, time_to_check);
+			if (time_after(now, entry->last_used + time_to_check)
+			    && !(entry->flags & LEC_PERMANENT_FLAG)
+			    && !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
 				/* Remove entry */
 				DPRINTK("LEC:Entry timed out\n");
-				next = entry->next;      
+				next = entry->next;
 				lec_arp_remove(priv, entry);
 				kfree(entry);
 				entry = next;
 			} else {
 				/* Something else */
 				if ((entry->status == ESI_VC_PENDING ||
-				     entry->status == ESI_ARP_PENDING) 
+				     entry->status == ESI_ARP_PENDING)
 				    && time_after_eq(now,
-				    entry->timestamp +
-				    priv->max_unknown_frame_time)) {
+						     entry->timestamp +
+						     priv->
+						     max_unknown_frame_time)) {
 					entry->timestamp = jiffies;
 					entry->packets_flooded = 0;
 					if (entry->status == ESI_VC_PENDING)
-						send_to_lecd(priv, l_svc_setup, entry->mac_addr, entry->atm_addr, NULL);
+						send_to_lecd(priv, l_svc_setup,
+							     entry->mac_addr,
+							     entry->atm_addr,
+							     NULL);
 				}
-				if (entry->status == ESI_FLUSH_PENDING 
-				   &&
-				   time_after_eq(now, entry->timestamp+
-				   priv->path_switching_delay)) {
+				if (entry->status == ESI_FLUSH_PENDING
+				    &&
+				    time_after_eq(now, entry->timestamp +
+						  priv->path_switching_delay)) {
 					struct sk_buff *skb;
 
-					while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
-						lec_send(entry->vcc, skb, entry->priv);
+					while ((skb =
+						skb_dequeue(&entry->tx_wait)) !=
+					       NULL)
+						lec_send(entry->vcc, skb,
+							 entry->priv);
 					entry->last_used = jiffies;
-					entry->status = 
-						ESI_FORWARD_DIRECT;
+					entry->status = ESI_FORWARD_DIRECT;
 				}
 				entry = entry->next;
 			}
@@ -2003,93 +1994,101 @@ lec_arp_check_expire(unsigned long data)
 	}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
-        mod_timer(&priv->lec_arp_timer, jiffies + LEC_ARP_REFRESH_INTERVAL);
+	mod_timer(&priv->lec_arp_timer, jiffies + LEC_ARP_REFRESH_INTERVAL);
 }
+
 /*
  * Try to find vcc where mac_address is attached.
  * 
  */
-static struct atm_vcc*
-lec_arp_resolve(struct lec_priv *priv, unsigned char *mac_to_find,
-		int is_rdesc, struct lec_arp_table **ret_entry)
+static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
+				       unsigned char *mac_to_find, int is_rdesc,
+				       struct lec_arp_table **ret_entry)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry;
+	struct lec_arp_table *entry;
 	struct atm_vcc *found;
 
-        if (mac_to_find[0] & 0x01) {
-                switch (priv->lane_version) {
-                case 1:
-                        return priv->mcast_vcc;
-                        break;
-                case 2:  /* LANE2 wants arp for multicast addresses */
-                        if (!compare_ether_addr(mac_to_find, bus_mac))
-                                return priv->mcast_vcc;
-                        break;
-                default:
-                        break;
-                }
-        }
+	if (mac_to_find[0] & 0x01) {
+		switch (priv->lane_version) {
+		case 1:
+			return priv->mcast_vcc;
+			break;
+		case 2:	/* LANE2 wants arp for multicast addresses */
+			if (!compare_ether_addr(mac_to_find, bus_mac))
+				return priv->mcast_vcc;
+			break;
+		default:
+			break;
+		}
+	}
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        entry = lec_arp_find(priv, mac_to_find);
-  
-        if (entry) {
-                if (entry->status == ESI_FORWARD_DIRECT) {
-                        /* Connection Ok */
-                        entry->last_used = jiffies;
-                        *ret_entry = entry;
-                        found = entry->vcc;
+	entry = lec_arp_find(priv, mac_to_find);
+
+	if (entry) {
+		if (entry->status == ESI_FORWARD_DIRECT) {
+			/* Connection Ok */
+			entry->last_used = jiffies;
+			*ret_entry = entry;
+			found = entry->vcc;
 			goto out;
-                }
-		/* If the LE_ARP cache entry is still pending, reset count to 0
+		}
+		/*
+		 * If the LE_ARP cache entry is still pending, reset count to 0
 		 * so another LE_ARP request can be made for this frame.
 		 */
 		if (entry->status == ESI_ARP_PENDING) {
 			entry->no_tries = 0;
 		}
-                /* Data direct VC not yet set up, check to see if the unknown
-                   frame count is greater than the limit. If the limit has
-                   not been reached, allow the caller to send packet to
-                   BUS. */
-                if (entry->status != ESI_FLUSH_PENDING &&
-                    entry->packets_flooded<priv->maximum_unknown_frame_count) {
-                        entry->packets_flooded++;
-                        DPRINTK("LEC_ARP: Flooding..\n");
-                        found = priv->mcast_vcc;
+		/*
+		 * Data direct VC not yet set up, check to see if the unknown
+		 * frame count is greater than the limit. If the limit has
+		 * not been reached, allow the caller to send packet to
+		 * BUS.
+		 */
+		if (entry->status != ESI_FLUSH_PENDING &&
+		    entry->packets_flooded <
+		    priv->maximum_unknown_frame_count) {
+			entry->packets_flooded++;
+			DPRINTK("LEC_ARP: Flooding..\n");
+			found = priv->mcast_vcc;
 			goto out;
-                }
-		/* We got here because entry->status == ESI_FLUSH_PENDING
+		}
+		/*
+		 * We got here because entry->status == ESI_FLUSH_PENDING
 		 * or BUS flood limit was reached for an entry which is
 		 * in ESI_ARP_PENDING or ESI_VC_PENDING state.
 		 */
-                *ret_entry = entry;
-                DPRINTK("lec: entry->status %d entry->vcc %p\n", entry->status, entry->vcc);
-                found = NULL;
-        } else {
-                /* No matching entry was found */
-                entry = make_entry(priv, mac_to_find);
-                DPRINTK("LEC_ARP: Making entry\n");
-                if (!entry) {
-                        found = priv->mcast_vcc;
+		*ret_entry = entry;
+		DPRINTK("lec: entry->status %d entry->vcc %p\n", entry->status,
+			entry->vcc);
+		found = NULL;
+	} else {
+		/* No matching entry was found */
+		entry = make_entry(priv, mac_to_find);
+		DPRINTK("LEC_ARP: Making entry\n");
+		if (!entry) {
+			found = priv->mcast_vcc;
 			goto out;
-                }
-                lec_arp_add(priv, entry);
-                /* We want arp-request(s) to be sent */
-                entry->packets_flooded =1;
-                entry->status = ESI_ARP_PENDING;
-                entry->no_tries = 1;
-                entry->last_used = entry->timestamp = jiffies;
-                entry->is_rdesc = is_rdesc;
-                if (entry->is_rdesc)
-                        send_to_lecd(priv, l_rdesc_arp_xmt, mac_to_find, NULL, NULL);
-                else
-                        send_to_lecd(priv, l_arp_xmt, mac_to_find, NULL, NULL);
-                entry->timer.expires = jiffies + (1*HZ);
-                entry->timer.function = lec_arp_expire_arp;
-                add_timer(&entry->timer);
-                found = priv->mcast_vcc;
-        }
+		}
+		lec_arp_add(priv, entry);
+		/* We want arp-request(s) to be sent */
+		entry->packets_flooded = 1;
+		entry->status = ESI_ARP_PENDING;
+		entry->no_tries = 1;
+		entry->last_used = entry->timestamp = jiffies;
+		entry->is_rdesc = is_rdesc;
+		if (entry->is_rdesc)
+			send_to_lecd(priv, l_rdesc_arp_xmt, mac_to_find, NULL,
+				     NULL);
+		else
+			send_to_lecd(priv, l_arp_xmt, mac_to_find, NULL, NULL);
+		entry->timer.expires = jiffies + (1 * HZ);
+		entry->timer.function = lec_arp_expire_arp;
+		add_timer(&entry->timer);
+		found = priv->mcast_vcc;
+	}
 
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
@@ -2097,30 +2096,31 @@ out:
 }
 
 static int
-lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr, 
-                unsigned long permanent)
+lec_addr_delete(struct lec_priv *priv, unsigned char *atm_addr,
+		unsigned long permanent)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry, *next;
-        int i;
+	struct lec_arp_table *entry, *next;
+	int i;
 
-        DPRINTK("lec_addr_delete\n");
+	DPRINTK("lec_addr_delete\n");
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-                for(entry = priv->lec_arp_tables[i]; entry != NULL; entry = next) {
-                        next = entry->next;
-                        if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
-                            && (permanent || 
-                                !(entry->flags & LEC_PERMANENT_FLAG))) {
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (entry = priv->lec_arp_tables[i]; entry != NULL;
+		     entry = next) {
+			next = entry->next;
+			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
+			    && (permanent ||
+				!(entry->flags & LEC_PERMANENT_FLAG))) {
 				lec_arp_remove(priv, entry);
-                                kfree(entry);
-                        }
+				kfree(entry);
+			}
 			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-                        return 0;
-                }
-        }
+			return 0;
+		}
+	}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-        return -1;
+	return -1;
 }
 
 /*
@@ -2128,109 +2128,109 @@ lec_addr_delete(struct lec_priv *priv, u
  */
 static void
 lec_arp_update(struct lec_priv *priv, unsigned char *mac_addr,
-               unsigned char *atm_addr, unsigned long remoteflag,
-               unsigned int targetless_le_arp)
+	       unsigned char *atm_addr, unsigned long remoteflag,
+	       unsigned int targetless_le_arp)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry, *tmp;
-        int i;
+	struct lec_arp_table *entry, *tmp;
+	int i;
 
-        DPRINTK("lec:%s", (targetless_le_arp) ? "targetless ": " ");
-        DPRINTK("lec_arp_update mac:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
-                mac_addr[0],mac_addr[1],mac_addr[2],mac_addr[3],
-                mac_addr[4],mac_addr[5]);
+	DPRINTK("lec:%s", (targetless_le_arp) ? "targetless " : " ");
+	DPRINTK("lec_arp_update mac:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
+		mac_addr[0], mac_addr[1], mac_addr[2], mac_addr[3],
+		mac_addr[4], mac_addr[5]);
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        entry = lec_arp_find(priv, mac_addr);
-        if (entry == NULL && targetless_le_arp)
-                goto out;   /* LANE2: ignore targetless LE_ARPs for which
-                             * we have no entry in the cache. 7.1.30
-                             */
-        if (priv->lec_arp_empty_ones) {
-                entry = priv->lec_arp_empty_ones;
-                if (!memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN)) {
-                        priv->lec_arp_empty_ones = entry->next;
-                } else {
-                        while(entry->next && memcmp(entry->next->atm_addr, 
-                                                    atm_addr, ATM_ESA_LEN))
-                                entry = entry->next;
-                        if (entry->next) {
-                                tmp = entry;
-                                entry = entry->next;
-                                tmp->next = entry->next;
-                        } else
-                                entry = NULL;
-                        
-                }
-                if (entry) {
-                        del_timer(&entry->timer);
-                        tmp = lec_arp_find(priv, mac_addr);
-                        if (tmp) {
-                                del_timer(&tmp->timer);
-                                tmp->status = ESI_FORWARD_DIRECT;
-                                memcpy(tmp->atm_addr, atm_addr, ATM_ESA_LEN);
-                                tmp->vcc = entry->vcc;
-                                tmp->old_push = entry->old_push;
-                                tmp->last_used = jiffies;
-                                del_timer(&entry->timer);
-                                kfree(entry);
-                                entry=tmp;
-                        } else {
-                                entry->status = ESI_FORWARD_DIRECT;
-                                memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
-                                entry->last_used = jiffies;
-                                lec_arp_add(priv, entry);
-                        }
-                        if (remoteflag)
-                                entry->flags|=LEC_REMOTE_FLAG;
-                        else
-                                entry->flags&=~LEC_REMOTE_FLAG;
-                        DPRINTK("After update\n");
-                        dump_arp_table(priv);
-                        goto out;
-                }
-        }
-        entry = lec_arp_find(priv, mac_addr);
-        if (!entry) {
-                entry = make_entry(priv, mac_addr);
-                if (!entry)
+	entry = lec_arp_find(priv, mac_addr);
+	if (entry == NULL && targetless_le_arp)
+		goto out;	/*
+				 * LANE2: ignore targetless LE_ARPs for which
+				 * we have no entry in the cache. 7.1.30
+				 */
+	if (priv->lec_arp_empty_ones) {
+		entry = priv->lec_arp_empty_ones;
+		if (!memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN)) {
+			priv->lec_arp_empty_ones = entry->next;
+		} else {
+			while (entry->next && memcmp(entry->next->atm_addr,
+						     atm_addr, ATM_ESA_LEN))
+				entry = entry->next;
+			if (entry->next) {
+				tmp = entry;
+				entry = entry->next;
+				tmp->next = entry->next;
+			} else
+				entry = NULL;
+
+		}
+		if (entry) {
+			del_timer(&entry->timer);
+			tmp = lec_arp_find(priv, mac_addr);
+			if (tmp) {
+				del_timer(&tmp->timer);
+				tmp->status = ESI_FORWARD_DIRECT;
+				memcpy(tmp->atm_addr, atm_addr, ATM_ESA_LEN);
+				tmp->vcc = entry->vcc;
+				tmp->old_push = entry->old_push;
+				tmp->last_used = jiffies;
+				del_timer(&entry->timer);
+				kfree(entry);
+				entry = tmp;
+			} else {
+				entry->status = ESI_FORWARD_DIRECT;
+				memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
+				entry->last_used = jiffies;
+				lec_arp_add(priv, entry);
+			}
+			if (remoteflag)
+				entry->flags |= LEC_REMOTE_FLAG;
+			else
+				entry->flags &= ~LEC_REMOTE_FLAG;
+			DPRINTK("After update\n");
+			dump_arp_table(priv);
 			goto out;
-                entry->status = ESI_UNKNOWN;
-                lec_arp_add(priv, entry);
-                /* Temporary, changes before end of function */
-        }
-        memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
-        del_timer(&entry->timer);
-        for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-                for(tmp = priv->lec_arp_tables[i]; tmp; tmp=tmp->next) {
-                        if (entry != tmp &&
-                            !memcmp(tmp->atm_addr, atm_addr,
-                                    ATM_ESA_LEN)) { 
-                                /* Vcc to this host exists */
-                                if (tmp->status > ESI_VC_PENDING) {
-                                        /*
-                                         * ESI_FLUSH_PENDING,
-                                         * ESI_FORWARD_DIRECT
-                                         */
-                                        entry->vcc = tmp->vcc;
-                                        entry->old_push=tmp->old_push;
-                                }
-                                entry->status=tmp->status;
-                                break;
-                        }
-                }
-        }
-        if (remoteflag)
-                entry->flags|=LEC_REMOTE_FLAG;
-        else
-                entry->flags&=~LEC_REMOTE_FLAG;
-        if (entry->status == ESI_ARP_PENDING ||
-            entry->status == ESI_UNKNOWN) {
-                entry->status = ESI_VC_PENDING;
-                send_to_lecd(priv, l_svc_setup, entry->mac_addr, atm_addr, NULL);
-        }
-        DPRINTK("After update2\n");
-        dump_arp_table(priv);
+		}
+	}
+	entry = lec_arp_find(priv, mac_addr);
+	if (!entry) {
+		entry = make_entry(priv, mac_addr);
+		if (!entry)
+			goto out;
+		entry->status = ESI_UNKNOWN;
+		lec_arp_add(priv, entry);
+		/* Temporary, changes before end of function */
+	}
+	memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
+	del_timer(&entry->timer);
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (tmp = priv->lec_arp_tables[i]; tmp; tmp = tmp->next) {
+			if (entry != tmp &&
+			    !memcmp(tmp->atm_addr, atm_addr, ATM_ESA_LEN)) {
+				/* Vcc to this host exists */
+				if (tmp->status > ESI_VC_PENDING) {
+					/*
+					 * ESI_FLUSH_PENDING,
+					 * ESI_FORWARD_DIRECT
+					 */
+					entry->vcc = tmp->vcc;
+					entry->old_push = tmp->old_push;
+				}
+				entry->status = tmp->status;
+				break;
+			}
+		}
+	}
+	if (remoteflag)
+		entry->flags |= LEC_REMOTE_FLAG;
+	else
+		entry->flags &= ~LEC_REMOTE_FLAG;
+	if (entry->status == ESI_ARP_PENDING || entry->status == ESI_UNKNOWN) {
+		entry->status = ESI_VC_PENDING;
+		send_to_lecd(priv, l_svc_setup, entry->mac_addr, atm_addr,
+			     NULL);
+	}
+	DPRINTK("After update2\n");
+	dump_arp_table(priv);
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
@@ -2240,299 +2240,312 @@ out:
  */
 static void
 lec_vcc_added(struct lec_priv *priv, struct atmlec_ioc *ioc_data,
-              struct atm_vcc *vcc,
-              void (*old_push)(struct atm_vcc *vcc, struct sk_buff *skb))
+	      struct atm_vcc *vcc,
+	      void (*old_push) (struct atm_vcc *vcc, struct sk_buff *skb))
 {
 	unsigned long flags;
-        struct lec_arp_table *entry;
-        int i, found_entry=0;
+	struct lec_arp_table *entry;
+	int i, found_entry = 0;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        if (ioc_data->receive == 2) {
-                /* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
+	if (ioc_data->receive == 2) {
+		/* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
 
-                DPRINTK("LEC_ARP: Attaching mcast forward\n");
+		DPRINTK("LEC_ARP: Attaching mcast forward\n");
 #if 0
-                entry = lec_arp_find(priv, bus_mac);
-                if (!entry) {
-                        printk("LEC_ARP: Multicast entry not found!\n");
+		entry = lec_arp_find(priv, bus_mac);
+		if (!entry) {
+			printk("LEC_ARP: Multicast entry not found!\n");
 			goto out;
-                }
-                memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
-                entry->recv_vcc = vcc;
-                entry->old_recv_push = old_push;
+		}
+		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
+		entry->recv_vcc = vcc;
+		entry->old_recv_push = old_push;
 #endif
-                entry = make_entry(priv, bus_mac);
-                if (entry == NULL)
+		entry = make_entry(priv, bus_mac);
+		if (entry == NULL)
 			goto out;
-                del_timer(&entry->timer);
-                memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
-                entry->recv_vcc = vcc;
-                entry->old_recv_push = old_push;
-                entry->next = priv->mcast_fwds;
-                priv->mcast_fwds = entry;
-                goto out;
-        } else if (ioc_data->receive == 1) {
-                /* Vcc which we don't want to make default vcc, attach it
-                   anyway. */
-                DPRINTK("LEC_ARP:Attaching data direct, not default :%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
-                        ioc_data->atm_addr[0],ioc_data->atm_addr[1],
-                        ioc_data->atm_addr[2],ioc_data->atm_addr[3],
-                        ioc_data->atm_addr[4],ioc_data->atm_addr[5],
-                        ioc_data->atm_addr[6],ioc_data->atm_addr[7],
-                        ioc_data->atm_addr[8],ioc_data->atm_addr[9],
-                        ioc_data->atm_addr[10],ioc_data->atm_addr[11],
-                        ioc_data->atm_addr[12],ioc_data->atm_addr[13],
-                        ioc_data->atm_addr[14],ioc_data->atm_addr[15],
-                        ioc_data->atm_addr[16],ioc_data->atm_addr[17],
-                        ioc_data->atm_addr[18],ioc_data->atm_addr[19]);
-                entry = make_entry(priv, bus_mac);
-                if (entry == NULL)
+		del_timer(&entry->timer);
+		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
+		entry->recv_vcc = vcc;
+		entry->old_recv_push = old_push;
+		entry->next = priv->mcast_fwds;
+		priv->mcast_fwds = entry;
+		goto out;
+	} else if (ioc_data->receive == 1) {
+		/*
+		 * Vcc which we don't want to make default vcc,
+		 * attach it anyway.
+		 */
+		DPRINTK
+		    ("LEC_ARP:Attaching data direct, not default: "
+		     "%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
+		     ioc_data->atm_addr[0], ioc_data->atm_addr[1],
+		     ioc_data->atm_addr[2], ioc_data->atm_addr[3],
+		     ioc_data->atm_addr[4], ioc_data->atm_addr[5],
+		     ioc_data->atm_addr[6], ioc_data->atm_addr[7],
+		     ioc_data->atm_addr[8], ioc_data->atm_addr[9],
+		     ioc_data->atm_addr[10], ioc_data->atm_addr[11],
+		     ioc_data->atm_addr[12], ioc_data->atm_addr[13],
+		     ioc_data->atm_addr[14], ioc_data->atm_addr[15],
+		     ioc_data->atm_addr[16], ioc_data->atm_addr[17],
+		     ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
+		entry = make_entry(priv, bus_mac);
+		if (entry == NULL)
 			goto out;
-                memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
-                memset(entry->mac_addr, 0, ETH_ALEN);
-                entry->recv_vcc = vcc;
-                entry->old_recv_push = old_push;
-                entry->status = ESI_UNKNOWN;
-                entry->timer.expires = jiffies + priv->vcc_timeout_period;
-                entry->timer.function = lec_arp_expire_vcc;
-                add_timer(&entry->timer);
-                entry->next = priv->lec_no_forward;
-                priv->lec_no_forward = entry;
+		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
+		memset(entry->mac_addr, 0, ETH_ALEN);
+		entry->recv_vcc = vcc;
+		entry->old_recv_push = old_push;
+		entry->status = ESI_UNKNOWN;
+		entry->timer.expires = jiffies + priv->vcc_timeout_period;
+		entry->timer.function = lec_arp_expire_vcc;
+		add_timer(&entry->timer);
+		entry->next = priv->lec_no_forward;
+		priv->lec_no_forward = entry;
 		dump_arp_table(priv);
 		goto out;
-        }
-        DPRINTK("LEC_ARP:Attaching data direct, default:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
-                ioc_data->atm_addr[0],ioc_data->atm_addr[1],
-                ioc_data->atm_addr[2],ioc_data->atm_addr[3],
-                ioc_data->atm_addr[4],ioc_data->atm_addr[5],
-                ioc_data->atm_addr[6],ioc_data->atm_addr[7],
-                ioc_data->atm_addr[8],ioc_data->atm_addr[9],
-                ioc_data->atm_addr[10],ioc_data->atm_addr[11],
-                ioc_data->atm_addr[12],ioc_data->atm_addr[13],
-                ioc_data->atm_addr[14],ioc_data->atm_addr[15],
-                ioc_data->atm_addr[16],ioc_data->atm_addr[17],
-                ioc_data->atm_addr[18],ioc_data->atm_addr[19]);
-        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-                for (entry = priv->lec_arp_tables[i]; entry; entry=entry->next) {
-                        if (memcmp(ioc_data->atm_addr, entry->atm_addr, 
-                                   ATM_ESA_LEN)==0) {
-                                DPRINTK("LEC_ARP: Attaching data direct\n");
-                                DPRINTK("Currently -> Vcc: %d, Rvcc:%d\n",
-                                        entry->vcc?entry->vcc->vci:0,
-                                        entry->recv_vcc?entry->recv_vcc->vci:0);
-                                found_entry=1;
-                                del_timer(&entry->timer);
-                                entry->vcc = vcc;
-                                entry->old_push = old_push;
-                                if (entry->status == ESI_VC_PENDING) {
-                                        if(priv->maximum_unknown_frame_count
-                                           ==0)
-                                                entry->status = 
-                                                        ESI_FORWARD_DIRECT;
-                                        else {
-                                                entry->timestamp = jiffies;
-                                                entry->status = 
-                                                        ESI_FLUSH_PENDING;
+	}
+	DPRINTK
+	    ("LEC_ARP:Attaching data direct, default: "
+	     "%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
+	     ioc_data->atm_addr[0], ioc_data->atm_addr[1],
+	     ioc_data->atm_addr[2], ioc_data->atm_addr[3],
+	     ioc_data->atm_addr[4], ioc_data->atm_addr[5],
+	     ioc_data->atm_addr[6], ioc_data->atm_addr[7],
+	     ioc_data->atm_addr[8], ioc_data->atm_addr[9],
+	     ioc_data->atm_addr[10], ioc_data->atm_addr[11],
+	     ioc_data->atm_addr[12], ioc_data->atm_addr[13],
+	     ioc_data->atm_addr[14], ioc_data->atm_addr[15],
+	     ioc_data->atm_addr[16], ioc_data->atm_addr[17],
+	     ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (entry = priv->lec_arp_tables[i]; entry;
+		     entry = entry->next) {
+			if (memcmp
+			    (ioc_data->atm_addr, entry->atm_addr,
+			     ATM_ESA_LEN) == 0) {
+				DPRINTK("LEC_ARP: Attaching data direct\n");
+				DPRINTK("Currently -> Vcc: %d, Rvcc:%d\n",
+					entry->vcc ? entry->vcc->vci : 0,
+					entry->recv_vcc ? entry->recv_vcc->
+					vci : 0);
+				found_entry = 1;
+				del_timer(&entry->timer);
+				entry->vcc = vcc;
+				entry->old_push = old_push;
+				if (entry->status == ESI_VC_PENDING) {
+					if (priv->maximum_unknown_frame_count
+					    == 0)
+						entry->status =
+						    ESI_FORWARD_DIRECT;
+					else {
+						entry->timestamp = jiffies;
+						entry->status =
+						    ESI_FLUSH_PENDING;
 #if 0
-                                                send_to_lecd(priv,l_flush_xmt,
-                                                             NULL,
-                                                             entry->atm_addr,
-                                                             NULL);
+						send_to_lecd(priv, l_flush_xmt,
+							     NULL,
+							     entry->atm_addr,
+							     NULL);
 #endif
-                                        }
-                                } else {
-                                        /* They were forming a connection
-                                           to us, and we to them. Our
-                                           ATM address is numerically lower
-                                           than theirs, so we make connection
-                                           we formed into default VCC (8.1.11).
-                                           Connection they made gets torn
-                                           down. This might confuse some
-                                           clients. Can be changed if
-                                           someone reports trouble... */
-                                        ;
-                                }
-                        }
-                }
-        }
-        if (found_entry) {
-                DPRINTK("After vcc was added\n");
-                dump_arp_table(priv);
+					}
+				} else {
+					/*
+					 * They were forming a connection
+					 * to us, and we to them. Our
+					 * ATM address is numerically lower
+					 * than theirs, so we make connection
+					 * we formed into default VCC (8.1.11).
+					 * Connection they made gets torn
+					 * down. This might confuse some
+					 * clients. Can be changed if
+					 * someone reports trouble...
+					 */
+					;
+				}
+			}
+		}
+	}
+	if (found_entry) {
+		DPRINTK("After vcc was added\n");
+		dump_arp_table(priv);
 		goto out;
-        }
-        /* Not found, snatch address from first data packet that arrives from
-           this vcc */
-        entry = make_entry(priv, bus_mac);
-        if (!entry)
+	}
+	/*
+	 * Not found, snatch address from first data packet that arrives
+	 * from this vcc
+	 */
+	entry = make_entry(priv, bus_mac);
+	if (!entry)
 		goto out;
-        entry->vcc = vcc;
-        entry->old_push = old_push;
-        memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
-        memset(entry->mac_addr, 0, ETH_ALEN);
-        entry->status = ESI_UNKNOWN;
-        entry->next = priv->lec_arp_empty_ones;
-        priv->lec_arp_empty_ones = entry;
-        entry->timer.expires = jiffies + priv->vcc_timeout_period;
-        entry->timer.function = lec_arp_expire_vcc;
-        add_timer(&entry->timer);
-        DPRINTK("After vcc was added\n");
+	entry->vcc = vcc;
+	entry->old_push = old_push;
+	memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
+	memset(entry->mac_addr, 0, ETH_ALEN);
+	entry->status = ESI_UNKNOWN;
+	entry->next = priv->lec_arp_empty_ones;
+	priv->lec_arp_empty_ones = entry;
+	entry->timer.expires = jiffies + priv->vcc_timeout_period;
+	entry->timer.function = lec_arp_expire_vcc;
+	add_timer(&entry->timer);
+	DPRINTK("After vcc was added\n");
 	dump_arp_table(priv);
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
-static void
-lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
+static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry;
-        int i;
-  
-        DPRINTK("LEC:lec_flush_complete %lx\n",tran_id);
-	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-                for (entry = priv->lec_arp_tables[i]; entry; entry=entry->next) {
-                        if (entry->flush_tran_id == tran_id &&
-                            entry->status == ESI_FLUSH_PENDING) {
-			        struct sk_buff *skb;
+	struct lec_arp_table *entry;
+	int i;
 
- 				while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
+	DPRINTK("LEC:lec_flush_complete %lx\n", tran_id);
+	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (entry = priv->lec_arp_tables[i]; entry;
+		     entry = entry->next) {
+			if (entry->flush_tran_id == tran_id
+			    && entry->status == ESI_FLUSH_PENDING) {
+				struct sk_buff *skb;
+
+				while ((skb =
+					skb_dequeue(&entry->tx_wait)) != NULL)
 					lec_send(entry->vcc, skb, entry->priv);
-                                entry->status = ESI_FORWARD_DIRECT;
-                                DPRINTK("LEC_ARP: Flushed\n");
-                        }
-                }
-        }
+				entry->status = ESI_FORWARD_DIRECT;
+				DPRINTK("LEC_ARP: Flushed\n");
+			}
+		}
+	}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-        dump_arp_table(priv);
+	dump_arp_table(priv);
 }
 
 static void
 lec_set_flush_tran_id(struct lec_priv *priv,
-                      unsigned char *atm_addr, unsigned long tran_id)
+		      unsigned char *atm_addr, unsigned long tran_id)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry;
-        int i;
+	struct lec_arp_table *entry;
+	int i;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        for (i = 0; i < LEC_ARP_TABLE_SIZE; i++)
-                for(entry = priv->lec_arp_tables[i]; entry; entry=entry->next)
-                        if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
-                                entry->flush_tran_id = tran_id;
-                                DPRINTK("Set flush transaction id to %lx for %p\n",tran_id,entry);
-                        }
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++)
+		for (entry = priv->lec_arp_tables[i]; entry;
+		     entry = entry->next)
+			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
+				entry->flush_tran_id = tran_id;
+				DPRINTK
+				    ("Set flush transaction id to %lx for %p\n",
+				     tran_id, entry);
+			}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
-static int 
-lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
+static int lec_mcast_make(struct lec_priv *priv, struct atm_vcc *vcc)
 {
 	unsigned long flags;
-        unsigned char mac_addr[] = {
-                0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
-        struct lec_arp_table *to_add;
+	unsigned char mac_addr[] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
+	struct lec_arp_table *to_add;
 	struct lec_vcc_priv *vpriv;
 	int err = 0;
-  
+
 	if (!(vpriv = kmalloc(sizeof(struct lec_vcc_priv), GFP_KERNEL)))
 		return -ENOMEM;
 	vpriv->xoff = 0;
 	vpriv->old_pop = vcc->pop;
 	vcc->user_back = vpriv;
-        vcc->pop = lec_pop;
+	vcc->pop = lec_pop;
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        to_add = make_entry(priv, mac_addr);
-        if (!to_add) {
+	to_add = make_entry(priv, mac_addr);
+	if (!to_add) {
 		vcc->pop = vpriv->old_pop;
 		kfree(vpriv);
-                err = -ENOMEM;
+		err = -ENOMEM;
 		goto out;
-        }
-        memcpy(to_add->atm_addr, vcc->remote.sas_addr.prv, ATM_ESA_LEN);
-        to_add->status = ESI_FORWARD_DIRECT;
-        to_add->flags |= LEC_PERMANENT_FLAG;
-        to_add->vcc = vcc;
-        to_add->old_push = vcc->push;
-        vcc->push = lec_push;
-        priv->mcast_vcc = vcc;
-        lec_arp_add(priv, to_add);
+	}
+	memcpy(to_add->atm_addr, vcc->remote.sas_addr.prv, ATM_ESA_LEN);
+	to_add->status = ESI_FORWARD_DIRECT;
+	to_add->flags |= LEC_PERMANENT_FLAG;
+	to_add->vcc = vcc;
+	to_add->old_push = vcc->push;
+	vcc->push = lec_push;
+	priv->mcast_vcc = vcc;
+	lec_arp_add(priv, to_add);
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-        return err;
+	return err;
 }
 
-static void
-lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
+static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
 {
 	unsigned long flags;
-        struct lec_arp_table *entry, *next;
-        int i;
+	struct lec_arp_table *entry, *next;
+	int i;
 
-        DPRINTK("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n",vcc->vpi,vcc->vci);
-        dump_arp_table(priv);
+	DPRINTK("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n", vcc->vpi, vcc->vci);
+	dump_arp_table(priv);
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        for(i=0;i<LEC_ARP_TABLE_SIZE;i++) {
-                for(entry = priv->lec_arp_tables[i];entry; entry=next) {
-                        next = entry->next;
-                        if (vcc == entry->vcc) {
-                                lec_arp_remove(priv, entry);
-                                kfree(entry);
-                                if (priv->mcast_vcc == vcc) {
-                                        priv->mcast_vcc = NULL;
-                                }
-                        }
-                }
-        }
-
-        entry = priv->lec_arp_empty_ones;
-        priv->lec_arp_empty_ones = NULL;
-        while (entry != NULL) {
-                next = entry->next;
-                if (entry->vcc == vcc) { /* leave it out from the list */
-                        lec_arp_clear_vccs(entry);
-                        del_timer(&entry->timer);
-                        kfree(entry);
-                }
-                else {              /* put it back to the list */
-                        entry->next = priv->lec_arp_empty_ones;
-                        priv->lec_arp_empty_ones = entry;
-                }
-                entry = next;
-        }
-        
-        entry = priv->lec_no_forward;
-        priv->lec_no_forward = NULL;
-        while (entry != NULL) {
-                next = entry->next;
-                if (entry->recv_vcc == vcc) {
-                        lec_arp_clear_vccs(entry);
-                        del_timer(&entry->timer);
-                        kfree(entry);
-                }
-                else {
-                        entry->next = priv->lec_no_forward;
-                        priv->lec_no_forward = entry;
-                }
-                entry = next;
-        }
-
-        entry = priv->mcast_fwds;
-        priv->mcast_fwds = NULL;
-        while (entry != NULL) {
-                next = entry->next;
-                if (entry->recv_vcc == vcc) {
-                        lec_arp_clear_vccs(entry);
-                        /* No timer, LANEv2 7.1.20 and 2.3.5.3 */
-                        kfree(entry);
-                }
-                else {
-                        entry->next = priv->mcast_fwds;
-                        priv->mcast_fwds = entry;
-                }
-                entry = next;
-        }
+	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+		for (entry = priv->lec_arp_tables[i]; entry; entry = next) {
+			next = entry->next;
+			if (vcc == entry->vcc) {
+				lec_arp_remove(priv, entry);
+				kfree(entry);
+				if (priv->mcast_vcc == vcc) {
+					priv->mcast_vcc = NULL;
+				}
+			}
+		}
+	}
+
+	entry = priv->lec_arp_empty_ones;
+	priv->lec_arp_empty_ones = NULL;
+	while (entry != NULL) {
+		next = entry->next;
+		if (entry->vcc == vcc) {	/* leave it out from the list */
+			lec_arp_clear_vccs(entry);
+			del_timer(&entry->timer);
+			kfree(entry);
+		} else {			/* put it back to the list */
+			entry->next = priv->lec_arp_empty_ones;
+			priv->lec_arp_empty_ones = entry;
+		}
+		entry = next;
+	}
+
+	entry = priv->lec_no_forward;
+	priv->lec_no_forward = NULL;
+	while (entry != NULL) {
+		next = entry->next;
+		if (entry->recv_vcc == vcc) {
+			lec_arp_clear_vccs(entry);
+			del_timer(&entry->timer);
+			kfree(entry);
+		} else {
+			entry->next = priv->lec_no_forward;
+			priv->lec_no_forward = entry;
+		}
+		entry = next;
+	}
+
+	entry = priv->mcast_fwds;
+	priv->mcast_fwds = NULL;
+	while (entry != NULL) {
+		next = entry->next;
+		if (entry->recv_vcc == vcc) {
+			lec_arp_clear_vccs(entry);
+			/* No timer, LANEv2 7.1.20 and 2.3.5.3 */
+			kfree(entry);
+		} else {
+			entry->next = priv->mcast_fwds;
+			priv->mcast_fwds = entry;
+		}
+		entry = next;
+	}
 
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 	dump_arp_table(priv);
@@ -2540,57 +2553,59 @@ lec_vcc_close(struct lec_priv *priv, str
 
 static void
 lec_arp_check_empties(struct lec_priv *priv,
-                      struct atm_vcc *vcc, struct sk_buff *skb)
+		      struct atm_vcc *vcc, struct sk_buff *skb)
 {
-        unsigned long flags;
-        struct lec_arp_table *entry, *prev;
-        struct lecdatahdr_8023 *hdr = (struct lecdatahdr_8023 *)skb->data;
-        unsigned char *src;
+	unsigned long flags;
+	struct lec_arp_table *entry, *prev;
+	struct lecdatahdr_8023 *hdr = (struct lecdatahdr_8023 *)skb->data;
+	unsigned char *src;
 #ifdef CONFIG_TR
-        struct lecdatahdr_8025 *tr_hdr = (struct lecdatahdr_8025 *)skb->data;
+	struct lecdatahdr_8025 *tr_hdr = (struct lecdatahdr_8025 *)skb->data;
 
-        if (priv->is_trdev) src = tr_hdr->h_source;
-        else
+	if (priv->is_trdev)
+		src = tr_hdr->h_source;
+	else
 #endif
-        src = hdr->h_source;
+		src = hdr->h_source;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-        entry = priv->lec_arp_empty_ones;
-        if (vcc == entry->vcc) {
-                del_timer(&entry->timer);
-                memcpy(entry->mac_addr, src, ETH_ALEN);
-                entry->status = ESI_FORWARD_DIRECT;
-                entry->last_used = jiffies;
-                priv->lec_arp_empty_ones = entry->next;
-                /* We might have got an entry */
-                if ((prev = lec_arp_find(priv,src))) {
-                        lec_arp_remove(priv, prev);
-                        kfree(prev);
-                }
-                lec_arp_add(priv, entry);
+	entry = priv->lec_arp_empty_ones;
+	if (vcc == entry->vcc) {
+		del_timer(&entry->timer);
+		memcpy(entry->mac_addr, src, ETH_ALEN);
+		entry->status = ESI_FORWARD_DIRECT;
+		entry->last_used = jiffies;
+		priv->lec_arp_empty_ones = entry->next;
+		/* We might have got an entry */
+		if ((prev = lec_arp_find(priv, src))) {
+			lec_arp_remove(priv, prev);
+			kfree(prev);
+		}
+		lec_arp_add(priv, entry);
 		goto out;
-        }
-        prev = entry;
-        entry = entry->next;
-        while (entry && entry->vcc != vcc) {
-                prev= entry;
-                entry = entry->next;
-        }
-        if (!entry) {
-                DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
+	}
+	prev = entry;
+	entry = entry->next;
+	while (entry && entry->vcc != vcc) {
+		prev = entry;
+		entry = entry->next;
+	}
+	if (!entry) {
+		DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
 		goto out;
-        }
-        del_timer(&entry->timer);
-        memcpy(entry->mac_addr, src, ETH_ALEN);
-        entry->status = ESI_FORWARD_DIRECT;
-        entry->last_used = jiffies;
-        prev->next = entry->next;
-        if ((prev = lec_arp_find(priv, src))) {
-                lec_arp_remove(priv, prev);
-                kfree(prev);
-        }
-        lec_arp_add(priv, entry);
+	}
+	del_timer(&entry->timer);
+	memcpy(entry->mac_addr, src, ETH_ALEN);
+	entry->status = ESI_FORWARD_DIRECT;
+	entry->last_used = jiffies;
+	prev->next = entry->next;
+	if ((prev = lec_arp_find(priv, src))) {
+		lec_arp_remove(priv, prev);
+		kfree(prev);
+	}
+	lec_arp_add(priv, entry);
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
+
 MODULE_LICENSE("GPL");
