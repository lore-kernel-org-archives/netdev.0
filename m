From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Subject: Re: [RFC PATCH 01/14] packet: introduce AF_PACKET V4 userspace API
Date: Thu, 2 Nov 2017 11:06:38 +0100
Message-ID: <CAJ+HfNhymyDqCS8hVgMZ45c3swZXHea3nkFHYfKhr4i48bqYJg@mail.gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com> <20171031124145.9667-2-bjorn.topel@gmail.com>
 <CAF=yD-Jr-w-E3r9BySYmcfH+zaWSrGMXaL4-MoPZqnMB20YDQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Network Development <netdev@vger.kernel.org>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>,
        jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:56790 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755215AbdKBKGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 06:06:41 -0400
Received: by mail-lf0-f68.google.com with SMTP id 90so5750473lfs.13
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 03:06:40 -0700 (PDT)
In-Reply-To: <CAF=yD-Jr-w-E3r9BySYmcfH+zaWSrGMXaL4-MoPZqnMB20YDQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-11-02 02:45, Willem de Bruijn wrote:
> On Tue, Oct 31, 2017 at 9:41 PM, Bj=C3=B6rn T=C3=B6pel <bjorn.topel@gmail=
.com> wrote:
>> From: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>>
>> This patch adds the necessary AF_PACKET V4 structures for usage from
>> userspace. AF_PACKET V4 is a new interface optimized for high
>> performance packet processing.
>>
>> Signed-off-by: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>> ---
>>   include/uapi/linux/if_packet.h | 65 ++++++++++++++++++++++++++++++++++=
+++++++-
>>   1 file changed, 64 insertions(+), 1 deletion(-)
>>
>> +struct tpacket4_queue {
>> +       struct tpacket4_desc *ring;
>> +
>> +       unsigned int avail_idx;
>> +       unsigned int last_used_idx;
>> +       unsigned int num_free;
>> +       unsigned int ring_mask;
>> +};
>>
>>   struct packet_mreq {
>> @@ -294,6 +335,28 @@ struct packet_mreq {
>>          unsigned char   mr_address[8];
>>   };
>>
>> +/*
>> + * struct tpacket_memreg_req is used in conjunction with PACKET_MEMREG
>> + * to register user memory which should be used to store the packet
>> + * data.
>> + *
>> + * There are some constraints for the memory being registered:
>> + * - The memory area has to be memory page size aligned.
>> + * - The frame size has to be a power of 2.
>> + * - The frame size cannot be smaller than 2048B.
>> + * - The frame size cannot be larger than the memory page size.
>> + *
>> + * Corollary: The number of frames that can be stored is
>> + * len / frame_size.
>> + *
>> + */
>> +struct tpacket_memreg_req {
>> +       unsigned long   addr;           /* Start of packet data area */
>> +       unsigned long   len;            /* Length of packet data area */
>> +       unsigned int    frame_size;     /* Frame size */
>> +       unsigned int    data_headroom;  /* Frame head room */
>> +};
>
> Existing packet sockets take a tpacket_req, allocate memory and let the
> user process mmap this. I understand that TPACKET_V4 distinguishes
> the descriptor from packet pools, but could both use the existing structs
> and logic (packet_mmap)? That would avoid introducing a lot of new code
> just for granting user pages to the kernel.
>

We could certainly pass the "tpacket_memreg_req" fields as part of
descriptor ring setup ("tpacket_req4"), but we went with having the
memory register as a new separate setsockopt. Having it separated,
makes it easier to compare regions at the kernel side of things. "Is
this the same umem as another one?" If we go the path of passing the
range at descriptor ring setup, we need to handle all kind of
overlapping ranges to determine when a copy is needed or not, in those
cases where the packet buffer (i.e. umem) is shared between processes.

> Also, use of unsigned long can cause problems on 32/64 bit compat
> environments. Prefer fixed width types in uapi. Same for pointer in
> tpacket4_queue.

I agree; We'll change to a fixed width type in next version. Do you
(and others on the list) prefer __u32/__u64 or unsigned int / unsigned
long long?


Thanks,
Bj=C3=B6rn
