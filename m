From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 5/6] net: Generic resolver backend
Date: Wed, 14 Sep 2016 12:56:11 -0700
Message-ID: <CALx6S356PRaqCP=ZwceyqSgSg4vR8zthTnPTvsn3ZVMm6vmetg@mail.gmail.com>
References: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
 <1473463197-3076903-6-git-send-email-tom@herbertland.com> <20160914094911.GE11841@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36724 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755879AbcINT4M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 15:56:12 -0400
Received: by mail-qk0-f195.google.com with SMTP id z143so1819112qka.3
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:56:12 -0700 (PDT)
In-Reply-To: <20160914094911.GE11841@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 2:49 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/09/16 at 04:19pm, Tom Herbert wrote:
>> diff --git a/net/core/resolver.c b/net/core/resolver.c
>> new file mode 100644
>> index 0000000..61b36c5
>> --- /dev/null
>> +++ b/net/core/resolver.c
>> @@ -0,0 +1,267 @@
>> +#include <linux/errno.h>
>> +#include <linux/ip.h>
>> +#include <linux/kernel.h>
>> +#include <linux/module.h>
>> +#include <linux/netlink.h>
>> +#include <linux/skbuff.h>
>> +#include <linux/socket.h>
>> +#include <linux/types.h>
>> +#include <linux/vmalloc.h>
>> +#include <net/checksum.h>
>> +#include <net/ip.h>
>> +#include <net/ip6_fib.h>
>> +#include <net/lwtunnel.h>
>> +#include <net/protocol.h>
>> +#include <net/resolver.h>
>> +#include <uapi/linux/ila.h>
>
> This include list could be stripped down a bit. ila, lwt, fib, ...
>
>> +
>> +static struct net_rslv_ent *net_rslv_new_ent(struct net_rslv *nrslv,
>> +                                          void *key)
>
> Comment above that net_rslv_get_lock() must be held?
>
>> +{
>> +     struct net_rslv_ent *nrent;
>> +     int err;
>> +
>> +     nrent = kzalloc(sizeof(*nrent) + nrslv->obj_size, GFP_KERNEL);
>
> GFP_ATOMIC since you typically hold net_rslv_get_lock() spinlock?
>
>> +     if (!nrent)
>> +             return ERR_PTR(-EAGAIN);
>> +
>> +     /* Key is always at beginning of object data */
>> +     memcpy(nrent->object, key, nrslv->params.key_len);
>> +
>> +     /* Initialize user data */
>> +     if (nrslv->rslv_init)
>> +             nrslv->rslv_init(nrslv, nrent);
>> +
>> +     /* Put in hash table */
>> +     err = rhashtable_lookup_insert_fast(&nrslv->rhash_table,
>> +                                         &nrent->node, nrslv->params);
>> +     if (err)
>> +             return ERR_PTR(err);
>> +
>> +     if (nrslv->timeout) {
>> +             /* Schedule timeout for resolver */
>> +             INIT_DELAYED_WORK(&nrent->timeout_work, net_rslv_delayed_work);
>
> Should this be done before inserting into rhashtable?
>
Adding to the table and setting delayed work are done under a lock so
I think it should be okay. I'll add a comment to the function that the
lock is held.

>> +             schedule_delayed_work(&nrent->timeout_work, nrslv->timeout);
>> +     }
>> +
>> +     nrent->nrslv = nrslv;
>
> Same here.  net_rslv_cancel_all_delayed_work() walking the rhashtable could
> see ->nrslv as NULL.

I'll move it up, but net_rslv_cancel_all_delayed_work is only called
when we're destroying the table so it would be a bug in the higher
layer if it is both destroying the table and adding entries at the
same time.

Thanks,
Tom


>
