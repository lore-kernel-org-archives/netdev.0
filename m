From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH] tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 1 Dec 2016 10:39:46 +0100
Message-ID: <CAAeHK+xuoz6h8iF-PEDcf4QcSPYCZE424HymCZHsDHMrmCRdOQ@mail.gmail.com>
References: <1480433136-7922-1-git-send-email-andreyknvl@google.com> <20161129181631-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Jason Wang <jasowang@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129181631-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 5:20 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Nov 29, 2016 at 04:25:36PM +0100, Andrey Konovalov wrote:
>> This patch changes tun.c to call netif_receive_skb instead of netif_rx
>> when a packet is received. The difference between the two is that netif_rx
>> queues the packet into the backlog, and netif_receive_skb proccesses the
>> packet in the current context.
>>
>> This patch is required for syzkaller [1] to collect coverage from packet
>> receive paths, when a packet being received through tun (syzkaller collects
>> coverage per process in the process context).
>>
>> A similar patch was introduced back in 2010 [2, 3], but the author found
>> out that the patch doesn't help with the task he had in mind (for cgroups
>> to shape network traffic based on the original process) and decided not to
>> go further with it. The main concern back then was about possible stack
>> exhaustion with 4K stacks, but CONFIG_4KSTACKS was removed and stacks are
>> 8K now.
>>
>> [1] https://github.com/google/syzkaller
>>
>> [2] https://www.spinics.net/lists/netdev/thrd440.html#130570
>>
>> [3] https://www.spinics.net/lists/netdev/msg130570.html
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>
> This was on my list of things to investigate ever since
> 8k stack default went in. Thanks for looking into this!
>
> I note that there are still seem to exit 3 architectures that do have
> CONFIG_4KSTACKS.

Hi Michael,

Missed that, mailed v2.

Thanks!

>
> How about a wrapper that does netif_rx_ni with CONFIG_4KSTACKS.
>
>
>> ---
>>  drivers/net/tun.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 8093e39..4b56e91 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1304,7 +1304,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>>       skb_probe_transport_header(skb, 0);
>>
>>       rxhash = skb_get_hash(skb);
>> -     netif_rx_ni(skb);
>> +     local_bh_disable();
>> +     netif_receive_skb(skb);
>> +     local_bh_enable();
>>
>>       stats = get_cpu_ptr(tun->pcpu_stats);
>>       u64_stats_update_begin(&stats->syncp);
>> --
>> 2.8.0.rc3.226.g39d4020
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
