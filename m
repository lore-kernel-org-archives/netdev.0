From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v4 3/3] SUNRPC: optimize net_ns dereferencing in rpcbind
	registering calls
Date: Tue, 08 Nov 2011 14:41:36 +0300
Message-ID: <20111108104135.1714.83981.stgit@localhost6.localdomain6>
References: <20111108104023.1714.87978.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111108104023.1714.87978.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Static rpcbind registering functions can be parametrized by network namespace
pointer, calculated only once, instead of using init_net pointer (or taking it
from current when virtualization will be comleted) in many places.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 3df276a..371d229 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -451,14 +451,14 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 /*
  * Fill in AF_INET family-specific arguments to register
  */
-static int rpcb_register_inet4(const struct sockaddr *sap,
+static int rpcb_register_inet4(struct sunrpc_net *sn,
+			       const struct sockaddr *sap,
 			       struct rpc_message *msg)
 {
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
 	unsigned short port = ntohs(sin->sin_port);
 	int result;
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
 
 	map->r_addr = rpc_sockaddr2uaddr(sap, GFP_KERNEL);
 
@@ -479,14 +479,14 @@ static int rpcb_register_inet4(const struct sockaddr *sap,
 /*
  * Fill in AF_INET6 family-specific arguments to register
  */
-static int rpcb_register_inet6(const struct sockaddr *sap,
+static int rpcb_register_inet6(struct sunrpc_net *sn,
+			       const struct sockaddr *sap,
 			       struct rpc_message *msg)
 {
 	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
 	struct rpcbind_args *map = msg->rpc_argp;
 	unsigned short port = ntohs(sin6->sin6_port);
 	int result;
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
 
 	map->r_addr = rpc_sockaddr2uaddr(sap, GFP_KERNEL);
 
@@ -504,10 +504,10 @@ static int rpcb_register_inet6(const struct sockaddr *sap,
 	return result;
 }
 
-static int rpcb_unregister_all_protofamilies(struct rpc_message *msg)
+static int rpcb_unregister_all_protofamilies(struct sunrpc_net *sn,
+					     struct rpc_message *msg)
 {
 	struct rpcbind_args *map = msg->rpc_argp;
-	struct sunrpc_net *sn = net_generic(&init_net, sunrpc_net_id);
 
 	dprintk("RPC:       unregistering [%u, %u, '%s'] with "
 		"local rpcbind\n",
@@ -580,13 +580,13 @@ int rpcb_v4_register(const u32 program, const u32 version,
 		return -EPROTONOSUPPORT;
 
 	if (address == NULL)
-		return rpcb_unregister_all_protofamilies(&msg);
+		return rpcb_unregister_all_protofamilies(sn, &msg);
 
 	switch (address->sa_family) {
 	case AF_INET:
-		return rpcb_register_inet4(address, &msg);
+		return rpcb_register_inet4(sn, address, &msg);
 	case AF_INET6:
-		return rpcb_register_inet6(address, &msg);
+		return rpcb_register_inet6(sn, address, &msg);
 	}
 
 	return -EAFNOSUPPORT;
