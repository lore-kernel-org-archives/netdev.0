From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] net: unix socket code abuses csum_partial
Date: Tue, 4 Mar 2014 21:01:04 +1100
Message-ID: <20140304210104.42ef3dd8@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, edumazet@google.com,
	gustavold@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50701 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756511AbaCDKBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 05:01:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The unix socket code is using the result of csum_partial to
hash into a lookup table:

	unix_hash_fold(csum_partial(sunaddr, len, 0));

csum_partial is only guaranteed to produce something that can be
folded into a checksum, as its prototype explains:

 * returns a 32-bit number suitable for feeding into itself
 * or csum_tcpudp_magic

The 32bit value should not be used directly.

Depending on the alignment the ppc64 csum_partial will return
different 32bit values that will fold into the same checksum.

This difference causes the following testcase (courtesy of
Gustavo) to sometimes fail:


#include <sys/socket.h>
#include <stdio.h>

int main()
{
	int fd = socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0);

	int i = 1;
	setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &i, 4);

	struct sockaddr addr;
	addr.sa_family = AF_LOCAL;
	bind(fd, &addr, 2);

	listen(fd, 128);

	struct sockaddr_storage ss;
	socklen_t sslen = (socklen_t)sizeof(ss);
	getsockname(fd, (struct sockaddr*)&ss, &sslen);

	fd = socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0);

	if (connect(fd, (struct sockaddr*)&ss, sslen) == -1){
		perror(NULL);
		return 1;
	}
	printf("OK\n");
	return 0;
}


Use jhash instead of the current hand crafted csum_partial +
xor based hash.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable@vger.kernel.org
---

Would appreciate a sanity check here. Are there other users that
expect a stable 32bit value out of csum_partial?

Is this performance critical enough that jhash is going to hurt?
Another option would be to csum_fold the 32bit intermediate value
and just hash based on the result.

Index: b/net/unix/af_unix.c
===================================================================
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -117,6 +117,7 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 #include <linux/freezer.h>
+#include <linux/jhash.h>
 
 struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 EXPORT_SYMBOL_GPL(unix_socket_table);
@@ -161,13 +162,9 @@ static inline void unix_set_secdata(stru
  *    each socket state is protected by separate spin lock.
  */
 
-static inline unsigned int unix_hash_fold(__wsum n)
+static inline unsigned int unix_hash(void *data, unsigned int len)
 {
-	unsigned int hash = (__force unsigned int)n;
-
-	hash ^= hash>>16;
-	hash ^= hash>>8;
-	return hash&(UNIX_HASH_SIZE-1);
+	return jhash(data, len, 0) & (UNIX_HASH_SIZE - 1);
 }
 
 #define unix_peer(sk) (unix_sk(sk)->peer)
@@ -232,7 +229,7 @@ static int unix_mkname(struct sockaddr_u
 		return len;
 	}
 
-	*hashp = unix_hash_fold(csum_partial(sunaddr, len, 0));
+	*hashp = unix_hash(sunaddr, len);
 	return len;
 }
 
@@ -738,7 +735,7 @@ static int unix_autobind(struct socket *
 
 retry:
 	addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);
-	addr->hash = unix_hash_fold(csum_partial(addr->name, addr->len, 0));
+	addr->hash = unix_hash(addr->name, addr->len);
 
 	spin_lock(&unix_table_lock);
 	ordernum = (ordernum+1)&0xFFFFF;
