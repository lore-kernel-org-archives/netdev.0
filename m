From: akpm@linux-foundation.org
Subject: [patch 1/1] sctp: prevent reading out-of-bounds memory
Date: Fri, 01 Oct 2010 14:16:58 -0700
Message-ID: <201010012116.o91LGwS5021150@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dan.j.rosenberg@gmail.com, vladislav.yasevich@hp.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39355 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754045Ab0JAVRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 17:17:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <dan.j.rosenberg@gmail.com>

Two user-controlled allocations in SCTP are subsequently dereferenced as
sockaddr structs, without checking if the dereferenced struct members fall
beyond the end of the allocated chunk.  There doesn't appear to be any
information leakage here based on how these members are used and
additional checking, but it's still worth fixing.

[akpm@linux-foundation.org: remove unfashionable newlines, fix gmail tab->space conversion]
Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sctp/socket.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff -puN net/sctp/socket.c~sctp-prevent-reading-out-of-bounds-memory net/sctp/socket.c
--- a/net/sctp/socket.c~sctp-prevent-reading-out-of-bounds-memory
+++ a/net/sctp/socket.c
@@ -918,6 +918,11 @@ SCTP_STATIC int sctp_setsockopt_bindx(st
 	/* Walk through the addrs buffer and count the number of addresses. */
 	addr_buf = kaddrs;
 	while (walk_size < addrs_size) {
+		if (walk_size + sizeof(sa_family_t) > addrs_size) {
+			kfree(kaddrs);
+			return -EINVAL;
+		}
+
 		sa_addr = (struct sockaddr *)addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa_family);
 
@@ -1004,9 +1009,13 @@ static int __sctp_connect(struct sock* s
 	/* Walk through the addrs buffer and count the number of addresses. */
 	addr_buf = kaddrs;
 	while (walk_size < addrs_size) {
+		if (walk_size + sizeof(sa_family_t) > addrs_size) {
+			err = -EINVAL;
+			goto out_free;
+		}
+
 		sa_addr = (union sctp_addr *)addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa.sa_family);
-		port = ntohs(sa_addr->v4.sin_port);
 
 		/* If the address family is not supported or if this address
 		 * causes the address buffer to overflow return EINVAL.
@@ -1016,6 +1025,8 @@ static int __sctp_connect(struct sock* s
 			goto out_free;
 		}
 
+		port = ntohs(sa_addr->v4.sin_port);
+
 		/* Save current address so we can work with it */
 		memcpy(&to, sa_addr, af->sockaddr_len);
 
_
