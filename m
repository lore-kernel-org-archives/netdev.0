From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] LLC: fix client side after sockaddr_llc fixup
Date: Sat, 1 Nov 2003 22:49:23 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031102004923.GB11632@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	After I did the fixup in struct sockaddr_llc, i.e. not to use
3 addresses, but just one the server side was OK, as I said to you in that
RFC, but the client side was working by luck, i.e. it was always getting
the destination sap and using it as both local and destination sap, this was
because llc_ui_autobind was OK for servers and clients in the past with 3
addresses, but now it can't be shared by PF_LLC->bind() and PF_LLC->{sendmsg,
connect}, so I made ->bind() have its own specific autobinding code and
llc_ui_autobind is now only used by ->connect() and ->sendmsg().

	This makes the client able to make multiple connections to the same
sap on another machine.

	I refrained from changing the comments in llc_ui_bind and
llc_ui_autobind to make the hunks in this patch look sane, will submit another
patch that updates the comments to the (now) correct behaviour.

	Tested running sshd server with PF_LLC patch on both machines and
connecting back and forth several times, everything working fine now.

Best Regards,

- Arnaldo

===== net/llc/af_llc.c 1.57 vs edited =====
--- 1.57/net/llc/af_llc.c	Thu Oct 30 16:35:41 2003
+++ edited/net/llc/af_llc.c	Sat Nov  1 21:36:53 2003
@@ -250,41 +250,19 @@
 
 	if (!sk->sk_zapped)
 		goto out;
-	/* bind to a specific sap, optional. */
-	if (!addr->sllc_sap) {
-		rc = -EUSERS;
-		addr->sllc_sap = llc_ui_autoport();
-		if (!addr->sllc_sap)
-			goto out;
-	}
-	sap = llc_sap_find(addr->sllc_sap);
-	if (!sap) {
-		sap = llc_sap_open(addr->sllc_sap, NULL);
-		rc = -EBUSY; /* some other network layer is using the sap */
-		if (!sap)
-			goto out;
-	} else {
-		struct llc_addr laddr, daddr;
-		struct sock *ask;
-
-		memset(&laddr, 0, sizeof(laddr));
-		memset(&daddr, 0, sizeof(daddr));
-		/*
-		 * FIXME: check if the the address is multicast,
-		 * 	  only SOCK_DGRAM can do this.
-		 */
-		memcpy(laddr.mac, addr->sllc_mac, IFHWADDRLEN);
-		laddr.lsap = addr->sllc_sap;
-		rc = -EADDRINUSE; /* mac + sap clash. */
-		ask = llc_lookup_established(sap, &daddr, &laddr);
-		if (ask) {
-			sock_put(ask);
-			goto out;
-		}
-	}
-	llc->laddr.lsap = addr->sllc_sap;
-	if (llc->dev)
-		memcpy(llc->laddr.mac, llc->dev->dev_addr, IFHWADDRLEN);
+	rc = -ENODEV;
+	llc->dev = dev_getfirstbyhwtype(addr->sllc_arphrd);
+	if (!llc->dev)
+		goto out;
+	rc = -EUSERS;
+	llc->laddr.lsap = llc_ui_autoport();
+	if (!llc->laddr.lsap)
+		goto out;
+	rc = -EBUSY; /* some other network layer is using the sap */
+	sap = llc_sap_open(llc->laddr.lsap, NULL);
+	if (!sap)
+		goto out;
+	memcpy(llc->laddr.mac, llc->dev->dev_addr, IFHWADDRLEN);
 	memcpy(&llc->addr, addr, sizeof(llc->addr));
 	/* assign new connection to its SAP */
 	llc_sap_add_socket(sap, sk);
