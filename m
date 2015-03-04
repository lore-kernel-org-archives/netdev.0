From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 6/7] fib: hook IPv4 fib for hardware offload
Date: Tue, 3 Mar 2015 19:16:49 -0800
Message-ID: <CAE4R7bBhWZSmmzbs+vZOG69EJu=HgzXHr9HxY1hcE2D-J3AQ1w@mail.gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
	<1425425520-34017-7-git-send-email-sfeldma@gmail.com>
	<54F64B48.8040707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:44164 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756036AbbCDDQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 22:16:50 -0500
Received: by mail-qa0-f54.google.com with SMTP id v8so3229104qal.13
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 19:16:49 -0800 (PST)
In-Reply-To: <54F64B48.8040707@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 4:01 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> On 03/03/2015 03:31 PM, sfeldma@gmail.com wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Call into the switchdev driver any time an IPv4 fib entry is
>> added/modified/deleted from the kernel's FIB.  The switchdev driver may or
>> may not install the route to the offload device.  In the case where the
>> driver tries to install the route and something goes wrong (device's
>> routing
>> table is full, etc), then all of the offloaded routes will be flushed from
>> the
>> device, and route forwarding falls back to the kernel.
>>
>> We can refine this fail-over logic in subsequent patches.  For now, use
>> the
>> simplist model of offloading routes up to the point of failure, and then
>> on
>> failure, undo everything.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>>   net/ipv4/fib_trie.c |   36 +++++++++++++++++++++++++++++++++---
>>   1 file changed, 33 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> index 32c0117..668f09b 100644
>> --- a/net/ipv4/fib_trie.c
>> +++ b/net/ipv4/fib_trie.c
>> @@ -79,6 +79,7 @@
>>   #include <net/tcp.h>
>>   #include <net/sock.h>
>>   #include <net/ip_fib.h>
>> +#include <net/switchdev.h>
>>   #include "fib_lookup.h"
>>     #define MAX_STAT_DEPTH 32
>> @@ -1161,7 +1162,18 @@ int fib_table_insert(struct fib_table *tb, struct
>> fib_config *cfg)
>>                         new_fa->fa_state = state & ~FA_S_ACCESSED;
>>                         new_fa->fa_slen = fa->fa_slen;
>>   +                     err = netdev_switch_fib_ipv4_add(key, plen, fi,
>> +                                                        new_fa->fa_tos,
>> +                                                        cfg->fc_type,
>> +                                                        tb->tb_id);
>> +                       if (err) {
>> +                               fib_flush_external(fi->fib_net);
>> +                               kmem_cache_free(fn_alias_kmem, new_fa);
>> +                               goto out;
>> +                       }
>> +
>>                         hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
>> +
>>                         alias_free_mem_rcu(fa);
>>                         fib_release_info(fi_drop);
>> @@ -1197,12 +1209,20 @@ int fib_table_insert(struct fib_table *tb, struct
>> fib_config *cfg)
>>         new_fa->fa_state = 0;
>>         new_fa->fa_slen = slen;
>>   +     /* (Optionally) offload fib entry to switch hardware. */
>> +       err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
>> +                                        cfg->fc_type, tb->tb_id);
>> +       if (err) {
>> +               fib_flush_external(fi->fib_net);
>> +               goto out_free_new_fa;
>> +       }
>> +
>>         /* Insert new entry to the list. */
>>         if (!l) {
>>                 l = fib_insert_node(t, key, plen);
>>                 if (unlikely(!l)) {
>>                         err = -ENOMEM;
>> -                       goto out_free_new_fa;
>> +                       goto out_sw_fib_del;
>>                 }
>>         }
>>
>
>
> Wouldn't it make more sense to insert the route in the trie first, and then
> notify the hardware of the new route?  It seems like it would be much easier
> to pull the route back out of the trie on failure rather than having to
> delete a route from the hardware on a failure to allocate memory to store

6 one way half a dozen the other.  At one point I wanted return code
from hw install to indicate if route is installed to kernel FIB, so I
needed to try hw install first.  Now we've simplified the logic, so
order could be reversed.  Maybe lets keep it the way it is so we can
fancy with hw install return code later.
