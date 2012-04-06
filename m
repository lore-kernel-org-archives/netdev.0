From: John Keeping <john@keeping.me.uk>
Subject: [PATCH] net/core: Fix seeking in /proc/net/dev
Date: Fri,  6 Apr 2012 18:05:44 +0100
Message-ID: <1333731944-15808-1-git-send-email-john@keeping.me.uk>
Cc: John Keeping <john@keeping.me.uk>, linux-kernel@vger.kernel.org,
	Mihai Maruseac <mihai.maruseac@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit f04565ddf52e4 (dev: use name hash for dev_seq_ops) introduced
code that fails to check the requested position when getting an item for
/proc/net/dev.  This means that any code which seeks within this file is
likely to receive corrupted data.

A test case for this is to use the read builtin in bash:

$ while read line; do echo "$line"; done </proc/net/dev | cut -c-20
Inter-|   Receive
face |bytes    packe
virbr0:   20706
0
lo: 2329335   10305
eth0:       0

compared to just cat'ing the file:

$ cat /proc/net/dev | cut -c-20
Inter-|   Receive
 face |bytes    pack
    lo: 2329335   10
virbr0:   20706
  sit0:       0
 wlan0: 1727234745 1
  eth0:       0

This patch takes the sledgehammer approach of starting again from the
beginning if asked to seek backwards.

Signed-off-by: John Keeping <john@keeping.me.uk>

---
I have made the minimal change required to fix the bug here.  If desired I
can spend some more time and enhance the dev_from_new_bucket and
dev_from_same_bucket functions to support walking backwards as well as
forwards through the items in the table.

---
 net/core/dev.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6ca32f6..66b1e891 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4040,6 +4040,7 @@ static int dev_ifconf(struct net *net, char __user *arg)
 
 struct dev_iter_state {
 	struct seq_net_private p;
+	loff_t expected_pos; /* current index */
 	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
 };
 
@@ -4096,24 +4097,37 @@ static inline struct net_device *dev_from_new_bucket(struct seq_file *seq)
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
+	struct net_device *dev;
 	struct dev_iter_state *state = seq->private;
 
 	rcu_read_lock();
-	if (!*pos)
+	if (!*pos) {
+		state->expected_pos = 0;
+		state->pos = 0;
 		return SEQ_START_TOKEN;
+	}
 
-	/* check for end of the hash */
-	if (state->pos == 0 && *pos > 1)
-		return NULL;
+	/* If we're asked for something behind where we are, start again. */
+	if (state->expected_pos >= *pos) {
+		state->expected_pos = 0;
+		state->pos = 0;
+	}
 
-	return dev_from_new_bucket(seq);
+	do {
+		dev = dev_from_new_bucket(seq);
+		++state->expected_pos;
+	} while (dev && state->expected_pos < *pos);
+
+	return dev;
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct net_device *dev;
+	struct dev_iter_state *state = seq->private;
 
 	++*pos;
+	state->expected_pos = *pos;
 
 	if (v == SEQ_START_TOKEN)
 		return dev_from_new_bucket(seq);
-- 
1.7.8.5
