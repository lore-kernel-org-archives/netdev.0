From: baker.kernel@gmail.com
Subject: [PATCH V3 net-next] fib_trie: avoid a redundant bit judgement in inflate
Date: Tue,  1 Oct 2013 07:45:09 +0800
Message-ID: <1380584709-5877-1-git-send-email-baker.kernel@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"baker.zhang" <baker.kernel@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "baker.zhang" <baker.kernel@gmail.com>

Because 'node' is the i'st child of 'oldnode',
thus, here 'i' equals
tkey_extract_bits(node->key, oldtnode->pos, oldtnode->bits)

we just get 1 more bit,
and need not care the detail value of this bits.

I apologize for the mistake.

I generated the patch on a branch version,
and did not notice the put_child has been changed.

I have redone the test on HEAD version with my patch.

two cases are used.
case 1. inflate a node which has a leaf child node.
case 2: inflate a node which has a an child node with skipped bits

test env:
  ip link set eth0 up
  ip a add dev eth0 192.168.11.1/32
here, we just focus on route table(MAIN),
so I use a "192.168.11.1/32" address to simplify the test case.

call trace:
+ fib_insert_node
+ + trie_rebalance
+ + + resize
+ + + + inflate

Test case 1:  inflate a node which has a leaf child node.
===========================================================
step 1. prepare a fib trie
------------------------------------------
  ip r a 192.168.0.0/24 via 192.168.11.1
  ip r a 192.168.1.0/24 via 192.168.11.1

we get a fib trie.
root@baker:~# cat /proc/net/fib_trie
Main:
  +-- 192.168.0.0/23 1 0 0
   |-- 192.168.0.0
    /24 universe UNICAST
   |-- 192.168.1.0
    /24 universe UNICAST
Local:
.....

step 2. Add the third route
------------------------------------------
root@baker:~# ip r a 192.168.2.0/24 via 192.168.11.1

A fib_trie leaf will be inserted in fib_insert_node before trie_rebalance.

For function 'inflate':
'inflate' is called with following trie.
  +-- 192.168.0.0/22 1 1 0 <=== tn node
    +-- 192.168.0.0/23 1 0 0    <== node a
        |-- 192.168.0.0
          /24 universe UNICAST
        |-- 192.168.1.0
          /24 universe UNICAST
      |-- 192.168.2.0          <== leaf(node b)

When process node b, which is a leaf. here:
i is 1,
node key "192.168.2.0"
oldnode is (pos:22, bits:1)

unpatch source:
tkey_extract_bits(node->key, oldtnode->pos + oldtnode->bits, 1)
it equals:
tkey_extract_bits("192.168,2,0", 22 + 1, 1)

thus got 0, and call put_child(tn, 2*i, node); <== 2*i=2.

patched source:
tkey_extract_bits(node->key, oldtnode->pos, oldtnode->bits + 1),
tkey_extract_bits("192.168,2,0", 22, 1 + 1)  <== get 2.

Test case 2:  inflate a node which has a an child node with skipped bits
==========================================================================
step 1. prepare a fib trie.
  ip link set eth0 up
  ip a add dev eth0 192.168.11.1/32
  ip r a 192.168.128.0/24 via 192.168.11.1
  ip r a 192.168.0.0/24  via 192.168.11.1
  ip r a 192.168.16.0/24   via 192.168.11.1
  ip r a 192.168.32.0/24  via 192.168.11.1
  ip r a 192.168.48.0/24  via 192.168.11.1
  ip r a 192.168.144.0/24   via 192.168.11.1
  ip r a 192.168.160.0/24   via 192.168.11.1
  ip r a 192.168.176.0/24   via 192.168.11.1

check:
root@baker:~# cat /proc/net/fib_trie
Main:
  +-- 192.168.0.0/16 1 0 0
     +-- 192.168.0.0/18 2 0 0
        |-- 192.168.0.0
           /24 universe UNICAST
        |-- 192.168.16.0
           /24 universe UNICAST
        |-- 192.168.32.0
           /24 universe UNICAST
        |-- 192.168.48.0
           /24 universe UNICAST
     +-- 192.168.128.0/18 2 0 0
        |-- 192.168.128.0
           /24 universe UNICAST
        |-- 192.168.144.0
           /24 universe UNICAST
        |-- 192.168.160.0
           /24 universe UNICAST
        |-- 192.168.176.0
           /24 universe UNICAST
Local:
  ...

step 2. add a route to trigger inflate.
  ip r a 192.168.96.0/24   via 192.168.11.1

This command will call serveral times inflate.
In the first time, the fib_trie is:
________________________
+-- 192.168.128.0/(16, 1) <== tn node
 +-- 192.168.0.0/(17, 1)  <== node a
  +-- 192.168.0.0/(18, 2)
   |-- 192.168.0.0
   |-- 192.168.16.0
   |-- 192.168.32.0
   |-- 192.168.48.0
  |-- 192.168.96.0
 +-- 192.168.128.0/(18, 2) <== node b.
  |-- 192.168.128.0
  |-- 192.168.144.0
  |-- 192.168.160.0
  |-- 192.168.176.0

NOTE: node b is a interal node with skipped bits.
here,
i:1,
node->key "192.168.128.0",
oldnode:(pos:16, bits:1)
so
tkey_extract_bits(node->key, oldtnode->pos + oldtnode->bits, 1)
it equals:
tkey_extract_bits("192.168,128,0", 16 + 1, 1) <=== 0

tkey_extract_bits(node->key, oldtnode->pos, oldtnode->bits, 1)
it equals:
tkey_extract_bits("192.168,128,0", 16, 1+1) <=== 2

2*i + 0 == 2, so the result is same.

Signed-off-by: baker.zhang <baker.kernel@gmail.com>
---
 net/ipv4/fib_trie.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3df6d3e..45c74ba 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -762,12 +762,9 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 
 		if (IS_LEAF(node) || ((struct tnode *) node)->pos >
 		   tn->pos + tn->bits - 1) {
-			if (tkey_extract_bits(node->key,
-					      oldtnode->pos + oldtnode->bits,
-					      1) == 0)
-				put_child(tn, 2*i, node);
-			else
-				put_child(tn, 2*i+1, node);
+			put_child(tn,
+				tkey_extract_bits(node->key, oldtnode->pos, oldtnode->bits + 1),
+				node);
 			continue;
 		}
 
-- 
1.8.1.2
