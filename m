From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] af_packet: TX_RING support for TPACKET_V3
Date: Mon, 2 Jan 2017 17:57:10 -0500
Message-ID: <CAF=yD-J2Sw0=iTuvPe-sa01Ld0D1U6f=R-99WLRKggap_WKdug@mail.gmail.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com> <bc66616d08758cfe225a4b02316b72de16e00302.1483309545.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:33515 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755556AbdABW5y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:57:54 -0500
Received: by mail-ua0-f193.google.com with SMTP id d5so24795987uag.0
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 14:57:53 -0800 (PST)
In-Reply-To: <bc66616d08758cfe225a4b02316b72de16e00302.1483309545.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 1, 2017 at 5:45 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> Although TPACKET_V3 Rx has some benefits over TPACKET_V2 Rx, *_v3
> does not currently have TX_RING support. As a result an application
> that wants the best perf for Tx and Rx (e.g. to handle request/response
> transacations) ends up needing 2 sockets, one with *_v2 for Tx and
> another with *_v3 for Rx.
>
> This patch enables TPACKET_V2 compatible Tx features in TPACKET_V3
> so that an application can use a single descriptor to get the benefits
> of _v3 RX_RING and _v2 TX_RING. An application may do a block-send by
> first filling up multiple frames in the Tx ring and then triggering a
> transmit. This patch only support fixed size Tx frames for TPACKET_V3,
> and requires that tp_next_offset must be zero.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: sanity checks on tp_next_offset and corresponding Doc updates
>     as suggested by Willem de Bruijn
>
>  Documentation/networking/packet_mmap.txt |    9 +++++++--
>  net/packet/af_packet.c                   |   27 +++++++++++++++++++--------
>  2 files changed, 26 insertions(+), 10 deletions(-)

> @@ -4180,9 +4193,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>                         goto out;
>                 switch (po->tp_version) {
>                 case TPACKET_V3:
> -               /* Transmit path is not supported. We checked
> -                * it above but just being paranoid
> -                */
> +                       /* Block transmit is not supported yet */
>                         if (!tx_ring)
>                                 init_prb_bdqc(po, rb, pg_vec, req_u);


One more point. We should validate the tpacket_req3 input and fail if
unsupported options are passed. Specifically, fail if any of
{tp_retire_blk_tov, tp_sizeof_priv, tp_feature_req_word} is non-zero.

Otherwise looks good to me.
