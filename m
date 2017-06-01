From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: commit f5f99309 (sock: do not set sk_err in sock_dequeue_err_skb)
 has broken ping
Date: Thu, 1 Jun 2017 10:39:26 -0400
Message-ID: <CACSApvbKwbX2u16V1oQfmHC7SvGZgk-KehA9tashjQAtj0bB0Q@mail.gmail.com>
References: <20170601140048.GA24401@rei.lan> <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
 <20170601143141.GB24401@rei.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Yaogong Wang <wygivan@google.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Cyril Hrubis <chrubis@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:34902 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFAOkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 10:40:08 -0400
Received: by mail-it0-f50.google.com with SMTP id f72so40150692ite.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 07:40:08 -0700 (PDT)
In-Reply-To: <20170601143141.GB24401@rei.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 10:31 AM, Cyril Hrubis <chrubis@suse.cz> wrote:
> I've started bisecting on v4.11 and see the problem on v4.10 on another
> machine, the patch should be there in both cases and the bug is easily
> reproducible.

Thank you for the confirmation. Could you please try the following
patch to see if it fixes your issue?

>From 3ec438460425d127741b20f03f78644c9e441e8c Mon Sep 17 00:00:00 2001
From: Soheil Hassas Yeganeh <soheil@google.com>
Date: Thu, 1 Jun 2017 10:34:09 -0400
Subject: [PATCH net] sock: reset sk_err when the error queue is empty

Before f5f99309fa74 (sock: do not set sk_err in
sock_dequeue_err_skb), sk_err was reset to 0 upon reading
from the error queue when the error queue was empty.

Applications, most notably ping, are relying on this
behavior to reset sk_err.

Reset sk_err when there is no packet left on the
error queue.

Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
Reported-by: Cyril Hrubis <chrubis@suse.cz>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 346d3e85dfbc..5a726161f4e4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3758,7 +3758,7 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
  icmp_next = is_icmp_err_skb(skb_next);
  spin_unlock_irqrestore(&q->lock, flags);

- if (is_icmp_err_skb(skb) && !icmp_next)
+ if ((is_icmp_err_skb(skb) && !icmp_next) || !skb_next)
  sk->sk_err = 0;

  if (skb_next)
-- 
2.13.0.219.gdb65acc882-goog


>> 2. I've also have sent a fix to iputils on
>> https://github.com/iputils/iputils/pull/75. Would you be kind to try
>> that pull request as well?
>
> That fixed the problem, you can add:
>
> Tested-by: Cyril Hrubis <chrubis@suse.cz>

Thank you for testing! Will do.
