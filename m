From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net_random_init needs to get seed later in boot process
Date: Mon, 30 Aug 2004 13:20:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830132030.32d071d0@dell_ss3.pdx.osdl.net>
References: <64243634.20040830173251@huno.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: thomas <tom@huno.net>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <64243634.20040830173251@huno.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Argh.. random_init isn't called until the device's are initialized.
Rather than mess with random.c initialization, how about this; it resets
the net_random state late in initialization when get_random_bytes is ready.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

 
diff -Nru a/net/core/utils.c b/net/core/utils.c
--- a/net/core/utils.c	2004-08-30 11:56:15 -07:00
+++ b/net/core/utils.c	2004-08-30 11:56:15 -07:00
@@ -21,6 +21,7 @@
 #include <linux/types.h>
 #include <linux/random.h>
 #include <linux/percpu.h>
+#include <linux/init.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -77,10 +78,8 @@
 	return (state->s1 ^ state->s2 ^ state->s3);
 }
 
-static void __net_srandom(struct nrnd_state *state, unsigned long entropy)
+static void __net_srandom(struct nrnd_state *state, unsigned long s)
 {
-	u32 s = state->s1 ^ entropy;
-
 	if (s == 0)
 		s = 1;      /* default seed is 1 */
 
@@ -112,24 +111,33 @@
 void net_srandom(unsigned long entropy)
 {
 	struct nrnd_state *state = &get_cpu_var(net_rand_state);
-	__net_srandom(state, entropy);
+	__net_srandom(state, state->s1^entropy);
 	put_cpu_var(state);
 }
 
 void __init net_random_init(void)
 {
 	int i;
+
+	for (i = 0; i < NR_CPUS; i++) {
+		struct nrnd_state *state = &per_cpu(net_rand_state,i);
+		__net_srandom(state, i+jiffies);
+	}
+}
+
+static int net_random_reseed(void)
+{
+	int i;
 	unsigned long seed[NR_CPUS];
 
 	get_random_bytes(seed, sizeof(seed));
-
 	for (i = 0; i < NR_CPUS; i++) {
 		struct nrnd_state *state = &per_cpu(net_rand_state,i);
-
-		memset(state, 0, sizeof(*state));
 		__net_srandom(state, seed[i]);
 	}
+	return 0;
 }
+late_initcall(net_random_reseed);
 
 int net_msg_cost = 5*HZ;
 int net_msg_burst = 10;
