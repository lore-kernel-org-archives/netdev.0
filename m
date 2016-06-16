From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v5 2/7] vmxnet3: introduce generalized command interface to configure the device
Date: Thu, 16 Jun 2016 10:51:54 -0700
Message-ID: <1466099519-39322-3-git-send-email-skhare@vmware.com>
References: <1466099519-39322-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Guolin Yang <gyang@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466099519-39322-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shared memory is used to exchange information between the vmxnet3 driver
and the emulation. In order to request emulation to perform a task, the
driver first populates specific fields in this shared memory and then
issues corresponding command by writing to the command register(CMD). The
layout of the shared memory was defined by vmxnet3 version 1 and cannot
be extended for every new command without breaking backward compatibility.

To address this problem, in vmxnet3 version 3, the emulation repurposed
a reserved field in the shared memory to represent command information
instead. For new commands, the driver first populates the command
information field in the shared memory and then issues the command. The
emulation interprets the data written to the command information depending
on the type of the command. This patch exposes this capability to the driver.

Signed-off-by: Guolin Yang <gyang@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 8345e0c..a26a69d 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -79,6 +79,7 @@ enum {
 	VMXNET3_CMD_RESERVED1,
 	VMXNET3_CMD_LOAD_PLUGIN,
 	VMXNET3_CMD_RESERVED2,
+	VMXNET3_CMD_RESERVED3,
 
 	VMXNET3_CMD_FIRST_GET = 0xF00D0000,
 	VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
@@ -612,6 +613,18 @@ struct Vmxnet3_RxQueueDesc {
 	u8				      __pad[88]; /* 128 aligned */
 };
 
+struct Vmxnet3_SetPolling {
+	u8					enablePolling;
+};
+
+/* If the command data <= 16 bytes, use the shared memory directly.
+ * otherwise, use variable length configuration descriptor.
+ */
+union Vmxnet3_CmdInfo {
+	struct Vmxnet3_VariableLenConfDesc	varConf;
+	struct Vmxnet3_SetPolling		setPolling;
+	__le64					data[2];
+};
 
 struct Vmxnet3_DSDevRead {
 	/* read-only region for device, read by dev in response to a SET cmd */
@@ -630,7 +643,14 @@ struct Vmxnet3_DriverShared {
 	__le32				pad;
 	struct Vmxnet3_DSDevRead	devRead;
 	__le32				ecr;
-	__le32				reserved[5];
+	__le32				reserved;
+	union {
+		__le32			reserved1[4];
+		union Vmxnet3_CmdInfo	cmdInfo; /* only valid in the context of
+						  * executing the relevant
+						  * command
+						  */
+	} cu;
 };
 
 
-- 
2.8.2
