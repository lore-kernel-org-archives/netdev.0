From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix MSG_SENDPAGE_NOTLAST logic
Date: Sun, 06 Jan 2013 20:21:49 -0800
Message-ID: <1357532509.6919.1715.camel@edumazet-glaptop>
References: <1357490393.6919.267.camel@edumazet-glaptop>
	 <20130106164416.GF16031@1wt.eu>
	 <1357492255.6919.336.camel@edumazet-glaptop>
	 <20130106173543.GB22432@1wt.eu>
	 <1357497541.6919.519.camel@edumazet-glaptop>
	 <1357497809.6919.529.camel@edumazet-glaptop>
	 <1357498276.6919.547.camel@edumazet-glaptop>
	 <1357498815.6919.570.camel@edumazet-glaptop>
	 <20130106193410.GL16031@1wt.eu>
	 <1357501171.6919.650.camel@edumazet-glaptop>
	 <20130106195359.GN16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:39122 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477Ab3AGEVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 23:21:54 -0500
In-Reply-To: <20130106195359.GN16031@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 35f9c09fe9c72e (tcp: tcp_sendpages() should call tcp_push() once)
added an internal flag : MSG_SENDPAGE_NOTLAST meant to be set on all
frags but the last one for a splice() call.

The condition used to set the flag in pipe_to_sendpage() relied on
splice() user passing the exact number of bytes present in the pipe,
or a smaller one.

But some programs pass an arbitrary high value, and the test fails.

The effect of this bug is a lack of tcp_push() at the end of a
splice(pipe -> socket) call, and possibly very slow or erratic TCP
sessions.

We should both test sd->total_len and fact that another fragment
is in the pipe (pipe->nrbufs > 1)

Many thanks to Willy for providing very clear bug report, bisection
and test programs.

Reported-by: Willy Tarreau <w@1wt.eu>
Bisected-by: Willy Tarreau <w@1wt.eu>
Tested-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 fs/splice.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/splice.c b/fs/splice.c
index 8890604..6909d89 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -696,8 +696,10 @@ static int pipe_to_sendpage(struct pipe_inode_info *pipe,
 		return -EINVAL;
 
 	more = (sd->flags & SPLICE_F_MORE) ? MSG_MORE : 0;
-	if (sd->len < sd->total_len)
+
+	if (sd->len < sd->total_len && pipe->nrbufs > 1)
 		more |= MSG_SENDPAGE_NOTLAST;
+
 	return file->f_op->sendpage(file, buf->page, buf->offset,
 				    sd->len, &pos, more);
 }
