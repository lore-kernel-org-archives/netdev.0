From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net v2] sctp: fix copying more bytes than expected in sctp_add_bind_addr
Date: Tue,  8 Mar 2016 10:34:28 -0300
Message-ID: <c774cc7c0b589b8fe979fea7bf1aa6748eecd2f0.1457443254.git.marcelo.leitner@gmail.com>
Cc: dvyukov@google.com, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com, davem@davemloft.net,
	lkp@intel.com, fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry reported that sctp_add_bind_addr may read more bytes than
expected in case the parameter is a IPv4 addr supplied by the user
through calls such as sctp_bindx_add(), because it always copies
sizeof(union sctp_addr) while the buffer may be just a struct
sockaddr_in, which is smaller.

This patch then fixes it by limiting the memcpy to the min between the
union size and a (new parameter) provided addr size. Where possible this
parameter still is the size of that union, except for reading from
user-provided buffers, which then it accounts for protocol type.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
v1->v2:
  Fixed sizeof() at a pointer, reported by Fengguang Wu

 include/net/sctp/structs.h |  2 +-
 net/sctp/bind_addr.c       | 14 ++++++++------
 net/sctp/protocol.c        |  1 +
 net/sctp/sm_make_chunk.c   |  3 ++-
 net/sctp/socket.c          |  4 +++-
 5 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 205630bb5010b8ac76b84651b302e488fc1c76ff..f816344f65f2dc47d5a3088d92d77e68aa6fd5c3 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1098,7 +1098,7 @@ int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
 			const struct sctp_bind_addr *src,
 			gfp_t gfp);
 int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
-		       __u8 addr_state, gfp_t gfp);
+		       int new_size, __u8 addr_state, gfp_t gfp);
 int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
 int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
 			 struct sctp_sock *);
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 871cdf9567e6bc9c13cb1077dc6866a67e6e4367..401c60750b206c00f9fb14f6b635d15a4342ae0f 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -111,7 +111,8 @@ int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
 	dest->port = src->port;
 
 	list_for_each_entry(addr, &src->address_list, list) {
-		error = sctp_add_bind_addr(dest, &addr->a, 1, gfp);
+		error = sctp_add_bind_addr(dest, &addr->a, sizeof(addr->a),
+					   1, gfp);
 		if (error < 0)
 			break;
 	}
@@ -150,7 +151,7 @@ void sctp_bind_addr_free(struct sctp_bind_addr *bp)
 
 /* Add an address to the bind address list in the SCTP_bind_addr structure. */
 int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
-		       __u8 addr_state, gfp_t gfp)
+		       int new_size, __u8 addr_state, gfp_t gfp)
 {
 	struct sctp_sockaddr_entry *addr;
 
@@ -159,7 +160,7 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
 	if (!addr)
 		return -ENOMEM;
 
-	memcpy(&addr->a, new, sizeof(*new));
+	memcpy(&addr->a, new, min_t(size_t, sizeof(*new), new_size));
 
 	/* Fix up the port if it has not yet been set.
 	 * Both v4 and v6 have the port at the same offset.
@@ -291,7 +292,8 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw_addr_list,
 		}
 
 		af->from_addr_param(&addr, rawaddr, htons(port), 0);
-		retval = sctp_add_bind_addr(bp, &addr, SCTP_ADDR_SRC, gfp);
+		retval = sctp_add_bind_addr(bp, &addr, sizeof(addr),
+					    SCTP_ADDR_SRC, gfp);
 		if (retval) {
 			/* Can't finish building the list, clean up. */
 			sctp_bind_addr_clean(bp);
@@ -453,8 +455,8 @@ static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
 		    (((AF_INET6 == addr->sa.sa_family) &&
 		      (flags & SCTP_ADDR6_ALLOWED) &&
 		      (flags & SCTP_ADDR6_PEERSUPP))))
-			error = sctp_add_bind_addr(dest, addr, SCTP_ADDR_SRC,
-						    gfp);
+			error = sctp_add_bind_addr(dest, addr, sizeof(*addr),
+						   SCTP_ADDR_SRC, gfp);
 	}
 
 	return error;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 1099e99a53c485402ddd9c0693ff5cdd707accca..d3d50daa248b06d7a4306d903b2dad89e9d2acbd 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -216,6 +216,7 @@ int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
 			      (copy_flags & SCTP_ADDR6_ALLOWED) &&
 			      (copy_flags & SCTP_ADDR6_PEERSUPP)))) {
 				error = sctp_add_bind_addr(bp, &addr->a,
+						    sizeof(addr->a),
 						    SCTP_ADDR_SRC, GFP_ATOMIC);
 				if (error)
 					goto end_copy;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 5d6a03fad3789a12290f5f14c5a7efa69c98f41a..7fe971e30ad6b60e21bfa2986f1c9909a0dabc21 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1830,7 +1830,8 @@ no_hmac:
 	/* Also, add the destination address. */
 	if (list_empty(&retval->base.bind_addr.address_list)) {
 		sctp_add_bind_addr(&retval->base.bind_addr, &chunk->dest,
-				SCTP_ADDR_SRC, GFP_ATOMIC);
+				   sizeof(chunk->dest), SCTP_ADDR_SRC,
+				   GFP_ATOMIC);
 	}
 
 	retval->next_tsn = retval->c.initial_tsn;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e878da0949dbfc0012d2e7985bf6e28386678d0f..0e3de0c71137c9ae823bebd7b827561826792d4a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -386,7 +386,8 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 	/* Add the address to the bind address list.
 	 * Use GFP_ATOMIC since BHs will be disabled.
 	 */
-	ret = sctp_add_bind_addr(bp, addr, SCTP_ADDR_SRC, GFP_ATOMIC);
+	ret = sctp_add_bind_addr(bp, addr, af->sockaddr_len,
+				 SCTP_ADDR_SRC, GFP_ATOMIC);
 
 	/* Copy back into socket for getsockname() use. */
 	if (!ret) {
@@ -577,6 +578,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 			af = sctp_get_af_specific(addr->v4.sin_family);
 			memcpy(&saveaddr, addr, af->sockaddr_len);
 			retval = sctp_add_bind_addr(bp, &saveaddr,
+						    sizeof(saveaddr),
 						    SCTP_ADDR_NEW, GFP_ATOMIC);
 			addr_buf += af->sockaddr_len;
 		}
-- 
2.5.0
