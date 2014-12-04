From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 6/6] bridge/link: add learning_sync policy flag
Date: Thu,  4 Dec 2014 09:57:18 +0100
Message-ID: <1417683438-10935-7-git-send-email-jiri@resnulli.us>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:59169 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaLDI53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:57:29 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so27095007wiw.3
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 00:57:27 -0800 (PST)
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add 'learned_sync' flag to turn on/off syncing of learned FDB entries from
offload device to bridge's FDB.   Flag would be set/cleared in on SELF using
hwmode qualifier 'swdev'.  E.g.:

  $ sudo bridge link set dev swp1 hwmode swdev learning_sync on

  $ bridge -d link show dev swp1
  2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 2
      hairpin off guard off root_block off fastleave off learning off flood off
  2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0
      learning on learning_sync on hwmode swdev

Adds new IFLA_BRPORT_LEARNING_SYNC attribute for IFLA_PROTINFO on the SELF
brport.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 bridge/link.c           | 11 +++++++++++
 include/linux/if_link.h |  1 +
 man/man8/bridge.8       |  6 ++++++
 3 files changed, 18 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index efe0b8c..0f8649f 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -188,6 +188,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 				if (prtb[IFLA_BRPORT_LEARNING])
 					print_onoff(fp, "learning",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING]));
+				if (prtb[IFLA_BRPORT_LEARNING_SYNC])
+					print_onoff(fp, "learning_sync",
+						    rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING_SYNC]));
 				if (prtb[IFLA_BRPORT_UNICAST_FLOOD])
 					print_onoff(fp, "flood",
 						    rta_getattr_u8(prtb[IFLA_BRPORT_UNICAST_FLOOD]));
@@ -221,6 +224,7 @@ static void usage(void)
 	fprintf(stderr, "                               [ fastleave {on | off} ]\n");
 	fprintf(stderr,	"                               [ root_block {on | off} ]\n");
 	fprintf(stderr,	"                               [ learning {on | off} ]\n");
+	fprintf(stderr,	"                               [ learning_sync {on | off} ]\n");
 	fprintf(stderr,	"                               [ flood {on | off} ]\n");
 	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
 	fprintf(stderr, "       bridge link show [dev DEV]\n");
@@ -252,6 +256,7 @@ static int brlink_modify(int argc, char **argv)
 	} req;
 	char *d = NULL;
 	__s8 learning = -1;
+	__s8 learning_sync = -1;
 	__s8 flood = -1;
 	__s8 hairpin = -1;
 	__s8 bpdu_guard = -1;
@@ -295,6 +300,10 @@ static int brlink_modify(int argc, char **argv)
 			NEXT_ARG();
 			if (!on_off("learning", &learning, *argv))
 				exit(-1);
+		} else if (strcmp(*argv, "learning_sync") == 0) {
+			NEXT_ARG();
+			if (!on_off("learning_sync", &learning_sync, *argv))
+				exit(-1);
 		} else if (strcmp(*argv, "flood") == 0) {
 			NEXT_ARG();
 			if (!on_off("flood", &flood, *argv))
@@ -359,6 +368,8 @@ static int brlink_modify(int argc, char **argv)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_UNICAST_FLOOD, flood);
 	if (learning >= 0)
 		addattr8(&req.n, sizeof(req), IFLA_BRPORT_LEARNING, learning);
+	if (learning_sync >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_LEARNING_SYNC, learning_sync);
 
 	if (cost > 0)
 		addattr32(&req.n, sizeof(req), IFLA_BRPORT_COST, cost);
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 06efa2d..9947f1b 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -243,6 +243,7 @@ enum {
 	IFLA_BRPORT_LEARNING,	/* mac learning */
 	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
 	IFLA_BRPORT_PROXYARP,   /* proxy ARP */
+	IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index d3d64d1..83c049a 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -37,6 +37,7 @@ bridge \- show / manipulate bridge addresses and devices
 .BR fastleave " { " on " | " off " } ] [ "
 .BR root_block " { " on " | " off " } ] [ "
 .BR learning " { " on " | " off " } ] [ "
+.BR learning_sync " { " on " | " off " } ] [ "
 .BR flood " { " on " | " off " } ] [ "
 .BR hwmode " { " vepa " | " veb " | " swdev " } ] "
 
@@ -242,6 +243,11 @@ not.  If learning if off, the bridge will end up flooding any traffic for which
 it has no FDB entry.  By default this flag is on.
 
 .TP
+.BR "learning_sync on " or " learning_sync off "
+Controls whether a given port will sync MAC addresses learned on device port
+to bridge FDB.  This flags applies to device ports in "swdev" hwmode.
+
+.TP
 .BR "flooding on " or " flooding off "
 Controls whether a given port will flood unicast traffic for which there is no FDB entry.  By default this flag is on.
 
-- 
1.9.3
