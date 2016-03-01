From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH] ethtool: check size of user memory before copying strings and stats
Date: Tue,  1 Mar 2016 13:31:09 -0800
Message-ID: <1456867869-14350-1-git-send-email-jacob.e.keller@intel.com>
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24975 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbcCAVbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 16:31:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since at least 2005, (oldest commit in ethtool.git), the userspace
ethtool implementation has given the size of the memory it has allocated
as the actual size in the ethtool data structures. We previously blindly
ignore this and overwrite the requested size with the current size
returned by .get_strings or .get_sset_count. This can cause problems if
these values aren't static.

Since ethtool has always given the expected size, first perform a check
to ensure that the current size is no larger than the requested size. If
it is, return with -ENOMEM, as we do not have enough memory to save the
results.

This protects against buffer overrun should the driver have a non-static
number of statistics, tests, or private flags, and the value changes
between the ethtool userspace call to .get_sset_count and the actual
calls to populate the requested memory.

Update the header files to indicate the expected behavior of userspace.
This change shouldn't break current or previous userspace as they have
consistently included the length correctly since as far back as we can
check.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
---
 include/uapi/linux/ethtool.h | 19 +++++++++++++------
 net/core/ethtool.c           | 12 ++++++++++++
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 37fd6dc33de4..0d7f4855dc0b 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -560,13 +560,16 @@ enum ethtool_stringset {
  * struct ethtool_gstrings - string set for data tagging
  * @cmd: Command number = %ETHTOOL_GSTRINGS
  * @string_set: String set ID; one of &enum ethtool_stringset
- * @len: On return, the number of strings in the string set
+ * @len: On entry, the number of strings which fit into the allocated space.
+ *       On return, the number of strings in the string set
  * @data: Buffer for strings.  Each string is null-padded to a size of
  *	%ETH_GSTRING_LEN.
  *
  * Users must use %ETHTOOL_GSSET_INFO to find the number of strings in
  * the string set.  They must allocate a buffer of the appropriate
- * size immediately following this structure.
+ * size immediately following this structure. They must set the len to the
+ * number of strings which will fit into the allocated space following this
+ * structure.
  */
 struct ethtool_gstrings {
 	__u32	cmd;
@@ -622,13 +625,15 @@ enum ethtool_test_flags {
  * @flags: A bitmask of flags from &enum ethtool_test_flags.  Some
  *	flags may be set by the user on entry; others may be set by
  *	the driver on return.
- * @len: On return, the number of test results
+ * @len: On entry, the number of test results that fit in the allocated space
+ *       On return, the number of test results
  * @data: Array of test results
  *
  * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
  * number of test results that will be returned.  They must allocate a
  * buffer of the appropriate size (8 * number of results) immediately
- * following this structure.
+ * following this structure. They must set the len to the number of tests
+ * results which will fit into the allocated space following the structure.
  */
 struct ethtool_test {
 	__u32	cmd;
@@ -641,13 +646,15 @@ struct ethtool_test {
 /**
  * struct ethtool_stats - device-specific statistics
  * @cmd: Command number = %ETHTOOL_GSTATS
- * @n_stats: On return, the number of statistics
+ * @n_stats: On entry, the number of stats that fit into the allocated space.
+ *           On return, the number of statistics
  * @data: Array of statistics
  *
  * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
  * number of statistics that will be returned.  They must allocate a
  * buffer of the appropriate size (8 * number of statistics)
- * immediately following this structure.
+ * immediately following this structure. They must set n_stats to the number
+ * of stats which fit into the allocated space at the end of the structure.
  */
 struct ethtool_stats {
 	__u32	cmd;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 2966cd0d7c93..20abcc43787e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1766,6 +1766,9 @@ static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 	if (copy_from_user(&test, useraddr, sizeof(test)))
 		return -EFAULT;
 
+	if (test_len > test.len)
+		return -ENOMEM;
+
 	test.len = test_len;
 	data = kmalloc(test_len * sizeof(u64), GFP_USER);
 	if (!data)
@@ -1799,6 +1802,9 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 	if (ret < 0)
 		return ret;
 
+	if (ret > gstrings.len)
+		return -ENOMEM;
+
 	gstrings.len = ret;
 
 	data = kcalloc(gstrings.len, ETH_GSTRING_LEN, GFP_USER);
@@ -1898,6 +1904,9 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&stats, useraddr, sizeof(stats)))
 		return -EFAULT;
 
+	if (n_stats > stats.n_stats)
+		return -ENOMEM;
+
 	stats.n_stats = n_stats;
 	data = kmalloc(n_stats * sizeof(u64), GFP_USER);
 	if (!data)
@@ -1937,6 +1946,9 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&stats, useraddr, sizeof(stats)))
 		return -EFAULT;
 
+	if (n_stats > stats.n_stats)
+		return -ENOMEM;
+
 	stats.n_stats = n_stats;
 	data = kmalloc_array(n_stats, sizeof(u64), GFP_USER);
 	if (!data)
-- 
2.7.1.429.g45cd78e
