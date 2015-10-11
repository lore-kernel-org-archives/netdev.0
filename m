From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: nhs: fix 32-bit build warning
Date: Sun, 11 Oct 2015 13:13:40 -0700
Message-ID: <1444594420.8012.34.camel@perches.com>
References: <8581924.9CPedieySC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	huangdaode <huangdaode@hisilicon.com>,
	Kenneth Lee <liguozhu@huawei.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0032.hostedemail.com ([216.40.44.32]:46967 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751409AbbJKUNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 16:13:44 -0400
In-Reply-To: <8581924.9CPedieySC@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-06 at 23:53 +0200, Arnd Bergmann wrote:
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
[]
> @@ -448,12 +448,12 @@ static ssize_t handles_show(struct device *dev,
>  		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
>  			    i++, h->eport_id, h->dev->name);
>  		for (j = 0; j < h->q_num; j++) {
> -			s += sprintf(buf + s, "\tqueue[%d] on 0x%llx\n",
> -				     j, (u64)h->qs[i]->io_base);
> -#define HANDEL_TX_MSG "\t\ttx_ring on 0x%llx:%u,%u,%u,%u,%u,%llu,%llu\n"
> +			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
> +				     j, h->qs[i]->io_base);
> +#define HANDEL_TX_MSG "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n"
>  			s += sprintf(buf + s,
>  				     HANDEL_TX_MSG,

Maybe one day remove the misspelled and
used once HANDEL_TX_MSG macro too.

Another possibility is to use a generally
smaller object code style like:

	char *s = buf;
	...
	s += sprintf(s, ...)
	...
	return s - buf;

instead of

	ssize_t s = 0;
	...
	s += sprintf(buf + s, ...)
	...
	return s;
---
 drivers/net/ethernet/hisilicon/hns/hnae.c | 35 +++++++++++++++----------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index f52e99a..d2af46f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -439,40 +439,39 @@ EXPORT_SYMBOL(hnae_ae_unregister);
 static ssize_t handles_show(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
-	ssize_t s = 0;
+	char *s = buf;
 	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
 	struct hnae_handle *h;
 	int i = 0, j;
 
 	list_for_each_entry_rcu(h, &hdev->handle_list, node) {
-		s += sprintf(buf + s, "handle %d (eport_id=%u from %s):\n",
-			    i++, h->eport_id, h->dev->name);
+		s += sprintf(s, "handle %d (eport_id=%u from %s):\n",
+			     i++, h->eport_id, h->dev->name);
 		for (j = 0; j < h->q_num; j++) {
-			s += sprintf(buf + s, "\tqueue[%d] on %p\n",
+			s += sprintf(s, "\tqueue[%d] on %p\n",
 				     j, h->qs[i]->io_base);
-#define HANDEL_TX_MSG "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n"
-			s += sprintf(buf + s,
-				     HANDEL_TX_MSG,
+			s += sprintf(s,
+				     "\t\ttx_ring on %p:%u,%u,%u,%u,%u,%llu,%llu\n",
 				     h->qs[i]->tx_ring.io_base,
 				     h->qs[i]->tx_ring.buf_size,
 				     h->qs[i]->tx_ring.desc_num,
 				     h->qs[i]->tx_ring.max_desc_num_per_pkt,
 				     h->qs[i]->tx_ring.max_raw_data_sz_per_desc,
 				     h->qs[i]->tx_ring.max_pkt_size,
-				 h->qs[i]->tx_ring.stats.sw_err_cnt,
-				 h->qs[i]->tx_ring.stats.io_err_cnt);
-			s += sprintf(buf + s,
-				"\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
-				h->qs[i]->rx_ring.io_base,
-				h->qs[i]->rx_ring.buf_size,
-				h->qs[i]->rx_ring.desc_num,
-				h->qs[i]->rx_ring.stats.sw_err_cnt,
-				h->qs[i]->rx_ring.stats.io_err_cnt,
-				h->qs[i]->rx_ring.stats.seg_pkt_cnt);
+				     h->qs[i]->tx_ring.stats.sw_err_cnt,
+				     h->qs[i]->tx_ring.stats.io_err_cnt);
+			s += sprintf(s,
+				     "\t\trx_ring on %p:%u,%u,%llu,%llu,%llu\n",
+				     h->qs[i]->rx_ring.io_base,
+				     h->qs[i]->rx_ring.buf_size,
+				     h->qs[i]->rx_ring.desc_num,
+				     h->qs[i]->rx_ring.stats.sw_err_cnt,
+				     h->qs[i]->rx_ring.stats.io_err_cnt,
+				     h->qs[i]->rx_ring.stats.seg_pkt_cnt);
 		}
 	}
 
-	return s;
+	return s - buf;
 }
 
 static DEVICE_ATTR_RO(handles);
