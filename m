From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 04/12] bpftool: print program device bound info
Date: Tue, 31 Oct 2017 18:52:09 -0700
Message-ID: <20171101015217.10666-5-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:45421 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932920AbdKABxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:02 -0400
Received: by mail-pf0-f194.google.com with SMTP id d28so737331pfe.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:02 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If program is bound to a device, print the name of the relevant
interface or unknown if the netdev has since been removed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/prog.c       | 31 +++++++++++++++++++++++++++++++
 tools/include/uapi/linux/bpf.h |  8 ++++++++
 2 files changed, 39 insertions(+)

diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index 250f80fd46aa..d3ab808dc882 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -41,6 +41,7 @@
 #include <string.h>
 #include <time.h>
 #include <unistd.h>
+#include <net/if.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 
@@ -229,6 +230,21 @@ static void print_prog_json(struct bpf_prog_info *info, int fd)
 		     info->tag[0], info->tag[1], info->tag[2], info->tag[3],
 		     info->tag[4], info->tag[5], info->tag[6], info->tag[7]);
 
+	if (info->status & BPF_PROG_STATUS_DEV_BOUND) {
+		jsonw_name(json_wtr, "dev");
+		if (info->ifindex) {
+			char name[IF_NAMESIZE];
+
+			if (!if_indextoname(info->ifindex, name))
+				jsonw_printf(json_wtr, "\"ifindex:%d\"",
+					     info->ifindex);
+			else
+				jsonw_printf(json_wtr, "\"%s\"", name);
+		} else {
+			jsonw_printf(json_wtr, "\"unknown\"");
+		}
+	}
+
 	if (info->load_time) {
 		char buf[32];
 
@@ -274,6 +290,21 @@ static void print_prog_plain(struct bpf_prog_info *info, int fd)
 
 	printf("tag ");
 	fprint_hex(stdout, info->tag, BPF_TAG_SIZE, "");
+	printf(" ");
+
+	if (info->status & BPF_PROG_STATUS_DEV_BOUND) {
+		printf("dev ");
+		if (info->ifindex) {
+			char name[IF_NAMESIZE];
+
+			if (!if_indextoname(info->ifindex, name))
+				printf("ifindex:%d ", info->ifindex);
+			else
+				printf("%s ", name);
+		} else {
+			printf("unknown ");
+		}
+	}
 	printf("\n");
 
 	if (info->load_time) {
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 4a4b6e78c977..f684ba3732e5 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -259,6 +259,8 @@ union bpf_attr {
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 		__u32		prog_flags;
 		char		prog_name[BPF_OBJ_NAME_LEN];
+
+		__u32		prog_ifindex;	/* ifindex of netdev to prep for */
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
@@ -894,6 +896,10 @@ enum sk_action {
 
 #define BPF_TAG_SIZE	8
 
+enum bpf_prog_status {
+	BPF_PROG_STATUS_DEV_BOUND	= (1 << 0),
+};
+
 struct bpf_prog_info {
 	__u32 type;
 	__u32 id;
@@ -907,6 +913,8 @@ struct bpf_prog_info {
 	__u32 nr_map_ids;
 	__aligned_u64 map_ids;
 	char name[BPF_OBJ_NAME_LEN];
+	__u32 ifindex;
+	__u32 status;
 } __attribute__((aligned(8)));
 
 struct bpf_map_info {
-- 
2.14.1
