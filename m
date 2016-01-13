From: David Miller <davem@davemloft.net>
Subject: Re: memory leak in lapb_create_cb
Date: Wed, 13 Jan 2016 11:46:34 -0500 (EST)
Message-ID: <20160113.114634.1483349324408375191.davem@davemloft.net>
References: <CACT4Y+b59Ct8YXezM+HKGDfrV9YYLcB=Hi1YNNpe41JMQRAoFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peter@hurleysoftware.com,
	gregkh@linuxfoundation.org, jslaby@suse.com,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com
To: dvyukov@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b59Ct8YXezM+HKGDfrV9YYLcB=Hi1YNNpe41JMQRAoFw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 30 Dec 2015 22:00:44 +0100

> The following program leads to a leak of struct lapb_cb:

I looked into this report a bit, and although I couldn't figure out
how lapb_cb could be leaked, I definitely found an x25_asy object
leak in this driver.

====================
[PATCH] x25_asy: Free x25_asy on x25_asy_open() failure.

Based upon a report by Dmitry Vyukov.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wan/x25_asy.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index cd39025..1bc5e93 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -571,8 +571,10 @@ static int x25_asy_open_tty(struct tty_struct *tty)
 
 	/* Perform the low-level X.25 async init */
 	err = x25_asy_open(sl->dev);
-	if (err)
+	if (err) {
+		x25_asy_free(sl);
 		return err;
+	}
 	/* Done.  We have linked the TTY line to a channel. */
 	return 0;
 }
-- 
2.1.0
