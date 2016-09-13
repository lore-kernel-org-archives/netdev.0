From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 04/10] rxrpc: Requeue call for recvmsg if more data
Date: Tue, 13 Sep 2016 23:21:23 +0100
Message-ID: <147380528385.23135.2106954961242678721.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rxrpc_recvmsg() needs to make sure that the call it has just been
processing gets requeued for further attention if the buffer has been
filled and there's more data to be consumed.  The softirq producer only
queues the call and wakes the socket if it fills the first slot in the
window, so userspace might end up sleeping forever otherwise, despite there
being data available.

This is not a problem provided the userspace buffer is big enough or it
empties the buffer completely before more data comes in.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 20d0b5c6f81b..16ff56f69256 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -463,6 +463,10 @@ try_again:
 					 flags, &copied);
 		if (ret == -EAGAIN)
 			ret = 0;
+
+		if (after(call->rx_top, call->rx_hard_ack) &&
+		    call->rxtx_buffer[(call->rx_hard_ack + 1) & RXRPC_RXTX_BUFF_MASK])
+			rxrpc_notify_socket(call);
 		break;
 	default:
 		ret = 0;
