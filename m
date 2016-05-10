From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 May 2016 11:29:05 +1000
Message-ID: <20160510112905.5bffcad8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bjorn Andersson <bjorn.andersson@sonymobile.com>,
	Andy Gross <andy.gross@linaro.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/qrtr/smd.c:106:14: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
  .callback = qcom_smd_qrtr_callback,
              ^
net/qrtr/smd.c:106:14: note: (near initialization for 'qcom_smd_qrtr_driver.callback')

Caused by commit

  bdabad3e363d ("net: Add Qualcomm IPC router")

interacting with commit

  b853cb9628bf ("soc: qcom: smd: Make callback pass channel reference")

from the arm-soc tree.

I added the following merge fix patch (and it turned out I needed the
new stubs).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 May 2016 11:14:06 +1000
Subject: [PATCH] soc: qcom: smd: fix for Qualcomm IPC router and callback API
 change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/soc/qcom/smd.h | 9 +++++++++
 net/qrtr/smd.c               | 9 ++++++---
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/linux/soc/qcom/smd.h b/include/linux/soc/qcom/smd.h
index 086e36d76be9..fbebbfc82ed3 100644
--- a/include/linux/soc/qcom/smd.h
+++ b/include/linux/soc/qcom/smd.h
@@ -70,6 +70,15 @@ static inline void qcom_smd_driver_unregister(struct qcom_smd_driver *drv)
 	WARN_ON(1);
 }
 
+static inline void *qcom_smd_get_drvdata(struct qcom_smd_channel *channel)
+{
+	return NULL;
+}
+
+static inline void qcom_smd_set_drvdata(struct qcom_smd_channel *channel, void *data)
+{
+}
+
 static inline int qcom_smd_send(struct qcom_smd_channel *channel,
 				const void *data, int len)
 {
diff --git a/net/qrtr/smd.c b/net/qrtr/smd.c
index 84ebce73aa23..0d11132b3370 100644
--- a/net/qrtr/smd.c
+++ b/net/qrtr/smd.c
@@ -21,13 +21,14 @@
 struct qrtr_smd_dev {
 	struct qrtr_endpoint ep;
 	struct qcom_smd_channel *channel;
+	struct device *dev;
 };
 
 /* from smd to qrtr */
-static int qcom_smd_qrtr_callback(struct qcom_smd_device *sdev,
+static int qcom_smd_qrtr_callback(struct qcom_smd_channel *channel,
 				  const void *data, size_t len)
 {
-	struct qrtr_smd_dev *qdev = dev_get_drvdata(&sdev->dev);
+	struct qrtr_smd_dev *qdev = qcom_smd_get_drvdata(channel);
 	int rc;
 
 	if (!qdev)
@@ -35,7 +36,7 @@ static int qcom_smd_qrtr_callback(struct qcom_smd_device *sdev,
 
 	rc = qrtr_endpoint_post(&qdev->ep, data, len);
 	if (rc == -EINVAL) {
-		dev_err(&sdev->dev, "invalid ipcrouter packet\n");
+		dev_err(qdev->dev, "invalid ipcrouter packet\n");
 		/* return 0 to let smd drop the packet */
 		rc = 0;
 	}
@@ -73,12 +74,14 @@ static int qcom_smd_qrtr_probe(struct qcom_smd_device *sdev)
 		return -ENOMEM;
 
 	qdev->channel = sdev->channel;
+	qdev->dev = &sdev->dev;
 	qdev->ep.xmit = qcom_smd_qrtr_send;
 
 	rc = qrtr_endpoint_register(&qdev->ep, QRTR_EP_NID_AUTO);
 	if (rc)
 		return rc;
 
+	qcom_smd_set_drvdata(sdev->channel, qdev);
 	dev_set_drvdata(&sdev->dev, qdev);
 
 	dev_dbg(&sdev->dev, "Qualcomm SMD QRTR driver probed\n");
-- 
2.7.0

-- 
Cheers,
Stephen Rothwell
