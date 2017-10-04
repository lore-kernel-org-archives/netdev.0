From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Wed, 4 Oct 2017 11:17:24 -0700
Message-ID: <20171004111724.29a4d7ff@cakuba.netronome.com>
References: <20171003200546.165731-1-mka@chromium.org>
        <20171003145000.53683e21@cakuba>
        <CAAMbb05G=HBQweiWqYva_9zTnQqAcwMhJ0yYBUi26T04YA4CxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthias Kaehlcke <mka@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Renato Golin <renato.golin@linaro.org>,
        Guenter Roeck <groeck@chromium.org>,
        Doug Anderson <dianders@chromium.org>
To: Manoj Gupta <manojgupta@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAMbb05G=HBQweiWqYva_9zTnQqAcwMhJ0yYBUi26T04YA4CxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2017 10:42:42 -0700, Manoj Gupta wrote:
> Hi Jakub,
> 
> I had discussed about supporting this code with some clang developers.
> However, the consensus was this code relies on a specific GCC optimizer
> behavior and Clang does not share the same behavior by design.

Hm.  I find surprising that constant propagation to inlined functions
is considered something GCC-specific rather than obvious/basic.

> Note that even GCC can't compile this code at -O0.

Yes, that makes me feel uncomfortable...  Could you try this?

-------8<-------

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index f6f7c085f8e0..47251396fcae 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -469,10 +469,10 @@ int nfp_eth_set_configured(struct nfp_cpp *cpp, unsigned int idx, bool configed)
 	return nfp_eth_config_commit_end(nsp);
 }
 
-/* Force inline, FIELD_* macroes require masks to be compilation-time known */
-static __always_inline int
+static int
 nfp_eth_set_bit_config(struct nfp_nsp *nsp, unsigned int raw_idx,
-		       const u64 mask, unsigned int val, const u64 ctrl_bit)
+		       const u64 mask, const unsigned int shift,
+		       unsigned int val, const u64 ctrl_bit)
 {
 	union eth_table_entry *entries = nfp_nsp_config_entries(nsp);
 	unsigned int idx = nfp_nsp_config_idx(nsp);
@@ -489,11 +489,11 @@ nfp_eth_set_bit_config(struct nfp_nsp *nsp, unsigned int raw_idx,
 
 	/* Check if we are already in requested state */
 	reg = le64_to_cpu(entries[idx].raw[raw_idx]);
-	if (val == FIELD_GET(mask, reg))
+	if (val == (reg & mask) >> shift)
 		return 0;
 
 	reg &= ~mask;
-	reg |= FIELD_PREP(mask, val);
+	reg |= (val << shift) & mask;
 	entries[idx].raw[raw_idx] = cpu_to_le64(reg);
 
 	entries[idx].control |= cpu_to_le64(ctrl_bit);
@@ -503,6 +503,13 @@ nfp_eth_set_bit_config(struct nfp_nsp *nsp, unsigned int raw_idx,
 	return 0;
 }
 
+#define NFP_ETH_SET_BIT_CONFIG(nsp, raw_idx, mask, val, ctrl_bit)	\
+	({								\
+		__BF_FIELD_CHECK(mask, 0ULL, val, "NFP_ETH_SET_BIT_CONFIG: "); \
+		nfp_eth_set_bit_config(nsp, raw_idx, mask, __bf_shf(mask), \
+				       val, ctrl_bit);			\
+	})
+
 /**
  * __nfp_eth_set_aneg() - set PHY autonegotiation control bit
  * @nsp:	NFP NSP handle returned from nfp_eth_config_start()
@@ -515,7 +522,7 @@ nfp_eth_set_bit_config(struct nfp_nsp *nsp, unsigned int raw_idx,
  */
 int __nfp_eth_set_aneg(struct nfp_nsp *nsp, enum nfp_eth_aneg mode)
 {
-	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_STATE,
+	return NFP_ETH_SET_BIT_CONFIG(nsp, NSP_ETH_RAW_STATE,
 				      NSP_ETH_STATE_ANEG, mode,
 				      NSP_ETH_CTRL_SET_ANEG);
 }
@@ -544,7 +551,7 @@ int __nfp_eth_set_speed(struct nfp_nsp *nsp, unsigned int speed)
 		return -EINVAL;
 	}
 
-	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_STATE,
+	return NFP_ETH_SET_BIT_CONFIG(nsp, NSP_ETH_RAW_STATE,
 				      NSP_ETH_STATE_RATE, rate,
 				      NSP_ETH_CTRL_SET_RATE);
 }
@@ -561,6 +568,6 @@ int __nfp_eth_set_speed(struct nfp_nsp *nsp, unsigned int speed)
  */
 int __nfp_eth_set_split(struct nfp_nsp *nsp, unsigned int lanes)
 {
-	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_PORT, NSP_ETH_PORT_LANES,
+	return NFP_ETH_SET_BIT_CONFIG(nsp, NSP_ETH_RAW_PORT, NSP_ETH_PORT_LANES,
 				      lanes, NSP_ETH_CTRL_SET_LANES);
 }
-- 
2.14.1
