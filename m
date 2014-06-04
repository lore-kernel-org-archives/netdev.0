From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: Revert "fib_trie: use seq_file_net rather than seq->private"
Date: Wed,  4 Jun 2014 18:02:32 -0400
Message-ID: <1401919352-32263-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dsahern@gmail.com, Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 30f38d2fdd79f13fc929489f7e6e517b4a4bfe63.

fib_triestat is surrounded by a big lie: while it claims that it's a
seq_file (fib_triestat_seq_open, fib_triestat_seq_show), it isn't:

	static const struct file_operations fib_triestat_fops = {
	        .owner  = THIS_MODULE,
	        .open   = fib_triestat_seq_open,
	        .read   = seq_read,
	        .llseek = seq_lseek,
	        .release = single_release_net,
	};

Yes, fib_triestat is just a regular file.

A small detail (assuming CONFIG_NET_NS=y) is that while for seq_files
you could do seq_file_net() to get the net ptr, doing so for a regular
file would be wrong and would dereference an invalid pointer.

The fib_triestat lie claimed a victim, and trying to show the file would
be bad for the kernel. This patch just reverts the issue and fixes
fib_triestat, which still needs a rewrite to either be a seq_file or
stop claiming it is.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/ipv4/fib_trie.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 243c7f4..5afeb5a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2166,7 +2166,7 @@ static void fib_table_print(struct seq_file *seq, struct fib_table *tb)
 
 static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = seq_file_net(seq);
+	struct net *net = (struct net *)seq->private;
 	unsigned int h;
 
 	seq_printf(seq,
-- 
1.7.10.4
