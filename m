From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) skfp - cleanup is_XXX functions
Date: Tue, 22 Jun 2004 14:20:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622142052.7b9af6bc@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This started out from sparse warnings about calling with fddi_broadcast
that is declared const.  This fixes that and gets rid of some of the namespace
pollution of this driver by moving the predicate function is_individual, is_broadcast, ...
as inline's in the one file that uses them.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/skfp/h/cmtdef.h b/drivers/net/skfp/h/cmtdef.h
--- a/drivers/net/skfp/h/cmtdef.h	2004-06-22 13:56:20 -07:00
+++ b/drivers/net/skfp/h/cmtdef.h	2004-06-22 13:56:20 -07:00
@@ -571,10 +571,6 @@
 int port_to_mib(struct s_smc *smc, int p);
 int cem_build_path(struct s_smc *smc, char *to, int path_index);
 int sm_mac_get_tx_state(struct s_smc *smc);
-int is_individual(struct fddi_addr *addr);
-int is_my_addr(struct s_smc *smc, struct fddi_addr *addr);
-int is_broadcast(struct fddi_addr *addr);
-int is_equal(struct fddi_addr *addr1, struct fddi_addr *addr2);
 char *get_pcmstate(struct s_smc *smc, int np);
 int smt_action(struct s_smc *smc, int class, int code, int index);
 u_short smt_online(struct s_smc *smc, int on);
diff -Nru a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
--- a/drivers/net/skfp/smt.c	2004-06-22 13:56:20 -07:00
+++ b/drivers/net/skfp/smt.c	2004-06-22 13:56:20 -07:00
@@ -76,8 +76,8 @@
 static int phy_con_resource_index(struct s_smc *smc, int phy);
 static void smt_send_rdf(struct s_smc *smc, SMbuf *rej, int fc, int reason,
 			 int local);
-static void smt_send_nif(struct s_smc *smc, struct fddi_addr *dest, int fc,
-			 u_long tid, int type, int local);
+static void smt_send_nif(struct s_smc *smc, const struct fddi_addr *dest, 
+			 int fc, u_long tid, int type, int local);
 static void smt_send_ecf(struct s_smc *smc, struct fddi_addr *dest, int fc,
                          u_long tid, int type, int len);
 static void smt_echo_test(struct s_smc *smc, int dna);
@@ -123,6 +123,45 @@
 #define		hwm_conv_can(smc,data,len)
 #endif
 
+
+static inline int is_my_addr(const struct s_smc *smc, 
+			     const struct fddi_addr *addr)
+{
+	return(*(short *)(&addr->a[0]) ==
+		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[0])
+	  && *(short *)(&addr->a[2]) ==
+		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[2])
+	  && *(short *)(&addr->a[4]) ==
+		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[4])) ;
+}
+
+static inline int is_zero(const struct fddi_addr *addr)
+{
+	return(*(short *)(&addr->a[0]) == 0 &&
+	       *(short *)(&addr->a[2]) == 0 &&
+	       *(short *)(&addr->a[4]) == 0 ) ;
+}
+
+static inline int is_broadcast(const struct fddi_addr *addr)
+{
+	return(*(u_short *)(&addr->a[0]) == 0xffff &&
+	       *(u_short *)(&addr->a[2]) == 0xffff &&
+	       *(u_short *)(&addr->a[4]) == 0xffff ) ;
+}
+
+static inline int is_individual(const struct fddi_addr *addr)
+{
+	return(!(addr->a[0] & GROUP_ADDR)) ;
+}
+
+static inline int is_equal(const struct fddi_addr *addr1, 
+			   const struct fddi_addr *addr2)
+{
+	return(*(u_short *)(&addr1->a[0]) == *(u_short *)(&addr2->a[0]) &&
+	       *(u_short *)(&addr1->a[2]) == *(u_short *)(&addr2->a[2]) &&
+	       *(u_short *)(&addr1->a[4]) == *(u_short *)(&addr2->a[4]) ) ;
+}
+
 /*
  * list of mandatory paras in frames
  */
@@ -382,7 +421,7 @@
 		 */
 		if (!smc->sm.pend[SMT_TID_NIF])
 			smc->sm.pend[SMT_TID_NIF] = smt_get_tid(smc) ;
-		smt_send_nif(smc,&fddi_broadcast,FC_SMT_NSA,
+		smt_send_nif(smc,&fddi_broadcast, FC_SMT_NSA,
 			smc->sm.pend[SMT_TID_NIF], SMT_REQUEST,0) ;
 		smc->sm.smt_last_notify = time ;
 	}
@@ -926,8 +965,8 @@
 /*
  * generate and send NIF
  */
-static void smt_send_nif(struct s_smc *smc, struct fddi_addr *dest, int fc,
-			 u_long tid, int type, int local)
+static void smt_send_nif(struct s_smc *smc, const struct fddi_addr *dest, 
+			 int fc, u_long tid, int type, int local)
 /* struct fddi_addr *dest;	dest address */
 /* int fc;			frame control */
 /* u_long tid;			transaction id */
@@ -1687,43 +1726,6 @@
 	}
 	return(0) ;
 }
-
-int is_my_addr(struct s_smc *smc, struct fddi_addr *addr)
-{
-	return(*(short *)(&addr->a[0]) ==
-		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[0])
-	  && *(short *)(&addr->a[2]) ==
-		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[2])
-	  && *(short *)(&addr->a[4]) ==
-		*(short *)(&smc->mib.m[MAC0].fddiMACSMTAddress.a[4])) ;
-}
-
-int is_zero(struct fddi_addr *addr)
-{
-	return(*(short *)(&addr->a[0]) == 0 &&
-	       *(short *)(&addr->a[2]) == 0 &&
-	       *(short *)(&addr->a[4]) == 0 ) ;
-}
-
-int is_broadcast(struct fddi_addr *addr)
-{
-	return(*(u_short *)(&addr->a[0]) == 0xffff &&
-	       *(u_short *)(&addr->a[2]) == 0xffff &&
-	       *(u_short *)(&addr->a[4]) == 0xffff ) ;
-}
-
-int is_individual(struct fddi_addr *addr)
-{
-	return(!(addr->a[0] & GROUP_ADDR)) ;
-}
-
-int is_equal(struct fddi_addr *addr1, struct fddi_addr *addr2)
-{
-	return(*(u_short *)(&addr1->a[0]) == *(u_short *)(&addr2->a[0]) &&
-	       *(u_short *)(&addr1->a[2]) == *(u_short *)(&addr2->a[2]) &&
-	       *(u_short *)(&addr1->a[4]) == *(u_short *)(&addr2->a[4]) ) ;
-}
-
 
 #if	0
 /*
