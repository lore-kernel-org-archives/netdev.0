From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] net: unix socket code abuses csum_partial
Date: Wed, 5 Mar 2014 14:29:58 +1100
Message-ID: <20140305142958.1ed421dc@kryten>
References: <20140304210104.42ef3dd8@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, edumazet@google.com,
	gustavold@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44925 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756891AbaCED37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 22:29:59 -0500
In-Reply-To: <20140304210104.42ef3dd8@kryten>
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

Depending on the alignment, the ppc64 csum_partial will return
different 32bit partial checksums that will fold into the same
16bit checksum.

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
 

As suggested by davem, fix this by using csum_fold to fold the
partial 32bit checksum into a 16bit checksum before using it.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: stable@vger.kernel.org
---

Index: b/net/unix/af_unix.c
===================================================================
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -163,9 +163,8 @@ static inline void unix_set_secdata(stru
 
 static inline unsigned int unix_hash_fold(__wsum n)
 {
-	unsigned int hash = (__force unsigned int)n;
+	unsigned int hash = (__force unsigned int)csum_fold(n);
 
-	hash ^= hash>>16;
 	hash ^= hash>>8;
 	return hash&(UNIX_HASH_SIZE-1);
 }
