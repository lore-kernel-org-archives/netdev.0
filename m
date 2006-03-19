From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [AX.25] Fix potencial memory hole.
Date: Sun, 19 Mar 2006 12:42:46 +0000
Message-ID: <20060319124246.GA6261@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the AX.25 dialect chosen by the sysadmin is set to DAMA master / 3
(or DAMA slave / 2, if CONFIG_AX25_DAMA_SLAVE=n) ax25_kick() will fall
through the switch statement without calling ax25_send_iframe() or any
other function that would eventually free skbn thus leaking the packet.

Fix by restricting the sysctl inferface to allow only actually supported
AX.25 dialects.

The system administration mistake needed for this to happen is rather
unlikely, so this is an uncritical hole.

Coverity #651.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 2250a18..d052b22 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -110,8 +110,15 @@ enum { 
 enum {
 	AX25_PROTO_STD_SIMPLEX,
 	AX25_PROTO_STD_DUPLEX,
+#ifdef CONFIG_AX25_DAMA_SLAVE
 	AX25_PROTO_DAMA_SLAVE,
-	AX25_PROTO_DAMA_MASTER
+#ifdef CONFIG_AX25_DAMA_MASTER
+	AX25_PROTO_DAMA_MASTER,
+#define AX25_PROTO_MAX AX25_PROTO_DAMA_MASTER
+#endif
+#endif
+	__AX25_PROTO_MAX,
+	AX25_PROTO_MAX = __AX25_PROTO_MAX -1
 };
 
 enum {
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index f67711f..894a225 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -24,7 +24,7 @@ static int min_t3[1],   		max_t3[] = {36
 static int min_idle[1],  		max_idle[] = {65535 * HZ};
 static int min_n2[] = {1},		max_n2[] = {31};
 static int min_paclen[] = {1},		max_paclen[] = {512};
-static int min_proto[1],		max_proto[] = {3};
+static int min_proto[1],		max_proto[] = { AX25_PROTO_MAX };
 static int min_ds_timeout[1],   	max_ds_timeout[] = {65535 * HZ};
 
 static struct ctl_table_header *ax25_table_header;
