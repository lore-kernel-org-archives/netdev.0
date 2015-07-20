From: "j.ps@openmailbox.org" <j.ps@openmailbox.org>
Subject: Re: Segmentation fault in iproute2 ss -p (versions 4.0.0, 4.1.0 and
 4.1.1)
Date: Mon, 20 Jul 2015 08:07:17 +0100
Message-ID: <55AC9E25.9050804@openmailbox.org>
References: <20150719140548.6d17a475@urahara>
Reply-To: j.ps@openmailbox.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030400010603020105080300"
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.openmailbox.org ([62.4.1.36]:43253 "EHLO
	smtp2.openmailbox.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755359AbbGTHNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 03:13:36 -0400
In-Reply-To: <20150719140548.6d17a475@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030400010603020105080300
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable




--- iproute2-4.1.1-orig/misc/ss.c	2015-07-06 22:57:34.000000000 +0100
+++ iproute2-4.1.1/misc/ss.c	2015-07-19 12:16:25.000000000 +0100
@@ -428,9 +428,12 @@
 	while (cnt !=3D USER_ENT_HASH_SIZE) {
 		p =3D user_ent_hash[cnt];
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
 			p_next =3D p->next;
 			free(p);
 			p =3D p_next;
@@ -456,7 +459,21 @@

 	user_ent_hash_build_init =3D 1;

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
 	if (strlen(name) =3D=3D 0 || name[strlen(name)-1] !=3D '/')
 		strcat(name, "/");

@@ -480,7 +497,7 @@
 		if (getpidcon(pid, &pid_context) !=3D 0)
 			pid_context =3D strdup(no_ctx);

-		sprintf(name + nameoff, "%d/fd/", pid);
+		snprintf(name + nameoff, sizeof(name) - nameoff, "%d/fd/", pid);
 		pos =3D strlen(name);
 		if ((dir1 =3D opendir(name)) =3D=3D NULL)
 			continue;
@@ -499,7 +516,7 @@
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) !=3D 1)
 				continue;

-			sprintf(name+pos, "%d", fd);
+			snprintf(name+pos, sizeof(name) - pos, "%d", fd);

 			link_len =3D readlink(name, lnk, sizeof(lnk)-1);
 			if (link_len =3D=3D -1)
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
 		if (!(u =3D malloc(sizeof(*u))))
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
 			if ((fp =3D fopen(procname, "r")) !=3D NULL) {
 				if (fscanf(fp, "%*d (%[^)])", procname) =3D=3D 1) {
-					sprintf(procname+strlen(procname), "/%d", pid);
+					snprintf(procname+strlen(procname),
+						sizeof(procname)-strlen(procname), "/%d", pid);
 					done =3D 1;
 				}
 				fclose(fp);


-------- Forwarded Message --------
Subject: Re: Segmentation fault in iproute2 ss -p (versions 4.0.0, 4.1.0
and 4.1.1)
Date: Sun, 19 Jul 2015 14:05:48 -0700
From: Stephen Hemminger <stephen@networkplumber.org>
To: <j.ps@member.fsf.org>

Please send patches as plain text for review to netdev@vger.kernel.org




--------------030400010603020105080300
Content-Type: text/plain; charset=UTF-8;
 name="iproute2-4.1.1-patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="iproute2-4.1.1-patch"

--- iproute2-4.1.1-orig/misc/ss.c	2015-07-06 22:57:34.000000000 +0100
+++ iproute2-4.1.1/misc/ss.c	2015-07-19 12:16:25.000000000 +0100
@@ -428,9 +428,12 @@
 	while (cnt !=3D USER_ENT_HASH_SIZE) {
 		p =3D user_ent_hash[cnt];
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
 			p_next =3D p->next;
 			free(p);
 			p =3D p_next;
@@ -456,7 +459,21 @@
=20
 	user_ent_hash_build_init =3D 1;
=20
-	strcpy(name, root);
+	/* strcpy is really dangerous!  in this case if we're going to=20
+	   copy an  unknown input  size from  getenv("PROC_ROOT") to a=20
+	   fixed size buffer name[1024] we're going to get troubles.=20
+	   If the size of a manipulated  "PROC_ROOT" > size of name we
+	   will have a buffer overrun smashing the stack,  overwriting=20
+	   other local variables and/or return address, etc... */
+
+	memset(name, 0, sizeof(name));
+
+	strncpy(name, root, 512);
+	/* Chose this value ^^^ (maybe too large) just to avoid buffer=20
+	   overflow  if sizeof getenv("PROC_ROOT") > sizeof(name)  and=20
+	   to allow the  name composition that follows below to fit in=20
+	   the remaining space. */
+
 	if (strlen(name) =3D=3D 0 || name[strlen(name)-1] !=3D '/')
 		strcat(name, "/");
=20
@@ -480,7 +497,7 @@
 		if (getpidcon(pid, &pid_context) !=3D 0)
 			pid_context =3D strdup(no_ctx);
=20
-		sprintf(name + nameoff, "%d/fd/", pid);
+		snprintf(name + nameoff, sizeof(name) - nameoff, "%d/fd/", pid);
 		pos =3D strlen(name);
 		if ((dir1 =3D opendir(name)) =3D=3D NULL)
 			continue;
@@ -499,7 +516,7 @@
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) !=3D 1)
 				continue;
=20
-			sprintf(name+pos, "%d", fd);
+			snprintf(name+pos, sizeof(name) - pos, "%d", fd);
=20
 			link_len =3D readlink(name, lnk, sizeof(lnk)-1);
 			if (link_len =3D=3D -1)
@@ -529,9 +546,16 @@
 			}
 			user_ent_add(ino, p, pid, fd,
 					pid_context, sock_context);
-			free(sock_context);
-		}
-		free(pid_context);
+			/* memory was  allocated  conditionally so
+			   freeing it should go the same way (even=20
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
 		if (!(u =3D malloc(sizeof(*u))))
 			break;
=20
+		/* The following memset of 'u' struct is crucial to avoid a segfault
+		   when freeing memory 'free(name)' at 'unix_list_free()'.  In fact,=20
+		   without this  'initialization', testing 'if (name)'  at line 2513=20
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
 			if ((fp =3D fopen(procname, "r")) !=3D NULL) {
 				if (fscanf(fp, "%*d (%[^)])", procname) =3D=3D 1) {
-					sprintf(procname+strlen(procname), "/%d", pid);
+					snprintf(procname+strlen(procname),=20
+						sizeof(procname)-strlen(procname), "/%d", pid);
 					done =3D 1;
 				}
 				fclose(fp);

--------------030400010603020105080300--
