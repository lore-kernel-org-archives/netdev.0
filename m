From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/7] net: ethernet: ti: cpdma: am437x: allow descs to be plased in ddr
Date: Thu, 1 Dec 2016 17:34:26 -0600
Message-ID: <20161201233432.6182-2-grygorii.strashko@ti.com>
References: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201233432.6182-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's observed that cpsw/cpdma is not working properly when CPPI
descriptors are placed in DDR instead of internal CPPI RAM on am437x
SoC:
- rx/tx silently stops processing packets;
- or - after boot it's working for sometime, but stuck once Network
load is increased (ping is working, but iperf is not).
(The same issue has not been reproduced on am335x and am57xx).

It seems that write to HDP register processed faster by interconnect
than writing of descriptor memory buffer in DDR, which is probably
caused by store buffer / write buffer differences as these function
are implemented differently across devices. So, to fix this i come up
with two changes:

1) all accesses to the channel register HDP/CP/RXFREE registers should
be done using sync IO accessors readl()/writel(), because all previous
memory writes writes have to be completed before starting channel
(write to HDP) or completing desc processing.

2) the change 1 only doesn't work on am437x and additional reading of
desc's field is required right after the new descriptor was filled
with data and before pointer on it will be stored in
prev_desc->hw_next field or HDP register.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c776e45..0924014 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -167,10 +167,10 @@ static struct cpdma_control_info controls[] = {
 
 /* various accessors */
 #define dma_reg_read(ctlr, ofs)		__raw_readl((ctlr)->dmaregs + (ofs))
-#define chan_read(chan, fld)		__raw_readl((chan)->fld)
+#define chan_read(chan, fld)		readl((chan)->fld)
 #define desc_read(desc, fld)		__raw_readl(&(desc)->fld)
 #define dma_reg_write(ctlr, ofs, v)	__raw_writel(v, (ctlr)->dmaregs + (ofs))
-#define chan_write(chan, fld, v)	__raw_writel(v, (chan)->fld)
+#define chan_write(chan, fld, v)	writel(v, (chan)->fld)
 #define desc_write(desc, fld, v)	__raw_writel((u32)(v), &(desc)->fld)
 
 #define cpdma_desc_to_port(chan, mode, directed)			\
@@ -1064,6 +1064,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 	desc_write(desc, sw_token,  token);
 	desc_write(desc, sw_buffer, buffer);
 	desc_write(desc, sw_len,    len);
+	desc_read(desc, sw_len);
 
 	__cpdma_chan_submit(chan, desc);
 
-- 
2.10.1
