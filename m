From: jamal <hadi@cyberus.ca>
Subject: Re: [RFT] new iproute2
Date: 14 Aug 2004 18:32:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092522729.2877.33.camel@jzny.localdomain>
References: <20040813170051.67d79b9d@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-0WGlRc+Z4atePLsA/Ie3"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040813170051.67d79b9d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-0WGlRc+Z4atePLsA/Ie3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2004-08-13 at 20:00, Stephen Hemminger wrote: 
> Okay, here is a new version of iproute2 with your last round of CLS patches
> incorporated in.  Note: I fixed up some things that seemed to have changed in
> the current version of pkt_cls.h
> 
> Also:
> 	- removed all #ifdef CONFIG_ from the command. 
> 	- copy of kernel headers is now in iproute2/include/linux so that
> 	  it will build without matching kernel headers.
> 	- this reduces the amount of configuration necessary.
> 
> I don't want this final until you go over it Jamal, cause I had to rework your
> stuff enough that I probably broke it.

It was broken already because of latest kernel changes. Heres a patch on
top of what you have that fixes it. I have not run my full regression
tests on it (will do later next week) but basic tests all pass. 

Note that i think you may have a typo in your bit conversion for rates.
Example:

--
[root@jzny tc]# ./tc filter add dev eth0 parent ffff: protocol ip prio 6
u32 match ip src 10.0.0.1/32 flowid 1:16 police rate 1kbit burst 90k
drop

[root@jzny tc]# ./tc -s filter show parent ffff: dev eth0
filter protocol ip pref 6 u32 
filter protocol ip pref 6 u32 fh 800: ht divisor 1 
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
flowid 1:16 
police 1 action drop rate 125bps burst 90Kb mtu 2Kb 
  match 0a000001/ffffffff at 12
Sent 0 bytes 0 pkts (dropped 0, overlimits 0) 
--

125bps Should be 125Bps which is 1Kbits/sec, no?

cheers,
jamal

--=-0WGlRc+Z4atePLsA/Ie3
Content-Disposition: attachment; filename=p1
Content-Type: text/plain; name=p1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/tc/tc_filter.c	2004-08-13 19:57:35.000000000 -0400
+++ b/tc/tc_filter.c	2004-08-13 21:54:49.000000000 -0400
@@ -254,18 +254,14 @@
 
 	if (show_stats) {
 		if (tb[TCA_STATS]) {
-#ifndef STOOPID_8BYTE
 			if (RTA_PAYLOAD(tb[TCA_STATS]) < sizeof(struct tc_stats))
 				fprintf(fp, "statistics truncated");
 			else {
-#endif
 				struct tc_stats st;
 				memcpy(&st, RTA_DATA(tb[TCA_STATS]), sizeof(st));
 				print_tcstats(fp, &st);
 				fprintf(fp, "\n");
-#ifndef STOOPID_8BYTE
 			}
-#endif
 		}
 	}
 	fflush(fp);
