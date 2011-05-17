From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH ethtool] ethtool: merge ETHTOOL_[GS]FEATURES support to -k/-K modes
Date: Tue, 17 May 2011 22:33:58 +0200 (CEST)
Message-ID: <9efbc0ee6be6fd642f54474fd8d4aea59d45a065.1305663326.git.mirq-linux@rere.qmqm.pl>
References: <20110517084543.GB18423@rere.qmqm.pl>
	<20110514103539.GA5214@rere.qmqm.pl>
        <1305513923.19966.20.camel@localhost>
        <20110516132807.1A89F13A6A@rere.qmqm.pl>
        <1305553066.19966.32.camel@localhost>
        <20110516142340.GA2980@rere.qmqm.pl>
        <1305557597.2885.5.camel@bwh-desktop>
        <20110516205137.GA7667@rere.qmqm.pl>
        <1305580139.2885.47.camel@bwh-desktop>
        <20110516215034.GA8463@rere.qmqm.pl>
        <1305583775.2885.65.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46212 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab1EQUeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 16:34:00 -0400
In-Reply-To: <20110517084543.GB18423@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

This depends on the previous patch introducing -w/-W for [GS]FEATURES.

BTW, I noticed an old bug in ethtool (present currently and in debian-l=
enny's
version 6+20080913-1): "ethtool -k" -- i.e. with no other parameters --=
 runs
and tries to check device named '-k'.

Example:

icybox:~# ./ethtool -k ge0
Offload parameters for ge0:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off
receive-hashing: off

=46ull offload state:  (feature-name: active,wanted,changable)
     tx-scatter-gather                 no,yes,yes
     tx-checksum-ipv4                  no, no,yes
     tx-checksum-unneeded              no,---, no
     tx-checksum-ip-generic            no,---, no
     tx_checksum-ipv6                  no, no,yes
     highdma                           no,---, no
     tx-scatter-gather-fraglist        no,---, no
     tx-vlan-hw-insert                 no,---, no
     rx-vlan-hw-parse                  no,---, no
     rx-vlan-filter                    no,---, no
     vlan-challenged                   no,---,---
     tx-generic-segmentation           no,yes,yes
     tx-lockless                       no,---,---
     netns-local                       no,---,---
     rx-gro                           yes,yes,yes
     rx-lro                            no,---, no
     tx-tcp-segmentation               no, no,yes
     tx-udp-fragmentation              no,---, no
     tx-gso-robust                     no,---, no
     tx-tcp-ecn-segmentation           no, no,yes
     tx-tcp6-segmentation              no, no,yes
     tx-fcoe-segmentation              no,---, no
     tx-checksum-fcoe-crc              no,---, no
     tx-checksum-sctp                  no,---, no
     fcoe-mtu                          no,---, no
     rx-ntuple-filter                  no,---, no
     rx-hashing                        no,---, no
     rx-checksum                      yes,yes,yes
     tx-nocache-copy                   no, no,yes
     loopback                          no,---, no

icybox:~# ./ethtool -K ge0 tx_checksum-ipv6 on
feature tx-scatter-gather is enabled (expected: disabled, saved: enable=
d)
feature tx-generic-segmentation is enabled (expected: disabled, saved: =
enabled)

icybox:~# ./ethtool -K ge0 sg off
[turns off SG and GSO; like before]

icybox:~# ./ethtool -K ge0 tx_checksum-ipv6 off
[no other feature changed state]

icybox:~# ./ethtool -K ge0 sg on
[SG was remembered this time, but is inactive (no checksum offloads)]

icybox:~# ./ethtool -K ge0 tx_checksum-ipv6 on
feature tx-scatter-gather is enabled (expected: disabled, saved: enable=
d)
feature tx-generic-segmentation is enabled (expected: disabled, saved: =
enabled)

icybox:~# ./ethtool -K ge0 tx_checksum-ipv6 off
feature tx-scatter-gather is disabled (expected: enabled, saved: enable=
d)
feature tx-generic-segmentation is disabled (expected: enabled, saved: =
enabled)

---
 ethtool.c |  155 ++++++++++++++++++++++++++++-------------------------=
-------
 1 files changed, 72 insertions(+), 83 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 86a5a8b..a541007 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -123,8 +123,6 @@ static enum {
 	MODE_SRING,
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
-	MODE_GFEATURES,
-	MODE_SFEATURES,
 	MODE_GSTATS,
 	MODE_GNFC,
 	MODE_SNFC,
@@ -202,9 +200,6 @@ static struct option {
 		"		[ txvlan on|off ]\n"
 		"		[ ntuple on|off ]\n"
 		"		[ rxhash on|off ]\n"
-    },
-    { "-w", "--show-features", MODE_GFEATURES, "Get offload status" },
-    { "-W", "--request-features", MODE_SFEATURES, "Set requested offlo=
ad",
 		"		[ feature-name on|off [...] ]\n"
 		"		see --show-features output for feature-name strings\n" },
     { "-i", "--driver", MODE_GDRV, "Show driver information" },
@@ -306,7 +301,6 @@ static void show_usage(void)
=20
 static char *devname =3D NULL;
=20
-static int goffload_changed =3D 0;
 static int off_csum_rx_wanted =3D -1;
 static int off_csum_tx_wanted =3D -1;
 static int off_sg_wanted =3D -1;
@@ -316,6 +310,7 @@ static int off_gso_wanted =3D -1;
 static u32 off_flags_wanted =3D 0;
 static u32 off_flags_mask =3D 0;
 static int off_gro_wanted =3D -1;
+static struct ethtool_sfeatures *features_req;
=20
 static struct ethtool_pauseparam epause;
 static int gpause_changed =3D 0;
@@ -778,8 +773,6 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode =3D=3D MODE_SRING) ||
 			    (mode =3D=3D MODE_GOFFLOAD) ||
 			    (mode =3D=3D MODE_SOFFLOAD) ||
