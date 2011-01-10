From: Dan Carpenter <error27@gmail.com>
Subject: [patch v2] phonet: some signedness bugs
Date: Mon, 10 Jan 2011 17:06:58 +0300
Message-ID: <20110110140658.GB2721@bicker>
References: <20110107203755.GB1959@bicker>
 <201101100958.32549.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, dan.j.rosenberg@gmail.com
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:41255 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab1AJOHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:07:22 -0500
Content-Disposition: inline
In-Reply-To: <201101100958.32549.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Rosenberg pointed out that there were some signed comparison bugs
in the phonet protocol.

http://marc.info/?l=full-disclosure&m=129424528425330&w=2

The problem is that we check for array overflows but "protocol" is
signed and we don't check for array underflows.  If you have already
have CAP_SYS_ADMIN then you could use the bugs to get root, or someone
could cause an oops by mistake.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
v2:  in v1 I changed pn_socket_create() but that change caused a
compiler warning.  That part of the patch wasn't needed so I've just
dropped.

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index d5df797..5395e09 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -107,8 +107,8 @@ struct phonet_protocol {
 	int			sock_type;
 };
 
-int phonet_proto_register(int protocol, struct phonet_protocol *pp);
-void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
+int phonet_proto_register(unsigned int protocol, struct phonet_protocol *pp);
+void phonet_proto_unregister(unsigned int protocol, struct phonet_protocol *pp);
 
 int phonet_sysctl_init(void);
 void phonet_sysctl_exit(void);
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index fd95beb..1072b2c 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -37,7 +37,7 @@
 /* Transport protocol registration */
 static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
 
-static struct phonet_protocol *phonet_proto_get(int protocol)
+static struct phonet_protocol *phonet_proto_get(unsigned int protocol)
 {
 	struct phonet_protocol *pp;
 
@@ -458,7 +458,7 @@ static struct packet_type phonet_packet_type __read_mostly = {
 
 static DEFINE_MUTEX(proto_tab_lock);
 
-int __init_or_module phonet_proto_register(int protocol,
+int __init_or_module phonet_proto_register(unsigned int protocol,
 						struct phonet_protocol *pp)
 {
 	int err = 0;
@@ -481,7 +481,7 @@ int __init_or_module phonet_proto_register(int protocol,
 }
 EXPORT_SYMBOL(phonet_proto_register);
 
-void phonet_proto_unregister(int protocol, struct phonet_protocol *pp)
+void phonet_proto_unregister(unsigned int protocol, struct phonet_protocol *pp)
 {
 	mutex_lock(&proto_tab_lock);
 	BUG_ON(proto_tab[protocol] != pp);
