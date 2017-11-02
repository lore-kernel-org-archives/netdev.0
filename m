From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH 01/14] packet: introduce AF_PACKET V4 userspace API
Date: Thu, 2 Nov 2017 10:45:43 +0900
Message-ID: <CAF=yD-Jr-w-E3r9BySYmcfH+zaWSrGMXaL4-MoPZqnMB20YDQA@mail.gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com> <20171031124145.9667-2-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: magnus.karlsson@intel.com,
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
To: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:47524 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdKBBqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 21:46:24 -0400
Received: by mail-oi0-f67.google.com with SMTP id h200so7177201oib.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 18:46:23 -0700 (PDT)
In-Reply-To: <20171031124145.9667-2-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 9:41 PM, Bj=C3=B6rn T=C3=B6pel <bjorn.topel@gmail.c=
om> wrote:
> From: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>
> This patch adds the necessary AF_PACKET V4 structures for usage from
> userspace. AF_PACKET V4 is a new interface optimized for high
> performance packet processing.
>
> Signed-off-by: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
> ---
>  include/uapi/linux/if_packet.h | 65 ++++++++++++++++++++++++++++++++++++=
+++++-
>  1 file changed, 64 insertions(+), 1 deletion(-)
>
> +struct tpacket4_queue {
> +       struct tpacket4_desc *ring;
> +
> +       unsigned int avail_idx;
> +       unsigned int last_used_idx;
> +       unsigned int num_free;
> +       unsigned int ring_mask;
> +};
>
>  struct packet_mreq {
> @@ -294,6 +335,28 @@ struct packet_mreq {
>         unsigned char   mr_address[8];
>  };
>
> +/*
> + * struct tpacket_memreg_req is used in conjunction with PACKET_MEMREG
> + * to register user memory which should be used to store the packet
> + * data.
> + *
> + * There are some constraints for the memory being registered:
> + * - The memory area has to be memory page size aligned.
> + * - The frame size has to be a power of 2.
> + * - The frame size cannot be smaller than 2048B.
> + * - The frame size cannot be larger than the memory page size.
> + *
> + * Corollary: The number of frames that can be stored is
> + * len / frame_size.
> + *
> + */
> +struct tpacket_memreg_req {
> +       unsigned long   addr;           /* Start of packet data area */
> +       unsigned long   len;            /* Length of packet data area */
> +       unsigned int    frame_size;     /* Frame size */
> +       unsigned int    data_headroom;  /* Frame head room */
> +};

Existing packet sockets take a tpacket_req, allocate memory and let the
user process mmap this. I understand that TPACKET_V4 distinguishes
the descriptor from packet pools, but could both use the existing structs
and logic (packet_mmap)? That would avoid introducing a lot of new code
just for granting user pages to the kernel.

Also, use of unsigned long can cause problems on 32/64 bit compat
environments. Prefer fixed width types in uapi. Same for pointer in
tpacket4_queue.
