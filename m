From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v3 05/10] ss: framed skeleton for json output in ss
Date: Thu, 20 Aug 2015 22:40:16 +0200
Message-ID: <1440103221-21854-6-git-send-email-matthias.tafelmeier@gmx.net>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:57500 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752053AbbHTUkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 16:40:32 -0400
In-Reply-To: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just adds the --json flag to ss. Also it ensures proper
stats components bracketization =E2=80=93 that goes for ex. TCP, UDP, N=
ETLINK etc.

Moreover, this patch prevents human readable headers to be printed. The
first element flag ensures, that every first output json container
element is treated specially, while all the others are treated equally.
That is, only the first one does not print a coma ahead of itself. The
rest does. This mechanism ensures the correct coma setting as demaned b=
y
the spec. Illustration in the following:

PSEUDOCODE:

{ >>>> no comma
	{first }
>>>>	,
	{sec}
>>>>	,
	{third}
	.
	.
	.
}

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss.c | 198 ++++++++++++++++++++++++++++++++++++++++++++++++------=
--------
 1 file changed, 155 insertions(+), 43 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index e7ea041..1bc2546 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -34,6 +34,9 @@
 #include "libnetlink.h"
 #include "namespace.h"
 #include "SNAPSHOT.h"
+#include "ss_out_fmt.h"
+#include "ss_json_fmt.h"
+#include "ss_types.h"
=20
 #include <linux/tcp.h>
 #include <linux/sock_diag.h>
@@ -101,6 +104,7 @@ int show_sock_ctx =3D 0;
 /* If show_users & show_proc_ctx only do user_ent_hash_build() once */
 int user_ent_hash_build_init =3D 0;
 int follow_events =3D 0;
+int json_output =3D 0;
=20
 int netid_width;
 int state_width;
@@ -716,7 +720,6 @@ static int is_ephemeral(int port)
 	return (port >=3D ip_local_port_min && port<=3D ip_local_port_max);
 }
=20
-
 static const char *__resolve_service(int port)
 {
 	struct scache *c;
@@ -3069,6 +3072,9 @@ static int print_summary(void)
=20
 	printf("\n");
=20
+	if (json_output && has_successor)
+		printf(",\n");
+
 	return 0;
 }
=20
@@ -3095,6 +3101,7 @@ static void _usage(FILE *dest)
 "   -z, --contexts      display process and socket SELinux security co=
ntexts\n"
 "   -N, --net           switch to the specified network namespace name=
\n"
 "\n"
+"   -j, --json          format output in JSON\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
 "   -0, --packet        display PACKET sockets\n"
@@ -3194,6 +3201,7 @@ static const struct option long_opts[] =3D {
 	{ "help", 0, 0, 'h' },
 	{ "context", 0, 0, 'Z' },
 	{ "contexts", 0, 0, 'z' },
+	{ "json", 0, 0, 'j' },
 	{ "net", 1, 0, 'N' },
 	{ 0 }
=20
@@ -3209,7 +3217,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter =3D 0;
=20
-	while ((ch =3D getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:=
vVzZN:",
+	while ((ch =3D getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:=
vVzZN:j",
 				 long_opts, NULL)) !=3D EOF) {
 		switch(ch) {
 		case 'n':
@@ -3390,6 +3398,10 @@ int main(int argc, char *argv[])
 			if (netns_switch(optarg))
 				exit(1);
 			break;
+		case 'j':
+			fmt_type =3D FMT_JSON;
+			json_output =3D 1;
+			break;
 		case 'h':
 		case '?':
 			help();
@@ -3471,11 +3483,33 @@ int main(int argc, char *argv[])
 				exit(-1);
 			}
 		}
+		printf("\"TCP\": [\n");
 		inet_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
+		res_json_fmt_branch(current_filter.dbs & (1<<NETLINK_DB) ||
+				current_filter.dbs & PACKET_DBM ||
+				current_filter.dbs & UNIX_DBM ||
+				current_filter.dbs & (1<<RAW_DB) ||
+				current_filter.dbs & (1<<UDP_DB) ||
+				current_filter.dbs & (1<<TCP_DB) ||
+				current_filter.dbs & (1<<DCCP_DB), ']');
 		fflush(dump_fp);
 		exit(0);
 	}
=20
+	if (do_summary) {
+		print_summary(current_filter.dbs & PACKET_DBM ||
+				current_filter.dbs & UNIX_DBM ||
+				current_filter.dbs & (1<<RAW_DB) ||
+				current_filter.dbs & (1<<UDP_DB) ||
+				current_filter.dbs & (1<<TCP_DB) ||
+				current_filter.dbs & (1<<DCCP_DB));
+		if (do_default && argc =3D=3D 0) {
+			if (json_output)
+				printf("}\n");
+			exit(0);
+		}
+	}
+
 	if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
 		usage();
=20
@@ -3497,62 +3531,140 @@ int main(int argc, char *argv[])
 		}
 	}
