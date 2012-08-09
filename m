From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] tun: don't zeroize sock->file on detach
Date: Thu, 09 Aug 2012 16:50:40 +0400
Message-ID: <20120809124436.5156.26944.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org, rick.jones2@hp.com,
	ycheng@google.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a fix for bug, introduced in 3.4 kernel by commit
1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things, replaced
simple sock_put() by sk_release_kernel(). Below is sequence, which leads to
oops for non-persistent devices:

tun_chr_close()
tun_detach()				<== tun->socket.file = NULL
tun_free_netdev()
sk_release_sock()
sock_release(sock->file == NULL)
iput(SOCK_INODE(sock))			<== dereference on NULL pointer

This patch just removes zeroing of socket's file from __tun_detach().
sock_release() will do this.

Cc: stable@vger.kernel.org
Reported-by: Ruan Zhijie <ruanzhijie@hotmail.com>
Tested-by: Ruan Zhijie <ruanzhijie@hotmail.com>
Acked-by: Al Viro <viro@ZenIV.linux.org.uk>
Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 drivers/net/tun.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 987aeef..c1639f3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -185,7 +185,6 @@ static void __tun_detach(struct tun_struct *tun)
 	netif_tx_lock_bh(tun->dev);
 	netif_carrier_off(tun->dev);
 	tun->tfile = NULL;
-	tun->socket.file = NULL;
 	netif_tx_unlock_bh(tun->dev);
 
 	/* Drop read queue */
