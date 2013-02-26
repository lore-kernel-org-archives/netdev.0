From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] proc connector: reject unprivileged listener bumps
Date: Mon, 25 Feb 2013 23:32:25 -0800
Message-ID: <20130226073225.GA15489@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org,
	Matt Helsley <matthltc@us.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While PROC_CN_MCAST_LISTEN/IGNORE is entirely advisory, it was possible
for an unprivileged user to turn off notifications for all listeners by
sending PROC_CN_MCAST_IGNORE. Instead, require the same privileges as
required for a multicast bind.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Matt Helsley <matthltc@us.ibm.com>
Cc: stable@vger.kernel.org
---
 drivers/connector/cn_proc.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index fce2000..1110478 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -313,6 +313,12 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 	    (task_active_pid_ns(current) != &init_pid_ns))
 		return;
 
+	/* Can only change if privileged. */
+	if (!capable(CAP_NET_ADMIN)) {
+		err = EPERM;
+		goto out;
+	}
+
 	mc_op = (enum proc_cn_mcast_op *)msg->data;
 	switch (*mc_op) {
 	case PROC_CN_MCAST_LISTEN:
@@ -325,6 +331,8 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 		err = EINVAL;
 		break;
 	}
+
+out:
 	cn_proc_ack(err, msg->seq, msg->ack);
 }
 
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
