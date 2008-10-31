From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 6/7] fs: replace NIPQUAD()
Date: Thu, 30 Oct 2008 17:13:47 -0700
Message-ID: <1225412027.5574.37.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:44522 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbYJaAN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:13:59 -0400
Received: by wf-out-1314.google.com with SMTP id 27so879406wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:13:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 fs/afs/proc.c                  |    4 ++--
 fs/afs/server.c                |    9 ++++-----
 fs/cifs/cifs_spnego.c          |    3 +--
 fs/cifs/connect.c              |    4 ++--
 fs/lockd/host.c                |    6 +++---
 fs/lockd/mon.c                 |    2 +-
 fs/nfs/nfsroot.c               |    6 +++---
 fs/nfs/super.c                 |    3 +--
 fs/nfsd/nfs4state.c            |    4 ++--
 fs/nfsd/nfsctl.c               |    2 +-
 fs/ocfs2/cluster/netdebug.c    |    8 ++++----
 fs/ocfs2/cluster/nodemanager.c |    2 +-
 fs/ocfs2/cluster/tcp.c         |   29 ++++++++++++++---------------
 13 files changed, 39 insertions(+), 43 deletions(-)

diff --git a/fs/afs/proc.c b/fs/afs/proc.c
index 9f7d1ae..7578c1a 100644
--- a/fs/afs/proc.c
+++ b/fs/afs/proc.c
@@ -646,7 +646,7 @@ static int afs_proc_cell_vlservers_show(struct seq_file *m, void *v)
 	}
 
 	/* display one cell per line on subsequent lines */
-	seq_printf(m, "%u.%u.%u.%u\n", NIPQUAD(addr->s_addr));
+	seq_printf(m, "%pI4\n", &addr->s_addr);
 	return 0;
 }
 
@@ -737,7 +737,7 @@ static int afs_proc_cell_servers_show(struct seq_file *m, void *v)
 	}
 
 	/* display one cell per line on subsequent lines */
-	sprintf(ipaddr, "%u.%u.%u.%u", NIPQUAD(server->addr));
+	sprintf(ipaddr, "%pI4", &server->addr);
 	seq_printf(m, "%3d %-15.15s %5d\n",
 		   atomic_read(&server->usage), ipaddr, server->fs_state);
 
