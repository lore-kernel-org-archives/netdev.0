From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 18/58] net: vxge: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:02 -0700
Message-ID: <1508200182-104605-19-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Jon Mason <jdmason@kudzu.us>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        Jarod Wilson <jarod@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        stephen hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Jon Mason <jdmason@kudzu.us>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Miroslav Lichvar <mlichvar@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: stephen hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 12 ++++++------
 drivers/net/ethernet/neterion/vxge/vxge-main.h |  8 +++-----
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 50ea69d88480..5d5b9855e24e 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2597,9 +2597,9 @@ static int vxge_add_isr(struct vxgedev *vdev)
 	return VXGE_HW_OK;
 }
 
-static void vxge_poll_vp_reset(unsigned long data)
+static void vxge_poll_vp_reset(struct timer_list *t)
 {
-	struct vxgedev *vdev = (struct vxgedev *)data;
+	struct vxgedev *vdev = from_timer(vdev, t, vp_reset_timer);
 	int i, j = 0;
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
@@ -2616,9 +2616,9 @@ static void vxge_poll_vp_reset(unsigned long data)
 	mod_timer(&vdev->vp_reset_timer, jiffies + HZ / 2);
 }
 
-static void vxge_poll_vp_lockup(unsigned long data)
+static void vxge_poll_vp_lockup(struct timer_list *t)
 {
-	struct vxgedev *vdev = (struct vxgedev *)data;
+	struct vxgedev *vdev = from_timer(vdev, t, vp_lockup_timer);
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct vxge_vpath *vpath;
 	struct vxge_ring *ring;
@@ -2858,12 +2858,12 @@ static int vxge_open(struct net_device *dev)
 		vdev->config.rx_pause_enable);
 
 	if (vdev->vp_reset_timer.function == NULL)
-		vxge_os_timer(&vdev->vp_reset_timer, vxge_poll_vp_reset, vdev,
+		vxge_os_timer(&vdev->vp_reset_timer, vxge_poll_vp_reset,
 			      HZ / 2);
 
 	/* There is no need to check for RxD leak and RxD lookup on Titan1A */
 	if (vdev->titan1 && vdev->vp_lockup_timer.function == NULL)
-		vxge_os_timer(&vdev->vp_lockup_timer, vxge_poll_vp_lockup, vdev,
+		vxge_os_timer(&vdev->vp_lockup_timer, vxge_poll_vp_lockup,
 			      HZ / 2);
 
 	set_bit(__VXGE_STATE_CARD_UP, &vdev->state);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.h b/drivers/net/ethernet/neterion/vxge/vxge-main.h
index 3a79d93b8445..59a57ff5e96a 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.h
@@ -417,12 +417,10 @@ struct vxge_tx_priv {
 	module_param(p, int, 0)
 
 static inline
-void vxge_os_timer(struct timer_list *timer, void (*func)(unsigned long data),
-		   struct vxgedev *vdev, unsigned long timeout)
+void vxge_os_timer(struct timer_list *timer, void (*func)(struct timer_list *),
+		   unsigned long timeout)
 {
-	init_timer(timer);
-	timer->function = func;
-	timer->data = (unsigned long)vdev;
+	timer_setup(timer, func, 0);
 	mod_timer(timer, jiffies + timeout);
 }
 
-- 
2.7.4
