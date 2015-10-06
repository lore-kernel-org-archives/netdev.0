From: Willy Tarreau <w@1wt.eu>
Subject: Re: "ss -p" segfaults (updated to 4.2)
Date: Tue, 6 Oct 2015 12:09:33 +0200
Message-ID: <20151006100933.GA2702@1wt.eu>
References: <55AE15FE.6020802@openmailbox.org> <55AE16BD.40607@openmailbox.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
Cc: netdev@vger.kernel.org, schwab@linux-m68k.org
To: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:46182 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbbJFKJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 06:09:44 -0400
Content-Disposition: inline
In-Reply-To: <55AE16BD.40607@openmailbox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi guys,

I've updated Jose's patch to make it slightly simpler (eg: calloc instead
of malloc+memset), and ported it to 4.2.0 which requires it as well, and
attached it to this e-mail.

I can confirm that with this patch 4.1.1 doesn't segfault on me anymore.
The commit message should be reworked I guess though everything's in it
and I didn't want to modify his description.

Can it be merged as-is or should I reword the commit message and reference
Jose as the fix reporter ? We should not let this bug live forever.

Thanks,
Willy


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-ss-p-segfaults.patch"

>From 618028d6c5bfa4fb9898f2ec1ab5483e6f5392d4 Mon Sep 17 00:00:00 2001
From: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Date: Tue, 21 Jul 2015 10:54:05 +0100
Subject: "ss -p" segfaults

Patch for 4.2.0

Essentially all that is needed to get rid of this issue is the
addition of:

    memset(u, 0, sizeof(*u));

after:

    if (!(u = malloc(sizeof(*u))))
            break;

Also patched some other situations (strcpy and sprintf uses) that
potentially produce the same results.

Signed-off-by: Jose P Santos <j.ps@openmailbox.org>

[ wt: made Jose's patch slightly simpler, all credits to him for the diag ]
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 misc/ss.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2f34962..8b0d606 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -457,7 +457,9 @@ static void user_ent_hash_build(void)
 
 	user_ent_hash_build_init = 1;
 
-	strcpy(name, root);
+	strncpy(name, root, sizeof(name)-1);
+	name[sizeof(name)-1] = 0;
+
 	if (strlen(name) == 0 || name[strlen(name)-1] != '/')
 		strcat(name, "/");
 
@@ -481,7 +483,7 @@ static void user_ent_hash_build(void)
 		if (getpidcon(pid, &pid_context) != 0)
 			pid_context = strdup(no_ctx);
 
-		sprintf(name + nameoff, "%d/fd/", pid);
+		snprintf(name + nameoff, sizeof(name) - nameoff, "%d/fd/", pid);
 		pos = strlen(name);
 		if ((dir1 = opendir(name)) == NULL) {
 			free(pid_context);
@@ -502,7 +504,7 @@ static void user_ent_hash_build(void)
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) != 1)
 				continue;
 
-			sprintf(name+pos, "%d", fd);
+			snprintf(name+pos, sizeof(name) - pos, "%d", fd);
 
 			link_len = readlink(name, lnk, sizeof(lnk)-1);
 			if (link_len == -1)
@@ -2736,7 +2738,7 @@ static int unix_show(struct filter *f)
 		struct sockstat *u, **insp;
 		int flags;
 
-		if (!(u = malloc(sizeof(*u))))
+		if (!(u = calloc(1, sizeof(*u))))
 			break;
 		u->name = NULL;
 		u->peer_name = NULL;
@@ -3086,11 +3088,13 @@ static int netlink_show_one(struct filter *f,
 			strncpy(procname, "kernel", 6);
 		} else if (pid > 0) {
 			FILE *fp;
-			sprintf(procname, "%s/%d/stat",
+			snprintf(procname, sizeof(procname), "%s/%d/stat",
 				getenv("PROC_ROOT") ? : "/proc", pid);
 			if ((fp = fopen(procname, "r")) != NULL) {
 				if (fscanf(fp, "%*d (%[^)])", procname) == 1) {
-					sprintf(procname+strlen(procname), "/%d", pid);
+					snprintf(procname+strlen(procname),
+						sizeof(procname)-strlen(procname),
+						"/%d", pid);
 					done = 1;
 				}
 				fclose(fp);
-- 
1.7.12.1


--SUOF0GtieIMvvwua--
