From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/7] sctp: Push struct net down into sctp_transport_init
Date: Tue, 07 Aug 2012 10:26:14 -0700
Message-ID: <87y5lqboll.fsf_-_@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com>
	<87ipcud3ld.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ipcud3ld.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 07 Aug 2012 10:17:02 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sctp/structs.h |    2 +-
 net/sctp/associola.c       |    3 ++-
 net/sctp/sm_statefuns.c    |    2 +-
 net/sctp/transport.c       |    8 +++++---
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6bdfcab..88d2179 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1066,7 +1066,7 @@ struct sctp_transport {
 	__u64 hb_nonce;
 };
 
-struct sctp_transport *sctp_transport_new(const union sctp_addr *,
+struct sctp_transport *sctp_transport_new(struct net *, const union sctp_addr *,
 					  gfp_t);
 void sctp_transport_set_owner(struct sctp_transport *,
 			      struct sctp_association *);
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 6bcbeca..93a4513 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -641,6 +641,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 					   const gfp_t gfp,
 					   const int peer_state)
 {
+	struct net *net = sock_net(asoc->base.sk);
 	struct sctp_transport *peer;
 	struct sctp_sock *sp;
 	unsigned short port;
@@ -674,7 +675,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 		return peer;
 	}
 
-	peer = sctp_transport_new(addr, gfp);
+	peer = sctp_transport_new(net, addr, gfp);
 	if (!peer)
 		return NULL;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index bee5e2c..ff2530c 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -5958,7 +5958,7 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 	}
 
 	/* Make a transport for the bucket, Eliza... */
-	transport = sctp_transport_new(sctp_source(chunk), GFP_ATOMIC);
+	transport = sctp_transport_new(net, sctp_source(chunk), GFP_ATOMIC);
 	if (!transport)
 		goto nomem;
 
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index c97472b..aada963 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -59,7 +59,8 @@
 /* 1st Level Abstractions.  */
 
 /* Initialize a new transport from provided memory.  */
-static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
+static struct sctp_transport *sctp_transport_init(struct net *net,
+						  struct sctp_transport *peer,
 						  const union sctp_addr *addr,
 						  gfp_t gfp)
 {
@@ -109,7 +110,8 @@ static struct sctp_transport *sctp_transport_init(struct sctp_transport *peer,
 }
 
 /* Allocate and initialize a new transport.  */
-struct sctp_transport *sctp_transport_new(const union sctp_addr *addr,
+struct sctp_transport *sctp_transport_new(struct net *net,
+					  const union sctp_addr *addr,
 					  gfp_t gfp)
 {
 	struct sctp_transport *transport;
@@ -118,7 +120,7 @@ struct sctp_transport *sctp_transport_new(const union sctp_addr *addr,
 	if (!transport)
 		goto fail;
 
-	if (!sctp_transport_init(transport, addr, gfp))
+	if (!sctp_transport_init(net, transport, addr, gfp))
 		goto fail_init;
 
 	transport->malloced = 1;
-- 
1.7.5.4
