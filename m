From: "Michael Richardson" <mcr@sandelman.ottawa.on.ca>
Subject: [PATCH] iproute2 -- add fwmarkmask
Date: Mon, 20 Feb 2006 11:27:08 -0500
Message-ID: <23395.1140452828@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: shemminger@osdl.org
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

--=-=-=


{see discussion about RTA_FWMARK in other posting}

diff-tree 573e55d29ef2f014218508d01eee678d82c7c9b7 (from cb420780b79a1d6f5db2082bdac0b310dbc5ebcc)
Author: Michael Richardson <mcr@xelerance.com>
Date:   Mon Feb 20 10:21:05 2006 -0500

    this patch adds a mask operation to the fwmark rule case, permitting
    one to test for only certain bits being set in the fwmark.
    (cherry picked from 5fb85fa9da78cc3822f929f181c651391e35de73 commit)

diff --git a/ChangeLog b/ChangeLog
index 68d2342..b67b81d 100644
--- a/ChangeLog
+++ b/ChangeLog
@@ -1,5 +1,9 @@
+2006-02-20  Michael Richardson <mcr@xelerance.com>
+
+	* Added fwmarkmask option to ip rule to go with addition to kernel.
+	
 2006-01-12  Patrick McHardy <kaber@trash.net>
 
 	* Handle DCCP in ipxfrm.c to allow using port numbers in the selector.
 
 2006-01-10  Masahide NAKAMURA <nakam@linux-ipv6.org>
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index ced29f2..7f4a258 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -263,10 +263,13 @@ enum rtattr_type_t
 	RTA_SESSION,
 	RTA_MP_ALGO,
 	__RTA_MAX
 };
 
+#define RTA_FWMARK      RTA_PROTOINFO
+#define RTA_FWMARK_MASK RTA_CACHEINFO
+
 #define RTA_MAX (__RTA_MAX - 1)
 
 #define RTM_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct rtmsg))))
 #define RTM_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct rtmsg))
 
diff --git a/ip/iprule.c b/ip/iprule.c
index ccf699f..90ffcce 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -33,11 +33,11 @@ extern struct rtnl_handle rth;
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
-	fprintf(stderr, "SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK ]\n");
+	fprintf(stderr, "SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK ] [ fwmarkmask MASK ]\n");
 	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | NUMBER ]\n");
@@ -119,14 +119,22 @@ static int print_rule(const struct socka
 
 	if (r->rtm_tos) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
 	}
-	if (tb[RTA_PROTOINFO]) {
-		fprintf(fp, "fwmark %#x ", *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]));
+	if (tb[RTA_FWMARK]) {
+		__u32 value = *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]);
+		if (tb[RTA_FWMARK_MASK]) {
+			__u32 mask;
+			mask=*(__u32*)RTA_DATA(tb[RTA_FWMARK_MASK]);
+			fprintf(fp, "fwmark %#x&%#x ", value, mask);
+		} else {
+			fprintf(fp, "fwmark %#x&0xffffffff ", value);
+		}
 	}
 
+
 	if (tb[RTA_IIF]) {
 		fprintf(fp, "iif %s ", (char*)RTA_DATA(tb[RTA_IIF]));
 	}
 
 	if (r->rtm_table)
@@ -242,11 +250,17 @@ static int iprule_modify(int cmd, int ar
 		} else if (strcmp(*argv, "fwmark") == 0) {
 			__u32 fwmark;
 			NEXT_ARG();
 			if (get_u32(&fwmark, *argv, 0))
 				invarg("fwmark value is invalid\n", *argv);
-			addattr32(&req.n, sizeof(req), RTA_PROTOINFO, fwmark);
+			addattr32(&req.n, sizeof(req), RTA_FWMARK, fwmark);
+		} else if (strcmp(*argv, "fwmarkmask") == 0) {
+			__u32 fwmarkmask;
+			NEXT_ARG();
+			if (get_u32(&fwmarkmask, *argv, 0))
+				invarg("fwmarkmask value is invalid\n", *argv);
+			addattr32(&req.n, sizeof(req), RTA_FWMARK_MASK, fwmarkmask);
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
 			if (get_rt_realms(&realm, *argv))
 				invarg("invalid realms\n", *argv);




--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iQEVAwUAQ/nt3ICLcPvd0N1lAQKJsAgAgMK5kUe55lsNbZNivNjAyIaIdFfkc7sb
HZ5F4eVNliAVVFdTh3GilhSN2/K5pBdWKhr5VtuO9SsL1VxjdclhFKcmO74H2IbO
AqO+n8b39H+3a3nDUpOu23A8YpLWjhSz+CeHMntFoFy3OU54hRXhrCc5kz5CuVrr
oO5IZaEAaynlASfcE8TACZ9AYEyMRMyvnWixQVO7Z5uyKDvS0s4hnFr9I/462oIA
Sq0Dfikfo8ST/ajux9MtlGFYn0VF3zwxJNewh/KT26pV0glRF0iQX7ruE/QaCpKR
6nNMLMxC1EL7jSBsfldv3jpd/qui3TS1xaeBDVnR5J3VO9o2Vn5jVg==
=8vsf
-----END PGP SIGNATURE-----
--=-=-=--
