From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/8] af_rxrpc: Fix UDP MTU calculation from ICMP_FRAG_NEEDED
 [ver #2]
Date: Thu, 06 Mar 2014 12:46:36 +0000
Message-ID: <20140306124636.16645.23202.stgit@warthog.procyon.org.uk>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AF_RXRPC sends UDP packets with the "Don't Fragment" bit set in an attempt to
determine the maximum packet size between the local socket and the peer by
invoking the generation of ICMP_FRAG_NEEDED packets.

Once a packet is sent with the "Don't Fragment" bit set, it is then
inconvenient to break it up as that requires recalculating all the rxrpc serial
and sequence numbers and reencrypting all the fragments, so we switch off the
"Don't Fragment" service temporarily and send the bounced packet again.  Future
packets then use the new MTU.

That's all fine.  The problem lies in rxrpc_UDP_error_report() where the code
that deals with ICMP_FRAG_NEEDED packets lives.  Packets of this type have a
field (ee_info) to indicate the maximum packet size at the reporting node - but
sometimes ee_info isn't filled in and is just left as 0 and the code must allow
for this.

When ee_info is 0, the code should take the MTU size we're currently using and
reduce it for the next packet we want to send.  However, it takes ee_info
(which is known to be 0) and tries to reduce that instead.

This was discovered by Coverity.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-error.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index a9206087b4d7..db57458c824c 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -83,6 +83,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 
 		if (mtu == 0) {
 			/* they didn't give us a size, estimate one */
+			mtu = peer->if_mtu;
 			if (mtu > 1500) {
 				mtu >>= 1;
 				if (mtu < 1500)
