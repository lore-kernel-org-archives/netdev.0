From: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Subject: "ss -p" segfaults
Date: Mon, 20 Jul 2015 18:31:31 +0100
Message-ID: <55AD3073.3000302@openmailbox.org>
References: <55AC9E8C.7040200@openmailbox.org>
Reply-To: j.ps@openmailbox.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.openmailbox.org ([62.4.1.36]:58309 "EHLO
	smtp2.openmailbox.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756524AbbGTRbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 13:31:35 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail2.openmailbox.org (Postfix) with ESMTP id BDB292026C5
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 19:31:33 +0200 (CEST)
In-Reply-To: <55AC9E8C.7040200@openmailbox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please find attached one simple patch for the code 4.1.0/4.1.1.

Essentially all that is needed to get rid of this issue is the
addition of:

    memset(u, 0, sizeof(*u));

after:

    if (!(u = malloc(sizeof(*u))))
            break;

During the analysis of this issue I also found some other situations
(strcpy and sprintf uses) that potentially produce the same results.

Corrections are also added, all with full comments.

Regards,
Jose Santos


--- iproute2-4.1.1-orig/misc/ss.c	2015-07-06 22:57:34.000000000 +0100
+++ iproute2-4.1.1/misc/ss.c	2015-07-19 12:16:25.000000000 +0100
@@ -428,9 +428,12 @@
 	while (cnt != USER_ENT_HASH_SIZE) {
 		p = user_ent_hash[cnt];
 		while (p) {
-			free(p->process);
-			free(p->process_ctx);
-			free(p->socket_ctx);
+			if (p->process)
+				free(p->process);
+			if (p->process_ctx)
+				free(p->process_ctx);
+			if (p->socket_ctx)
+				free(p->socket_ctx);
 			p_next = p->next;
 			free(p);
 			p = p_next;
@@ -456,7 +459,21 @@

 	user_ent_hash_build_init = 1;

-	strcpy(name, root);
+	/* strcpy is really dangerous!  in this case if we're going to
+	   copy an  unknown input  size from  getenv("PROC_ROOT") to a
+	   fixed size buffer name[1024] we're going to get troubles.
+	   If the size of a manipulated  "PROC_ROOT" > size of name we
+	   will have a buffer overrun smashing the stack,  overwriting
+	   other local variables and/or return address, etc... */
+
+	memset(name, 0, sizeof(name));
+
+	strncpy(name, root, 512);
+	/* Chose this value ^^^ (maybe too large) just to avoid buffer
+	   overflow  if sizeof getenv("PROC_ROOT") > sizeof(name)  and
+	   to allow the  name composition that follows below to fit in
+	   the remaining space. */
+
 	if (strlen(name) == 0 || name[strlen(name)-1] != '/')
 		strcat(name, "/");

@@ -480,7 +497,7 @@
 		if (getpidcon(pid, &pid_context) != 0)
 			pid_context = strdup(no_ctx);

-		sprintf(name + nameoff, "%d/fd/", pid);
+		snprintf(name + nameoff, sizeof(name) - nameoff, "%d/fd/", pid);
 		pos = strlen(name);
 		if ((dir1 = opendir(name)) == NULL)
 			continue;
@@ -499,7 +516,7 @@
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) != 1)
 				continue;

-			sprintf(name+pos, "%d", fd);
+			snprintf(name+pos, sizeof(name) - pos, "%d", fd);

 			link_len = readlink(name, lnk, sizeof(lnk)-1);
 			if (link_len == -1)
@@ -529,9 +546,16 @@
 			}
 			user_ent_add(ino, p, pid, fd,
 					pid_context, sock_context);
-			free(sock_context);
-		}
-		free(pid_context);
+			/* memory was  allocated  conditionally so
+			   freeing it should go the same way (even
+			   though the actual  code implies that in
+			   this case it will always be allocated). */
+			if (sock_context)
+				free(sock_context);
+		}
+		/* same as above */
+		if (pid_context)
+			free(pid_context);
 		closedir(dir1);
 	}
 	closedir(dir);
@@ -2722,6 +2746,13 @@
 		if (!(u = malloc(sizeof(*u))))
 			break;

+		/* The following memset of 'u' struct is crucial to avoid a segfault
+		   when freeing memory 'free(name)' at 'unix_list_free()'.  In fact,
+		   without this  'initialization', testing 'if (name)'  at line 2513
+		   will most likely return true even if 'name' isn't allocated. */
+
+		memset(u, 0, sizeof(*u));
+
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
 			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
 			   &u->state, &u->ino, name) < 8)
@@ -3064,11 +3095,12 @@
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
+						sizeof(procname)-strlen(procname), "/%d", pid);
 					done = 1;
 				}
 				fclose(fp);
