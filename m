From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in skb_array_produce
Date: Thu, 9 Feb 2017 11:49:30 +0100
Message-ID: <CACT4Y+ZVS_SvUarbvk4aeXkJvFCCfgozq5DzHYLcfbjMN4aTtg@mail.gmail.com>
References: <CACT4Y+bs15VR7xjeYhece+0_X5Ss+5FM0w6jpJH0Dbbdu-+qCQ@mail.gmail.com>
 <50038580.20299907.1486634551103.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:33558 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbdBIK5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 05:57:14 -0500
Received: by mail-ua0-f182.google.com with SMTP id i68so36501uad.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 02:57:13 -0800 (PST)
In-Reply-To: <50038580.20299907.1486634551103.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 11:02 AM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> ----- Original Message -----
>> Hello,
>>
>> I've got the following report while running syzkaller fuzzer on mmotm
>> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
>> remotes/mmotm/auto-latest ee4ba7533626ba7bf2f8b992266467ac9fdc045e:
>>
>
> [...]
>
>>
>> other info that might help us debug this:
>>
>>  Possible interrupt unsafe locking scenario:
>>
>>        CPU0                    CPU1
>>        ----                    ----
>>   lock(&(&r->consumer_lock)->rlock);
>>                                local_irq_disable();
>>                                lock(&(&r->producer_lock)->rlock);
>>                                lock(&(&r->consumer_lock)->rlock);
>>   <Interrupt>
>>     lock(&(&r->producer_lock)->rlock);
>>
>
> Thanks a lot for the testing.
>
> Looks like we could address this by using skb_array_consume_bh() instead.
>
> Could you pls verify if the following patch works?

No, I can't test it, sorry. This happened once on bots. And bots
currently test only upstream versions.


> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8a7d6b9..a97c00d 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -520,7 +520,7 @@ static void tun_queue_purge(struct tun_file *tfile)
>  {
>         struct sk_buff *skb;
>
> -       while ((skb = skb_array_consume(&tfile->tx_array)) != NULL)
> +       while ((skb = skb_array_consume_bh(&tfile->tx_array)) != NULL)
>                 kfree_skb(skb);
>
>         skb_queue_purge(&tfile->sk.sk_write_queue);
> @@ -1458,7 +1458,7 @@ static struct sk_buff *tun_ring_recv(struct tun_file *tfile, int noblock,
>         struct sk_buff *skb = NULL;
>         int error = 0;
>
> -       skb = skb_array_consume(&tfile->tx_array);
> +       skb = skb_array_consume_bh(&tfile->tx_array);
>         if (skb)
>                 goto out;
>         if (noblock) {
> @@ -1470,7 +1470,7 @@ static struct sk_buff *tun_ring_recv(struct tun_file *tfile, int noblock,
>         current->state = TASK_INTERRUPTIBLE;
>
>         while (1) {
> -               skb = skb_array_consume(&tfile->tx_array);
> +               skb = skb_array_consume_bh(&tfile->tx_array);
>                 if (skb)
>                         break;
>                 if (signal_pending(current)) {
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
