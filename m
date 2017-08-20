From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v6 iproute2 5/8] rdma: Add json and pretty outputs
Date: Sun, 20 Aug 2017 12:58:25 +0300
Message-ID: <20170820095828.13812-6-leon@kernel.org>
References: <20170820095828.13812-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170820095828.13812-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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
index 36b047d3..4c564fef 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -21,6 +21,7 @@
 
 #include "list.h"
 #include "utils.h"
+#include "json_writer.h"
 
 #define pr_err(args...) fprintf(stderr, ##args)
 #define pr_out(args...) fprintf(stdout, ##args)
@@ -46,6 +47,9 @@ struct rd {
 	struct mnl_socket *nl;
 	struct nlmsghdr *nlh;
 	char *buff;
+	json_writer_t *jw;
+	bool json_output;
+	bool pretty_output;
 };
 
 struct rd_cmd {
-- 
2.14.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
