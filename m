From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH] iproute2:  act_ipt fix xtables breakage
Date: Sun, 16 Dec 2012 15:41:39 -0500
Message-ID: <50CE3203.9080007@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040401050102000601060308"
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:56358 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab2LPUlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 15:41:42 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so4868392iay.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 12:41:41 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040401050102000601060308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Attached.

I am going to send a kernel patch as well.
There is an "intermediate solution" from Hasan which doesnt require
the kernel change. It changes the kernel endpoint to "ipt". I am
conflicted because it is a quick hack while otoh forcing people to
upgrade kernel is a usability issue.

cheers,
jamal

--------------040401050102000601060308
Content-Type: text/plain; charset=UTF-8;
 name="patch-xt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-xt"

commit ff707eaa1fd51435958ae2afcd09d4b3600160b4
Author: Hasan Chowdhury <shemonc@gmail.com>
Date:   Sun Dec 16 14:09:38 2012 -0500

    Fixes breakage with xtables API starting with version 1.4.10
    
    Signed-off-by: Hasan Chowdhury <shemonc@gmail.com>
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/m_xt.c b/tc/m_xt.c
index bcc4d75..e1c3f38 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -118,6 +118,7 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 	struct xtables_target *m = NULL;
 	struct ipt_entry fw;
 	struct rtattr *tail;
+
 	int c;
 	int rargc = *argc_p;
 	char **argv = *argv_p;
@@ -126,6 +127,7 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 	int size = 0;
 	int iok = 0, ok = 0;
 	__u32 hook = 0, index = 0;
+	struct option *opts = NULL;
 
 	xtables_init_all(&tcipt_globals, NFPROTO_IPV4);
 	set_lib_dir();
@@ -158,14 +160,22 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 					printf(" %s error \n", m->name);
 					return -1;
 				}
-				tcipt_globals.opts =
-				    xtables_merge_options(
 #if (XTABLES_VERSION_CODE >= 6)
-				        tcipt_globals.orig_opts,
+			opts = xtables_options_xfrm(tcipt_globals.orig_opts,
+						    tcipt_globals.opts, 
+						    m->x6_options,
+						    &m->option_offset);
+#else                                   
+			opts = xtables_merge_options(tcipt_globals.orig_opts,
+						     tcipt_globals.opts,
+						     m->extra_opts,
+						     &m->option_offset); 
 #endif
-				        tcipt_globals.opts,
-				        m->extra_opts,
-				        &m->option_offset);
+			if (opts == NULL) {
+				fprintf(stderr, " failed to find aditional options for target %s\n\n", optarg);
+				return -1;
+			} else
+				tcipt_globals.opts = opts;
 			} else {
 				fprintf(stderr," failed to find target %s\n\n", optarg);
 				return -1;
@@ -175,17 +185,21 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 
 		default:
 			memset(&fw, 0, sizeof (fw));
-			if (m) {
-				m->parse(c - m->option_offset, argv, 0,
-					 &m->tflags, NULL, &m->t);
+#if (XTABLES_VERSION_CODE >= 6)
+		if (m != NULL && m->x6_parse != NULL ) {
+			xtables_option_tpcall(c, argv, 0 , m, NULL);
+#else
+		if (m != NULL && m->parse != NULL ) {
+			m->parse(c - m->option_offset, argv, 0, &m->tflags,
+				 NULL, &m->t);
+#endif
 			} else {
-				fprintf(stderr," failed to find target %s\n\n", optarg);
+				fprintf(stderr,"failed to find target %s\n\n", optarg);
 				return -1;
 
 			}
 			ok++;
 			break;
-
 		}
 	}
 
@@ -208,8 +222,13 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 	}
 
 	/* check that we passed the correct parameters to the target */
+#if (XTABLES_VERSION_CODE >= 6)
+	if (m)
+		xtables_option_tfcall(m);
+#else
 	if (m && m->final_check)
 		m->final_check(m->tflags);
+#endif
 
 	{
 		struct tcmsg *t = NLMSG_DATA(n);
@@ -271,6 +290,7 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 {
 	struct rtattr *tb[TCA_IPT_MAX + 1];
 	struct xt_entry_target *t = NULL;
+	struct option *opts = NULL;
 
 	if (arg == NULL)
 		return -1;
@@ -309,14 +329,22 @@ print_ipt(struct action_util *au,FILE * f, struct rtattr *arg)
 				return -1;
 			}
 
-			tcipt_globals.opts =
-			    xtables_merge_options(
 #if (XTABLES_VERSION_CODE >= 6)
-				                  tcipt_globals.orig_opts,
+		opts = xtables_options_xfrm(tcipt_globals.orig_opts,
+					    tcipt_globals.opts,
+					    m->x6_options,
+					    &m->option_offset);
+#else                                   
+		opts = xtables_merge_options(tcipt_globals.orig_opts,
+					     tcipt_globals.opts,
+					     m->extra_opts,
+					     &m->option_offset); 
 #endif
-				                  tcipt_globals.opts,
-			                          m->extra_opts,
-			                          &m->option_offset);
+	if (opts == NULL) {
+		fprintf(stderr, " failed to find aditional options for target %s\n\n", optarg);
+		return -1;
+	} else
+		tcipt_globals.opts = opts;
 		} else {
 			fprintf(stderr, " failed to find target %s\n\n",
 				t->u.user.name);
@@ -355,4 +383,3 @@ struct action_util xt_action_util = {
         .parse_aopt = parse_ipt,
         .print_aopt = print_ipt,
 };
-

--------------040401050102000601060308--
