From: Benjamin Serebrin <serebrin@google.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Sun, 5 Feb 2017 23:28:09 -0800
Message-ID: <CAN+hb0UScuWow6YsaG-kd21ZdUeZrbs1vq36ov8x2_RXHHQKRA@mail.gmail.com>
References: <20170203061905.100283-1-serebrin@google.com> <6af5d025-4b94-e3e2-1a98-efde69ec8be9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        James Mattson <jmattson@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38668 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdBFH2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 02:28:11 -0500
Received: by mail-wm0-f44.google.com with SMTP id r141so101728258wmg.1
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 23:28:11 -0800 (PST)
In-Reply-To: <6af5d025-4b94-e3e2-1a98-efde69ec8be9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 5, 2017 at 11:24 PM, Jason Wang <jasowang@redhat.com> wrote:
>
>
> On 2017=E5=B9=B402=E6=9C=8803=E6=97=A5 14:19, Ben Serebrin wrote:
>>
>> From: Benjamin Serebrin <serebrin@google.com>
>>
>> If the number of virtio queue pairs is not equal to the
>> number of VCPUs, the virtio guest driver doesn't assign
>> any CPU affinity for the queue interrupts or the xps
>> aggregation interrupt.
>
>
> So this in fact is not a affinity fixing for #cpus > 32 but adding  affin=
ity
> for #cpus !=3D #queue pairs.

Fair enough.  I'll adjust the title line in the subsequent version.


>
>> Google Compute Engine currently provides 1 queue pair for
>> every VCPU, but limits that at a maximum of 32 queue pairs.
>>
>> This code assigns interrupt affinity even when there are more than
>> 32 VCPUs.
>>
>> Tested:
>>
>> (on a 64-VCPU VM with debian 8, jessie-backports 4.9.2)
>>
>> Without the fix we see all queues affinitized to all CPUs:
>
>
> [...]
>
>>   +     /* If there are more cpus than queues, then assign the queues'
>> +        * interrupts to the first cpus until we run out.
>> +        */
>>         i =3D 0;
>>         for_each_online_cpu(cpu) {
>> +               if (i =3D=3D vi->max_queue_pairs)
>> +                       break;
>>                 virtqueue_set_affinity(vi->rq[i].vq, cpu);
>>                 virtqueue_set_affinity(vi->sq[i].vq, cpu);
>> -               netif_set_xps_queue(vi->dev, cpumask_of(cpu), i);
>>                 i++;
>>         }
>>   +     /* Stripe the XPS affinities across the online CPUs.
>> +        * Hyperthread pairs are typically assigned such that Linux's
>> +        * CPU X and X + (numcpus / 2) are hyperthread twins, so we caus=
e
>> +        * hyperthread twins to share TX queues, in the case where there
>> are
>> +        * more cpus than queues.
>
>
> Since we use combined queue pairs, why not use the same policy for RX?

XPS is for transmit only.


> Thanks
>
>
>> +        */
>> +       for (i =3D 0; i < vi->max_queue_pairs; i++) {
>> +               struct cpumask mask;
>> +               int skip =3D i;
>> +
>> +               cpumask_clear(&mask);
>> +               for_each_online_cpu(cpu) {
>> +                       while (skip--)
>> +                               cpu =3D cpumask_next(cpu, cpu_online_mas=
k);
>> +                       if (cpu < num_possible_cpus())
>> +                               cpumask_set_cpu(cpu, &mask);
>> +                       skip =3D vi->max_queue_pairs - 1;
>> +               }
>> +               netif_set_xps_queue(vi->dev, &mask, i);
>> +       }
>> +
>>         vi->affinity_hint_set =3D true;
>>   }
>>
>
>
