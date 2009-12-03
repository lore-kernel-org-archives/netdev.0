From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 05/18] Bluetooth: Implement raw output support for HIDP layer
Date: Thu,  3 Dec 2009 19:45:42 +0100
Message-ID: <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767AbZLCSp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:56 -0500
In-Reply-To: <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jkosina@suse.cz>

Implement raw output callback which is used by hidraw to send raw data to
the underlying device.

Without this patch, the userspace hidraw-based applications can't send
output reports to HID Bluetooth devices.

Reported-and-tested-by: Brian Gunn <bgunn@solekai.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hidp/core.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 49d8495..5697500 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -280,6 +280,13 @@ static int hidp_send_report(struct hidp_session *session, struct hid_report *rep
 	return hidp_queue_report(session, buf, rsize);
 }
 
+static int hidp_output_raw_report(struct hid_device *hid, unsigned char *data, size_t count)
+{
+	if (hidp_queue_report(hid->driver_data, data, count))
+		return -ENOMEM;
+	return count;
+}
+
 static void hidp_idle_timeout(unsigned long arg)
 {
 	struct hidp_session *session = (struct hidp_session *) arg;
@@ -785,6 +792,8 @@ static int hidp_setup_hid(struct hidp_session *session,
 	hid->dev.parent = hidp_get_device(session);
 	hid->ll_driver = &hidp_hid_driver;
 
+	hid->hid_output_raw_report = hidp_output_raw_report;
+
 	err = hid_add_device(hid);
 	if (err < 0)
 		goto failed;
-- 
1.6.5.2

