From: Johannes Naab <jn@stusta.de>
Subject: [PATCH] iproute2: tc netem rate: allow negative packet/cell overhead
Date: Wed, 23 Jan 2013 22:38:19 +0100
Message-ID: <5100584B.6000108@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stusta.mhn.de ([141.84.69.5]:52867 "EHLO
	mail.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab3AWVqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 16:46:48 -0500
Received: from [10.150.30.16] (r030016.stusta.swh.mhn.de [10.150.30.16])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: 004445)
	by mail.stusta.mhn.de (Postfix) with ESMTPSA id BDAE5125F1
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 22:38:19 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Naab <jn@stusta.de>

by fixing the parsing of command-line tokens

Signed-off-by: Johannes Naab <jn@stusta.de>
---

The packet or cell overhead used with the rate extension can be negative. The
man page tc-netem(8) documents this. However, iproute2 currently does not
detect negative numbers as valid token.

> $ tc qdisc add dev eth0 root netem rate 1024bps -14
> What is "-14"?
> Usage: ... netem [ limit PACKETS ]

I developed this patch while doing a student project at
http://www.nav.ei.tum.de/.


 tc/q_netem.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index f8489e9..2583072 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -147,6 +147,8 @@ static int get_distribution(const char *type, __s16 *data, int maxdata)
 }
 
 #define NEXT_IS_NUMBER() (NEXT_ARG_OK() && isdigit(argv[1][0]))
+#define NEXT_IS_SIGNED_NUMBER() \
+	(NEXT_ARG_OK() && (isdigit(argv[1][0]) || argv[1][0] == '-'))
 
 /* Adjust for the fact that psched_ticks aren't always usecs
    (based on kernel PSCHED_CLOCK configuration */
@@ -393,7 +395,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				explain1("rate");
 				return -1;
 			}
-			if (NEXT_IS_NUMBER()) {
+			if (NEXT_IS_SIGNED_NUMBER()) {
 				NEXT_ARG();
 				if (get_s32(&rate.packet_overhead, *argv, 0)) {
 					explain1("rate");
@@ -407,7 +409,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 					return -1;
 				}
 			}
-			if (NEXT_IS_NUMBER()) {
+			if (NEXT_IS_SIGNED_NUMBER()) {
 				NEXT_ARG();
 				if (get_s32(&rate.cell_overhead, *argv, 0)) {
 					explain1("rate");
