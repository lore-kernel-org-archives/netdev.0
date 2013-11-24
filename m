From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] pipe_to_sendpage: Ensure that MSG_MORE is set if we set MSG_SENDPAGE_NOTLAST
Date: Mon, 25 Nov 2013 00:42:07 +0100
Message-ID: <1385336527-27304-1-git-send-email-richard@nod.at>
References: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	shawnlandden@gmail.com, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Richard Weinberger <richard@nod.at>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <stable@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAJusiZXN4dOxg9S4ZiCziVXfNZ+=yu7a=84vUikV2RhbhYU7QA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
added an internal flag MSG_SENDPAGE_NOTLAST.
We have to ensure that MSG_MORE is also set if we set MSG_SENDPAGE_NOTLAST.
Otherwise users that check against MSG_MORE will not see it.

This fixes sendfile() on AF_ALG.

Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: <stable@vger.kernel.org> # 3.4.x
Reported-and-tested-by: Shawn Landden <shawnlandden@gmail.com>
Signed-off-by: Richard Weinberger <richard@nod.at>
---
 fs/splice.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/splice.c b/fs/splice.c
index 3b7ee65..b93f1b8 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -701,7 +701,7 @@ static int pipe_to_sendpage(struct pipe_inode_info *pipe,
 	more = (sd->flags & SPLICE_F_MORE) ? MSG_MORE : 0;
 
 	if (sd->len < sd->total_len && pipe->nrbufs > 1)
-		more |= MSG_SENDPAGE_NOTLAST;
+		more |= MSG_SENDPAGE_NOTLAST | MSG_MORE;
 
 	return file->f_op->sendpage(file, buf->page, buf->offset,
 				    sd->len, &pos, more);
-- 
1.8.1.4
