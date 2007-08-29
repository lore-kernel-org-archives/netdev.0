From: dlezcano@fr.ibm.com
Subject: [patch 1/1][RFC] add a private field to the sock structure
Date: Wed, 29 Aug 2007 18:41:15 +0200
Message-ID: <20070829164714.637053362@f002726.toulouse-stg.fr.ibm.com>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:55455 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbXH2QxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 12:53:12 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7TGrAkE786108
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 16:53:10 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TGrAnu655398
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 18:53:10 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TGrAmj020896
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 18:53:10 +0200
Received: from f002726.toulouse-stg.fr.ibm.com (dyn-9-101-17-26.toulouse-stg.fr.ibm.com [9.101.17.26])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l7TGrAhv020882
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 18:53:10 +0200
Received: from f002726.toulouse-stg.fr.ibm.com (localhost.localdomain [127.0.0.1])
	by f002726.toulouse-stg.fr.ibm.com (8.14.1/8.14.1) with ESMTP id l7TGlFZ6029251
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 18:47:15 +0200
Received: (from dlezcano@localhost)
	by f002726.toulouse-stg.fr.ibm.com (8.14.1/8.14.1/Submit) id l7TGlFab029250
	for netdev@vger.kernel.org; Wed, 29 Aug 2007 18:47:15 +0200
Content-Disposition: inline; filename=sock-private-data.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

Store private information for a socket

This patch adds a field to the common socket structure. This field
is a anonymous pointer which allow to store an information about
the socket

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

---
 include/net/inet_timewait_sock.h |    1 +
 include/net/sock.h               |    3 +++
 net/ipv4/inet_timewait_sock.c    |    1 +
 3 files changed, 5 insertions(+)

Index: net-2.6.24-bf/include/net/sock.h
===================================================================
--- net-2.6.24-bf.orig/include/net/sock.h
+++ net-2.6.24-bf/include/net/sock.h
@@ -106,6 +106,7 @@
  *	@skc_refcnt: reference count
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_prot: protocol handlers inside a network family
+ *      @skc_private: field used to store private data
  *
  *	This is the minimal network layer representation of sockets, the header
  *	for struct sock and struct inet_timewait_sock.
@@ -120,6 +121,7 @@
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
 	struct proto		*skc_prot;
+	void                    *skc_private;
 };
 
 /**
@@ -196,6 +198,7 @@
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_hash			__sk_common.skc_hash
 #define sk_prot			__sk_common.skc_prot
+#define sk_private		__sk_common.skc_private
 	unsigned char		sk_shutdown : 2,
 				sk_no_check : 2,
 				sk_userlocks : 4;
Index: net-2.6.24-bf/net/ipv4/inet_timewait_sock.c
===================================================================
--- net-2.6.24-bf.orig/net/ipv4/inet_timewait_sock.c
+++ net-2.6.24-bf/net/ipv4/inet_timewait_sock.c
@@ -108,6 +108,7 @@
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		tw->tw_private      = sk->sk_private;
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
Index: net-2.6.24-bf/include/net/inet_timewait_sock.h
===================================================================
--- net-2.6.24-bf.orig/include/net/inet_timewait_sock.h
+++ net-2.6.24-bf/include/net/inet_timewait_sock.h
@@ -115,6 +115,7 @@
 #define tw_refcnt		__tw_common.skc_refcnt
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
+#define tw_private              __tw_common.skc_private
 	volatile unsigned char	tw_substate;
 	/* 3 bits hole, try to pack */
 	unsigned char		tw_rcv_wscale;

-- 