@@ -315,6 +293,8 @@
 {
 	struct sockaddr_llc *addr = (struct sockaddr_llc *)uaddr;
 	struct sock *sk = sock->sk;
+	struct llc_opt *llc = llc_sk(sk);
+	struct llc_sap *sap;
 	int rc = -EINVAL;
 
 	dprintk("%s: binding %02X\n", __FUNCTION__, addr->sllc_sap);
@@ -323,8 +303,43 @@
 	rc = -EAFNOSUPPORT;
 	if (addr->sllc_family != AF_LLC)
 		goto out;
-	/* use autobind, to avoid code replication. */
-	rc = llc_ui_autobind(sock, addr);
+	if (!addr->sllc_sap) {
+		rc = -EUSERS;
+		addr->sllc_sap = llc_ui_autoport();
+		if (!addr->sllc_sap)
+			goto out;
+	}
+	sap = llc_sap_find(addr->sllc_sap);
+	if (!sap) {
+		sap = llc_sap_open(addr->sllc_sap, NULL);
+		rc = -EBUSY; /* some other network layer is using the sap */
+		if (!sap)
+			goto out;
+	} else {
+		struct llc_addr laddr, daddr;
+		struct sock *ask;
+
+		memset(&laddr, 0, sizeof(laddr));
+		memset(&daddr, 0, sizeof(daddr));
+		/*
+		 * FIXME: check if the the address is multicast,
+		 * 	  only SOCK_DGRAM can do this.
+		 */
+		memcpy(laddr.mac, addr->sllc_mac, IFHWADDRLEN);
+		laddr.lsap = addr->sllc_sap;
+		rc = -EADDRINUSE; /* mac + sap clash. */
+		ask = llc_lookup_established(sap, &daddr, &laddr);
+		if (ask) {
+			sock_put(ask);
+			goto out;
+		}
+	}
+	llc->laddr.lsap = addr->sllc_sap;
+	memcpy(llc->laddr.mac, addr->sllc_mac, IFHWADDRLEN);
+	memcpy(&llc->addr, addr, sizeof(llc->addr));
+	/* assign new connection to its SAP */
+	llc_sap_add_socket(sap, sk);
+	rc = sk->sk_zapped = 0;
 out:
 	return rc;
 }
@@ -399,15 +414,7 @@
 		llc->daddr.lsap = addr->sllc_sap;
 		memcpy(llc->daddr.mac, addr->sllc_mac, IFHWADDRLEN);
 	}
-	if (!llc->dev) {
-		rc = -ENODEV;
-		dev = dev_getfirstbyhwtype(addr->sllc_arphrd);
-		if (!dev)
-			goto out;
-		llc->dev = dev;
-		memcpy(llc->laddr.mac, llc->dev->dev_addr, IFHWADDRLEN);
-	} else
-		dev = llc->dev;
+	dev = llc->dev;
 	if (sk->sk_type != SOCK_STREAM)
 		goto out;
 	rc = -EALREADY;
@@ -610,7 +617,7 @@
 	int rc = -EOPNOTSUPP;
 
 	dprintk("%s: accepting on %02X\n", __FUNCTION__,
-	        llc_sk(sk)->addr.sllc_sap);
+	        llc_sk(sk)->laddr.lsap);
 	lock_sock(sk);
 	if (sk->sk_type != SOCK_STREAM)
 		goto out;
@@ -622,7 +629,7 @@
 	if (rc)
 		goto out;
 	dprintk("%s: got a new connection on %02X\n", __FUNCTION__,
-	        llc_sk(sk)->addr.sllc_sap);
+	        llc_sk(sk)->laddr.lsap);
 	skb = skb_dequeue(&sk->sk_receive_queue);
 	rc = -EINVAL;
 	if (!skb->sk)
@@ -747,13 +754,7 @@
 		if (rc)
 			goto release;
 	}
-	if (!llc->dev) {
-		rc = -ENODEV;
-		dev = dev_getfirstbyhwtype(addr->sllc_arphrd);
-		if (!dev)
-			goto release;
-	} else
-		dev = llc->dev;
+	dev = llc->dev;
 	hdrlen = dev->hard_header_len + llc_ui_header_len(sk, addr);
 	size = hdrlen + len;
 	if (size > dev->mtu)
