From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net v2] sctp: fix ICMP processing if skb is non-linear
Date: Fri, 26 May 2017 15:02:17 +0800
Message-ID: <CADvbK_dTQaJ+BHbrVfq2c1kg1L6kLFbM-vdWWdYKm3YOYyxSzg@mail.gmail.com>
References: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:32795 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763463AbdEZHCT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 03:02:19 -0400
In-Reply-To: <d0cd7c2e4b9329ec23e48aed94bf2fbf94554f44.1495730857.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 26, 2017 at 1:14 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> sometimes ICMP replies to INIT chunks are ignored by the client, even if
> the encapsulated SCTP headers match an open socket. This happens when the
> ICMP packet is carried by a paged skb: use skb_header_pointer() to read
> packet contents beyond the SCTP header, so that chunk header and initiate
> tag are validated correctly.
>
> v2:
> - don't use skb_header_pointer() to read the transport header, since
>   icmp_socket_deliver() already puts these 8 bytes in the linear area.
> - change commit message to make specific reference to INIT chunks.
>
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Thanks.
Reviewed-by: Xin Long <lucien.xin@gmail.com>

> ---
>  net/sctp/input.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
>
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 0e06a27..ba9ad32 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -473,15 +473,14 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
>                              struct sctp_association **app,
>                              struct sctp_transport **tpp)
>  {
> +       struct sctp_init_chunk *chunkhdr, _chunkhdr;
>         union sctp_addr saddr;
>         union sctp_addr daddr;
>         struct sctp_af *af;
>         struct sock *sk = NULL;
>         struct sctp_association *asoc;
>         struct sctp_transport *transport = NULL;
> -       struct sctp_init_chunk *chunkhdr;
>         __u32 vtag = ntohl(sctphdr->vtag);
> -       int len = skb->len - ((void *)sctphdr - (void *)skb->data);
>
>         *app = NULL; *tpp = NULL;
>
> @@ -516,13 +515,16 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
>          * discard the packet.
>          */
>         if (vtag == 0) {
> -               chunkhdr = (void *)sctphdr + sizeof(struct sctphdr);
> -               if (len < sizeof(struct sctphdr) + sizeof(sctp_chunkhdr_t)
> -                         + sizeof(__be32) ||
> +               /* chunk header + first 4 octects of init header */
> +               chunkhdr = skb_header_pointer(skb, skb_transport_offset(skb) +
> +                                             sizeof(struct sctphdr),
> +                                             sizeof(struct sctp_chunkhdr) +
> +                                             sizeof(__be32), &_chunkhdr);
> +               if (!chunkhdr ||
>                     chunkhdr->chunk_hdr.type != SCTP_CID_INIT ||
> -                   ntohl(chunkhdr->init_hdr.init_tag) != asoc->c.my_vtag) {
> +                   ntohl(chunkhdr->init_hdr.init_tag) != asoc->c.my_vtag)
>                         goto out;
> -               }
> +
>         } else if (vtag != asoc->c.peer_vtag) {
>                 goto out;
>         }
> --
> 2.9.4
>
