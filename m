From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: transmit napi
Date: Mon, 3 Apr 2017 01:07:49 -0400
Message-ID: <CAF=yD-+5+X6UBYaX=Dh3M3caty0fJ7cjamTfX0=_+Lwx6r_VQw@mail.gmail.com>
References: <20170402201012.76473-1-willemdebruijn.kernel@gmail.com>
 <20170402201012.76473-3-willemdebruijn.kernel@gmail.com> <20170403052938-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33829 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdDCFIa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 01:08:30 -0400
Received: by mail-qk0-f195.google.com with SMTP id 10so17965759qkh.1
        for <netdev@vger.kernel.org>; Sun, 02 Apr 2017 22:08:30 -0700 (PDT)
In-Reply-To: <20170403052938-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 2, 2017 at 10:30 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Sun, Apr 02, 2017 at 04:10:11PM -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Convert virtio-net to a standard napi tx completion path. This enables
>> better TCP pacing using TCP small queues and increases single stream
>> throughput.
>>
>> The virtio-net driver currently cleans tx descriptors on transmission
>> of new packets in ndo_start_xmit. Latency depends on new traffic, so
>> is unbounded. To avoid deadlock when a socket reaches its snd limit,
>> packets are orphaned on tranmission. This breaks socket backpressure,
>> including TSQ.
>>
>> Napi increases the number of interrupts generated compared to the
>> current model, which keeps interrupts disabled as long as the ring
>> has enough free descriptors. Keep tx napi optional for now. Follow-on
>> patches will reduce the interrupt cost.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/net/virtio_net.c | 63 ++++++++++++++++++++++++++++++++++++++++--------
>>  1 file changed, 53 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 6aac0ad0d9b2..95d938e82080 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -33,9 +33,10 @@
>>  static int napi_weight = NAPI_POLL_WEIGHT;
>>  module_param(napi_weight, int, 0444);
>>
>> -static bool csum = true, gso = true;
>> +static bool csum = true, gso = true, napi_tx = true;
>>  module_param(csum, bool, 0444);
>>  module_param(gso, bool, 0444);
>> +module_param(napi_tx, bool, 0644);
>>
>>  /* FIXME: MTU in config. */
>>  #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
>
> Off by default seems safer until we can find better ways
> to reduce the overhead, esp for UDP.

Okay, I'll change that. I don't have an immediate idea for that
unidirectional case.
