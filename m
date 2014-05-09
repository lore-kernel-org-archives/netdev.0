From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: [PATCH iproute2] tc/netem: fix loss state display and p14 parsing
Date: Thu, 08 May 2014 19:02:20 -0700
Message-ID: <13144.1399600940@localhost.localdomain>
Cc: netdev@vger.kernel.org, netem@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55722 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355AbaEICC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:02:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	The display of the entire netem loss state is shown as if it
were gemodel state, as the loss state information is assigned to the
wrong pointer.  Correct this by assigning the loss state to the correct
pointer.

	Additionally, attempting to set netem loss state will result in
random values in the p14 state probability because the option value
passed to the kernel by tc netem is not parsed or initialized.  Fix this
by supplying a default value of 0 for p14 and parsing the p14 value if
one is supplied.

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

---
 tc/q_netem.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index 946007c..c83e301 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -263,6 +263,7 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 				set_percent(&gimodel.p31, 1. - p13);
 				set_percent(&gimodel.p32, 0);
 				set_percent(&gimodel.p23, 1.);
+				set_percent(&gimodel.p14, 0);
 				loss_type = NETEM_LOSS_GI;
 
 				if (!NEXT_IS_NUMBER())
@@ -288,6 +289,13 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 					explain1("loss p23");
 					return -1;
 				}
+				if (!NEXT_IS_NUMBER())
+					continue;
+				NEXT_ARG();
+				if (get_percent(&gimodel.p14, *argv)) {
+					explain1("loss p14");
+					return -1;
+				}
 
 			} else if (!strcmp(*argv, "gemodel")) {
 				NEXT_ARG();
@@ -569,7 +577,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 
 			parse_rtattr_nested(lb, NETEM_LOSS_MAX, tb[TCA_NETEM_LOSS]);
 			if (lb[NETEM_LOSS_GI])
-				gemodel = RTA_DATA(lb[NETEM_LOSS_GI]);
+				gimodel = RTA_DATA(lb[NETEM_LOSS_GI]);
 			if (lb[NETEM_LOSS_GE])
 				gemodel = RTA_DATA(lb[NETEM_LOSS_GE]);
 		}			
-- 
1.8.3.2
