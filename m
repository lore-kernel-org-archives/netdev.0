From: Jorgen Hansen <jhansen@vmware.com>
Subject: [PATCH] VSOCK: Only check error on skb_recv_datagram when skb is NULL
Date: Mon, 18 Apr 2016 23:58:52 -0700
Message-ID: <1461049132-59927-1-git-send-email-jhansen@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net,
	Jorgen Hansen <jhansen@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

If skb_recv_datagram returns an skb, we should ignore the err
value returned. Otherwise, datagram receives will return EAGAIN
when they have to wait for a datagram.

Acked-by: Adit Ranadive <aditr@vmware.com>
Signed-off-by: Jorgen Hansen <jhansen@vmware.com>
---
 net/vmw_vsock/vmci_transport.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 662bdd2..5621473 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1735,11 +1735,8 @@ static int vmci_transport_dgram_dequeue(struct vsock_sock *vsk,
 	/* Retrieve the head sk_buff from the socket's receive queue. */
 	err = 0;
 	skb = skb_recv_datagram(&vsk->sk, flags, noblock, &err);
-	if (err)
-		return err;
-
 	if (!skb)
-		return -EAGAIN;
+		return err;
 
 	dg = (struct vmci_datagram *)skb->data;
 	if (!dg)
@@ -2154,7 +2151,7 @@ module_exit(vmci_transport_exit);
 
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMCI transport for Virtual Sockets");
-MODULE_VERSION("1.0.3.0-k");
+MODULE_VERSION("1.0.4.0-k");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS("vmware_vsock");
 MODULE_ALIAS_NETPROTO(PF_VSOCK);
-- 
1.7.0
