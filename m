From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Tue,  3 Oct 2017 13:05:46 -0700
Message-ID: <20171003200546.165731-1-mka@chromium.org>
Cc: oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Renato Golin <renato.golin@linaro.org>,
        Manoj Gupta <manojgupta@chromium.org>,
        Guenter Roeck <groeck@chromium.org>,
        Doug Anderson <dianders@chromium.org>,
        Matthias Kaehlcke <mka@chromium.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nfp_eth_set_bit_config() is marked as __always_inline to allow gcc to
identify the 'mask' parameter as known to be constant at compile time,
which is required to use the FIELD_GET() macro.

The forced inlining does the trick for gcc, but for kernel builds with
clang it results in undefined symbols:

drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.o: In function
  `__nfp_eth_set_aneg':
drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c:(.text+0x787):
  undefined reference to `__compiletime_assert_492'
drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c:(.text+0x7b1):
  undefined reference to `__compiletime_assert_496'

These __compiletime_assert_xyx() calls would have been optimized away if
the compiler had seen 'mask' as a constant.

Convert nfp_eth_set_bit_config() into a macro, which allows both gcc and
clang to identify 'mask' as a compile time constant.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
I am aware that a lengthy macro is not a pretty solution, I'm open for
better suggestions.

Note: The patch has been build-tested only since I don't have any NFP
hardware.

 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   | 67 +++++++++++-----------
 1 file changed, 34 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
index f6f7c085f8e0..e9c635867918 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c
@@ -469,39 +469,40 @@ int nfp_eth_set_configured(struct nfp_cpp *cpp, unsigned int idx, bool configed)
 	return nfp_eth_config_commit_end(nsp);
 }
 
-/* Force inline, FIELD_* macroes require masks to be compilation-time known */
-static __always_inline int
-nfp_eth_set_bit_config(struct nfp_nsp *nsp, unsigned int raw_idx,
-		       const u64 mask, unsigned int val, const u64 ctrl_bit)
-{
-	union eth_table_entry *entries = nfp_nsp_config_entries(nsp);
-	unsigned int idx = nfp_nsp_config_idx(nsp);
-	u64 reg;
-
-	/* Note: set features were added in ABI 0.14 but the error
-	 *	 codes were initially not populated correctly.
-	 */
-	if (nfp_nsp_get_abi_ver_minor(nsp) < 17) {
-		nfp_err(nfp_nsp_cpp(nsp),
-			"set operations not supported, please update flash\n");
-		return -EOPNOTSUPP;
-	}
-
-	/* Check if we are already in requested state */
-	reg = le64_to_cpu(entries[idx].raw[raw_idx]);
-	if (val == FIELD_GET(mask, reg))
-		return 0;
-
-	reg &= ~mask;
-	reg |= FIELD_PREP(mask, val);
-	entries[idx].raw[raw_idx] = cpu_to_le64(reg);
-
-	entries[idx].control |= cpu_to_le64(ctrl_bit);
-
-	nfp_nsp_config_set_modified(nsp, true);
-
-	return 0;
-}
+#define nfp_eth_set_bit_config(nsp, raw_idx, mask, val, ctrl_bit)	\
+({									\
+	union eth_table_entry *entries = nfp_nsp_config_entries(nsp);	\
+	unsigned int idx = nfp_nsp_config_idx(nsp);			\
+	u64 reg;							\
+	int rc;								\
+									\
+	/* Note: set features were added in ABI 0.14 but the error */	\
+	/*	 codes were initially not populated correctly.	   */	\
+	if (nfp_nsp_get_abi_ver_minor(nsp) < 17) {			\
+		nfp_err(nfp_nsp_cpp(nsp),				\
+			"set operations not supported, please update flash\n"); \
+		rc = -EOPNOTSUPP;					\
+		goto out;						\
+	}								\
+									\
+	rc = 0;								\
+									\
+	/* Check if we are already in requested state */		\
+	reg = le64_to_cpu(entries[idx].raw[raw_idx]);			\
+	if (val == FIELD_GET(mask, reg))				\
+		goto out;						\
+									\
+	reg &= ~mask;							\
+	reg |= FIELD_PREP(mask, val);					\
+	entries[idx].raw[raw_idx] = cpu_to_le64(reg);			\
+									\
+	entries[idx].control |= cpu_to_le64(ctrl_bit);			\
+									\
+	nfp_nsp_config_set_modified(nsp, true);				\
+									\
+out:									\
+	rc;								\
+})
 
 /**
  * __nfp_eth_set_aneg() - set PHY autonegotiation control bit
-- 
2.14.2.920.gcf0c67979c-goog
