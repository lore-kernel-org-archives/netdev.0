From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/4] netlink: add NULL-friendly helper for setting extended ACK message
Date: Sun, 30 Apr 2017 21:46:45 -0700
Message-ID: <20170501044648.13022-2-jakub.kicinski@netronome.com>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35528 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951827AbdEAErP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 00:47:15 -0400
Received: by mail-pg0-f41.google.com with SMTP id o3so35735619pgn.2
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 21:47:15 -0700 (PDT)
In-Reply-To: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we propagate extended ack reporting throughout various paths in
the kernel it may be that the same function is called with the
extended ack parameter passed as NULL.  One place where that happens
is in drivers which have a centralized reconfiguration function
called both from ndos and from ethtool_ops.  Add a new helper for
setting the error message in such conditions.

Existing helper is left as is to encourage propagating the ext act
fully wherever possible.  It also makes it clear in the code which
messages may be lost due to ext ack being NULL.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/netlink.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 8d2a8924705c..c20395edf2de 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -92,6 +92,14 @@ struct netlink_ext_ack {
 	(extack)->_msg = _msg;			\
 } while (0)
 
+#define NL_MOD_TRY_SET_ERR_MSG(extack, msg) do {		\
+	static const char _msg[] = KBUILD_MODNAME ": " msg;	\
+	struct netlink_ext_ack *_extack = (extack);		\
+								\
+	if (_extack)						\
+		_extack->_msg = _msg;				\
+} while (0)
+
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
-- 
2.11.0
