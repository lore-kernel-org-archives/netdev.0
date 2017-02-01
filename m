From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Wed, 1 Feb 2017 12:51:46 -0800
Message-ID: <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
 <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
 <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com> <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35523 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdBAUwI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 15:52:08 -0500
In-Reply-To: <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 7:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-01-30 at 22:19 -0800, Cong Wang wrote:
>
>>
>> The context is process context (TX path before hitting qdisc), and
>> BH is not disabled, so in_interrupt() doesn't catch it. Hmm, this
>> makes me thinking maybe we really need to disable BH in this
>> case for nf_hook()? But it is called in RX path too, and BH is
>> already disabled there.
>
> ipt_do_table() and similar netfilter entry points disable BH.
>
> Maybe it is done too late.

I think we need a fix like the following one for minimum impact.

diff --git a/net/core/dev.c b/net/core/dev.c
index 727b6fd..eee7d63 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1720,12 +1720,10 @@ EXPORT_SYMBOL(net_enable_timestamp);
 void net_disable_timestamp(void)
 {
 #ifdef HAVE_JUMP_LABEL
-       if (in_interrupt()) {
-               atomic_inc(&netstamp_needed_deferred);
-               return;
-       }
-#endif
+       atomic_inc(&netstamp_needed_deferred);
+#else
        static_key_slow_dec(&netstamp_needed);
+#endif
 }
 EXPORT_SYMBOL(net_disable_timestamp);
