From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: 64bit inode numbers
Date: Tue, 12 Apr 2016 15:22:29 -0700
Message-ID: <1460499749.6473.601.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34099 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758427AbcDLWWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:22:32 -0400
Received: by mail-pa0-f52.google.com with SMTP id ot11so21104195pab.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 15:22:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Lets prepare for a possibility to have 64bit inode numbers for sockets,
even if the kernel currently enforces 32bit numbers.

Presumably, if both kernel and userland are 64bit (no 32bit emulation),
kernel could switch to 64bit inode numbers soon.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |   38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 38cf331..3355da5 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -377,7 +377,7 @@ static FILE *ephemeral_ports_open(void)
 
 struct user_ent {
 	struct user_ent	*next;
-	unsigned int	ino;
+	__u64		ino;
 	int		pid;
 	int		fd;
 	char		*process;
@@ -388,17 +388,18 @@ struct user_ent {
 #define USER_ENT_HASH_SIZE	256
 struct user_ent *user_ent_hash[USER_ENT_HASH_SIZE];
 
-static int user_ent_hashfn(unsigned int ino)
+static int user_ent_hashfn(__u64 ino)
 {
-	int val = (ino >> 24) ^ (ino >> 16) ^ (ino >> 8) ^ ino;
+	unsigned int val = (unsigned int)ino;
 
+	val ^= (unsigned int)(ino >> 32);
+	val ^= (val >> 16);
+	val ^= (val >> 8);
 	return val & (USER_ENT_HASH_SIZE - 1);
 }
 
-static void user_ent_add(unsigned int ino, char *process,
-					int pid, int fd,
-					char *proc_ctx,
-					char *sock_ctx)
+static void user_ent_add(__u64 ino, char *process, int pid, int fd,
+			 char *proc_ctx, char *sock_ctx)
 {
 	struct user_ent *p, **pp;
 
@@ -494,7 +495,7 @@ static void user_ent_hash_build(void)
 
 		while ((d1 = readdir(dir1)) != NULL) {
 			const char *pattern = "socket:[";
-			unsigned int ino;
+			__u64 ino;
 			char lnk[64];
 			int fd;
 			ssize_t link_len;
@@ -513,7 +514,7 @@ static void user_ent_hash_build(void)
 			if (strncmp(lnk, pattern, strlen(pattern)))
 				continue;
 
-			sscanf(lnk, "socket:[%u]", &ino);
+			sscanf(lnk, "socket:[%llu]", &ino);
 
 			snprintf(tmp, sizeof(tmp), "%s/%d/fd/%s",
 					root, pid, d1->d_name);
@@ -549,7 +550,7 @@ enum entry_types {
 };
 
 #define ENTRY_BUF_SIZE 512
-static int find_entry(unsigned int ino, char **buf, int type)
+static int find_entry(__u64 ino, char **buf, int type)
 {
 	struct user_ent *p;
 	int cnt = 0;
@@ -728,10 +729,10 @@ struct sockstat {
 	int		    rport;
 	int		    state;
 	int		    rq, wq;
-	unsigned int ino;
-	unsigned int uid;
+	unsigned int	    uid;
 	int		    refcnt;
 	unsigned int	    iface;
+	__u64		    ino;
 	unsigned long long  sk;
 	char *name;
 	char *peer_name;
@@ -801,7 +802,7 @@ static void sock_details_print(struct sockstat *s)
 	if (s->uid)
 		printf(" uid:%u", s->uid);
 
-	printf(" ino:%u", s->ino);
+	printf(" ino:%llu", s->ino);
 	printf(" sk:%llx", s->sk);
 }
 
@@ -1799,7 +1800,7 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 		return 0;
 
 	opt[0] = 0;
-	n = sscanf(data, "%x %x:%x %x:%x %x %d %d %u %d %llx %d %d %d %d %d %[^\n]\n",
+	n = sscanf(data, "%x %x:%x %x:%x %x %d %d %llu %d %llx %d %d %d %d %d %[^\n]\n",
 		   &s.ss.state, &s.ss.wq, &s.ss.rq,
 		   &s.timer, &s.timeout, &s.retrans, &s.ss.uid, &s.probes,
 		   &s.ss.ino, &s.ss.refcnt, &s.ss.sk, &rto, &ato, &s.qack, &s.cwnd,
@@ -2481,7 +2482,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 		return 0;
 
 	opt[0] = 0;
-	n = sscanf(data, "%x %x:%x %*x:%*x %*x %d %*d %u %d %llx %[^\n]\n",
+	n = sscanf(data, "%x %x:%x %*x:%*x %*x %d %*d %llu %d %llx %[^\n]\n",
 	       &s.state, &s.wq, &s.rq,
 	       &s.uid, &s.ino,
 	       &s.refcnt, &s.sk, opt);
@@ -2829,7 +2830,7 @@ static int unix_show(struct filter *f)
 		u->name = NULL;
 		u->peer_name = NULL;
 
-		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
+		if (sscanf(buf, "%x: %x %x %x %x %x %llu %s",
 			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
 			   &u->state, &u->ino, name) < 8)
 			name[0] = 0;
@@ -3085,9 +3086,10 @@ static int packet_show_line(char *buf, const struct filter *f, int fam)
 {
 	unsigned long long sk;
 	struct sockstat stat = {};
-	int type, prot, iface, state, rq, uid, ino;
+	int type, prot, iface, state, rq, uid;
+	__u64 ino;
 
-	sscanf(buf, "%llx %*d %d %x %d %d %u %u %u",
+	sscanf(buf, "%llx %*d %d %x %d %d %u %u %llu",
 			&sk,
 			&type, &prot, &iface, &state,
 			&rq, &uid, &ino);
