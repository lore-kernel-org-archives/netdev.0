From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [RFC] moving the test for sockaddr->sa_family up
Date: Sat, 15 Nov 2003 19:20:34 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031115212034.GA16326@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Does anybody see any problem with this simplification? Not for 2.6.0, of
course...

- Arnaldo

===== net/socket.c 1.70 vs edited =====
--- 1.70/net/socket.c	Wed Oct 29 18:19:30 2003
+++ edited/net/socket.c	Sat Nov 15 04:53:48 2003
@@ -1187,13 +1187,17 @@
 	if((sock = sockfd_lookup(fd,&err))!=NULL)
 	{
 		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0) {
-			err = security_socket_bind(sock, (struct sockaddr *)address, addrlen);
-			if (err) {
-				sockfd_put(sock);
-				return err;
-			}
-			err = sock->ops->bind(sock, (struct sockaddr *)address, addrlen);
+			struct sockaddr *saddr = (struct sockaddr *)address;
+
+			err = -EAFNOSUPPORT;
+			if (saddr->sa_family != sock->sk->sk_family)
+				goto out_put;
+			err = security_socket_bind(sock, saddr, addrlen);
+			if (err)
+				goto out_put;
+			err = sock->ops->bind(sock, saddr, addrlen);
 		}
+out_put:
 		sockfd_put(sock);
 	}			
 	return err;
===== net/appletalk/ddp.c 1.40 vs edited =====
--- 1.40/net/appletalk/ddp.c	Fri Oct 31 01:43:17 2003
+++ edited/net/appletalk/ddp.c	Sat Nov 15 04:57:40 2003
@@ -1158,9 +1158,6 @@
 	if (!sk->sk_zapped || addr_len != sizeof(struct sockaddr_at))
 		return -EINVAL;
 
-	if (addr->sat_family != AF_APPLETALK)
-		return -EAFNOSUPPORT;
-
 	if (addr->sat_addr.s_net == htons(ATADDR_ANYNET)) {
 		struct atalk_addr *ap = atalk_find_primary();
 
===== net/atm/pvc.c 1.15 vs edited =====
--- 1.15/net/atm/pvc.c	Fri Sep  5 06:35:34 2003
+++ edited/net/atm/pvc.c	Sat Nov 15 04:58:22 2003
@@ -34,7 +34,6 @@
 
 	if (sockaddr_len != sizeof(struct sockaddr_atmpvc)) return -EINVAL;
 	addr = (struct sockaddr_atmpvc *) sockaddr;
-	if (addr->sap_family != AF_ATMPVC) return -EAFNOSUPPORT;
 	lock_sock(sk);
 	vcc = ATM_SD(sock);
 	if (!test_bit(ATM_VF_HASQOS, &vcc->flags)) {
===== net/ax25/af_ax25.c 1.33 vs edited =====
--- 1.33/net/ax25/af_ax25.c	Tue Oct  7 10:27:14 2003
+++ edited/net/ax25/af_ax25.c	Sat Nov 15 05:01:10 2003
@@ -1030,9 +1030,6 @@
 			current->comm);
 	}
 
