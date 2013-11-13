From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH iproute2 v2] ss: avoid passing negative numbers to malloc
Date: Wed, 13 Nov 2013 09:46:42 +0100
Message-ID: <20131113084642.GA23572@amd64.fatal.se>
References: <1384298327.28458.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:44486 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933119Ab3KMJLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 04:11:30 -0500
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 3F7D7E9201
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 09:54:05 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1384298327.28458.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Example:

$ ss state established \( sport = :4060  or sport = :4061 or sport = :4062  or sport = :4063 or sport = :4064  or sport = :4065 or sport = :4066  or sport = :4067 \)  > /dev/null
Aborted

In the example above ssfilter_bytecompile(...) will return (int)136.
char l1 = 136; means -120 which will result in a negative number
being passed to malloc at misc/ss.c:913.

Simply declare l1 and l2 as integers to avoid the char overflow.

This is one of the issues originally reported in http://bugs.debian.org/511720

Fix the same problem in other code paths as well (thanks to Eric Dumazet).

Reported-by: Andreas Schuldei <andreas@debian.org>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 misc/ss.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

v2 fixes the same problem in other code paths (AND, NOT).
Pointed out by Eric Dumazet.


diff --git a/misc/ss.c b/misc/ss.c
index c0369f1..6f38ae7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -894,7 +894,8 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 
 		case SSF_AND:
 	{
-		char *a1, *a2, *a, l1, l2;
+		char *a1, *a2, *a;
+		int l1, l2;
 		l1 = ssfilter_bytecompile(f->pred, &a1);
 		l2 = ssfilter_bytecompile(f->post, &a2);
 		if (!(a = malloc(l1+l2))) abort();
@@ -907,7 +908,8 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 	}
 		case SSF_OR:
 	{
-		char *a1, *a2, *a, l1, l2;
+		char *a1, *a2, *a;
+		int l1, l2;
 		l1 = ssfilter_bytecompile(f->pred, &a1);
 		l2 = ssfilter_bytecompile(f->post, &a2);
 		if (!(a = malloc(l1+l2+4))) abort();
@@ -920,7 +922,8 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 	}
 		case SSF_NOT:
 	{
-		char *a1, *a, l1;
+		char *a1, *a;
+		int l1;
 		l1 = ssfilter_bytecompile(f->pred, &a1);
 		if (!(a = malloc(l1+4))) abort();
 		memcpy(a, a1, l1);
-- 
1.8.4.3
