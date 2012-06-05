From: Hong zhi guo <honkiko@gmail.com>
Subject: Re: [PATCH] macvtap: use set_curren_state to ensure mb
Date: Tue, 5 Jun 2012 20:05:34 +0800
Message-ID: <CAA7+ByUH8LsSrbetHngEZmaHkvK5aUO5v7-F=+wbveo6q68f-g@mail.gmail.com>
References: <CAA7+ByX7Kp+Zh3ZQ2D6rSuhu6WCeqL-1MgDi9gy-0hHizVXncg@mail.gmail.com>
	<1338894329.2760.2318.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, arnd@arndb.de,
	zhiguo.hong@nsn.com, vikifang@juniper.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:40105 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090Ab2FEMFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 08:05:35 -0400
Received: by wgbdr13 with SMTP id dr13so5063202wgb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 05:05:34 -0700 (PDT)
In-Reply-To: <1338894329.2760.2318.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 5, 2012 at 7:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Why not using the more standard :
>
> prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
>
> and
>
> finish_wait(sk_sleep(sk), &wait);
>

Thanks for your comments.  The difference is that prepare_to_wait
inside loop introduces extra "list_empty" judgement than original
patch. But personally I prefer the newer version too:

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/net/macvtap.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 2ee56de..0737bd4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -847,13 +847,12 @@ static ssize_t macvtap_do_read(struct
macvtap_queue *q, struct kiocb *iocb,
 			       const struct iovec *iv, unsigned long len,
 			       int noblock)
 {
-	DECLARE_WAITQUEUE(wait, current);
+	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
 	ssize_t ret = 0;

-	add_wait_queue(sk_sleep(&q->sk), &wait);
 	while (len) {
-		current->state = TASK_INTERRUPTIBLE;
+		prepare_to_wait(sk_sleep(&q->sk), &wait, TASK_INTERRUPTIBLE);

 		/* Read frames from the queue */
 		skb = skb_dequeue(&q->sk.sk_receive_queue);
@@ -875,8 +874,7 @@ static ssize_t macvtap_do_read(struct
macvtap_queue *q, struct kiocb *iocb,
 		break;
 	}

-	current->state = TASK_RUNNING;
-	remove_wait_queue(sk_sleep(&q->sk), &wait);
+	finish_wait(sk_sleep(&q->sk), &wait);
 	return ret;
 }

-- 
1.7.4.1
