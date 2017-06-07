From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 4/4] net: qrtr: Inform open sockets about new controller
Date: Wed,  7 Jun 2017 14:07:39 -0700
Message-ID: <20170607210739.27263-5-bjorn.andersson@linaro.org>
References: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Cc: Arun Kumar Neelakantam <aneela@codeaurora.org>,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-kernel@vger.kernel.org, Courtney Cavin <ccavin@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170607210739.27263-1-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the higher level communication only deals with "services" the
a service directory is required to keep track of local and remote
services. In order for qrtr clients to be informed about when the
service directory implementation is available some event needs to be
passed to them.

Rather than introducing support for broadcasting such a message in-band
to all open local sockets we flag each socket with ENETRESET, as there
are no other expected operations that would benefit from having support
from locally broadcasting messages.

Cc: Courtney Cavin <ccavin@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index d7516098b5aa..c7a5d861906b 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -530,6 +530,26 @@ static int qrtr_port_assign(struct qrtr_sock *ipc, int *port)
 	return 0;
 }
 
+/* Reset all non-control ports */
+static void qrtr_reset_ports(void)
+{
+	struct qrtr_sock *ipc;
+	int id;
+
+	mutex_lock(&qrtr_port_lock);
+	idr_for_each_entry(&qrtr_ports, ipc, id) {
+		/* Don't reset control port */
+		if (id == 0)
+			continue;
+
+		sock_hold(&ipc->sk);
+		ipc->sk.sk_err = ENETRESET;
+		wake_up_interruptible(sk_sleep(&ipc->sk));
+		sock_put(&ipc->sk);
+	}
+	mutex_unlock(&qrtr_port_lock);
+}
+
 /* Bind socket to address.
  *
  * Socket should be locked upon call.
@@ -558,6 +578,10 @@ static int __qrtr_bind(struct socket *sock,
 
 	sock_reset_flag(sk, SOCK_ZAPPED);
 
+	/* Notify all open ports about the new controller */
+	if (port == QRTR_PORT_CTRL)
+		qrtr_reset_ports();
+
 	return 0;
 }
 
-- 
2.12.0