--- a/tc/tc_class.c	2004-08-13 19:57:34.000000000 -0400
+++ b/tc/tc_class.c	2004-08-13 21:58:37.000000000 -0400
@@ -241,18 +241,14 @@
 	fprintf(fp, "\n");
 	if (show_stats) {
 		if (tb[TCA_STATS]) {
-#ifndef STOOPID_8BYTE
 			if (RTA_PAYLOAD(tb[TCA_STATS]) < sizeof(struct tc_stats))
 				fprintf(fp, "statistics truncated");
 			else {
-#endif
 				struct tc_stats st;
 				memcpy(&st, RTA_DATA(tb[TCA_STATS]), sizeof(st));
 				print_class_tcstats(fp, &st);
 				fprintf(fp, "\n");
-#ifndef STOOPID_8BYTE
 			}
-#endif
 		}
 		if (q && tb[TCA_XSTATS]) {
 			q->print_xstats(q, fp, tb[TCA_XSTATS]);
--- a/tc/tc_qdisc.c	2004-08-13 19:57:34.000000000 -0400
+++ b/tc/tc_qdisc.c	2004-08-13 22:01:52.000000000 -0400
@@ -173,7 +173,6 @@
 
 	fprintf(fp, " Sent %llu bytes %u pkts (dropped %u, overlimits %u ) ",
 		(unsigned long long)st->bytes, st->packets, st->drops, st->overlimits);
-
 	if (st->bps || st->pps || st->qlen || st->backlog) {
 		fprintf(fp, "\n ");
 		if (st->bps || st->pps) {
@@ -256,19 +255,15 @@
 	fprintf(fp, "\n");
 	if (show_stats) {
 		if (tb[TCA_STATS]) {
-#ifndef STOOPID_8BYTE
 			if (RTA_PAYLOAD(tb[TCA_STATS]) < sizeof(struct tc_stats))
 				fprintf(fp, "statistics truncated");
 			else {
-#endif
 				struct tc_stats st;
 				memcpy(&st, RTA_DATA(tb[TCA_STATS]), sizeof(st));
 				print_tcstats(fp, &st);
 				fprintf(fp, "\n");
 			}
-#ifndef STOOPID_8BYTE
 		}
-#endif
 		if (q && tb[TCA_XSTATS]) {
 			q->print_xstats(q, fp, tb[TCA_XSTATS]);
 			fprintf(fp, "\n");
--- a/tc/m_action.c	2004-08-13 19:57:35.000000000 -0400
+++ b/tc/m_action.c	2004-08-13 22:34:09.000000000 -0400
@@ -262,21 +262,17 @@
 
 	if (show_stats) {
 		if (tb[TCA_STATS]) {
-#ifndef STOOPID_8BYTE
 			if (RTA_PAYLOAD(tb[TCA_STATS]) <
 			    sizeof (struct tc_stats))
 				fprintf(f, "statistics truncated");
 			else {
-#endif
 				struct tc_stats st;
 				memcpy(&st, RTA_DATA(tb[TCA_STATS]),
 				       sizeof (st));
 				fprintf(f, "\t");
 				print_tcstats(f, &st);
 				fprintf(f, "\n");
-#ifndef STOOPID_8BYTE
 			}
-#endif
 		}
 	}
 
--- a/tc/f_u32.c	2004-08-13 19:57:35.000000000 -0400
+++ b/tc/f_u32.c	2004-08-13 22:54:08.000000000 -0400
@@ -123,8 +123,6 @@
 				return -1;
 			sel->keys[i].val |= key;
 			sel->keys[i].mask |= mask;
-			sel->keys[i].off = 0;
-			sel->keys[i].offmask = 0;
 			return 0;
 		}
 	}
@@ -710,19 +708,10 @@
 	while (argc > 0) {
 		if (matches(*argv, "mask") == 0) {
 			__u32 mask;
-			int i = 0;
 			NEXT_ARG();
 			if (get_u32(&mask, *argv, 16))
 				return -1;
 			sel->hmask = htonl(mask);
-			mask = sel->hmask;
-			while (!(mask & 1)) {
-				i++;
-				mask>>=1;
-			}
-#ifdef fix_u32_bug
-			sel->fshift = i;
-#endif
 		} else if (matches(*argv, "at") == 0) {
 			int num;
 			NEXT_ARG();
@@ -875,6 +864,7 @@
 			}
 			strncpy(ind, *argv, sizeof (ind) - 1);
 			addattr_l(n, MAX_MSG, TCA_U32_INDEV, ind, strlen(ind) + 1);
+
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (parse_action(&argc, &argv, TCA_U32_ACT, n)) {
@@ -882,6 +872,7 @@
 				return -1;
 			}
 			continue;
+
 		} else if (matches(*argv, "police") == 0) {
 			NEXT_ARG();
 			if (parse_police(&argc, &argv, TCA_U32_POLICE, n)) {
@@ -920,6 +911,7 @@
 {
 	struct rtattr *tb[TCA_U32_MAX+1];
 	struct tc_u32_sel *sel = NULL;
+	struct tc_u32_pcnt *pf = NULL;
 
 	if (opt == NULL)
 		return 0;
@@ -964,10 +956,19 @@
 		fprintf(f, "link %s ", sprint_u32_handle(*(__u32*)RTA_DATA(tb[TCA_U32_LINK]), b1));
 	}
 
+	if (tb[TCA_U32_PCNT]) {
+		if (RTA_PAYLOAD(tb[TCA_U32_PCNT])  < sizeof(*pf)) {
+			fprintf(f, "Broken perf counters \n");
+			return -1;
+		}
+		pf = RTA_DATA(tb[TCA_U32_PCNT]);
+	}
 
 	if (sel) {
 		int i;
 		struct tc_u32_key *key = sel->keys;
+		if (show_stats && NULL != pf)
+			fprintf(f, " (rule hit %llu success %llu)",pf->rcnt,pf->rhit);
 		if (sel->nkeys) {
 			for (i=0; i<sel->nkeys; i++, key++) {
 				fprintf(f, "\n  match %08x/%08x at %s%d",
@@ -975,6 +976,8 @@
 					(unsigned int)ntohl(key->mask),
 					key->offmask ? "nexthdr+" : "",
 					key->off);
+				if (show_stats && NULL != pf)
+					fprintf(f, " (success %lld ) ",pf->kcnts[i]);
 			}
 		}
 
@@ -994,11 +997,6 @@
 		}
 	}
 
-	if (show_stats && tb[TCA_U32_PCNT]){
-		struct tc_u32_pcnt *p = RTA_DATA(tb[TCA_U32_PCNT]);
-		fprintf(f, " (rule hit %llu success %llu)",
-			p->rcnt, p->rhit);
-	}
 	if (tb[TCA_U32_POLICE]) {
 		fprintf(f, "\n");
 		tc_print_police(f, tb[TCA_U32_POLICE]);

--=-0WGlRc+Z4atePLsA/Ie3--
