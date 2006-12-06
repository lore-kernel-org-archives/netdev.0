From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 15/16] Spidernet RX Debugging printout
Date: Wed, 6 Dec 2006 17:49:23 -0600
Message-ID: <20061206234923.GO4649@austin.ibm.com>
References: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:42794 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937815AbWLFXt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 18:49:29 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6NnOOF014365
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 18:49:24 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6NnOed545264
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:49:24 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6NnNhq017239
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 16:49:24 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206223223.GH17931@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add some debugging and error printing.

The show_rx_chain() prints out the status of the rx chain,
which shows that the status of the descriptors gets
messed up after the second & subsequent RX ramfulls.

Print out contents of bad packets if error occurs.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

Index: linux-2.6.19-git7/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-git7.orig/drivers/net/spider_net.c	2006-12-06 16:03:18.000000000 -0600
+++ linux-2.6.19-git7/drivers/net/spider_net.c	2006-12-06 16:03:20.000000000 -0600
@@ -936,6 +936,34 @@ spider_net_pass_skb_up(struct spider_net
 	card->netdev_stats.rx_bytes += skb->len;
 }
 
+#ifdef DEBUG
+static void show_rx_chain(struct spider_net_card *card)
+{
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *start= chain->tail;
+	struct spider_net_descr *descr= start;
+	int status;
+
+	int cnt = 0;
+	int cstat = spider_net_get_descr_status(descr);
+	printk(KERN_INFO "RX chain tail at descr=%ld\n",
+	     (start - card->descr) - card->num_tx_desc);
+	status = cstat;
+	do
+	{
+		status = spider_net_get_descr_status(descr);
+		if (cstat != status) {
+			printk(KERN_INFO "Have %d descrs with stat=x%08x\n", cnt, cstat);
+			cstat = status;
+			cnt = 0;
+		}
+		cnt ++;
+		descr = descr->next;
+	} while (descr != start);
+	printk(KERN_INFO "Last %d descrs with stat=x%08x\n", cnt, cstat);
+}
+#endif
+
 /**
  * spider_net_decode_one_descr - Processes an RX descriptor
  * @card: card structure
@@ -1006,6 +1034,25 @@ spider_net_decode_one_descr(struct spide
 		goto bad_desc;
 	}
 
+	if (descr->dmac_cmd_status & 0xfefe) {
+		pr_err("%s: bad status, cmd_status=x%08x\n",
+			       card->netdev->name,
+			       descr->dmac_cmd_status);
+		pr_err("buf_addr=x%08x\n", descr->buf_addr);
+		pr_err("buf_size=x%08x\n", descr->buf_size);
+		pr_err("next_descr_addr=x%08x\n", descr->next_descr_addr);
+		pr_err("result_size=x%08x\n", descr->result_size);
+		pr_err("valid_size=x%08x\n", descr->valid_size);
+		pr_err("data_status=x%08x\n", descr->data_status);
+		pr_err("data_error=x%08x\n", descr->data_error);
+		pr_err("bus_addr=x%08x\n", descr->bus_addr);
+		pr_err("which=%ld\n",
+		       (descr - card->descr) - card->num_tx_desc);
+
+		card->spider_stats.rx_desc_error++;
+		goto bad_desc;
+	}
+
 	/* Ok, we've got a packet in descr */
 	spider_net_pass_skb_up(descr, card, napi);
 	descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