=20
-	addrp_width =3D screen_width;
-	addrp_width -=3D netid_width+1;
-	addrp_width -=3D state_width+1;
-	addrp_width -=3D 14;
+	if (!json_output) {
+
+		addrp_width =3D screen_width;
+		addrp_width -=3D netid_width + 1;
+		addrp_width -=3D state_width + 1;
+		addrp_width -=3D 14;
+
+		if (addrp_width & 1) {
+			if (netid_width)
+				netid_width++;
+			else if (state_width)
+				state_width++;
+		}
+
+		addrp_width /=3D 2;
+		addrp_width--;
+
+		serv_width =3D resolve_services ? 7 : 5;
+
+		if (addrp_width < 15 + serv_width + 1)
+			addrp_width =3D 15 + serv_width + 1;
=20
-	if (addrp_width&1) {
+		addr_width =3D addrp_width - serv_width - 1;
 		if (netid_width)
-			netid_width++;
-		else if (state_width)
-			state_width++;
-	}
+			printf("%-*s ", netid_width, "Netid");
+		if (state_width)
+			printf("%-*s ", state_width, "State");
+		printf("%-6s %-6s ", "Recv-Q", "Send-Q");
=20
-	addrp_width /=3D 2;
-	addrp_width--;
+		/* Make enough space for the local/remote port field */
+		addr_width -=3D 13;
+		serv_width +=3D 13;
=20
-	serv_width =3D resolve_services ? 7 : 5;
+		printf("%*s:%-*s %*s:%-*s\n",
+				addr_width, "Local Address", serv_width, "Port",
+				addr_width, "Peer Address", serv_width, "Port");
+	}
=20
-	if (addrp_width < 15+serv_width+1)
-		addrp_width =3D 15+serv_width+1;
+	fflush(stdout);
=20
-	addr_width =3D addrp_width - serv_width - 1;
+	if (current_filter.dbs & (1<<NETLINK_DB)) {
+		if (json_output) {
+			printf("\"NETLINK\": [\n");
+			netlink_show(&current_filter);
+			json_first_elem =3D 1;
+			res_json_fmt_branch(current_filter.dbs & PACKET_DBM ||
+					current_filter.dbs & UNIX_DBM ||
+					current_filter.dbs & (1<<RAW_DB) ||
+					current_filter.dbs & (1<<UDP_DB) ||
+					current_filter.dbs & (1<<TCP_DB) ||
+					current_filter.dbs & (1<<DCCP_DB), ']');
+		} else
+			netlink_show(&current_filter);
+	}
+	if (current_filter.dbs & PACKET_DBM) {
+		if (json_output) {
+			printf("\"PACKET\": [\n");
+			packet_show(&current_filter);
+			json_first_elem =3D 1;
+			res_json_fmt_branch(
+					current_filter.dbs & UNIX_DBM ||
+					current_filter.dbs & (1<<RAW_DB) ||
+					current_filter.dbs & (1<<UDP_DB) ||
+					current_filter.dbs & (1<<TCP_DB) ||
+					current_filter.dbs & (1<<DCCP_DB), ']');
+		} else
+			packet_show(&current_filter);
+	}
+	if (current_filter.dbs & UNIX_DBM) {
+		if (json_output) {
+			printf("\"UNIX\": [\n");
+			unix_show(&current_filter);
+			json_first_elem =3D 1;
+			res_json_fmt_branch(
+					current_filter.dbs & (1<<RAW_DB) ||
+					current_filter.dbs & (1<<UDP_DB) ||
+					current_filter.dbs & (1<<TCP_DB) ||
+					current_filter.dbs & (1<<DCCP_DB), ']');
=20
-	if (netid_width)
-		printf("%-*s ", netid_width, "Netid");
-	if (state_width)
-		printf("%-*s ", state_width, "State");
-	printf("%-6s %-6s ", "Recv-Q", "Send-Q");
+		} else
+			unix_show(&current_filter);
+	}
+	if (current_filter.dbs & (1<<RAW_DB)) {
+		if (json_output) {
+			printf("\"RAW\": [\n");
+			raw_show(&current_filter);
+			json_first_elem =3D 1;
+			res_json_fmt_branch(
+					current_filter.dbs & (1<<UDP_DB) ||
+					current_filter.dbs & (1<<TCP_DB) ||
+					current_filter.dbs & (1<<DCCP_DB), ']');
=20
-	/* Make enough space for the local/remote port field */
-	addr_width -=3D 13;
-	serv_width +=3D 13;
+		} else
+			raw_show(&current_filter);
+	}
+	if (current_filter.dbs & (1<<UDP_DB)) {
+		if (json_output) {
+			printf("\"UDP\": [\n");
+			udp_show(&current_filter);
+			json_first_elem =3D 1;
+			res_json_fmt_branch(
+					current_filter.dbs & (1<<TCP_DB) ||
+					current_filter.dbs & (1<<DCCP_DB), ']');
=20
-	printf("%*s:%-*s %*s:%-*s\n",
-	       addr_width, "Local Address", serv_width, "Port",
-	       addr_width, "Peer Address", serv_width, "Port");
+		} else
+			udp_show(&current_filter);
+	}
+	if (current_filter.dbs & (1<<TCP_DB)) {
+		if (json_output) {
+			printf("\"TCP\": [\n");
+			tcp_show(&current_filter, IPPROTO_TCP);
+			json_first_elem =3D 1;
+			res_json_fmt_branch(
+					current_filter.dbs & (1<<DCCP_DB), ']');
+		} else
+			tcp_show(&current_filter, IPPROTO_TCP);
+	}
+	if (current_filter.dbs & (1<<DCCP_DB)) {
+		if (json_output) {
+			printf("\"DCCP\": [\n");
+			tcp_show(&current_filter, IPPROTO_DCCP);
+			printf("]\n");
+		} else
+			tcp_show(&current_filter, IPPROTO_DCCP);
+	}
+
+	if (json_output)
+		printf("}\n");
=20
 	fflush(stdout);
=20
 	if (follow_events)
 		exit(handle_follow_request(&current_filter));
=20
-	if (current_filter.dbs & (1<<NETLINK_DB))
-		netlink_show(&current_filter);
-	if (current_filter.dbs & PACKET_DBM)
-		packet_show(&current_filter);
-	if (current_filter.dbs & UNIX_DBM)
-		unix_show(&current_filter);
-	if (current_filter.dbs & (1<<RAW_DB))
-		raw_show(&current_filter);
-	if (current_filter.dbs & (1<<UDP_DB))
-		udp_show(&current_filter);
-	if (current_filter.dbs & (1<<TCP_DB))
-		tcp_show(&current_filter, IPPROTO_TCP);
-	if (current_filter.dbs & (1<<DCCP_DB))
-		tcp_show(&current_filter, IPPROTO_DCCP);
-
 	if (show_users || show_proc_ctx || show_sock_ctx)
 		user_ent_destroy();
=20
--=20
1.9.1
