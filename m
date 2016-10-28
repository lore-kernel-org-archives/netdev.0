From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH 2/3] net: Refactor removal of
 queues from XPS map and apply on num_tc changes
Date: Fri, 28 Oct 2016 07:54:06 -0700
Message-ID: <CAKgT0UfWUYLb5RfPUxJGcXTraW53kEE8vrvipifU7CYJ3utOgg@mail.gmail.com>
References: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
 <20161027154009.13989.25522.stgit@ahduyck-blue-test.jf.intel.com> <CALx6S36OgqbtkUp76Mf23C7Xn7EnqPN_Ybyjz-60jn7gE=94pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33834 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754431AbcJ1OyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 10:54:08 -0400
Received: by mail-oi0-f67.google.com with SMTP id 62so433380oif.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 07:54:07 -0700 (PDT)
In-Reply-To: <CALx6S36OgqbtkUp76Mf23C7Xn7EnqPN_Ybyjz-60jn7gE=94pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 7:35 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Oct 27, 2016 at 8:40 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> This patch updates the code for removing queues from the XPS map and makes
>> it so that we can apply the code any time we change either the number of
>> traffic classes or the mapping of a given block of queues.  This way we
>> avoid having queues pulling traffic from a foreign traffic class.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  net/core/dev.c |   79 ++++++++++++++++++++++++++++++++++++++++----------------
>>  1 file changed, 56 insertions(+), 23 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index d4d45bf..d124081 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1953,32 +1953,56 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
>>  #define xmap_dereference(P)            \
>>         rcu_dereference_protected((P), lockdep_is_held(&xps_map_mutex))
>>
>> -static struct xps_map *remove_xps_queue(struct xps_dev_maps *dev_maps,
>> -                                       int cpu, u16 index)
>> +static bool remove_xps_queue(struct xps_dev_maps *dev_maps,
>> +                            int tci, u16 index)
>>  {
>>         struct xps_map *map = NULL;
>>         int pos;
>>
>>         if (dev_maps)
>> -               map = xmap_dereference(dev_maps->cpu_map[cpu]);
>> +               map = xmap_dereference(dev_maps->cpu_map[tci]);
>> +       if (!map)
>> +               return false;
>>
>> -       for (pos = 0; map && pos < map->len; pos++) {
>> -               if (map->queues[pos] == index) {
>> -                       if (map->len > 1) {
>> -                               map->queues[pos] = map->queues[--map->len];
>> -                       } else {
>> -                               RCU_INIT_POINTER(dev_maps->cpu_map[cpu], NULL);
>> -                               kfree_rcu(map, rcu);
>> -                               map = NULL;
>> -                       }
>> +       for (pos = map->len; pos--;) {
>> +               if (map->queues[pos] != index)
>> +                       continue;
>> +
>> +               if (map->len > 1) {
>> +                       map->queues[pos] = map->queues[--map->len];
>>                         break;
>>                 }
>> +
>> +               RCU_INIT_POINTER(dev_maps->cpu_map[tci], NULL);
>> +               kfree_rcu(map, rcu);
>> +               return false;
>>         }
>>
>> -       return map;
>> +       return true;
>>  }
>>
>> -static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
>> +static bool remove_xps_queue_cpu(struct net_device *dev,
>> +                                struct xps_dev_maps *dev_maps,
>> +                                int cpu, u16 offset, u16 count)
>> +{
>> +       bool active = false;
>> +       int i;
>> +
>> +       count += offset;
>> +       i = count;
>> +
>> +       do {
>> +               if (i-- == offset) {
>> +                       active = true;
>> +                       break;
>> +               }
>> +       } while (remove_xps_queue(dev_maps, cpu, i));
>> +
> IMO do/while's are hard to read. Does something like this work:
>
> static bool remove_xps_queue_cpu(struct net_device *dev,
>                                 struct xps_dev_maps *dev_maps,
>                                 int cpu, u16 offset, u16 count)
> {
>      int i;
>
>      for (i = count + offset; i > offset; i--)
>           if (!remove_xps_queue(dev_maps, cpu, i - 1))
>               break;
>
>      return (i == offset);
> }

I can flip the do/while back to a for loop.  That shouldn't be too big
of a deal, although I might see if I could convert the loop to do a
pre-decrement instead of a post-decrement.  Then I could just check
for (i - offset) < 0.

>> +       return active;
>> +}
>> +
>> +static void netif_reset_xps_queues(struct net_device *dev, u16 offset,
>> +                                  u16 count)
>>  {
>>         struct xps_dev_maps *dev_maps;
>>         int cpu, i;
>> @@ -1990,21 +2014,16 @@ static void netif_reset_xps_queues_gt(struct net_device *dev, u16 index)
>>         if (!dev_maps)
>>                 goto out_no_maps;
>>
>> -       for_each_possible_cpu(cpu) {
>> -               for (i = index; i < dev->num_tx_queues; i++) {
>> -                       if (!remove_xps_queue(dev_maps, cpu, i))
>> -                               break;
>> -               }
>> -               if (i == dev->num_tx_queues)
>> -                       active = true;
>> -       }
>> +       for_each_possible_cpu(cpu)
>> +               active |= remove_xps_queue_cpu(dev, dev_maps, cpu, offset,
>> +                                              count);
>
> Maybe just do dumb "if (remove_xps...) active = true;"

I prefer the |= for a loop where the initial value is false and we are
looping and setting it to true on a given condition, especially when
the given condition is a Boolean value.  It results in faster and
smaller code using the |= since it is literally just an OR operation
instead of having to do a TEST/JMP/MOV combination.
