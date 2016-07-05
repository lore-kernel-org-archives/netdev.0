From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/24] rxrpc: Fix processing of
 authenticated/encrypted jumbo packets
Date: Tue, 05 Jul 2016 14:12:18 +0100
Message-ID: <146772433840.21657.17138888082363167022.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a jumbo packet is being split up and processed, the crypto checksum
for each split-out packet is in the jumbo header and needs placing in the
reconstructed packet header.

When commit 0d12f8a4027d021c9cc942f09f38d28288020c5d moved to keeping the
stored copy of the packet header in host byte order, this reconstruction
was missed.

Found with sparse with CF=-D__CHECK_ENDIAN__:

    ../net/rxrpc/input.c:479:33: warning: incorrect type in assignment (different base types)
    ../net/rxrpc/input.c:479:33:    expected unsigned short [unsigned] [usertype] _rsvd
    ../net/rxrpc/input.c:479:33:    got restricted __be16 [addressable] [usertype] _rsvd

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index f4bd57b77b93..5f26cae43069 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -476,7 +476,7 @@ static void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
 		sp->hdr.seq	+= 1;
 		sp->hdr.serial	+= 1;
 		sp->hdr.flags	= jhdr.flags;
-		sp->hdr._rsvd	= jhdr._rsvd;
+		sp->hdr._rsvd	= ntohs(jhdr._rsvd);
 
 		_proto("Rx DATA Jumbo %%%u", sp->hdr.serial - 1);
 
