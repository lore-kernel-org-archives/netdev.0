From: Richard Haines <richard_c_haines@btinternet.com>
Subject: [PATCH V3] ss: Add support for retrieving SELinux contexts
Date: Fri,  7 Mar 2014 10:36:52 +0000
Message-ID: <1394188612-3662-1-git-send-email-richard_c_haines@btinternet.com>
Cc: Richard Haines <richard_c_haines@btinternet.com>
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout12.bt.lon5.cpcloud.co.uk ([65.20.0.132]:7757 "EHLO
	smtpout12.bt.lon5.cpcloud.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbaCGKhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:37:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The process SELinux contexts can be added to the output using the -Z
option. Using the -z option will show the process and socket contexts (see
the man page for details).
For netlink sockets: if valid process show process context, if pid = 0
show kernel initial context, if unknown show "unavailable".

Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
---
 configure     |  15 +++
 man/man8/ss.8 |  34 ++++++
 misc/Makefile |   5 +
 misc/ss.c     | 347 ++++++++++++++++++++++++++++++++++++++++++++++++----------
 4 files changed, 346 insertions(+), 55 deletions(-)

diff --git a/configure b/configure
index da01c19..d5170f0 100755
--- a/configure
+++ b/configure
@@ -231,6 +231,18 @@ EOF
     rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
 }
 
+check_selinux()
+# SELinux is a compile time option in the ss utility
+{
+	if ${PKG_CONFIG} libselinux --exists
+	then
+		echo "HAVE_SELINUX:=y" >>Config
+		echo "yes"
+	else
+		echo "no"
+	fi
+}
+
 echo "# Generated config based on" $INCLUDE >Config
 check_toolchain
 
@@ -253,3 +265,6 @@ check_ipt_lib_dir
 
 echo -n "libc has setns: "
 check_setns
+
+echo -n "SELinux support: "
+check_selinux
diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 807d9dc..2a4bbc5 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -53,6 +53,37 @@ Print summary statistics. This option does not parse socket lists obtaining
 summary from various sources. It is useful when amount of sockets is so huge
 that parsing /proc/net/tcp is painful.
 .TP
+.B \-Z, \-\-context
+As the
+.B \-p
+option but also shows process security context.
+.sp
+For
+.BR netlink (7)
+sockets the initiating process context is displayed as follows:
+.RS
+.RS
+.IP "1." 4
+If valid pid show the process context.
+.IP "2." 4
+If destination is kernel (pid = 0) show kernel initial context.
+.IP "3." 4
+If a unique identifier has been allocated by the kernel or netlink user,
+show context as "unavailable". This will generally indicate that a
+process has more than one netlink socket active.
+.RE
+.RE
+.TP
+.B \-z, \-\-contexts
+As the
+.B \-Z
+option but also shows the socket context. The socket context is
+taken from the associated inode and is not the actual socket
+context held by the kernel. Sockets are typically labeled with the
+context of the creating process, however the context shown will reflect
+any policy role, type and/or range transition rules applied,
+and is therefore a useful reference.
+.TP
 .B \-b, \-\-bpf
 Show socket BPF filters (only administrators are allowed to get these information).
 .TP
@@ -103,6 +134,9 @@ Please take a look at the official documentation (Debian package iproute-doc) fo
 .B ss -t -a
 Display all TCP sockets.
 .TP
+.B ss -t -a -Z
+Display all TCP sockets with process SELinux security contexts.
+.TP
 .B ss -u -a
 Display all UDP sockets.
 .TP
diff --git a/misc/Makefile b/misc/Makefile
index a59ff87..004bcc3 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -5,6 +5,11 @@ TARGETS=ss nstat ifstat rtacct arpd lnstat
 
 include ../Config
 
+ifeq ($(HAVE_SELINUX),y)
+	LDLIBS += $(shell pkg-config --libs libselinux)
+	CFLAGS += $(shell pkg-config --cflags libselinux) -DHAVE_SELINUX
+endif
+
 all: $(TARGETS)
 
 ss: $(SSOBJ)
diff --git a/misc/ss.c b/misc/ss.c
index ce6a0a8..187c852 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -41,6 +41,34 @@
 #include <linux/packet_diag.h>
 #include <linux/netlink_diag.h>
 