diff --git a/fs/afs/server.c b/fs/afs/server.c
index 28f2451..f490995 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -105,7 +105,7 @@ struct afs_server *afs_lookup_server(struct afs_cell *cell,
 {
 	struct afs_server *server, *candidate;
 
-	_enter("%p,"NIPQUAD_FMT, cell, NIPQUAD(addr->s_addr));
+	_enter("%p,%pI4", cell, &addr->s_addr);
 
 	/* quick scan of the list to see if we already have the server */
 	read_lock(&cell->servers_lock);
@@ -168,9 +168,8 @@ found_server:
 server_in_two_cells:
 	write_unlock(&cell->servers_lock);
 	kfree(candidate);
-	printk(KERN_NOTICE "kAFS:"
-	       " Server "NIPQUAD_FMT" appears to be in two cells\n",
-	       NIPQUAD(*addr));
+	printk(KERN_NOTICE "kAFS: Server %pI4 appears to be in two cells\n",
+	       addr);
 	_leave(" = -EEXIST");
 	return ERR_PTR(-EEXIST);
 }
@@ -184,7 +183,7 @@ struct afs_server *afs_find_server(const struct in_addr *_addr)
 	struct rb_node *p;
 	struct in_addr addr = *_addr;
 
-	_enter(NIPQUAD_FMT, NIPQUAD(addr.s_addr));
+	_enter("%pI4", &addr.s_addr);
 
 	read_lock(&afs_servers_lock);
 
diff --git a/fs/cifs/cifs_spnego.c b/fs/cifs/cifs_spnego.c
index 0e186cd..359144c 100644
--- a/fs/cifs/cifs_spnego.c
+++ b/fs/cifs/cifs_spnego.c
@@ -121,8 +121,7 @@ cifs_get_spnego_key(struct cifsSesInfo *sesInfo)
 
 	/* add the server address */
 	if (server->addr.sockAddr.sin_family == AF_INET)
-		sprintf(dp, "ip4=" NIPQUAD_FMT,
-			NIPQUAD(server->addr.sockAddr.sin_addr));
+		sprintf(dp, "ip4=%pI4", &server->addr.sockAddr.sin_addr);
 	else if (server->addr.sockAddr.sin_family == AF_INET6)
 		sprintf(dp, "ip6=%pi6", &server->addr.sockAddr6.sin6_addr);
 	else
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 71b7661..cd54fee 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -2058,8 +2058,8 @@ cifs_mount(struct super_block *sb, struct cifs_sb_info *cifs_sb,
 			rc = -ENOMEM;
 		else {
 			pSesInfo->server = srvTcp;
-			sprintf(pSesInfo->serverName, "%u.%u.%u.%u",
-				NIPQUAD(sin_server.sin_addr.s_addr));
+			sprintf(pSesInfo->serverName, "%pI4",
+				&sin_server.sin_addr.s_addr);
 		}
 
 		if (!rc) {
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index c8ab7d7..c48c263 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -115,12 +115,12 @@ static void nlm_display_address(const struct sockaddr *sap,
 		snprintf(buf, len, "unspecified");
 		break;
 	case AF_INET:
-		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+		snprintf(buf, len, "%pI4", &sin->sin_addr.s_addr);
 		break;
 	case AF_INET6:
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-			snprintf(buf, len, NIPQUAD_FMT,
-				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
+			snprintf(buf, len, "%pI4",
+				 &sin6->sin6_addr.s6_addr32[3]);
 		else
 			snprintf(buf, len, "%pI6", &sin6->sin6_addr);
 		break;
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4e7e958..ffd3461 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -179,7 +179,7 @@ static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 
 	if (!nsm_use_hostnames) {
 		snprintf(buffer, XDR_ADDRBUF_LEN,
-			 NIPQUAD_FMT, NIPQUAD(argp->addr));
+			 "%pI4", &argp->addr);
 		name = buffer;
 	}
 
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 8478fc2..d74d16c 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -329,7 +329,7 @@ static int __init root_nfs_addr(void)
 	}
 
 	snprintf(nfs_data.hostname, sizeof(nfs_data.hostname),
-		 "%u.%u.%u.%u", NIPQUAD(servaddr));
+		 "%pI4", &servaddr);
 	return 0;
 }
 
@@ -421,8 +421,8 @@ static int __init root_nfs_getport(int program, int version, int proto)
 {
 	struct sockaddr_in sin;
 
-	printk(KERN_NOTICE "Looking up port of RPC %d/%d on %u.%u.%u.%u\n",
-		program, version, NIPQUAD(servaddr));
+	printk(KERN_NOTICE "Looking up port of RPC %d/%d on %pI4\n",
+		program, version, &servaddr);
 	set_sockaddr(&sin, servaddr, 0);
 	return rpcb_getport_sync(&sin, program, version, proto);
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index eb391d8..bb0313a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -462,8 +462,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	switch (sap->sa_family) {
 	case AF_INET: {
 		struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-		seq_printf(m, ",mountaddr=" NIPQUAD_FMT,
-				NIPQUAD(sin->sin_addr.s_addr));
+		seq_printf(m, ",mountaddr=%pI4", &sin->sin_addr.s_addr);
 		break;
 	}
 	case AF_INET6: {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b0bebc5..16efb8f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -719,8 +719,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)
 				|| conf->cl_addr != sin->sin_addr.s_addr) {
-			dprintk("NFSD: setclientid: string in use by client"
-				"at %u.%u.%u.%u\n", NIPQUAD(conf->cl_addr));
+			dprintk("NFSD: setclientid: string in use by clientat %pI4\n",
+				&conf->cl_addr);
 			goto out;
 		}
 	}
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e3f9783..77d7b8c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -330,7 +330,7 @@ static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
 		return -EINVAL;
 
 	/* get ipv4 address */
-	if (sscanf(fo_path, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) != 4)
+	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
 		return -EINVAL;
 	if (b1 > 255 || b2 > 255 || b3 > 255 || b4 > 255)
 		return -EINVAL;
diff --git a/fs/ocfs2/cluster/netdebug.c b/fs/ocfs2/cluster/netdebug.c
index 52276c0..f842487 100644
--- a/fs/ocfs2/cluster/netdebug.c
+++ b/fs/ocfs2/cluster/netdebug.c
@@ -304,8 +304,8 @@ static int sc_seq_show(struct seq_file *seq, void *v)
 		 * use of it here generates a warning with -Wbitwise */
 		seq_printf(seq, "%p:\n"
 			   "  krefs:           %d\n"
-			   "  sock:            %u.%u.%u.%u:%u -> "
-					      "%u.%u.%u.%u:%u\n"
+			   "  sock:            %pI4:%u -> "
+					      "%pI4:%u\n"
 			   "  remote node:     %s\n"
 			   "  page off:        %zu\n"
 			   "  handshake ok:    %u\n"
@@ -319,8 +319,8 @@ static int sc_seq_show(struct seq_file *seq, void *v)
 			   "  func type:       %u\n",
 			   sc,
 			   atomic_read(&sc->sc_kref.refcount),
-			   NIPQUAD(saddr), inet ? ntohs(sport) : 0,
-			   NIPQUAD(daddr), inet ? ntohs(dport) : 0,
+			   &saddr, inet ? ntohs(sport) : 0,
+			   &daddr, inet ? ntohs(dport) : 0,
 			   sc->sc_node->nd_name,
 			   sc->sc_page_off,
 			   sc->sc_handshake_ok,
diff --git a/fs/ocfs2/cluster/nodemanager.c b/fs/ocfs2/cluster/nodemanager.c
index 816a3f6..70e8fa9 100644
--- a/fs/ocfs2/cluster/nodemanager.c
+++ b/fs/ocfs2/cluster/nodemanager.c
@@ -250,7 +250,7 @@ static ssize_t o2nm_node_ipv4_port_write(struct o2nm_node *node,
 
 static ssize_t o2nm_node_ipv4_address_read(struct o2nm_node *node, char *page)
 {
-	return sprintf(page, "%u.%u.%u.%u\n", NIPQUAD(node->nd_ipv4_address));
+	return sprintf(page, "%pI4\n", &node->nd_ipv4_address);
 }
 
 static ssize_t o2nm_node_ipv4_address_write(struct o2nm_node *node,
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 2bcf706..9fbe849 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -1597,8 +1597,8 @@ static void o2net_start_connect(struct work_struct *work)
 	ret = sock->ops->bind(sock, (struct sockaddr *)&myaddr,
 			      sizeof(myaddr));
 	if (ret) {
-		mlog(ML_ERROR, "bind failed with %d at address %u.%u.%u.%u\n",
-		     ret, NIPQUAD(mynode->nd_ipv4_address));
+		mlog(ML_ERROR, "bind failed with %d at address %pI4\n",
+		     ret, &mynode->nd_ipv4_address);
 		goto out;
 	}
 
@@ -1790,17 +1790,16 @@ static int o2net_accept_one(struct socket *sock)
 
 	node = o2nm_get_node_by_ip(sin.sin_addr.s_addr);
 	if (node == NULL) {
-		mlog(ML_NOTICE, "attempt to connect from unknown node at "
-		     "%u.%u.%u.%u:%d\n", NIPQUAD(sin.sin_addr.s_addr),
-		     ntohs(sin.sin_port));
+		mlog(ML_NOTICE, "attempt to connect from unknown node at %pI4:%d\n",
+		     &sin.sin_addr.s_addr, ntohs(sin.sin_port));
 		ret = -EINVAL;
 		goto out;
 	}
 
 	if (o2nm_this_node() > node->nd_num) {
 		mlog(ML_NOTICE, "unexpected connect attempted from a lower "
-		     "numbered node '%s' at " "%u.%u.%u.%u:%d with num %u\n",
-		     node->nd_name, NIPQUAD(sin.sin_addr.s_addr),
+		     "numbered node '%s' at " "%pI4:%d with num %u\n",
+		     node->nd_name, &sin.sin_addr.s_addr,
 		     ntohs(sin.sin_port), node->nd_num);
 		ret = -EINVAL;
 		goto out;
@@ -1810,8 +1809,8 @@ static int o2net_accept_one(struct socket *sock)
 	 * and tries to connect before we see their heartbeat */
 	if (!o2hb_check_node_heartbeating_from_callback(node->nd_num)) {
 		mlog(ML_CONN, "attempt to connect from node '%s' at "
-		     "%u.%u.%u.%u:%d but it isn't heartbeating\n",
-		     node->nd_name, NIPQUAD(sin.sin_addr.s_addr),
+		     "%pI4:%d but it isn't heartbeating\n",
+		     node->nd_name, &sin.sin_addr.s_addr,
 		     ntohs(sin.sin_port));
 		ret = -EINVAL;
 		goto out;
@@ -1827,8 +1826,8 @@ static int o2net_accept_one(struct socket *sock)
 	spin_unlock(&nn->nn_lock);
 	if (ret) {
 		mlog(ML_NOTICE, "attempt to connect from node '%s' at "
-		     "%u.%u.%u.%u:%d but it already has an open connection\n",
-		     node->nd_name, NIPQUAD(sin.sin_addr.s_addr),
+		     "%pI4:%d but it already has an open connection\n",
+		     node->nd_name, &sin.sin_addr.s_addr,
 		     ntohs(sin.sin_port));
 		goto out;
 	}
@@ -1924,15 +1923,15 @@ static int o2net_open_listening_sock(__be32 addr, __be16 port)
 	sock->sk->sk_reuse = 1;
 	ret = sock->ops->bind(sock, (struct sockaddr *)&sin, sizeof(sin));
 	if (ret < 0) {
-		mlog(ML_ERROR, "unable to bind socket at %u.%u.%u.%u:%u, "
-		     "ret=%d\n", NIPQUAD(addr), ntohs(port), ret);
+		mlog(ML_ERROR, "unable to bind socket at %pI4:%u, "
+		     "ret=%d\n", &addr, ntohs(port), ret);
 		goto out;
 	}
 
 	ret = sock->ops->listen(sock, 64);
 	if (ret < 0) {
-		mlog(ML_ERROR, "unable to listen on %u.%u.%u.%u:%u, ret=%d\n",
-		     NIPQUAD(addr), ntohs(port), ret);
+		mlog(ML_ERROR, "unable to listen on %pI4:%u, ret=%d\n",
+		     &addr, ntohs(port), ret);
 	}
 
 out:
-- 
1.6.0.3.756.gb776d


