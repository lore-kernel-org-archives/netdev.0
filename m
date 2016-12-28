From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] net: ethernet: ti: davinci_cpdma: fix access to uninitialized variable in cpdma_chan_set_descs()
Date: Wed, 28 Dec 2016 17:42:13 -0600
Message-ID: <20161228234213.22166-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now below code sequence causes "Unable to handle kernel NULL pointer
dereference.." exception and system crash during CPSW CPDMA initialization:

cpsw_probe
|-cpdma_chan_create (TX channel)
  |-cpdma_chan_split_pool
    |-cpdma_chan_set_descs(for TX channels)
    |-cpdma_chan_set_descs(for RX channels) [1]

- and -
static void cpdma_chan_set_descs(struct cpdma_ctlr *ctlr,
				 int rx, int desc_num,
				 int per_ch_desc)
{
	struct cpdma_chan *chan, *most_chan = NULL;

...

	for (i = min; i < max; i++) {
		chan = ctlr->channels[i];
		if (!chan)
			continue;
...

		if (most_dnum < chan->desc_num) {
			most_dnum = chan->desc_num;
			most_chan = chan;
		}
	}
	/* use remains */
	most_chan->desc_num += desc_cnt; [2]
}

So, most_chan value will never be reassigned when cpdma_chan_set_descs() is
called second time [1], because there are no RX channels yet and system
will crash at [2].

Hence, fix the issue by checking most_chan for NULL before accessing it.

Fixes: 0fc6432cc78d ("net: ethernet: ti: davinci_cpdma: add weight function for channels")
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 36518fc..b349d572 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -708,7 +708,8 @@ static void cpdma_chan_set_descs(struct cpdma_ctlr *ctlr,
 		}
 	}
 	/* use remains */
-	most_chan->desc_num += desc_cnt;
+	if (most_chan)
+		most_chan->desc_num += desc_cnt;
 }
 
 /**
-- 
2.10.1.dirty
