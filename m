From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Mon, 6 Feb 2017 15:45:38 +0800
Message-ID: <c9042cd9-c8aa-5569-4396-edd1f86bdca8@redhat.com>
References: <20170203061905.100283-1-serebrin@google.com>
 <6af5d025-4b94-e3e2-1a98-efde69ec8be9@redhat.com>
 <CAN+hb0UScuWow6YsaG-kd21ZdUeZrbs1vq36ov8x2_RXHHQKRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        James Mattson <jmattson@google.com>
To: Benjamin Serebrin <serebrin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61526 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750879AbdBFHpq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 02:45:46 -0500
In-Reply-To: <CAN+hb0UScuWow6YsaG-kd21ZdUeZrbs1vq36ov8x2_RXHHQKRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月06日 15:28, Benjamin Serebrin wrote:
> On Sun, Feb 5, 2017 at 11:24 PM, Jason Wang<jasowang@redhat.com>  wrote:
>> On 2017年02月03日 14:19, Ben Serebrin wrote:
>>> From: Benjamin Serebrin<serebrin@google.com>
>>>
>>> If the number of virtio queue pairs is not equal to the
>>> number of VCPUs, the virtio guest driver doesn't assign
>>> any CPU affinity for the queue interrupts or the xps
>>> aggregation interrupt.
>> So this in fact is not a affinity fixing for #cpus > 32 but adding  affinity
>> for #cpus != #queue pairs.
> Fair enough.  I'll adjust the title line in the subsequent version.
>
>
>>> Google Compute Engine currently provides 1 queue pair for
>>> every VCPU, but limits that at a maximum of 32 queue pairs.
>>>
>>> This code assigns interrupt affinity even when there are more than
>>> 32 VCPUs.
>>>
>>> Tested:
>>>
>>> (on a 64-VCPU VM with debian 8, jessie-backports 4.9.2)
>>>
>>> Without the fix we see all queues affinitized to all CPUs:
>> [...]
>>
>>>    +     /* If there are more cpus than queues, then assign the queues'
>>> +        * interrupts to the first cpus until we run out.
>>> +        */
>>>          i = 0;
>>>          for_each_online_cpu(cpu) {
>>> +               if (i == vi->max_queue_pairs)
>>> +                       break;
>>>                  virtqueue_set_affinity(vi->rq[i].vq, cpu);
>>>                  virtqueue_set_affinity(vi->sq[i].vq, cpu);
>>> -               netif_set_xps_queue(vi->dev, cpumask_of(cpu), i);
>>>                  i++;
>>>          }
>>>    +     /* Stripe the XPS affinities across the online CPUs.
>>> +        * Hyperthread pairs are typically assigned such that Linux's
>>> +        * CPU X and X + (numcpus / 2) are hyperthread twins, so we cause
>>> +        * hyperthread twins to share TX queues, in the case where there
>>> are
>>> +        * more cpus than queues.
>> Since we use combined queue pairs, why not use the same policy for RX?
> XPS is for transmit only.
>
>

Yes, but I mean, e.g consider you let hyperthread twins to share TX 
queues (XPS), why not share TX and RX queue interrupts (affinity)?

Thanks
