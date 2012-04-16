From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 6/6] vhost_net: don't poll on -EFAULT
Date: Mon, 16 Apr 2012 14:08:33 +0800
Message-ID: <20120416060833.14140.28139.stgit@intel-e5620-16-2.englab.nay.redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, we restart tx polling unconditionally when sendmsg()
fails. This would cause unnecessary wakeups of vhost wokers as it's
only needed when the socket send buffer were exceeded. Fix this by
restart the tx polling only when sendmsg() returns value other than
-EFAULT.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 29abd65..035fa95 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -262,7 +262,8 @@ static void handle_tx(struct vhost_net *net)
 					UIO_MAXIOV;
 			}
 			vhost_discard_vq_desc(vq, 1);
-			tx_poll_start(net, sock);
+			if (err != -EFAULT)
+				tx_poll_start(net, sock);
 			break;
 		}
 		if (err != len)
