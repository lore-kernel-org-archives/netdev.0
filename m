From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 31/53] perf tools: Add perf_data_file__switch() helper
Date: Mon, 11 Jan 2016 13:48:22 +0000
Message-ID: <1452520124-2073-32-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:45305 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932640AbcAKN44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 08:56:56 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

perf_data_file__switch() closes current output file, renames it, then
open a new one to continue record. It will be used by perf record
to split output into multiple perf.data files.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/data.c | 36 ++++++++++++++++++++++++++++++++++++
 tools/perf/util/data.h | 11 ++++++++++-
 2 files changed, 46 insertions(+), 1 deletion(-)

diff --git a/tools/perf/util/data.c b/tools/perf/util/data.c
index 1921942..bfded6a 100644
--- a/tools/perf/util/data.c
+++ b/tools/perf/util/data.c
@@ -136,3 +136,39 @@ ssize_t perf_data_file__write(struct perf_data_file *file,
 {
 	return writen(file->fd, buf, size);
 }
+
+int perf_data_file__switch(struct perf_data_file *file,
+			   const char *postfix,
+			   size_t pos, bool at_exit)
+{
+	char *new_filepath;
+	int ret;
+
+	if (check_pipe(file))
+		return -EINVAL;
+	if (perf_data_file__is_read(file))
+		return -EINVAL;
+
+	if (asprintf(&new_filepath, "%s.%s", file->path, postfix) < 0)
+		return -ENOMEM;
+
+	rename(file->path, new_filepath);
+
+	if (!at_exit) {
+		close(file->fd);
+		ret = perf_data_file__open(file);
+		if (ret < 0)
+			goto out;
+
+		if (lseek(file->fd, pos, SEEK_SET) == (off_t)-1) {
+			ret = -errno;
+			pr_debug("Failed to lseek to %zu: %s",
+				 pos, strerror(errno));
+			goto out;
+		}
+	}
+	ret = file->fd;
+out:
+	free(new_filepath);
+	return ret;
+}
diff --git a/tools/perf/util/data.h b/tools/perf/util/data.h
index 2b15d0c..7763300 100644
--- a/tools/perf/util/data.h
+++ b/tools/perf/util/data.h
@@ -46,5 +46,14 @@ int perf_data_file__open(struct perf_data_file *file);
 void perf_data_file__close(struct perf_data_file *file);
 ssize_t perf_data_file__write(struct perf_data_file *file,
 			      void *buf, size_t size);
-
+/*
+ * If at_exit is set, only rename current perf.data to
+ * perf.data.<postfix>, continue write on original file.
+ * Used when flushing the last output.
+ *
+ * Return value is fd of new output.
+ */
+int perf_data_file__switch(struct perf_data_file *file,
+			   const char *postfix,
+			   size_t pos, bool at_exit);
 #endif /* __PERF_DATA_H */
-- 
1.8.3.4
