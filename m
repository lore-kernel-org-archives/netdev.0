From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 2/6] test_bpf: allow tests to specify an skb fragment.
Date: Tue,  4 Aug 2015 15:19:08 +0200
Message-ID: <1438694352-17469-3-git-send-email-nschichan@freebox.fr>
References: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This introduce a new test->aux flag (FLAG_SKB_FRAG) to tell the
populate_skb() function to add a fragment to the test skb containing
the data specified in test->frag_data).

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>

---
 lib/test_bpf.c | 39 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 6843d0b..e261751 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -23,6 +23,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/random.h>
+#include <linux/highmem.h>
 
 /* General test specific settings */
 #define MAX_SUBTESTS	3
@@ -56,6 +57,7 @@
 /* Flags that can be passed to test cases */
 #define FLAG_NO_DATA		BIT(0)
 #define FLAG_EXPECTED_FAIL	BIT(1)
+#define FLAG_SKB_FRAG		BIT(2)
 
 enum {
 	CLASSIC  = BIT(6),	/* Old BPF instructions only. */
@@ -81,6 +83,7 @@ struct bpf_test {
 		__u32 result;
 	} test[MAX_SUBTESTS];
 	int (*fill_helper)(struct bpf_test *self);
+	__u8 frag_data[MAX_DATA];
 };
 
 /* Large test cases need separate allocation and fill handler. */
@@ -4525,6 +4528,9 @@ static struct sk_buff *populate_skb(char *buf, int size)
 
 static void *generate_test_data(struct bpf_test *test, int sub)
 {
+	struct sk_buff *skb;
+	struct page *page;
+
 	if (test->aux & FLAG_NO_DATA)
 		return NULL;
 
@@ -4532,7 +4538,38 @@ static void *generate_test_data(struct bpf_test *test, int sub)
 	 * subtests generate skbs of different sizes based on
 	 * the same data.
 	 */
-	return populate_skb(test->data, test->test[sub].data_size);
+	skb = populate_skb(test->data, test->test[sub].data_size);
+	if (!skb)
+		return NULL;
+
+	if (test->aux & FLAG_SKB_FRAG) {
+		/*
+		 * when the test requires a fragmented skb, add a
+		 * single fragment to the skb, filled with
+		 * test->frag_data.
+		 */
+		void *ptr;
+
+		page = alloc_page(GFP_KERNEL);
+
+		if (!page)
+			goto err_kfree_skb;
+
+		ptr = kmap(page);
+		if (!ptr)
+			goto err_free_page;
+		memcpy(ptr, test->frag_data, MAX_DATA);
+		kunmap(page);
+		skb_add_rx_frag(skb, 0, page, 0, MAX_DATA, MAX_DATA);
+	}
+
+	return skb;
+
+err_free_page:
+	__free_page(page);
+err_kfree_skb:
+	kfree_skb(skb);
+	return NULL;
 }
 
 static void release_test_data(const struct bpf_test *test, void *data)
-- 
1.9.1
