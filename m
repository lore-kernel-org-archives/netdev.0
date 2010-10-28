From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH iproute2] macvlan/macvtap: support 'passthru' mode
Date: Thu, 28 Oct 2010 16:10:55 -0700
Message-ID: <1288307455.30131.83.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for 'passthru' mode when creating a macvlan/macvtap device
which allows takeover of the underlying device and passing it to a KVM
guest using virtio with macvtap backend.

Only one macvlan device is allowed in passthru mode and it inherits
the mac address from the underlying device and sets it in promiscuous 
mode to receive and forward all the packets.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

-----------------------------------------------------------------------

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f5bb2dc..23de79e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -230,6 +230,7 @@ enum macvlan_mode {
 	MACVLAN_MODE_PRIVATE = 1, /* don't talk to other macvlans */
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
+	MACVLAN_MODE_PASSTHRU  = 8, /* take over the underlying device */
 };
 
 /* SR-IOV virtual function management section */
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index a3c78bd..15022aa 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -23,14 +23,14 @@
 static void explain(void)
 {
 	fprintf(stderr,
-		"Usage: ... macvlan mode { private | vepa | bridge }\n"
+		"Usage: ... macvlan mode { private | vepa | bridge | passthru }\n"
 	);
 }
 
 static int mode_arg(void)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\" or \"bridge\"\n");
+		"\"vepa\", \"bridge\" or \"passthru\" \n");
         return -1;
 }
 
@@ -48,6 +48,8 @@ static int macvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				mode = MACVLAN_MODE_VEPA;
 			else if (strcmp(*argv, "bridge") == 0)
 				mode = MACVLAN_MODE_BRIDGE;
+			else if (strcmp(*argv, "passthru") == 0)
+				mode = MACVLAN_MODE_PASSTHRU;
 			else
 				return mode_arg();
 
@@ -82,6 +84,7 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		  mode == MACVLAN_MODE_PRIVATE ? "private"
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
+		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
 		:				 "unknown");
 }
 
diff --git a/ip/iplink_macvtap.c b/ip/iplink_macvtap.c
index 35199b1..5665b6d 100644
--- a/ip/iplink_macvtap.c
+++ b/ip/iplink_macvtap.c
@@ -20,14 +20,14 @@
 static void explain(void)
 {
 	fprintf(stderr,
-		"Usage: ... macvtap mode { private | vepa | bridge }\n"
+		"Usage: ... macvtap mode { private | vepa | bridge | passthru }\n"
 	);
 }
 
 static int mode_arg(void)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
-		"\"vepa\" or \"bridge\"\n");
+		"\"vepa\", \"bridge\" or \"passthru\" \n");
         return -1;
 }
 
@@ -45,6 +45,8 @@ static int macvtap_parse_opt(struct link_util *lu, int argc, char **argv,
 				mode = MACVLAN_MODE_VEPA;
 			else if (strcmp(*argv, "bridge") == 0)
 				mode = MACVLAN_MODE_BRIDGE;
+			else if (strcmp(*argv, "passthru") == 0)
+				mode = MACVLAN_MODE_PASSTHRU;
 			else
 				return mode_arg();
 
@@ -79,6 +81,7 @@ static void macvtap_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		  mode == MACVLAN_MODE_PRIVATE ? "private"
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
 		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
+		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
 		:				 "unknown");
 }
 


