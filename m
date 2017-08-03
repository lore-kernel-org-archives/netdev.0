From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 4/4] ulp: Documention for ULP infrastructure
Date: Thu,  3 Aug 2017 12:31:44 -0700
Message-ID: <20170803193144.24108-5-tom@quantonium.net>
References: <20170803193144.24108-1-tom@quantonium.net>
Cc: rohit@quantonium.net, davejwatson@fb.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37802 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751897AbdHCTcP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 15:32:15 -0400
Received: by mail-pg0-f52.google.com with SMTP id y129so9931265pgy.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 12:32:15 -0700 (PDT)
In-Reply-To: <20170803193144.24108-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a doc in Documentation/networking

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 Documentation/networking/ulp.txt | 82 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 82 insertions(+)
 create mode 100644 Documentation/networking/ulp.txt

diff --git a/Documentation/networking/ulp.txt b/Documentation/networking/ulp.txt
new file mode 100644
index 000000000000..4d830314b0ff
--- /dev/null
+++ b/Documentation/networking/ulp.txt
@@ -0,0 +1,82 @@
+Upper Layer Protocol (ULP) Infrastructure
+=========================================
+
+The ULP kernel infrastructure provides a means to hook upper layer
+protocol support on a socket. A module may register a ULP hook
+in the kernel. ULP processing is enabled by a setsockopt on a socket
+that specifies the name of the registered ULP to invoked. An
+initialization function is defined for each ULP that can change the
+function entry points of the socket (sendmsg, rcvmsg, etc.) or change
+the socket in other fundamental ways.
+
+Note, no synchronization is enforced between the setsockopt to enable
+a ULP and ongoing asynchronous operations on the socket (such as a
+blocked read). If synchronization is required this must be handled by
+the ULP and caller.
+
+User interface
+==============
+
+The structure for the socket SOL_ULP options is defined in socket.h.
+
+Example to enable "my_ulp" ULP on a socket:
+
+struct ulp_config ulpc = {
+    .ulp_name = "my_ulp",
+};
+
+setsockopt(sock, SOL_SOCKET, SO_ULP, &ulpc, sizeof(ulpc))
+
+The ulp_config includes a "__u8 ulp_params[0]" filled that may be used
+to refer ULP specific parameters being set.
+
+Kernel interface
+================
+
+The interface for ULP infrastructure is defined in net/ulp_sock.h.
+
+ULP registration functions
+--------------------------
+
+int ulp_register(struct ulp_ops *type)
+
+     Called to register a ULP. The ulp_ops structure is described below.
+
+void ulp_unregister(struct ulp_ops *type);
+
+     Called to unregister a ULP.
+
+ulp_ops structure
+-----------------
+
+int (*init)(struct sock *sk, char __user *optval, int len)
+
+     Initialization function for the ULP. This is called from setsockopt
+     when the ULP name in the ulp_config argument matches the registered
+     ULP. optval is a userspace pointer to the ULP specific parameters.
+     len is the length of the ULP specific parameters.
+
+void (*release)(struct sock *sk)
+
+     Called when socket is being destroyed. The ULP implementation
+     should cancel any asynchronous operations (such as timers) and
+     release any acquired resources.
+
+int (*get_params)(struct sock *sk, char __user *optval, int *optlen)
+
+     Get the ULP specific parameters previous set in the init function
+     for the ULP. Note that optlen is a pointer to kernel memory.
+
+char name[ULP_NAME_MAX]
+
+     Name of the ULP. Must be NULL terminated.
+
+struct module *owner
+
+     Corresponding owner for ref count.
+
+Author
+======
+
+Tom Herbert (tom@quantonium.net)
+
-- 
2.11.0