+#if HAVE_SELINUX
+#include <selinux/selinux.h>
+#else
+/* Stubs for SELinux functions */
+static int is_selinux_enabled(void)
+{
+	return -1;
+}
+
+static int getpidcon(pid_t pid, char **context)
+{
+	*context = NULL;
+	return -1;
+}
+
+static int getfilecon(char *path, char **context)
+{
+	*context = NULL;
+	return -1;
+}
+
+static int security_get_initial_context(char *name,  char **context)
+{
+	*context = NULL;
+	return -1;
+}
+#endif
+
 int resolve_hosts = 0;
 int resolve_services = 1;
 int preferred_family = AF_UNSPEC;
@@ -50,6 +78,10 @@ int show_users = 0;
 int show_mem = 0;
 int show_tcpinfo = 0;
 int show_bpf = 0;
+int show_proc_ctx = 0;
+int show_sock_ctx = 0;
+/* If show_users & show_proc_ctx only do user_ent_hash_build() once */
+int user_ent_hash_build_init = 0;
 
 int netid_width;
 int state_width;
@@ -207,7 +239,9 @@ struct user_ent {
 	unsigned int	ino;
 	int		pid;
 	int		fd;
-	char		process[0];
+	char		*process;
+	char		*process_ctx;
+	char		*socket_ctx;
 };
 
 #define USER_ENT_HASH_SIZE	256
@@ -220,26 +254,50 @@ static int user_ent_hashfn(unsigned int ino)
 	return val & (USER_ENT_HASH_SIZE - 1);
 }
 
-static void user_ent_add(unsigned int ino, const char *process, int pid, int fd)
+static void user_ent_add(unsigned int ino, char *process,
+					int pid, int fd,
+					char *proc_ctx,
+					char *sock_ctx)
 {
 	struct user_ent *p, **pp;
-	int str_len;
 
-	str_len = strlen(process) + 1;
-	p = malloc(sizeof(struct user_ent) + str_len);
-	if (!p)
+	p = malloc(sizeof(struct user_ent));
+	if (!p) {
+		fprintf(stderr, "ss: failed to malloc buffer\n");
 		abort();
+	}
 	p->next = NULL;
 	p->ino = ino;
 	p->pid = pid;
 	p->fd = fd;
-	strcpy(p->process, process);
+	p->process = strdup(process);
+	p->process_ctx = strdup(proc_ctx);
+	p->socket_ctx = strdup(sock_ctx);
 
 	pp = &user_ent_hash[user_ent_hashfn(ino)];
 	p->next = *pp;
 	*pp = p;
 }
 
