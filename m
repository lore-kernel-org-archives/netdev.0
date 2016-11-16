From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 17 Nov 2016 10:46:30 +1100
Message-ID: <20161117104630.6044486f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michael Weiser <michael.weiser@gmx.de>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c

between commit:

  ba1ffd74df74 ("stmmac: fix PTP support for GMAC4")

from the net tree and commit:

  f8be0d78be6e ("net: ethernet: stmmac: change dma descriptors to __le32")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index a601f8d43b75,bec72d3103a1..000000000000
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@@ -211,18 -205,14 +212,18 @@@ static void dwmac4_rd_enable_tx_timesta
  
  static int dwmac4_wrback_get_tx_timestamp_status(struct dma_desc *p)
  {
 -	return (le32_to_cpu(p->des3) & TDES3_TIMESTAMP_STATUS)
 -		>> TDES3_TIMESTAMP_STATUS_SHIFT;
 +	/* Context type from W/B descriptor must be zero */
- 	if (p->des3 & TDES3_CONTEXT_TYPE)
++	if (le32_to_cpu(p->des3) & TDES3_CONTEXT_TYPE)
 +		return -EINVAL;
 +
 +	/* Tx Timestamp Status is 1 so des0 and des1'll have valid values */
- 	if (p->des3 & TDES3_TIMESTAMP_STATUS)
++	if (le32_to_cpu(p->des3) & TDES3_TIMESTAMP_STATUS)
 +		return 0;
 +
 +	return 1;
  }
  
 -/*  NOTE: For RX CTX bit has to be checked before
 - *  HAVE a specific function for TX and another one for RX
 - */
 -static u64 dwmac4_wrback_get_timestamp(void *desc, u32 ats)
 +static inline u64 dwmac4_get_timestamp(void *desc, u32 ats)
  {
  	struct dma_desc *p = (struct dma_desc *)desc;
  	u64 ns;
@@@ -234,54 -224,12 +235,54 @@@
  	return ns;
  }
  
 -static int dwmac4_context_get_rx_timestamp_status(void *desc, u32 ats)
 +static int dwmac4_rx_check_timestamp(void *desc)
 +{
 +	struct dma_desc *p = (struct dma_desc *)desc;
 +	u32 own, ctxt;
 +	int ret = 1;
 +
- 	own = p->des3 & RDES3_OWN;
- 	ctxt = ((p->des3 & RDES3_CONTEXT_DESCRIPTOR)
++	own = le32_to_cpu(p->des3) & RDES3_OWN;
++	ctxt = ((le32_to_cpu(p->des3) & RDES3_CONTEXT_DESCRIPTOR)
 +		>> RDES3_CONTEXT_DESCRIPTOR_SHIFT);
 +
 +	if (likely(!own && ctxt)) {
 +		if ((p->des0 == 0xffffffff) && (p->des1 == 0xffffffff))
 +			/* Corrupted value */
 +			ret = -EINVAL;
 +		else
 +			/* A valid Timestamp is ready to be read */
 +			ret = 0;
 +	}
 +
 +	/* Timestamp not ready */
 +	return ret;
 +}
 +
 +static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
  {
  	struct dma_desc *p = (struct dma_desc *)desc;
 +	int ret = -EINVAL;
 +
 +	/* Get the status from normal w/b descriptor */
- 	if (likely(p->des3 & TDES3_RS1V)) {
- 		if (likely(p->des1 & RDES1_TIMESTAMP_AVAILABLE)) {
++	if (likely(le32_to_cpu(p->des3) & TDES3_RS1V)) {
++		if (likely(le32_to_cpu(p->des1) & RDES1_TIMESTAMP_AVAILABLE)) {
 +			int i = 0;
 +
 +			/* Check if timestamp is OK from context descriptor */
 +			do {
 +				ret = dwmac4_rx_check_timestamp(desc);
 +				if (ret < 0)
 +					goto exit;
 +				i++;
  
 -	return (le32_to_cpu(p->des1) & RDES1_TIMESTAMP_AVAILABLE)
 -		>> RDES1_TIMESTAMP_AVAILABLE_SHIFT;
 +			} while ((ret == 1) || (i < 10));
 +
 +			if (i == 10)
 +				ret = -EBUSY;
 +		}
 +	}
 +exit:
 +	return ret;
  }
  
  static void dwmac4_rd_init_rx_desc(struct dma_desc *p, int disable_rx_ic,
