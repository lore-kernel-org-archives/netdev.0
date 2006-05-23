From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: need to ref count the LLC sap
Date: Tue, 23 May 2006 15:10:35 -0700
Message-ID: <20060523151035.43e7e4f6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46293 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932456AbWEWWL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 18:11:56 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bridge will OOPS on removal if other application has the SAP open.
The bridge SAP might be shared with other usages, so need
to do reference counting on module removal rather than explicit
close/delete.

Since packet might arrive after or during removal, need to clear
the receive function handle, so LLC only hands it to user (if any).

This should go in 2.616.stable and 2.6.17.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br.orig/net/bridge/br.c
+++ br/net/bridge/br.c
@@ -55,7 +55,7 @@ static int __init br_init(void)
 
 static void __exit br_deinit(void)
 {
-	llc_sap_close(br_stp_sap);
+	rcu_assign_pointer(br_stp_sap->rcv_func, NULL);
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 	br_netfilter_fini();
@@ -67,6 +67,7 @@ static void __exit br_deinit(void)
 
 	synchronize_net();
 
+	llc_sap_put(br_stp_sap);
 	br_fdb_get_hook = NULL;
 	br_fdb_put_hook = NULL;
 
