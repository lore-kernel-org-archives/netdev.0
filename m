From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: possible memory leak in ipc
Date: Fri, 26 Aug 2016 10:04:35 -0700
Message-ID: <CAM_iQpXFXwfrn7+FK1MrfmqHf1LzsNTCWSLnH7P6ZngSi=TvqA@mail.gmail.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
 <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
 <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com>
 <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
 <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
 <364510660.2709914.1472225156558.JavaMail.zimbra@redhat.com>
 <CANn89iJ606XRvmUhiODgXY5240ffBsak_6-rhZsnQhRyLFD4MA@mail.gmail.com> <CAM_iQpUEqg64k8tiodOYgje1bQJY7Y6gyvQr9Zp6EoOPubxVXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: CAI Qian <caiqian@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36137 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754833AbcHZRE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 13:04:57 -0400
Received: by mail-wm0-f47.google.com with SMTP id q128so892710wma.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 10:04:56 -0700 (PDT)
In-Reply-To: <CAM_iQpUEqg64k8tiodOYgje1bQJY7Y6gyvQr9Zp6EoOPubxVXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 10:00 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Aug 26, 2016 at 8:41 AM, Eric Dumazet <edumazet@google.com> wrote:
>>
>> There is a trivial bug in alloc_bucket_locks()
>> I will send a patch.
>
>
> Yeah, the 'else' branch looks so suspicious. ;)

It was correct until...

commit 4cf0b354d92ee2c642532ee39e330f8f580fd985
Author: Florian Westphal <fw@strlen.de>
Date:   Fri Aug 12 12:03:52 2016 +0200

    rhashtable: avoid large lock-array allocations


which is:

@@ -83,6 +83,9 @@ static int alloc_bucket_locks(struct rhashtable *ht,
struct bucket_table *tbl,
                        tbl->locks = vmalloc(size * sizeof(spinlock_t));
                else
 #endif
+               if (gfp != GFP_KERNEL)
+                       gfp |= __GFP_NOWARN | __GFP_NORETRY;
+
                tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
                                           gfp);
