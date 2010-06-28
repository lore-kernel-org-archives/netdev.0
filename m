From: David Miller <davem@davemloft.net>
Subject: Re: ss -p is much too slow
Date: Mon, 28 Jun 2010 16:21:39 -0700 (PDT)
Message-ID: <20100628.162139.59679342.davem@davemloft.net>
References: <AANLkTikd3VaSUa-pxzyi7_fND40vQ-L79X7yv19jj3y0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: sphink@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38749
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751145Ab0F1XV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 19:21:26 -0400
In-Reply-To: <AANLkTikd3VaSUa-pxzyi7_fND40vQ-L79X7yv19jj3y0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Fink <sphink@gmail.com>
Date: Wed, 9 Jun 2010 11:42:38 -0700

> On closer inspection, it appears that ss -p does a quadratic scan. It
> rescans every entry in /proc/*/fd/* repeatedly (once per listening
> port? per process? I don't remember what I figured out.)
> 
> I humbly suggest that this is not a good idea.

Yep, this is junk.  Please give this patch a try:

ss: Avoid quadradic complexity with '-p'

Scan the process list of open sockets once, and store in a hash
table to be used by subsequent find_user() calls.

Reported-by: Steve Fink <sphink@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/misc/ss.c b/misc/ss.c
index 8a9663c..482b6bb 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -195,90 +195,147 @@ static FILE *ephemeral_ports_open(void)
 	return generic_proc_open("PROC_IP_LOCAL_PORT_RANGE", "sys/net/ipv4/ip_local_port_range");
 }
 
-int find_users(unsigned ino, char *buf, int buflen)
+struct user_ent {
+	struct user_ent	*next;
+	unsigned int	ino;
+	int		pid;
+	int		fd;
+	char		process[0];
+};
+
+#define USER_ENT_HASH_SIZE	256
+struct user_ent *user_ent_hash[USER_ENT_HASH_SIZE];
+
+static int user_ent_hashfn(unsigned int ino)
 {
-	char pattern[64];
-	int  pattern_len;
-	char *ptr = buf;
-	char name[1024];
-	DIR *dir;
-	struct dirent *d;
-	int cnt = 0;
-	int nameoff;
+	int val = (ino >> 24) ^ (ino >> 16) ^ (ino >> 8) ^ ino;
 
-	if (!ino)
-		return 0;
+	return val & (USER_ENT_HASH_SIZE - 1);
+}
+
+static void user_ent_add(unsigned int ino, const char *process, int pid, int fd)
+{
+	struct user_ent *p, **pp;
+	int str_len;
 
-	sprintf(pattern, "socket:[%u]", ino);
-	pattern_len = strlen(pattern);
+	str_len = strlen(process) + 1;
+	p = malloc(sizeof(struct user_ent) + str_len);
+	if (!p)
+		abort();
+	p->next = NULL;
+	p->ino = ino;
+	p->pid = pid;
+	p->fd = fd;
+	strcpy(p->process, process);
+
+	pp = &user_ent_hash[user_ent_hashfn(ino)];
+	p->next = *pp;
+	*pp = p;
+}
 
-	strncpy(name, getenv("PROC_ROOT") ? : "/proc/", sizeof(name)/2);
-	name[sizeof(name)/2] = 0;
-	if (strlen(name) == 0 ||
-	    name[strlen(name)-1] != '/')
+static void user_ent_hash_build(void)
+{
+	const char *root = getenv("PROC_ROOT") ? : "/proc/";
+	struct dirent *d;
+	char name[1024];
+	int nameoff;
+	DIR *dir;
+
+	strcpy(name, root);
+	if (strlen(name) == 0 || name[strlen(name)-1] != '/')
 		strcat(name, "/");
+
 	nameoff = strlen(name);
-	if ((dir = opendir(name)) == NULL)
-		return 0;
+
+	dir = opendir(name);
+	if (!dir)
+		return;
 
 	while ((d = readdir(dir)) != NULL) {
-		DIR *dir1;
 		struct dirent *d1;
-		int pid;
-		int pos;
-		char crap;
 		char process[16];
+		int pid, pos;
+		DIR *dir1;
+		char crap;
 
 		if (sscanf(d->d_name, "%d%c", &pid, &crap) != 1)
 			continue;
 
-		sprintf(name+nameoff, "%d/fd/", pid);
+		sprintf(name + nameoff, "%d/fd/", pid);
 		pos = strlen(name);
 		if ((dir1 = opendir(name)) == NULL)
 			continue;
 
-		process[0] = 0;
+		process[0] = '\0';
 
 		while ((d1 = readdir(dir1)) != NULL) {
-			int fd, n;
+			const char *pattern = "socket:[";
+			unsigned int ino;
 			char lnk[64];
+			int fd, n;
 
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) != 1)
 				continue;
 
 			sprintf(name+pos, "%d", fd);
 			n = readlink(name, lnk, sizeof(lnk)-1);
-			if (n != pattern_len ||
-			    memcmp(lnk, pattern, n))
+			if (strncmp(lnk, pattern, strlen(pattern)))
 				continue;
 
-			if (ptr-buf >= buflen-1)
-				break;
+			sscanf(lnk, "socket:[%u]", &ino);
 
-			if (process[0] == 0) {
+			if (process[0] == '\0') {
 				char tmp[1024];
 				FILE *fp;
-				snprintf(tmp, sizeof(tmp), "%s/%d/stat",
-					 getenv("PROC_ROOT") ? : "/proc", pid);
+
+				snprintf(tmp, sizeof(tmp), "%s/%d/stat", root, pid);
 				if ((fp = fopen(tmp, "r")) != NULL) {
 					fscanf(fp, "%*d (%[^)])", process);
 					fclose(fp);
 				}
 			}
 
-			snprintf(ptr, buflen-(ptr-buf), "(\"%s\",%d,%d),", process, pid, fd);
-			ptr += strlen(ptr);
-			cnt++;
+			user_ent_add(ino, process, pid, fd);
 		}
 		closedir(dir1);
 	}
 	closedir(dir);
+}
+
+int find_users(unsigned ino, char *buf, int buflen)
+{
+	struct user_ent *p;
+	int cnt = 0;
+	char *ptr;
+
+	if (!ino)
+		return 0;
+
+	p = user_ent_hash[user_ent_hashfn(ino)];
+	ptr = buf;
+	while (p) {
+		if (p->ino != ino)
+			goto next;
+
+		if (ptr - buf >= buflen - 1)
+			break;
+
+		snprintf(ptr, buflen - (ptr - buf),
+			 "(\"%s\",%d,%d),",
+			 p->process, p->pid, p->fd);
+		ptr += strlen(ptr);
+		cnt++;
+
+	next:
+		p = p->next;
+	}
+
 	if (ptr != buf)
-		ptr[-1] = 0;
+		ptr[-1] = '\0';
+
 	return cnt;
 }
 
-
 /* Get stats from slab */
 
 struct slabstat
@@ -2476,6 +2533,7 @@ int main(int argc, char *argv[])
 			break;
 		case 'p':
 			show_users++;
+			user_ent_hash_build();
 			break;
 		case 'd':
 			current_filter.dbs |= (1<<DCCP_DB);
