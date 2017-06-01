From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: commit f5f99309 (sock: do not set sk_err in sock_dequeue_err_skb)
 has broken ping
Date: Thu, 1 Jun 2017 12:42:18 -0400
Message-ID: <CACSApvb_CtFEenaSGcpUk6yb8O3X95MAULkJ-+T1hscCE_O_jg@mail.gmail.com>
References: <20170601140048.GA24401@rei.lan> <CACSApvZiQTYSVkS62YdadjabUTqwO9O2=Sq4ELuO3eoJ_LM_ZQ@mail.gmail.com>
 <20170601143141.GB24401@rei.lan> <CACSApvbKwbX2u16V1oQfmHC7SvGZgk-KehA9tashjQAtj0bB0Q@mail.gmail.com>
 <20170601151003.GB10526@rei.suse.de> <CACSApvanT0ZRFH0ZBDLqygkH6Ue_CCVQBzVL9fCmZE_BndYEog@mail.gmail.com>
 <20170601153645.GC10526@rei.suse.de>
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
Received: from mail-it0-f46.google.com ([209.85.214.46]:36974 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdFAQnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:43:05 -0400
Received: by mail-it0-f46.google.com with SMTP id m47so24092034iti.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 09:43:04 -0700 (PDT)
In-Reply-To: <20170601153645.GC10526@rei.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 11:36 AM, Cyril Hrubis <chrubis@suse.cz> wrote:
> It seems to repeatedly produce (until I plug the cable back):
>
> ee_errno = 113 ee_origin = 2 ee_type = 3 ee_code = 1 ee_info = 0 ee_data = 0
>
> So we get EHOSTUNREACH on SO_EE_ORIGIN_ICMP.

Thank you very much! I have a wild guess that, when we
have a train of skbs on the error queue starting from a local error,
we will see this issue.

Ping (without my patch) considers EAGAIN on a normal read as an
indication that there is nothing on the error queue, but that's a
flawed assumption.

Would you mind trying another shot in the darkness please? Thanks!

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5a726161f4e4..097152a03c74 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3742,7 +3742,8 @@ EXPORT_SYMBOL(sock_queue_err_skb);
 static bool is_icmp_err_skb(const struct sk_buff *skb)
 {
        return skb && (SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
-                      SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP6);
+                      SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP6 ||
+                      SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_LOCAL);
 }

 struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
@@ -3751,14 +3752,19 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
        struct sk_buff *skb, *skb_next = NULL;
        bool icmp_next = false;
        unsigned long flags;
+       int err = 0;

        spin_lock_irqsave(&q->lock, flags);
        skb = __skb_dequeue(q);
-       if (skb && (skb_next = skb_peek(q)))
+       if (skb && (skb_next = skb_peek(q))) {
                icmp_next = is_icmp_err_skb(skb_next);
+               err = SKB_EXT_ERR(skb_next)->ee.ee_origin;
+       }
        spin_unlock_irqrestore(&q->lock, flags);

-       if (is_icmp_err_skb(skb) && !icmp_next)
+       if (icmp_next)
+               sk->sk_err = err;
+       else if (is_icmp_err_skb(skb) && !icmp_next)
                sk->sk_err = 0;

        if (skb_next)