-			    (mode =3D=3D MODE_GFEATURES) ||
-			    (mode =3D=3D MODE_SFEATURES) ||
 			    (mode =3D=3D MODE_GSTATS) ||
 			    (mode =3D=3D MODE_GNFC) ||
 			    (mode =3D=3D MODE_SNFC) ||
@@ -863,14 +856,6 @@ static void parse_cmdline(int argc, char **argp)
 				break;
 			}
 			if (mode =3D=3D MODE_SOFFLOAD) {
-				parse_generic_cmdline(argc, argp, i,
-					&goffload_changed,
-			      		cmdline_offload,
-			      		ARRAY_SIZE(cmdline_offload));
-				i =3D argc;
-				break;
-			}
-			if (mode =3D=3D MODE_SFEATURES) {
 				parse_sfeatures_args(argc, argp, i);
 				i =3D argc;
 				break;
@@ -1944,10 +1929,6 @@ static int doit(void)
 		return do_goffload(fd, &ifr);
 	} else if (mode =3D=3D MODE_SOFFLOAD) {
 		return do_soffload(fd, &ifr);
-	} else if (mode =3D=3D MODE_GFEATURES) {
-		return do_gfeatures(fd, &ifr);
-	} else if (mode =3D=3D MODE_SFEATURES) {
-		return do_sfeatures(fd, &ifr);
 	} else if (mode =3D=3D MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
 	} else if (mode =3D=3D MODE_GNFC) {
@@ -2262,13 +2243,20 @@ static int do_goffload(int fd, struct ifreq *if=
r)
 		allfail =3D 0;
 	}
=20
+	if (!allfail)
+		dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvlan,
+			    ntuple, rxhash);
+
+	err =3D do_gfeatures(fd, ifr);
+	if (!err)
+		allfail =3D 0;
+
 	if (allfail) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
=20
-	return dump_offload(rx, tx, sg, tso, ufo, gso, gro, lro, rxvlan, txvl=
an,
-			    ntuple, rxhash);
+	return 0;
 }
=20
 static int do_soffload(int fd, struct ifreq *ifr)
@@ -2277,116 +2265,114 @@ static int do_soffload(int fd, struct ifreq *=
ifr)
 	int err, changed =3D 0;
=20
 	if (off_csum_rx_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SRXCSUM;
 		eval.data =3D (off_csum_rx_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device rx csum settings");
-			return 84;
-		}
+		else
+			changed =3D 1;
 	}
=20
 	if (off_csum_tx_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_STXCSUM;
 		eval.data =3D (off_csum_tx_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device tx csum settings");
-			return 85;
-		}
+		else
+			changed =3D 1;
 	}
=20
 	if (off_sg_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SSG;
 		eval.data =3D (off_sg_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device scatter-gather settings");
-			return 86;
-		}
+		else
+			changed =3D 1;
 	}
=20
 	if (off_tso_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_STSO;
 		eval.data =3D (off_tso_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D send_ioctl(fd, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device tcp segmentation offload settings");
-			return 88;
-		}
+		else
+			changed =3D 1;
 	}
 	if (off_ufo_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SUFO;
 		eval.data =3D (off_ufo_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device udp large send offload settings");
-			return 89;
-		}
+		else
+			changed =3D 1;
 	}
 	if (off_gso_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SGSO;
 		eval.data =3D (off_gso_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device generic segmentation offload settings");
-			return 90;
-		}
+		else
+			changed =3D 1;
 	}
 	if (off_flags_mask) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_GFLAGS;
 		eval.data =3D 0;
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
 		if (err) {
 			perror("Cannot get device flag settings");
-			return 91;
-		}
+		} else {
+			eval.cmd =3D ETHTOOL_SFLAGS;
+			eval.data =3D ((eval.data & ~off_flags_mask) |
+				     off_flags_wanted);
=20
-		eval.cmd =3D ETHTOOL_SFLAGS;
-		eval.data =3D ((eval.data & ~off_flags_mask) |
-			     off_flags_wanted);
-
-		err =3D ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set device flag settings");
-			return 92;
+			err =3D ioctl(fd, SIOCETHTOOL, ifr);
+			if (err)
+				perror("Cannot set device flag settings");
+			else
+				changed =3D 1;
 		}
 	}
 	if (off_gro_wanted >=3D 0) {
-		changed =3D 1;
 		eval.cmd =3D ETHTOOL_SGRO;
 		eval.data =3D (off_gro_wanted =3D=3D 1);
 		ifr->ifr_data =3D (caddr_t)&eval;
 		err =3D ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
+		if (err)
 			perror("Cannot set device GRO settings");
-			return 93;
-		}
+		else
+			changed =3D 1;
+	}
+
+	if (features_req) {
+		err =3D do_sfeatures(fd, ifr);
+		if (!err)
+			changed =3D 1;
 	}
