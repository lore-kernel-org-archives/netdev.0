From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v4 2/3] mac80211: Prevent build failure with CONFIG_UBSAN=y
Date: Thu, 3 Dec 2015 18:50:06 +0300
Message-ID: <1449157807-20298-3-git-send-email-aryabinin@virtuozzo.com>
References: <1449157807-20298-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Jonathan Corbet <corbet@lwn.net>,
	Michal Marek <mmarek@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Yury Gribov <y.gribov@samsung.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Kostya Serebryany <kcc@google.com>, <x86@kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kbuild@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449157807-20298-1-git-send-email-aryabinin@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With upcoming CONFIG_UBSAN the following BUILD_BUG_ON in
net/mac80211/debugfs.c starts to trigger:
	BUILD_BUG_ON(hw_flag_names[NUM_IEEE80211_HW_FLAGS] != (void *)0x1);

It seems, that compiler instrumentation causes some code deoptimizations.
Because of that GCC is not being able to resolve condition in BUILD_BUG_ON()
at compile time.

We could make size of hw_flag_names array unspecified and replace the
condition in BUILD_BUG_ON() with following:
	ARRAY_SIZE(hw_flag_names) != NUM_IEEE80211_HW_FLAGS

That will have the same effect as before (adding new flag without updating
array will trigger build failure) except it doesn't fail with CONFIG_UBSAN.
As a bonus this patch slightly decreases size of hw_flag_names array.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/mac80211/debugfs.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index abbdff0..3e24d0d 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -91,7 +91,7 @@ static const struct file_operations reset_ops = {
 };
 #endif
 
-static const char *hw_flag_names[NUM_IEEE80211_HW_FLAGS + 1] = {
+static const char *hw_flag_names[] = {
 #define FLAG(F)	[IEEE80211_HW_##F] = #F
 	FLAG(HAS_RATE_CONTROL),
 	FLAG(RX_INCLUDES_FCS),
@@ -126,9 +126,6 @@ static const char *hw_flag_names[NUM_IEEE80211_HW_FLAGS + 1] = {
 	FLAG(SUPPORTS_AMSDU_IN_AMPDU),
 	FLAG(BEACON_TX_STATUS),
 	FLAG(NEEDS_UNIQUE_STA_ADDR),
-
-	/* keep last for the build bug below */
-	(void *)0x1
 #undef FLAG
 };
 
@@ -148,7 +145,7 @@ static ssize_t hwflags_read(struct file *file, char __user *user_buf,
 	/* fail compilation if somebody adds or removes
 	 * a flag without updating the name array above
 	 */
-	BUILD_BUG_ON(hw_flag_names[NUM_IEEE80211_HW_FLAGS] != (void *)0x1);
+	BUILD_BUG_ON(ARRAY_SIZE(hw_flag_names) != NUM_IEEE80211_HW_FLAGS);
 
 	for (i = 0; i < NUM_IEEE80211_HW_FLAGS; i++) {
 		if (test_bit(i, local->hw.flags))
-- 
2.4.10
