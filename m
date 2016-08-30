From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 3/3] macsec: fix byte ordering on input/display of 'sci'
Date: Tue, 30 Aug 2016 13:23:14 +0200
Message-ID: <8584ea633c296a3075adcf4861e9b33d6378d897.1472552276.git.dcaratti@redhat.com>
References: <cover.1472552276.git.dcaratti@redhat.com>
Cc: stephen@networkplumber.org, sd@queasysnail.net, phil@nwl.cc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757841AbcH3LYB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 07:24:01 -0400
In-Reply-To: <cover.1472552276.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use get_be64() in place of get_u64() when parsing input 'sci' parameter,
so that 'sci' can be entered using network byte order regardless the
endianness of target system; use ntohll() when printing out 'sci'. While
at it, improve documentation of 'sci' in ip-link.8.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 ip/ipmacsec.c         | 8 ++++----
 man/man8/ip-link.8.in | 4 +++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index c75e9d3..2e670e9 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -134,7 +134,7 @@ static int get_an(__u8 *val, const char *arg)
 
 static int get_sci(__u64 *sci, const char *arg)
 {
-	return get_u64(sci, arg, 16);
+	return get_be64(sci, arg, 16);
 }
 
 static int get_port(__be16 *port, const char *arg)
@@ -776,7 +776,7 @@ static void print_tx_sc(const char *prefix, __u64 sci, __u8 encoding_sa,
 	struct rtattr *a;
 	int rem;
 
-	printf("%sTXSC: %016llx on SA %d\n", prefix, sci, encoding_sa);
+	printf("%sTXSC: %016llx on SA %d\n", prefix, ntohll(sci), encoding_sa);
 	print_secy_stats(prefix, secy_stats);
 	print_txsc_stats(prefix, txsc_stats);
 
@@ -845,7 +845,7 @@ static void print_rx_sc(const char *prefix, __u64 sci, __u8 active,
 	struct rtattr *a;
 	int rem;
 
-	printf("%sRXSC: %016llx, state %s\n", prefix, sci,
+	printf("%sRXSC: %016llx, state %s\n", prefix, ntohll(sci),
 	       values_on_off[!!active]);
 	print_rxsc_stats(prefix, rxsc_stats);
 
@@ -1018,7 +1018,7 @@ static void macsec_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_MACSEC_SCI]) {
 		fprintf(f, "sci %016llx ",
-			rta_getattr_u64(tb[IFLA_MACSEC_SCI]));
+			ntohll(rta_getattr_u64(tb[IFLA_MACSEC_SCI])));
 	}
 
 	print_flag(f, tb, "protect", IFLA_MACSEC_PROTECT);
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 6fb5ad6..ffc4160 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -989,7 +989,9 @@ interpreted as octal and hexadecimal, respectively.
 
 .sp
 .BI sci " SCI "
-- sets the SCI for this MACsec device.
+- sets the secure channel identifier for this MACsec device.
+.I SCI
+is a 64bit wide number in hexadecimal format.
 
 .sp
 .BI cipher " CIPHER_SUITE "
-- 
2.5.5