=20
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
+		return err;
 	}
=20
 	return 0;
 }
=20
 static int get_feature_strings(int fd, struct ifreq *ifr,
-	struct ethtool_gstrings **strs)
+	struct ethtool_gstrings **strs, int quiet_nx)
 {
 	struct ethtool_sset_info *sset_info;
 	struct ethtool_gstrings *strings;
@@ -2398,16 +2384,18 @@ static int get_feature_strings(int fd, struct i=
freq *ifr,
 	ifr->ifr_data =3D (caddr_t)sset_info;
 	err =3D send_ioctl(fd, ifr);
=20
-	if ((err < 0) ||
-	    (!(sset_info->sset_mask & (1ULL << ETH_SS_FEATURES)))) {
-		perror("Cannot get driver strings info");
-		return -100;
-	}
-
 	n_strings =3D sset_info->data[0];
 	free(sset_info);
+
+	if ((err < 0) ||
+	    (!(sset_info->sset_mask & (1ULL << ETH_SS_FEATURES))) ||
+	    (n_strings =3D=3D 0)) {
+		if (!quiet_nx)
+			perror("Cannot get driver strings info");
+		return -100;
+	}
+
 	sz_str =3D n_strings * ETH_GSTRING_LEN;
-
 	strings =3D calloc(1, sz_str + sizeof(struct ethtool_gstrings));
 	if (!strings) {
 		fprintf(stderr, "no memory available\n");
@@ -2429,8 +2417,6 @@ static int get_feature_strings(int fd, struct ifr=
eq *ifr,
 	return n_strings;
 }
=20
-struct ethtool_sfeatures *features_req;
-
 static void parse_sfeatures_args(int argc, char **argp, int argi)
 {
 	struct cmdline_info *cmdline_desc, *cp;
@@ -2443,13 +2429,21 @@ static void parse_sfeatures_args(int argc, char=
 **argp, int argi)
 	if (fd < 0)
 		exit(100);
=20
-	n_strings =3D get_feature_strings(fd, &ifr, &strings);
-	if (n_strings < 0)
-		exit(-n_strings);
+	n_strings =3D get_feature_strings(fd, &ifr, &strings, 1);
+	if (n_strings < 0) {
+		/* ETHTOOL_GFEATURES unavailable */
+		parse_generic_cmdline(argc, argp, argi, &changed,
+			cmdline_offload, ARRAY_SIZE(cmdline_offload));
+		return;
+	}
=20
 	sz_features =3D sizeof(*features_req->features) * ((n_strings + 31) /=
 32);
=20
-	cp =3D cmdline_desc =3D calloc(n_strings, sizeof(*cmdline_desc));
+	cp =3D cmdline_desc =3D calloc(n_strings + ARRAY_SIZE(cmdline_offload=
),
+		sizeof(*cmdline_desc));
+	memcpy(cp, cmdline_offload, sizeof(cmdline_offload));
+	cp +=3D ARRAY_SIZE(cmdline_offload);
+
 	features_req =3D calloc(1, sizeof(*features_req) + sz_features);
 	if (!cmdline_desc || !features_req) {
 		fprintf(stderr, "no memory available\n");
@@ -2518,7 +2512,7 @@ static int do_gfeatures(int fd, struct ifreq *ifr=
)
 	struct ethtool_gfeatures *features;
 	int n_strings, err, i;
=20
-	n_strings =3D get_feature_strings(fd, ifr, &strings);
+	n_strings =3D get_feature_strings(fd, ifr, &strings, 1);
 	if (n_strings < 0)
 		return -n_strings;
=20
@@ -2528,7 +2522,7 @@ static int do_gfeatures(int fd, struct ifreq *ifr=
)
 		return err;
 	}
=20
-	fprintf(stdout, "Offload state:  (name: enabled,wanted,changable)\n")=
;
+	fprintf(stdout, "\nFull offload state:  (feature-name: active,wanted,=
changable)\n");
 	for (i =3D 0; i < n_strings; i++) {
 		if (!strings->data[i * ETH_GSTRING_LEN])
 			continue;	/* empty */
@@ -2585,12 +2579,7 @@ static int do_sfeatures(int fd, struct ifreq *if=
r)
 	struct ethtool_gfeatures *features0, *features1;
 	int n_strings, err, i;
=20
-	if (!features_req) {
-		fprintf(stderr, "no features changed\n");
-		return 97;
-	}
-
-	n_strings =3D get_feature_strings(fd, ifr, &strings);
+	n_strings =3D get_feature_strings(fd, ifr, &strings, 0);
 	if (n_strings < 0) {
 		free(features_req);
 		return -n_strings;
--=20
1.7.2.5

