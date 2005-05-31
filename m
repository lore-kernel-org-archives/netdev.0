From: Pablo Neira <pablo@eurodev.net>
Subject: [TC PATCH] some fixes for ipt action
Date: Tue, 31 May 2005 02:28:29 +0200
Message-ID: <429BAFAD.3080804@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060808090602060001060301"
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060808090602060001060301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Stephen,

I've sent this patch to jamal some weeks ago. He's acked it, you can 
confirm that from him. This patch:

- fixes a leak on error paths (a similar path was commited to iptables 
two days ago[1]).
- simplify option handling.
- fixes final_check checking, it was broken.

[1] 
https://lists.netfilter.org/pipermail/netfilter-devel/2005-May/019844.html

Pablo


--------------060808090602060001060301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== tc/m_ipt.c 1.5 vs edited =====
--- 1.5/tc/m_ipt.c	2005-03-24 12:53:31 +01:00
+++ edited/tc/m_ipt.c	2005-03-31 02:05:42 +02:00
@@ -69,6 +69,7 @@
 };
 
 static struct iptables_target *t_list = NULL;
+static struct option *opts = original_opts;
 static unsigned int global_option_offset = 0;
 #define OPTION_OFFSET 256
 
@@ -169,18 +170,13 @@
 	return result;
 }
 
-static struct option *
-copy_options(struct option *oldopts)
+static void free_opts(struct option *opts)
 {
-	struct option *merge;
-	unsigned int num_old;
-	for (num_old = 0; oldopts[num_old].name; num_old++) ;
-	merge = malloc(sizeof (struct option) * (num_old + 1));
-	if (NULL == merge)
-		return NULL;
-	memcpy(merge, oldopts, num_old * sizeof (struct option));
-	memset(merge + num_old, 0, sizeof (struct option));
-	return merge;
+	if (opts != original_opts) {
+		free(opts);
+		opts = original_opts;
+		global_option_offset = 0;
+	}
 }
 
 static struct option *
@@ -385,7 +381,6 @@
 	int c;
 	int rargc = *argc_p;
 	char **argv = *argv_p;
-	struct option *opts;
 	int argc = 0, iargc = 0;
 	char k[16];
 	int res = -1;
@@ -409,11 +404,6 @@
 		return -1;
 	}
 
-	opts = copy_options(original_opts);
-
-	if (NULL == opts)
-		return -1;
-
 	while (1) {
 		c = getopt_long(argc, argv, "j:", opts, NULL);
 		if (c == -1)
@@ -440,23 +430,14 @@
 		default:
 			memset(&fw, 0, sizeof (fw));
 			if (m) {
-				unsigned int fake_flags = 0;
 				m->parse(c - m->option_offset, argv, 0,
-					 &fake_flags, NULL, &m->t);
+					 &m->tflags, NULL, &m->t);
 			} else {
 				fprintf(stderr," failed to find target %s\n\n", optarg);
 				return -1;
 
 			}
 			ok++;
-
-			/*m->final_check(m->t); -- Is this necessary?
-			** useful when theres depencies
-			** eg ipt_TCPMSS.c has have the TCP match loaded
-			** before this can be used;
-			**  also seems the ECN target needs it 
-			*/
-
 			break;
 
 		}
@@ -466,6 +447,7 @@
 		if (matches(argv[optind], "index") == 0) {
 			if (get_u32(&index, argv[optind + 1], 10)) {
 				fprintf(stderr, "Illegal \"index\"\n");
+				free_opts(opts);
 				return -1;
 			}
 			iok++;
@@ -479,6 +461,10 @@
 		return -1;
 	}
 
+	/* check that we passed the correct parameters to the target */
+	if (m)
+		m->final_check(m->tflags);
+
 	{
 		struct tcmsg *t = NLMSG_DATA(n);
 		if (t->tcm_parent != TC_H_ROOT
@@ -519,6 +505,7 @@
 	*argv_p = argv;
 	
 	optind = 1;
+	free_opts(opts);
 
 	return 0;
 
@@ -529,16 +516,10 @@
 {
 	struct rtattr *tb[TCA_IPT_MAX + 1];
 	struct ipt_entry_target *t = NULL;
-	struct option *opts;
 
 	if (arg == NULL)
 		return -1;
 
-	opts = copy_options(original_opts);
-
-	if (NULL == opts)
-		return -1;
-
 	parse_rtattr_nested(tb, TCA_IPT_MAX, arg);
 
 	if (tb[TCA_IPT_TABLE] == NULL) {
@@ -601,6 +582,7 @@
 		fprintf(f, " \n");
 
 	}
+	free_opts(opts);
 
 	return 0;
 }


--------------060808090602060001060301--
