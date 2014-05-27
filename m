From: frank.blaschka@de.ibm.com
Subject: [patch 4/4] s390/net: fix format string mismatches
Date: Tue, 27 May 2014 11:13:45 +0200
Message-ID: <20140527091400.422890684@de.ibm.com>
References: <20140527091341.417448231@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Toralf Foerster <toralf.foerster@gmx.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:46373 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbaE0JOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 05:14:30 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 27 May 2014 10:14:06 +0100
Content-Disposition: inline; filename=608-net-format-strings.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

cppcheck blamed some issues in drivers/s390/net/...
They are fixed here.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reported-by: Toralf Foerster <toralf.foerster@gmx.de>
---
 drivers/s390/net/ctcm_sysfs.c   | 14 +++++++++-----
 drivers/s390/net/lcs.c          | 13 +++++++++----
 drivers/s390/net/qeth_l3_main.c |  2 +-
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/s390/net/ctcm_sysfs.c b/drivers/s390/net/ctcm_sysfs.c
index 985b5dc..883f713 100644
--- a/drivers/s390/net/ctcm_sysfs.c
+++ b/drivers/s390/net/ctcm_sysfs.c
@@ -34,8 +34,9 @@ static ssize_t ctcm_buffer_write(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct net_device *ndev;
-	int bs1;
+	unsigned int bs1;
 	struct ctcm_priv *priv = dev_get_drvdata(dev);
+	int rc;
 
 	ndev = priv->channel[CTCM_READ]->netdev;
 	if (!(priv && priv->channel[CTCM_READ] && ndev)) {
@@ -43,7 +44,9 @@ static ssize_t ctcm_buffer_write(struct device *dev,
 		return -ENODEV;
 	}
 
-	sscanf(buf, "%u", &bs1);
+	rc =  sscanf(buf, "%u", &bs1);
+	if (rc != 1)
+					goto einval;
 	if (bs1 > CTCM_BUFSIZE_LIMIT)
 					goto einval;
 	if (bs1 < (576 + LL_HEADER_LENGTH + 2))
@@ -143,13 +146,14 @@ static ssize_t ctcm_proto_show(struct device *dev,
 static ssize_t ctcm_proto_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	int value;
+	int value, rc;
 	struct ctcm_priv *priv = dev_get_drvdata(dev);
 
 	if (!priv)
 		return -ENODEV;
-	sscanf(buf, "%u", &value);
-	if (!((value == CTCM_PROTO_S390)  ||
+	rc = sscanf(buf, "%d", &value);
+	if ((rc != 1) ||
+	    !((value == CTCM_PROTO_S390)  ||
 	      (value == CTCM_PROTO_LINUX) ||
 	      (value == CTCM_PROTO_MPC) ||
 	      (value == CTCM_PROTO_OS390)))
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 8d5d969..0a7d87c 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1943,14 +1943,16 @@ static ssize_t
 lcs_portno_store (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
 {
         struct lcs_card *card;
-        int value;
+	int value, rc;
 
 	card = dev_get_drvdata(dev);
 
         if (!card)
                 return 0;
 
-        sscanf(buf, "%u", &value);
+	rc = sscanf(buf, "%d", &value);
+	if (rc != 1)
+		return -EINVAL;
         /* TODO: sanity checks */
         card->portno = value;
 
@@ -1997,14 +1999,17 @@ static ssize_t
 lcs_timeout_store (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
 {
         struct lcs_card *card;
-        int value;
+	unsigned int value;
+	int rc;
 
 	card = dev_get_drvdata(dev);
 
         if (!card)
                 return 0;
 
-        sscanf(buf, "%u", &value);
+	rc = sscanf(buf, "%u", &value);
+	if (rc != 1)
+		return -EINVAL;
         /* TODO: sanity checks */
         card->lancmd_timeout = value;
 
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c8d91d7..491be1a 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -63,7 +63,7 @@ void qeth_l3_ipaddr4_to_string(const __u8 *addr, char *buf)
 int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
 {
 	int count = 0, rc = 0;
-	int in[4];
+	unsigned int in[4];
 	char c;
 
 	rc = sscanf(buf, "%u.%u.%u.%u%c",
