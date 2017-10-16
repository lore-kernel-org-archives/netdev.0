From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v6 2/5] bpf: Add tests for eBPF file mode
Date: Mon, 16 Oct 2017 12:11:32 -0700
Message-ID: <20171016191135.8046-3-chenbofeng.kernel@gmail.com>
References: <20171016191135.8046-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171016191135.8046-1-chenbofeng.kernel@gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chenbo Feng <fengc@google.com>

Two related tests are added into bpf selftest to test read only map and
write only map. The tests verified the read only and write only flags
are working on hash maps.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 tools/testing/selftests/bpf/test_maps.c | 48 +++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index fe3a443a1102..896f23cfe918 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -1033,6 +1033,51 @@ static void test_map_parallel(void)
 	assert(bpf_map_get_next_key(fd, &key, &key) == -1 && errno == ENOENT);
 }
 
+static void test_map_rdonly(void)
+{
+	int i, fd, key = 0, value = 0;
+
+	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+			    MAP_SIZE, map_flags | BPF_F_RDONLY);
+	if (fd < 0) {
+		printf("Failed to create map for read only test '%s'!\n",
+		       strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* Insert key=1 element. */
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == -1 &&
+	       errno == EPERM);
+
+	/* Check that key=2 is not found. */
+	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_get_next_key(fd, &key, &value) == -1 && errno == ENOENT);
+}
+
+static void test_map_wronly(void)
+{
+	int i, fd, key = 0, value = 0;
+
+	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+			    MAP_SIZE, map_flags | BPF_F_WRONLY);
+	if (fd < 0) {
+		printf("Failed to create map for read only test '%s'!\n",
+		       strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* Insert key=1 element. */
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0)
+
+	/* Check that key=2 is not found. */
+	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == EPERM);
+	assert(bpf_map_get_next_key(fd, &key, &value) == -1 && errno == EPERM);
+}
+
 static void run_all_tests(void)
 {
 	test_hashmap(0, NULL);
@@ -1050,6 +1095,9 @@ static void run_all_tests(void)
 	test_map_large();
 	test_map_parallel();
 	test_map_stress();
+
+	test_map_rdonly();
+	test_map_wronly();
 }
 
 int main(void)
-- 
2.15.0.rc0.271.g36b669edcc-goog

