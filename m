From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Mon, 15 Dec 2008 08:09:16 +1100
Message-ID: <20081214210916.GA26325@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au> <1229112677.3051.9.camel@achroite> <20081212214835.GD11046@gondor.apana.org.au> <1229121327.3051.69.camel@achroite> <20081212224954.GA11636@gondor.apana.org.au> <Pine.WNT.4.64.0812141124040.13556@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59998 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751471AbYLNVJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 16:09:24 -0500
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.64.0812141124040.13556@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2008 at 11:36:14AM -0800, Waskiewicz Jr, Peter P wrote:
>
> I'm confused then.  You're adding two ethtool entry points with 
> ETHTOOL_GGRO and ETHTOOL_SGRO, adding the callpoints in dev_ethtool with 
> set_gro and get_gro, but how do you manipulate this without adding to the 
> userspace application?  Adding this functionality to the set/get_flags 
> will keep the userspace app from needing a patch to support the new 
> callbacks.

Huh? Whether you use get_flags or not you still need to patch the
user-space application so that it knows how to handle

	ethtool -K eth0 gro on/off

There is no way around that.

As I said earlier, I didn't use get_flags/set_flags because of the
need to depend on RX checksum offload.

BTW, here is the patch for ethtool to set the GRO flags.

diff --git a/ethtool-copy.h b/ethtool-copy.h
index eadba25..3ca4e2c 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -336,6 +336,8 @@ struct ethtool_rxnfc {
 
 #define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+#define	ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
+#define	ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/ethtool.c b/ethtool.c
index a7c02d0..502fc8f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -160,6 +160,7 @@ static struct option {
 	        "		[ tso on|off ]\n"
 	        "		[ ufo on|off ]\n"
 		"		[ gso on|off ]\n"
+		"		[ gro on|off ]\n"
 		"               [ lro on|off ]\n"
     },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
@@ -218,6 +219,7 @@ static int off_sg_wanted = -1;
 static int off_tso_wanted = -1;
 static int off_ufo_wanted = -1;
 static int off_gso_wanted = -1;
+static int off_gro_wanted = -1;
 static int off_lro_wanted = -1;
 
 static struct ethtool_pauseparam epause;
@@ -333,6 +335,7 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
 	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
 	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
+	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
 	{ "lro", CMDL_BOOL, &off_lro_wanted, NULL },
 };
 
@@ -1387,7 +1390,8 @@ static int dump_coalesce(void)
 	return 0;
 }
 
-static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso, int lro)
+static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
+			int gro, int lro)
 {
 	fprintf(stdout,
 		"rx-checksumming: %s\n"
@@ -1396,6 +1400,7 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso, int l
 		"tcp segmentation offload: %s\n"
 		"udp fragmentation offload: %s\n"
 		"generic segmentation offload: %s\n"
+		"generic receive offload: %s\n"
 		"large receive offload: %s\n",
 		rx ? "on" : "off",
 		tx ? "on" : "off",
@@ -1403,6 +1408,7 @@ static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso, int l
 		tso ? "on" : "off",
 		ufo ? "on" : "off",
 		gso ? "on" : "off",
+		gro ? "on" : "off",
 		lro ? "on" : "off");
 
 	return 0;
@@ -1714,7 +1720,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1, rx = 0, tx = 0, sg = 0;
-	int tso = 0, ufo = 0, gso = 0, lro = 0;
+	int tso = 0, ufo = 0, gso = 0, gro = 0, lro = 0;
 
 	fprintf(stdout, "Offload parameters for %s:\n", devname);
 
@@ -1778,6 +1784,16 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		allfail = 0;
 	}
 
+	eval.cmd = ETHTOOL_GGRO;
+	ifr->ifr_data = (caddr_t)&eval;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err)
+		perror("Cannot get device generic receive offload settings");
+	else {
+		gro = eval.data;
+		allfail = 0;
+	}
+
 	eval.cmd = ETHTOOL_GFLAGS;
 	ifr->ifr_data = (caddr_t)&eval;
 	err = ioctl(fd, SIOCETHTOOL, ifr);
@@ -1793,7 +1809,7 @@ static int do_goffload(int fd, struct ifreq *ifr)
 		return 83;
 	}
 
-	return dump_offload(rx, tx, sg, tso, ufo, gso, lro);
+	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro);
 }
 
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -1870,6 +1886,17 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 90;
 		}
 	}
+	if (off_gro_wanted >= 0) {
+		changed = 1;
+		eval.cmd = ETHTOOL_SGRO;
+		eval.data = (off_gro_wanted == 1);
+		ifr->ifr_data = (caddr_t)&eval;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot set device generic receive offload settings");
+			return 93;
+		}
+	}
 	if (off_lro_wanted >= 0) {
 		changed = 1;
 		eval.cmd = ETHTOOL_GFLAGS;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
