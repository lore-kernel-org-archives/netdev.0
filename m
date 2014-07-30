From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: ipv4: raw: don't agree to 0 sized headers
Date: Wed, 30 Jul 2014 09:21:08 -0400
Message-ID: <1406726468-19035-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: kuznet@ms2.inr.ac.ru, davem@davemloft.net, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For raw sockets, we'd always assume that a header is supplied and will attempt
to copy it into the ip header space using memcpy_fromiovecend():

	if (memcpy_fromiovecend((void *)iph, from, 0, length))
		goto error_free;

The problem is that memcpy_fromiovecend() assumes that there are actual data
to read from the iovec and doesn't deal with cases where there are none:

	int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
				int offset, int len)
	{
		/* Skip over the finished iovecs */
		while (offset >= iov->iov_len) {
			offset -= iov->iov_len;
			iov++;
		}
		[...]

So when offset == 0 and iov->iov_len == 0, we'll just run iov into random
kernel memory until it hits something bad and dies in a BUG/panic - either
killing the kernel or leaking memory and held locks.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/ipv4/raw.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 739db31..3af59ee 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -345,6 +345,10 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 			       rt->dst.dev->mtu);
 		return -EMSGSIZE;
 	}
+
+	if (length == 0)
+		return -EINVAL;
+
 	if (flags&MSG_PROBE)
 		goto out;
 
-- 
1.7.10.4
