From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] phonet: fix compilation with gcc-3.4
Date: Mon, 17 Nov 2008 13:03:20 +0300
Message-ID: <20081117100320.GB10586@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:48657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbYKQJ7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 04:59:44 -0500
Received: by ug-out-1314.google.com with SMTP id 39so355615ugf.37
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 01:59:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC [M]  net/phonet/af_phonet.o
net/phonet/af_phonet.c: In function `pn_socket_create':
net/phonet/af_phonet.c:38: sorry, unimplemented: inlining failed in call to 'phonet_proto_put': function body not available
net/phonet/af_phonet.c:99: sorry, unimplemented: called from here
make[3]: *** [net/phonet/af_phonet.o] Error 1

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/phonet/af_phonet.c |   52 ++++++++++++++++++++++---------------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -33,9 +33,30 @@
 #include <net/phonet/phonet.h>
 #include <net/phonet/pn_dev.h>
 
-static struct net_proto_family phonet_proto_family;
-static struct phonet_protocol *phonet_proto_get(int protocol);
-static inline void phonet_proto_put(struct phonet_protocol *pp);
+/* Transport protocol registration */
+static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
+static DEFINE_SPINLOCK(proto_tab_lock);
+
+static struct phonet_protocol *phonet_proto_get(int protocol)
+{
+	struct phonet_protocol *pp;
+
+	if (protocol >= PHONET_NPROTO)
+		return NULL;
+
+	spin_lock(&proto_tab_lock);
+	pp = proto_tab[protocol];
+	if (pp && !try_module_get(pp->prot->owner))
+		pp = NULL;
+	spin_unlock(&proto_tab_lock);
+
+	return pp;
+}
+
+static inline void phonet_proto_put(struct phonet_protocol *pp)
+{
+	module_put(pp->prot->owner);
+}
 
 /* protocol family functions */
 
@@ -375,10 +396,6 @@ static struct packet_type phonet_packet_type = {
 	.func = phonet_rcv,
 };
 
-/* Transport protocol registration */
-static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
-static DEFINE_SPINLOCK(proto_tab_lock);
-
 int __init_or_module phonet_proto_register(int protocol,
 						struct phonet_protocol *pp)
 {
@@ -412,27 +429,6 @@ void phonet_proto_unregister(int protocol, struct phonet_protocol *pp)
 }
 EXPORT_SYMBOL(phonet_proto_unregister);
 
-static struct phonet_protocol *phonet_proto_get(int protocol)
-{
-	struct phonet_protocol *pp;
-
-	if (protocol >= PHONET_NPROTO)
-		return NULL;
-
-	spin_lock(&proto_tab_lock);
-	pp = proto_tab[protocol];
-	if (pp && !try_module_get(pp->prot->owner))
-		pp = NULL;
-	spin_unlock(&proto_tab_lock);
-
-	return pp;
-}
-
-static inline void phonet_proto_put(struct phonet_protocol *pp)
-{
-	module_put(pp->prot->owner);
-}
-
 /* Module registration */
 static int __init phonet_init(void)
 {
