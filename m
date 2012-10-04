From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [RFC:PATCH 3.6.0-] net/ipconfig: Extend ipconfig retries to device open
Date: Thu,  4 Oct 2012 16:38:43 +0100
Message-ID: <1349365123-25826-1-git-send-email-srinivas.kandagatla@st.com>
Cc: srinivas.kandagatla@st.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:45638 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965609Ab2JDPkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 11:40:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds retries to ipconfig at device open, the reason to do
this is: Lets say If some mdio bus driver decide to use defered probe
when it does not find any phys on the bus. The same mdio-bus driver is
re-probed as part of lateinit calls. However ipconfig also fits into
lateinit calls, so if ipconfig is called before the re-probe of mdio-bus
driver, the mac driver will fail to find a valid PHY on the mdio-bus.

Real use case here, is that for phy modes like RMII where the clock to
the PHY should be supplied by MAC which can only happen once MAC driver
is setup. In my setup Am using stmmac MAC driver and mdio-gpio driver.

Moreover ipconfig code already uses retries in dynamic ip case, so
extending it to device open would help cases as described.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
Hi All, 
Recently I did try defered probe to address a sequencing issue with 
our STMMAC and mdio-gpio driver when PHY is in RMII mode.

Things did not work as expected, because ipconfig and 
defered probe both of them are called at lateinit call level.
So I was back to sequencing problem again.

As, ipconfig code already uses retries in dynamic ip case, so
extending it to device open helped in my case.

Comments?
Am open for any suggestions to address this issue.

Thanks,
srini


 net/ipv4/ipconfig.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 67e8a6b..c30505e 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1375,9 +1375,7 @@ static int __init wait_for_devices(void)
 static int __init ip_auto_config(void)
 {
 	__be32 addr;
-#ifdef IPCONFIG_DYNAMIC
 	int retries = CONF_OPEN_RETRIES;
-#endif
 	int err;
 
 #ifdef CONFIG_PROC_FS
@@ -1398,12 +1396,22 @@ static int __init ip_auto_config(void)
 
 	/* Setup all network devices */
 	err = ic_open_devs();
+
+	if (err && --retries) {
+		pr_info("IP-Config: Reopening network devices...\n");
+		ssleep(1);
+		goto try_try_again;
+	}
+
 	if (err)
 		return err;
 
 	/* Give drivers a chance to settle */
 	msleep(CONF_POST_OPEN);
 
+#ifdef IPCONFIG_DYNAMIC
+	retries = CONF_OPEN_RETRIES;
+#endif
 	/*
 	 * If the config information is insufficient (e.g., our IP address or
 	 * IP address of the boot server is missing or we have multiple network
-- 
1.7.0.4