+static void user_ent_destroy(void)
+{
+	struct user_ent *p, *p_next;
+	int cnt = 0;
+
+	while (cnt != USER_ENT_HASH_SIZE) {
+		p = user_ent_hash[cnt];
+		while (p) {
+			free(p->process);
+			free(p->process_ctx);
+			free(p->socket_ctx);
+			p_next = p->next;
+			free(p);
+			p = p_next;
+		}
+		cnt++;
+	}
+}
+
 static void user_ent_hash_build(void)
 {
 	const char *root = getenv("PROC_ROOT") ? : "/proc/";
@@ -247,6 +305,15 @@ static void user_ent_hash_build(void)
 	char name[1024];
 	int nameoff;
 	DIR *dir;
+	char *pid_context;
+	char *sock_context;
+	const char *no_ctx = "unavailable";
+
+	/* If show_users & show_proc_ctx set only do this once */
+	if (user_ent_hash_build_init != 0)
+		return;
+
+	user_ent_hash_build_init = 1;
 
 	strcpy(name, root);
 	if (strlen(name) == 0 || name[strlen(name)-1] != '/')
@@ -261,6 +328,7 @@ static void user_ent_hash_build(void)
 	while ((d = readdir(dir)) != NULL) {
 		struct dirent *d1;
 		char process[16];
+		char *p;
 		int pid, pos;
 		DIR *dir1;
 		char crap;
@@ -268,12 +336,16 @@ static void user_ent_hash_build(void)
 		if (sscanf(d->d_name, "%d%c", &pid, &crap) != 1)
 			continue;
 
+		if (getpidcon(pid, &pid_context) != 0)
+			pid_context = strdup(no_ctx);
+
 		sprintf(name + nameoff, "%d/fd/", pid);
 		pos = strlen(name);
 		if ((dir1 = opendir(name)) == NULL)
 			continue;
 
 		process[0] = '\0';
+		p = process;
 
 		while ((d1 = readdir(dir1)) != NULL) {
 			const char *pattern = "socket:[";
@@ -281,6 +353,7 @@ static void user_ent_hash_build(void)
 			char lnk[64];
 			int fd;
 			ssize_t link_len;
+			char tmp[1024];
 
 			if (sscanf(d1->d_name, "%d%c", &fd, &crap) != 1)
 				continue;
@@ -297,55 +370,107 @@ static void user_ent_hash_build(void)
 
 			sscanf(lnk, "socket:[%u]", &ino);
 
-			if (process[0] == '\0') {
-				char tmp[1024];
+			snprintf(tmp, sizeof(tmp), "%s/%d/fd/%s",
+					root, pid, d1->d_name);
+
+			if (getfilecon(tmp, &sock_context) <= 0)
+				sock_context = strdup(no_ctx);
+
+			if (*p == '\0') {
 				FILE *fp;
 
-				snprintf(tmp, sizeof(tmp), "%s/%d/stat", root, pid);
+				snprintf(tmp, sizeof(tmp), "%s/%d/stat",
+					root, pid);
 				if ((fp = fopen(tmp, "r")) != NULL) {
-					fscanf(fp, "%*d (%[^)])", process);
+					fscanf(fp, "%*d (%[^)])", p);
 					fclose(fp);
 				}
 			}
-
-			user_ent_add(ino, process, pid, fd);
+			user_ent_add(ino, p, pid, fd,
+					pid_context, sock_context);
+			free(sock_context);
 		}
+		free(pid_context);
 		closedir(dir1);
 	}
 	closedir(dir);
 }
 
-static int find_users(unsigned ino, char *buf, int buflen)
+enum entry_types {
+	USERS,
+	PROC_CTX,
+	PROC_SOCK_CTX
+};
+
+#define ENTRY_BUF_SIZE 512
+static int find_entry(unsigned ino, char **buf, int type)
 {
 	struct user_ent *p;
 	int cnt = 0;
 	char *ptr;
+	char **new_buf = buf;
+	int len, new_buf_len;
+	int buf_used = 0;
+	int buf_len = 0;
 
 	if (!ino)
 		return 0;
 
 	p = user_ent_hash[user_ent_hashfn(ino)];
-	ptr = buf;
+	ptr = *buf = NULL;
 	while (p) {
 		if (p->ino != ino)
 			goto next;
 
-		if (ptr - buf >= buflen - 1)
-			break;
+		while (1) {
+			ptr = *buf + buf_used;
+			switch (type) {
+			case USERS:
+				len = snprintf(ptr, buf_len - buf_used,
+					"(\"%s\",pid=%d,fd=%d),",
+					p->process, p->pid, p->fd);
+				break;
+			case PROC_CTX:
+				len = snprintf(ptr, buf_len - buf_used,
+					"(\"%s\",pid=%d,proc_ctx=%s,fd=%d),",
+					p->process, p->pid,
+					p->process_ctx, p->fd);
+				break;
+			case PROC_SOCK_CTX:
+				len = snprintf(ptr, buf_len - buf_used,
+					"(\"%s\",pid=%d,proc_ctx=%s,fd=%d,sock_ctx=%s),",
+					p->process, p->pid,
+					p->process_ctx, p->fd,
+					p->socket_ctx);
+				break;
+			default:
+				fprintf(stderr, "ss: invalid type: %d\n", type);
+				abort();
+			}
 
-		snprintf(ptr, buflen - (ptr - buf),
-			 "(\"%s\",%d,%d),",
-			 p->process, p->pid, p->fd);
-		ptr += strlen(ptr);
+			if (len < 0 || len >= buf_len - buf_used) {
+				new_buf_len = buf_len + ENTRY_BUF_SIZE;
+				*new_buf = realloc(*buf, new_buf_len);
+				if (!new_buf) {
+					fprintf(stderr, "ss: failed to malloc buffer\n");
+					abort();
+				}
+				**buf = **new_buf;
+				buf_len = new_buf_len;
+				continue;
+			} else {
+				buf_used += len;
+				break;
+			}
+		}
 		cnt++;
-
-	next:
+next:
 		p = p->next;
 	}
-
-	if (ptr != buf)
+	if (buf_used) {
+		ptr = *buf + buf_used;
 		ptr[-1] = '\0';
-
+	}
 	return cnt;
 }
 
@@ -1289,11 +1414,21 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 		if (s.qack&1)
 			printf(" bidir");
 	}
