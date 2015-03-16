From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v2 net-next 2/4] aio: prefer aio_op op over iter_op
Date: Mon, 16 Mar 2015 09:15:19 -0700
Message-ID: <20150316161519.16418.63051.stgit@tstruk-mobl1>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au, netdev@vger.kernel.org,
 ying.xue@windriver.com, bcrl@kvack.org, viro@ZenIV.linux.org.uk,
 linux-fsdevel@vger.kernel.org, hch@lst.de, linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <owner-linux-aio@kvack.org>
In-Reply-To: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Sender: owner-linux-aio@kvack.org
List-Id: netdev.vger.kernel.org

AIO interface should prefer AIO operations over iter_op

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 fs/aio.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index f8e52a1..389f4dd 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1449,11 +1449,15 @@ rw_common:
 		if (rw == WRITE)
 			file_start_write(file);
 
-		if (iter_op) {
+		if (rw_op) {
+			ret = rw_op(req, iovec, nr_segs, req->ki_pos);
+		} else if (iter_op) {
 			iov_iter_init(&iter, rw, iovec, nr_segs, req->ki_nbytes);
 			ret = iter_op(req, &iter);
 		} else {
-			ret = rw_op(req, iovec, nr_segs, req->ki_pos);
+			if (iovec != inline_vecs)
+				kfree(iovec);
+			return -EINVAL;
 		}
 
 		if (rw == WRITE)

--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
