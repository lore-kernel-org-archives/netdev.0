From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 41/53] perf record: Ensure return non-zero rc when mmap fail
Date: Mon, 11 Jan 2016 13:48:32 +0000
Message-ID: <1452520124-2073-42-git-send-email-wangnan0@huawei.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

perf_evlist__mmap_ex() can fail without setting errno (for example,
fail in condition checking. In this case all syscall is success).
If this happen, record__open() incorrectly returns 0. Force setting
rc is a quick way to avoid this problem, or we have to follow all
possible code path in perf_evlist__mmap_ex() to make sure there's
at least one system call before returning an error.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index aaf3b0f..b65b41f 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -361,7 +361,10 @@ try_again:
 		} else {
 			pr_err("failed to mmap with %d (%s)\n", errno,
 				strerror_r(errno, msg, sizeof(msg)));
-			rc = -errno;
+			if (errno)
+				rc = -errno;
+			else
+				rc = -EINVAL;
 		}
 		goto out;
 	}
-- 
1.8.3.4