-	if (addr->fsa_ax25.sax25_family != AF_AX25)
-		return -EINVAL;
-
 	call = ax25_findbyuid(current->euid);
 	if (call == NULL && ax25_uid_policy && !capable(CAP_NET_ADMIN)) {
 		return -EACCES;
===== net/bluetooth/hci_sock.c 1.26 vs edited =====
--- 1.26/net/bluetooth/hci_sock.c	Fri Sep 12 12:44:53 2003
+++ edited/net/bluetooth/hci_sock.c	Sat Nov 15 05:03:08 2003
@@ -264,9 +264,6 @@
 
 	BT_DBG("sock %p sk %p", sock, sk);
 
-	if (!haddr || haddr->hci_family != AF_BLUETOOTH)
-		return -EINVAL;
-
 	lock_sock(sk);
 
 	if (hci_pi(sk)->hdev) {
===== net/bluetooth/l2cap.c 1.37 vs edited =====
--- 1.37/net/bluetooth/l2cap.c	Thu Nov 13 04:30:44 2003
+++ edited/net/bluetooth/l2cap.c	Sat Nov 15 05:03:41 2003
@@ -396,9 +396,6 @@
 
 	BT_DBG("sk %p, %s %d", sk, batostr(&la->l2_bdaddr), la->l2_psm);
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
-		return -EINVAL;
-
 	lock_sock(sk);
 
 	if (sk->sk_state != BT_OPEN) {
===== net/bluetooth/sco.c 1.25 vs edited =====
--- 1.25/net/bluetooth/sco.c	Thu Nov 13 04:30:44 2003
+++ edited/net/bluetooth/sco.c	Sat Nov 15 05:04:03 2003
@@ -472,9 +472,6 @@
 
 	BT_DBG("sk %p %s", sk, batostr(&sa->sco_bdaddr));
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
-		return -EINVAL;
-
 	lock_sock(sk);
 
 	if (sk->sk_state != BT_OPEN) {
===== net/bluetooth/rfcomm/sock.c 1.27 vs edited =====
--- 1.27/net/bluetooth/rfcomm/sock.c	Thu Nov 13 04:30:44 2003
+++ edited/net/bluetooth/rfcomm/sock.c	Sat Nov 15 05:02:25 2003
@@ -323,9 +323,6 @@
 
 	BT_DBG("sk %p %s", sk, batostr(&sa->rc_bdaddr));
 
-	if (!addr || addr->sa_family != AF_BLUETOOTH)
-		return -EINVAL;
-
 	lock_sock(sk);
 
 	if (sk->sk_state != BT_OPEN) {
===== net/decnet/af_decnet.c 1.37 vs edited =====
--- 1.37/net/decnet/af_decnet.c	Thu Nov 13 06:50:30 2003
+++ edited/net/decnet/af_decnet.c	Sat Nov 15 05:05:09 2003
@@ -707,9 +707,6 @@
 	if (addr_len != sizeof(struct sockaddr_dn))
 		return -EINVAL;
 
-	if (saddr->sdn_family != AF_DECnet)
-		return -EINVAL;
-
 	if (dn_ntohs(saddr->sdn_nodeaddrl) && (dn_ntohs(saddr->sdn_nodeaddrl) != 2))
 		return -EINVAL;
 
===== net/econet/af_econet.c 1.27 vs edited =====
--- 1.27/net/econet/af_econet.c	Tue Oct  7 10:27:14 2003
+++ edited/net/econet/af_econet.c	Sat Nov 15 05:05:49 2003
@@ -188,8 +188,7 @@
 	 *	Check legality
 	 */
 	 
-	if (addr_len < sizeof(struct sockaddr_ec) ||
-	    sec->sec_family != AF_ECONET)
+	if (addr_len < sizeof(struct sockaddr_ec))
 		return -EINVAL;
 	
 	eo->cb	    = sec->cb;
===== net/llc/af_llc.c 1.70 vs edited =====
--- 1.70/net/llc/af_llc.c	Fri Nov 14 21:52:15 2003
+++ edited/net/llc/af_llc.c	Sat Nov 15 05:10:12 2003
@@ -285,9 +285,6 @@
 	dprintk("%s: binding %02X\n", __FUNCTION__, addr->sllc_sap);
 	if (unlikely(!sk->sk_zapped || addrlen != sizeof(*addr)))
 		goto out;
-	rc = -EAFNOSUPPORT;
-	if (unlikely(addr->sllc_family != AF_LLC))
-		goto out;
 	if (!addr->sllc_sap) {
 		rc = -EUSERS;
 		addr->sllc_sap = llc_ui_autoport();
===== net/netlink/af_netlink.c 1.37 vs edited =====
--- 1.37/net/netlink/af_netlink.c	Tue Nov  4 17:48:39 2003
+++ edited/net/netlink/af_netlink.c	Sat Nov 15 05:10:31 2003
@@ -329,9 +329,6 @@
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
 	
-	if (nladdr->nl_family != AF_NETLINK)
-		return -EINVAL;
-
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_RECV))
 		return -EPERM;
===== net/netrom/af_netrom.c 1.40 vs edited =====
--- 1.40/net/netrom/af_netrom.c	Sun Sep 21 22:17:31 2003
+++ edited/net/netrom/af_netrom.c	Sat Nov 15 05:10:59 2003
@@ -570,10 +570,6 @@
 		release_sock(sk);
 		return -EINVAL;
 	}
-	if (addr->fsa_ax25.sax25_family != AF_NETROM) {
-		release_sock(sk);
-		return -EINVAL;
-	}
 	if ((dev = nr_dev_get(&addr->fsa_ax25.sax25_call)) == NULL) {
 		SOCK_DEBUG(sk, "NET/ROM: bind failed: invalid node callsign\n");
 		release_sock(sk);
===== net/packet/af_packet.c 1.35 vs edited =====
--- 1.35/net/packet/af_packet.c	Tue Oct  7 10:27:14 2003
+++ edited/net/packet/af_packet.c	Sat Nov 15 05:11:13 2003
@@ -901,8 +901,6 @@
 	 
 	if (addr_len < sizeof(struct sockaddr_ll))
 		return -EINVAL;
-	if (sll->sll_family != AF_PACKET)
-		return -EINVAL;
 
 	if (sll->sll_ifindex) {
 		err = -ENODEV;
===== net/rose/af_rose.c 1.33 vs edited =====
--- 1.33/net/rose/af_rose.c	Tue Sep  9 15:22:56 2003
+++ edited/net/rose/af_rose.c	Sat Nov 15 05:11:39 2003
@@ -654,9 +654,6 @@
 	if (addr_len != sizeof(struct sockaddr_rose) && addr_len != sizeof(struct full_sockaddr_rose))
 		return -EINVAL;
 
-	if (addr->srose_family != AF_ROSE)
-		return -EINVAL;
-
 	if (addr_len == sizeof(struct sockaddr_rose) && addr->srose_ndigis > 1)
 		return -EINVAL;
 
===== net/unix/af_unix.c 1.56 vs edited =====
--- 1.56/net/unix/af_unix.c	Thu Nov 13 04:37:45 2003
+++ edited/net/unix/af_unix.c	Sat Nov 15 05:12:02 2003
@@ -649,10 +649,6 @@
 	struct unix_address *addr;
 	struct hlist_head *list;
 
-	err = -EINVAL;
-	if (sunaddr->sun_family != AF_UNIX)
-		goto out;
-
 	if (addr_len==sizeof(short)) {
 		err = unix_autobind(sock);
 		goto out;
===== net/wanrouter/af_wanpipe.c 1.31 vs edited =====
--- 1.31/net/wanrouter/af_wanpipe.c	Sun Oct  5 03:51:01 2003
+++ edited/net/wanrouter/af_wanpipe.c	Sat Nov 15 05:12:24 2003
@@ -1340,10 +1340,6 @@
 		printk(KERN_INFO "wansock: Address length error\n");
 		return -EINVAL;
 	}
-	if (sll->sll_family != AF_WANPIPE){
-		printk(KERN_INFO "wansock: Illegal family name specified.\n");
-		return -EINVAL;
-	}
 
 	card = wanpipe_find_card (sll->sll_card);
 	if (!card){
===== net/x25/af_x25.c 1.38 vs edited =====
--- 1.38/net/x25/af_x25.c	Thu Nov 13 01:18:49 2003
+++ edited/net/x25/af_x25.c	Sat Nov 15 05:12:43 2003
@@ -587,8 +587,7 @@
 	struct sockaddr_x25 *addr = (struct sockaddr_x25 *)uaddr;
 
 	if (!sk->sk_zapped ||
-	    addr_len != sizeof(struct sockaddr_x25) ||
-	    addr->sx25_family != AF_X25)
+	    addr_len != sizeof(struct sockaddr_x25))
 		return -EINVAL;
 
 	x25_sk(sk)->source_addr = addr->sx25_addr;
