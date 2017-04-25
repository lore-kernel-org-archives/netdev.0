From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 1/4] netlink: make extended ACK setting NULL-friendly
Date: Tue, 25 Apr 2017 01:06:41 -0700
Message-ID: <20170425080644.122536-2-jakub.kicinski@netronome.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34634 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1175186AbdDYIIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:08:14 -0400
Received: by mail-pg0-f50.google.com with SMTP id v1so13129380pgv.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 01:08:14 -0700 (PDT)
In-Reply-To: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we propagate extended ack reporting throughout various paths in
the kernel it may happen that the same function is called with the
extended ack parameter passed as NULL.  Make the NL_SET_ERR_MSG()
macro simply print the message to the logs if that happens.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/netlink.h | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 8d2a8924705c..b59cfbf2e2c7 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -86,10 +86,14 @@ struct netlink_ext_ack {
  * Currently string formatting is not supported (due
  * to the lack of an output buffer.)
  */
-#define NL_SET_ERR_MSG(extack, msg) do {	\
-	static const char _msg[] = (msg);	\
-						\
-	(extack)->_msg = _msg;			\
+#define NL_SET_ERR_MSG(extack, msg) do {		\
+	struct netlink_ext_ack *_extack = (extack);	\
+	static const char _msg[] = (msg);		\
+							\
+	if (_extack)					\
+		_extack->_msg = _msg;			\
+	else						\
+		pr_info("%s\n", _msg);			\
 } while (0)
 
 extern void netlink_kernel_release(struct sock *sk);
-- 
2.11.0
