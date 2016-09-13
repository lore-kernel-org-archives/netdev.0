From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/4] rxrpc: Create an address for sendmsg() to bind
 unbound socket with
Date: Tue, 13 Sep 2016 23:41:38 +0100
Message-ID: <147380649850.30728.13076467087664565055.stgit@warthog.procyon.org.uk>
References: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create an address for sendmsg() to bind unbound socket with rather than
using a completely blank address otherwise the transport socket creation
will fail because it will try to use address family 0.

We use the address family specified in the protocol argument when the
AF_RXRPC socket was created and SOCK_DGRAM as the default.  For anything
else, bind() must be used.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 25d00ded24bc..741b0d8d2e8c 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -401,6 +401,18 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 
 	switch (rx->sk.sk_state) {
 	case RXRPC_UNBOUND:
+		rx->srx.srx_family = AF_RXRPC;
+		rx->srx.srx_service = 0;
+		rx->srx.transport_type = SOCK_DGRAM;
+		rx->srx.transport.family = rx->family;
+		switch (rx->family) {
+		case AF_INET:
+			rx->srx.transport_len = sizeof(struct sockaddr_in);
+			break;
+		default:
+			ret = -EAFNOSUPPORT;
+			goto error_unlock;
+		}
 		local = rxrpc_lookup_local(&rx->srx);
 		if (IS_ERR(local)) {
 			ret = PTR_ERR(local);
