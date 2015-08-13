From: Andy Whitcroft <apw@canonical.com>
Subject: [PATCH 1/1 V2] ipv4: off-by-one in continuation handling in /proc/net/route
Date: Thu, 13 Aug 2015 20:49:01 +0100
Message-ID: <1439495341-12095-1-git-send-email-apw@canonical.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andy Whitcroft <apw@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When generating /proc/net/route we emit a header followed by a line for
each route.  When a short read is performed we will restart this process
based on the open file descriptor.  When calculating the start point we
fail to take into account that the 0th entry is the header.  This leads
us to skip the first entry when doing a continuation read.

This can be easily seen with the comparison below:

  while read l; do echo "$l"; done </proc/net/route >A
  cat /proc/net/route >B
  diff -bu A B | grep '^[+-]'

On my example machine I have approximatly 10KB of route output.  There we
see the very first non-title element is lost in the while read case,
and an entry around the 8K mark in the cat case:

  +wlan0 00000000 02021EAC 0003 0 0 400 00000000 0 0 0
  -tun1  00C0AC0A 00000000 0001 0 0 950 00C0FFFF 0 0 0

Fix up the off-by-one when reaquiring position on continuation.

Fixes: 8be33e955cb9 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")                                   
BugLink: http://bugs.launchpad.net/bugs/1483440
Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Andy Whitcroft <apw@canonical.com>
---
 net/ipv4/fib_trie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

	V2 incorporates the updated Fixes: line as suggested by Eric,
	and incorporates Alexander's Ack.

	This is for applicable to net and to suitable for stable trees
	v4.1 and up.

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 37c4bb8..b0c6258 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2465,7 +2465,7 @@ static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 		key = l->key + 1;
 		iter->pos++;
 
-		if (pos-- <= 0)
+		if (--pos <= 0)
 			break;
 
 		l = NULL;
-- 
2.5.0
