From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH stable<3.19] net: handle null iovec pointer in
 skb_copy_and_csum_datagram_iovec()
Date: Fri, 23 Oct 2015 10:46:09 +0200 (CEST)
Message-ID: <20151023084609.585AEA0C18@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Sasha Levin <sasha.levin@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>, Zefan Li <lizefan@huawei.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mainline commit 89c22d8c3b27 ("net: Fix skb csum races when peeking")
backport into pre-3.19 stable kernels introduces a regression causing
null pointer dererefence in skb_copy_and_csum_datagram_iovec().

This commit only sets CHECKSUM_UNNECESSARY for non-shared skb, allowing
udp_recvmsg() to take the "else" branch of if (skb_csum_unnecessary(skb))
when called with null iovec (and len=0, e.g. when peeking for datagram
size first). The problem is that unlike skb_copy_and_csum_datagram_msg()
called in this path since 3.19, skb_copy_and_csum_datagram_iovec() does
not handle null iov parameter and always dereferences iov->iov_len. This
is especially harmful when udp_recvmsg() is called in kernel context,
e.g. from kernel nfsd.

Band-aid skb_copy_and_csum_datagram_iovec() by testing iov for null and
only checking the checksum in this case.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/core/datagram.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 3a402a7b20e9..f8b38794fa9b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -799,6 +799,13 @@ int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
 	if (!chunk)
 		return 0;
 
+	if (!iov) {
+		if (__skb_checksum_complete(skb))
+			goto csum_error;
+		else
+			return 0;
+	}
+
 	/* Skip filled elements.
 	 * Pretty silly, look at memcpy_toiovec, though 8)
 	 */
-- 
2.6.2
