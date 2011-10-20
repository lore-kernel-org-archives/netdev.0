From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/5] macvtap: Don't leak unreceived packets when we delete a macvtap device.
Date: Thu, 20 Oct 2011 07:27:24 -0700
Message-ID: <m1hb33u4ab.fsf_-_@fess.ebiederm.org>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
	<m1sjmnu4cm.fsf@fess.ebiederm.org>
	<m1mxcvu4bk.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arnd.de>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Shirly Ma <mashirley@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58093 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab1JTO0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:26:53 -0400
In-Reply-To: <m1mxcvu4bk.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 20 Oct 2011 07:26:39 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To avoid leaking packets in the receive queue.  Add a socket destructor
that will run whenever destroy a macvtap socket.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/net/macvtap.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 1d9c9c2..515aa87 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -339,6 +339,11 @@ static void macvtap_sock_write_space(struct sock *sk)
 		wake_up_interruptible_poll(wqueue, POLLOUT | POLLWRNORM | POLLWRBAND);
 }
 
+static void macvtap_sock_destruct(struct sock *sk)
+{
+	skb_queue_purge(&sk->sk_receive_queue);
+}
+
 static int macvtap_open(struct inode *inode, struct file *file)
 {
 	struct net *net = current->nsproxy->net_ns;
@@ -369,6 +374,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	q->sock.ops = &macvtap_socket_ops;
 	sock_init_data(&q->sock, &q->sk);
 	q->sk.sk_write_space = macvtap_sock_write_space;
+	q->sk.sk_destruct = macvtap_sock_destruct;
 	q->flags = IFF_VNET_HDR | IFF_NO_PI | IFF_TAP;
 	q->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
-- 
1.7.2.5
