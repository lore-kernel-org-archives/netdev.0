From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 11/53] perf test: Fix false TEST_OK result for 'perf test hist'
Date: Mon, 11 Jan 2016 13:48:02 +0000
Message-ID: <1452520124-2073-12-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 71d6de64feddd4b455555326fba2111b3006d9e0 ('perf test: Fix hist
testcases when kptr_restrict is on') solves a double free problem when
'perf test hist' calling setup_fake_machine(). However, the result is
still incorrect. For example:

 $ ./perf test -v 'filtering hist entries'
 25: Test filtering hist entries                              :
 --- start ---
 test child forked, pid 4186
 Cannot create kernel maps
 test child finished with 0
 ---- end ----
 Test filtering hist entries: Ok

In this case the body of this test is not get executed at all, but the
result is 'Ok'.

Actually, in setup_fake_machine() there's no need to create real kernel
maps. What we want is the fake maps. This patch removes the
machine__create_kernel_maps() in setup_fake_machine(), so it won't be
affected by kptr_restrict setting.

Test result:

 $ cat /proc/sys/kernel/kptr_restrict
 1
 $ ~/perf test -v hist
 15: Test matching and linking multiple hists                 :
 --- start ---
 test child forked, pid 24031
 test child finished with 0
 ---- end ----
 Test matching and linking multiple hists: Ok
 [SNIP]

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Suggested-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Namhyung Kim <namhyung@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
---
 tools/perf/tests/hists_common.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/tools/perf/tests/hists_common.c b/tools/perf/tests/hists_common.c
index bcfd081..071a8b5 100644
--- a/tools/perf/tests/hists_common.c
+++ b/tools/perf/tests/hists_common.c
@@ -87,11 +87,6 @@ struct machine *setup_fake_machine(struct machines *machines)
 		return NULL;
 	}
 
-	if (machine__create_kernel_maps(machine)) {
-		pr_debug("Cannot create kernel maps\n");
-		return NULL;
-	}
-
 	for (i = 0; i < ARRAY_SIZE(fake_threads); i++) {
 		struct thread *thread;
 
-- 
1.8.3.4
