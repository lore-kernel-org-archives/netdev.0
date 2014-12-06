From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2/nstat: Bug in displaying icmp stats
Date: Fri, 05 Dec 2014 18:10:08 -0800
Message-ID: <1417831808.15618.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAGK4HS_ty2=f0PNU-w8QPP9BoP67E+4MaDxLTLV4G22dx_7A-Q@mail.gmail.com>
	 <1417828247.15618.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417828430.15618.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:61625 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaLFCKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 21:10:11 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so280779iga.8
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 18:10:10 -0800 (PST)
In-Reply-To: <1417828430.15618.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 17:13 -0800, Eric Dumazet wrote:

> I guess we could count number of spaces/fields in both lines,
> and disable the iproute2 trick if counts match.

Something like that maybe ?

 misc/nstat.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)
diff --git a/misc/nstat.c b/misc/nstat.c
index e54b3ae..c2cb056 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -156,6 +156,15 @@ static void load_good_table(FILE *fp)
 	}
 }
 
+static int count_spaces(const char *line)
+{
+	int count = 0;
+	char c;
+
+	while ((c = *line++) != 0)
+		count += c == ' ' || c == '\n';
+	return count;
+}
 
 static void load_ugly_table(FILE *fp)
 {
@@ -167,10 +176,12 @@ static void load_ugly_table(FILE *fp)
 		char idbuf[sizeof(buf)];
 		int  off;
 		char *p;
+		int count1, count2, skip = 0;
 
 		p = strchr(buf, ':');
 		if (!p)
 			abort();
+		count1 = count_spaces(buf);
 		*p = 0;
 		idbuf[0] = 0;
 		strncat(idbuf, buf, sizeof(idbuf) - 1);
@@ -199,6 +210,9 @@ static void load_ugly_table(FILE *fp)
 		n = db;
 		if (fgets(buf, sizeof(buf), fp) == NULL)
 			abort();
+		count2 = count_spaces(buf);
+		if (count2 > count1)
+			skip = count2 - count1;
 		do {
 			p = strrchr(buf, ' ');
 			if (!p)
@@ -207,8 +221,8 @@ static void load_ugly_table(FILE *fp)
 			if (sscanf(p+1, "%llu", &n->val) != 1)
 				abort();
 			/* Trick to skip "dummy" trailing ICMP MIB in 2.4 */
-			if (strcmp(idbuf, "IcmpOutAddrMaskReps") == 0)
-				idbuf[5] = 0;
+			if (skip)
+				skip--;
 			else
 				n = n->next;
 		} while (p > buf + off + 2);
