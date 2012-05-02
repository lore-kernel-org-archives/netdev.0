From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH 7/9] vhost_net: re-poll only on EAGAIN or ENOBUFS
Date: Wed, 02 May 2012 11:42:32 +0800
Message-ID: <20120502034232.11782.46122.stgit@amd-6168-8-1.englab.nay.redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758594Ab2EBDrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 23:47:48 -0400
In-Reply-To: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we restart tx polling unconditionally when sendmsg()
fails. This would cause unnecessary wakeups of vhost wokers and waste
cpu utlization when evil userspace(guest driver) is able to hit EFAULT or
EINVAL.

The polling is only needed when the socket send buffer were exceeded or not
enough memory. So fix this by restarting polling only when sendmsg() returns
EAGAIN/ENOBUFS.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index ffdc0d8..62828aa 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -257,7 +257,8 @@ static void handle_tx(struct vhost_net *net)
 					UIO_MAXIOV;
 			}
 			vhost_discard_vq_desc(vq, 1);
-			tx_poll_start(net, sock);
+			if (err == -EAGAIN || err == -ENOBUFS)
+				tx_poll_start(net, sock);
 			break;
 		}
 		if (err != len)