-	if (show_users) {
-		char ubuf[4096];
-		if (find_users(s.ino, ubuf, sizeof(ubuf)) > 0)
-			printf(" users:(%s)", ubuf);
+	char *buf = NULL;
+	if (show_proc_ctx || show_sock_ctx) {
+		if (find_entry(s.ino, &buf,
+				(show_proc_ctx & show_sock_ctx) ?
+				PROC_SOCK_CTX : PROC_CTX) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	} else if (show_users) {
+		if (find_entry(s.ino, &buf, USERS) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
 	}
+
 	if (show_details) {
 		if (s.uid)
 			printf(" uid:%u", (unsigned)s.uid);
@@ -1527,11 +1662,22 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 			       r->idiag_retrans);
 		}
 	}
-	if (show_users) {
-		char ubuf[4096];
-		if (find_users(r->idiag_inode, ubuf, sizeof(ubuf)) > 0)
-			printf(" users:(%s)", ubuf);
+	char *buf = NULL;
+
+	if (show_proc_ctx || show_sock_ctx) {
+		if (find_entry(r->idiag_inode, &buf,
+				(show_proc_ctx & show_sock_ctx) ?
+				PROC_SOCK_CTX : PROC_CTX) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	} else if (show_users) {
+		if (find_entry(r->idiag_inode, &buf, USERS) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
 	}
+
 	if (show_details) {
 		if (r->idiag_uid)
 			printf(" uid:%u", (unsigned)r->idiag_uid);
@@ -2016,10 +2162,20 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
 	formatted_print(&s.local, s.lport, 0);
 	formatted_print(&s.remote, s.rport, 0);
 
-	if (show_users) {
-		char ubuf[4096];
-		if (find_users(s.ino, ubuf, sizeof(ubuf)) > 0)
-			printf(" users:(%s)", ubuf);
+	char *buf = NULL;
+
+	if (show_proc_ctx || show_sock_ctx) {
+		if (find_entry(s.ino, &buf,
+				(show_proc_ctx & show_sock_ctx) ?
+				PROC_SOCK_CTX : PROC_CTX) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	} else if (show_users) {
+		if (find_entry(s.ino, &buf, USERS) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
 	}
 
 	if (show_details) {
@@ -2206,10 +2362,20 @@ static void unix_list_print(struct unixstat *list, struct filter *f)
 		printf("%*s %-*d %*s %-*d",
 		       addr_width, s->name ? : "*", serv_width, s->ino,
 		       addr_width, peer, serv_width, s->peer);
-		if (show_users) {
-			char ubuf[4096];
-			if (find_users(s->ino, ubuf, sizeof(ubuf)) > 0)
-				printf(" users:(%s)", ubuf);
+		char *buf = NULL;
+
+		if (show_proc_ctx || show_sock_ctx) {
+			if (find_entry(s->ino, &buf,
+					(show_proc_ctx & show_sock_ctx) ?
+					PROC_SOCK_CTX : PROC_CTX) > 0) {
+				printf(" users:(%s)", buf);
+				free(buf);
+			}
+		} else if (show_users) {
+			if (find_entry(s->ino, &buf, USERS) > 0) {
+				printf(" users:(%s)", buf);
+				free(buf);
+			}
 		}
 		printf("\n");
 	}
@@ -2271,10 +2437,20 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 			addr_width, "*", /* FIXME */
 			serv_width, peer_ino);
 
-	if (show_users) {
-		char ubuf[4096];
-		if (find_users(r->udiag_ino, ubuf, sizeof(ubuf)) > 0)
-			printf(" users:(%s)", ubuf);
+	char *buf = NULL;
+
+	if (show_proc_ctx || show_sock_ctx) {
+		if (find_entry(r->udiag_ino, &buf,
+				(show_proc_ctx & show_sock_ctx) ?
+				PROC_SOCK_CTX : PROC_CTX) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	} else if (show_users) {
+		if (find_entry(r->udiag_ino, &buf, USERS) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
 	}
 
 	if (show_mem) {
@@ -2532,11 +2708,22 @@ static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	printf("%*s*%-*s",
 	       addr_width, "", serv_width, "");
 
-	if (show_users) {
-		char ubuf[4096];
-		if (find_users(r->pdiag_ino, ubuf, sizeof(ubuf)) > 0)
-			printf(" users:(%s)", ubuf);
+	char *buf = NULL;
+
+	if (show_proc_ctx || show_sock_ctx) {
+		if (find_entry(r->pdiag_ino, &buf,
+				(show_proc_ctx & show_sock_ctx) ?
+				PROC_SOCK_CTX : PROC_CTX) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
+	} else if (show_users) {
+		if (find_entry(r->pdiag_ino, &buf, USERS) > 0) {
+			printf(" users:(%s)", buf);
+			free(buf);
+		}
 	}
+
 	if (show_details) {
 		__u32 uid = 0;
 
@@ -2727,11 +2914,22 @@ static int packet_show(struct filter *f)
 		printf("%*s*%-*s",
 		       addr_width, "", serv_width, "");
 
-		if (show_users) {
-			char ubuf[4096];
-			if (find_users(ino, ubuf, sizeof(ubuf)) > 0)
-				printf(" users:(%s)", ubuf);
+		char *buf = NULL;
+
+		if (show_proc_ctx || show_sock_ctx) {
+			if (find_entry(ino, &buf,
+					(show_proc_ctx & show_sock_ctx) ?
+					PROC_SOCK_CTX : PROC_CTX) > 0) {
+				printf(" users:(%s)", buf);
+				free(buf);
+			}
+		} else if (show_users) {
+			if (find_entry(ino, &buf, USERS) > 0) {
+				printf(" users:(%s)", buf);
+				free(buf);
+			}
 		}
+
 		if (show_details) {
 			printf(" ino=%u uid=%u sk=%llx", ino, uid, sk);
 		}
@@ -2807,6 +3005,27 @@ static void netlink_show_one(struct filter *f,
 		       addr_width, "", serv_width, "");
 	}
 
+	char *pid_context = NULL;
+	if (show_proc_ctx) {
+		/* The pid value will either be:
+		 *   0 if destination kernel - show kernel initial context.
+		 *   A valid process pid - use getpidcon.
+		 *   A unique value allocated by the kernel or netlink user
+		 *   to the process - show context as "not available".
+		 */
+		if (!pid)
+			security_get_initial_context("kernel", &pid_context);
+		else if (pid > 0)
+			getpidcon(pid, &pid_context);
+
+		if (pid_context != NULL) {
+			printf("proc_ctx=%-*s ", serv_width, pid_context);
+			free(pid_context);
+		} else {
+			printf("proc_ctx=%-*s ", serv_width, "unavailable");
+		}
+	}
+
 	if (show_details) {
 		printf(" sk=%llx cb=%llx groups=0x%08x", sk, cb, groups);
 	}
@@ -3081,6 +3300,8 @@ static void _usage(FILE *dest)
 "   -i, --info		show internal TCP information\n"
 "   -s, --summary	show socket usage summary\n"
 "   -b, --bpf           show bpf filter socket information\n"
+"   -Z, --context	display process SELinux security contexts\n"
+"   -z, --contexts	display process and socket SELinux security contexts\n"
 "\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
@@ -3170,6 +3391,8 @@ static const struct option long_opts[] = {
 	{ "filter", 1, 0, 'F' },
 	{ "version", 0, 0, 'V' },
 	{ "help", 0, 0, 'h' },
+	{ "context", 0, 0, 'Z' },
+	{ "contexts", 0, 0, 'z' },
 	{ 0 }
 
 };
@@ -3188,7 +3411,7 @@ int main(int argc, char *argv[])
 
 	current_filter.states = default_filter.states;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vV",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZ",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3348,6 +3571,16 @@ int main(int argc, char *argv[])
 		case 'V':
 			printf("ss utility, iproute2-ss%s\n", SNAPSHOT);
 			exit(0);
+		case 'z':
+			show_sock_ctx++;
+		case 'Z':
+			if (is_selinux_enabled() <= 0) {
+				fprintf(stderr, "ss: SELinux is not enabled.\n");
+				exit(1);
+			}
+			show_proc_ctx++;
+			user_ent_hash_build();
+			break;
 		case 'h':
 		case '?':
 			help();
@@ -3535,5 +3768,9 @@ int main(int argc, char *argv[])
 		tcp_show(&current_filter, IPPROTO_TCP);
 	if (current_filter.dbs & (1<<DCCP_DB))
 		tcp_show(&current_filter, IPPROTO_DCCP);
+
+	if (show_users || show_proc_ctx || show_sock_ctx)
+		user_ent_destroy();
+
 	return 0;
 }
-- 
1.8.5.3
