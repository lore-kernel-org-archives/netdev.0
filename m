From: Leon Romanovsky <leonro@mellanox.com>
Subject: [PATCH REPOST v5 iproute2 5/8] rdma: Add json and pretty outputs
Date: Thu, 17 Aug 2017 09:56:11 +0300
Message-ID: <20170817065614.1393-6-leonro@mellanox.com>
References: <20170817065614.1393-1-leonro@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57326 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752038AbdHQG4e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 02:56:34 -0400
In-Reply-To: <20170817065614.1393-1-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/rdma.c | 31 ++++++++++++++++++++++++++++---
 rdma/rdma.h |  4 ++++
 2 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/rdma/rdma.c b/rdma/rdma.c
index 74c09e8b..f9f4f2a2 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -16,7 +16,7 @@ static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
 	       "where  OBJECT := { dev | link | help }\n"
-	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
+	       "       OPTIONS := { -V[ersion] | -d[etails] | -j[son] | -p[retty]}\n", name);
 }

 static int cmd_help(struct rd *rd)
@@ -47,6 +47,16 @@ static int rd_init(struct rd *rd, int argc, char **argv, char *filename)
 	rd->argc = argc;
 	rd->argv = argv;
 	INIT_LIST_HEAD(&rd->dev_map_list);
+
+	if (rd->json_output) {
+		rd->jw = jsonw_new(stdout);
+		if (!rd->jw) {
+			pr_err("Failed to create JSON writer\n");
+			return -ENOMEM;
+		}
+		jsonw_pretty(rd->jw, rd->pretty_output);
+	}
+
 	rd->buff = malloc(MNL_SOCKET_BUFFER_SIZE);
 	if (!rd->buff)
 		return -ENOMEM;
@@ -62,6 +72,8 @@ static int rd_init(struct rd *rd, int argc, char **argv, char *filename)

 static void rd_free(struct rd *rd)
 {
+	if (rd->json_output)
+		jsonw_destroy(&rd->jw);
 	free(rd->buff);
 	rd_free_devmap(rd);
 }
@@ -71,10 +83,14 @@ int main(int argc, char **argv)
 	static const struct option long_options[] = {
 		{ "version",		no_argument,		NULL, 'V' },
 		{ "help",		no_argument,		NULL, 'h' },
+		{ "json",		no_argument,		NULL, 'j' },
+		{ "pretty",		no_argument,		NULL, 'p' },
 		{ "details",		no_argument,		NULL, 'd' },
 		{ NULL, 0, NULL, 0 }
 	};
+	bool pretty_output = false;
 	bool show_details = false;
+	bool json_output = false;
 	char *filename;
 	struct rd rd;
 	int opt;
@@ -82,16 +98,22 @@ int main(int argc, char **argv)

 	filename = basename(argv[0]);

-	while ((opt = getopt_long(argc, argv, "Vhd",
+	while ((opt = getopt_long(argc, argv, "Vhdpj",
 				  long_options, NULL)) >= 0) {
 		switch (opt) {
 		case 'V':
 			printf("%s utility, iproute2-ss%s\n",
 			       filename, SNAPSHOT);
 			return EXIT_SUCCESS;
+		case 'p':
+			pretty_output = true;
+			break;
 		case 'd':
 			show_details = true;
 			break;
+		case 'j':
+			json_output = true;
+			break;
 		case 'h':
 			help(filename);
 			return EXIT_SUCCESS;
@@ -105,11 +127,14 @@ int main(int argc, char **argv)
 	argc -= optind;
 	argv += optind;

+	rd.show_details = show_details;
+	rd.json_output = json_output;
+	rd.pretty_output = pretty_output;
+
 	err = rd_init(&rd, argc, argv, filename);
 	if (err)
 		goto out;

-	rd.show_details = show_details;
 	err = rd_cmd(&rd);
 out:
 	/* Always cleanup */
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 8037e2e6..5904f177 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -23,6 +23,7 @@

 #include "list.h"
 #include "utils.h"
+#include "json_writer.h"

 #define pr_err(args...) fprintf(stderr, ##args)
 #define pr_out(args...) fprintf(stdout, ##args)
@@ -48,6 +49,9 @@ struct rd {
 	struct mnl_socket *nl;
 	struct nlmsghdr *nlh;
 	char *buff;
+	json_writer_t *jw;
+	bool json_output;
+	bool pretty_output;
 };

 struct rd_cmd {
