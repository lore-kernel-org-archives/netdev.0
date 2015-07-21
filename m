From: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Subject: Re: Segmentation fault in iproute2 ss -p (versions 4.0.0, 4.1.0 and
 4.1.1)
Date: Tue, 21 Jul 2015 10:50:54 +0100
Message-ID: <55AE15FE.6020802@openmailbox.org>
References: <20150719140548.6d17a475@urahara>
 <55AC9E25.9050804@openmailbox.org> <20150720120954.2639f2e4@urahara>
Reply-To: j.ps@openmailbox.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp29.openmailbox.org ([62.4.1.63]:34840 "EHLO
	smtp29.openmailbox.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbbGUJvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 05:51:01 -0400
In-Reply-To: <20150720120954.2639f2e4@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch for 4.1.1.

Essentially all that is needed to get rid of this issue is the
addition of:

    memset(u, 0, sizeof(*u));

after:

    if (!(u = malloc(sizeof(*u))))
            break;

Also patched some other situations (strcpy and sprintf uses) that
potentially produce the same results.

Note: As far as I know strlcpy isn't (yet) available in glibc.

Signed-off-by: Jose P Santos <j.ps@openmailbox.org>

--- iproute2-4.1.1/misc/ss.c.orig	2015-07-06 22:57:34.000000000 +0100
+++ iproute2-4.1.1/misc/ss.c	2015-07-21 10:26:45.000000000 +0100
@@ -456,7 +456,10 @@ static void user_ent_hash_build(void)

 	user_ent_hash_build_init = 1;

-	strcpy(name, root);
+	/* Avoid buffer overrun if input size from PROC_ROOT > name */
+	memset(name, 0, sizeof(name));
+	strncpy(name, root, sizeof(name)-2);
+
 	if (strlen(name) == 0 || name[strlen(name)-1] != '/')
 		strcat(name, "/");

@@ -480,7 +483,7 @@ static void user_ent_hash_build(void)
 		if (getpidcon(pid, &pid_context) != 0)
 			pid_context = strdup(no_ctx);

-		sprintf(name + nameoff, "%d/fd/", pid);
+		snprintf(name + nameoff, sizeof(name) - nameoff, "%d/fd/", pid);
 		pos = strlen(name);
 		if ((dir1 = opendir(name)) == NULL)
 			continue;
@@ -499,7 +502,7 @@ static void user_ent_hash_build(void)
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) != 1)
 				continue;

-			sprintf(name+pos, "%d", fd);
+			snprintf(name+pos, sizeof(name) - pos, "%d", fd);

 			link_len = readlink(name, lnk, sizeof(lnk)-1);
 			if (link_len == -1)
@@ -2722,6 +2725,11 @@ static int unix_show(struct filter *f)
 		if (!(u = malloc(sizeof(*u))))
 			break;

+		/* Zero initialization of 'u' struct avoids a segfault
+		 * when freeing memory 'free(name)' at 'unix_list_free()'.
+		 */
+		memset(u, 0, sizeof(*u));
+
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
 			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
 			   &u->state, &u->ino, name) < 8)
@@ -3064,11 +3072,13 @@ static int netlink_show_one(struct filte
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



On 2015-07-20 20:09, Stephen Hemminger wrote:
> Patches are always appreciated and this looks like a real bug.
> But before I can accept it there are a couple of small
> changes needed.
> 
> 1. There is no need to check for NULL when calling free().
>    Glibc free is documented to accept NULL as a valid request
>    and do nothing.
> 
> 2. Please add a Signed-off-by: line with a real name.
>    Signed-off-by has legal meaning for the Developer's Certificate of Origin
>    see kernel documentation if you need more explaination.
> 
> 3. Although what you found is important, giving a full paragraph
>    of personal comment about it is not required. The point is software
>    should read like one source independent of who the authors are.
>    Your comment is basically just justifying using strncpy.
> 
> 4. Rather than strncpy() which has issues with maximal sized strings
>    consider using strlcpy() instead.
> 
> 5. Iproute2 uses kernel identation and style, consider running checkpatch
>    on your changes.
> 
> Please fixup and resubmit to netdev.
> 
> 
