From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [RFC PATCH 3/5] sctp: Add LSM hooks
Date: Wed, 18 Oct 2017 23:05:09 +0800
Message-ID: <CADvbK_d+LKRQHZXn5LMy+4L0Nq+ZEkvHGk=zn3odUr7FrzvkBQ@mail.gmail.com>
References: <20171017135833.4292-1-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: selinux@tycho.nsa.gov, network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org,
        paul@paul-moore.com, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, sds@tycho.nsa.gov,
        eparis@parisplace.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Richard Haines <richard_c_haines@btinternet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:52530 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751897AbdJRPFK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:05:10 -0400
In-Reply-To: <20171017135833.4292-1-richard_c_haines@btinternet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 9:58 PM, Richard Haines
<richard_c_haines@btinternet.com> wrote:
> Add security hooks to allow security modules to exercise access control
> over SCTP.
>
> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
> ---
>  include/net/sctp/structs.h | 10 ++++++++
>  include/uapi/linux/sctp.h  |  1 +
>  net/sctp/sm_make_chunk.c   | 12 +++++++++
>  net/sctp/sm_statefuns.c    | 14 ++++++++++-
>  net/sctp/socket.c          | 61 +++++++++++++++++++++++++++++++++++++++++++++-
>  5 files changed, 96 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 7767577..6e72e3e 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1270,6 +1270,16 @@ struct sctp_endpoint {
>               reconf_enable:1;
>
>         __u8  strreset_enable;
> +
> +       /* Security identifiers from incoming (INIT). These are set by
> +        * security_sctp_assoc_request(). These will only be used by
> +        * SCTP TCP type sockets and peeled off connections as they
> +        * cause a new socket to be generated. security_sctp_sk_clone()
> +        * will then plug these into the new socket.
> +        */
> +
> +       u32 secid;
> +       u32 peer_secid;
>  };
>
>  /* Recover the outter endpoint structure. */
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index 6217ff8..c04812f 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -122,6 +122,7 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_RESET_ASSOC       120
>  #define SCTP_ADD_STREAMS       121
>  #define SCTP_SOCKOPT_PEELOFF_FLAGS 122
> +#define SCTP_SENDMSG_CONNECT   123
>
>  /* PR-SCTP policies */
>  #define SCTP_PR_SCTP_NONE      0x0000
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 6110447..ca4705b 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -3059,6 +3059,12 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>                 if (af->is_any(&addr))
>                         memcpy(&addr, &asconf->source, sizeof(addr));
>
> +               if (security_sctp_bind_connect(asoc->ep->base.sk,
> +                                              SCTP_PARAM_ADD_IP,
> +                                              (struct sockaddr *)&addr,
> +                                              af->sockaddr_len))
> +                       return SCTP_ERROR_REQ_REFUSED;
> +
>                 /* ADDIP 4.3 D9) If an endpoint receives an ADD IP address
>                  * request and does not have the local resources to add this
>                  * new address to the association, it MUST return an Error
> @@ -3125,6 +3131,12 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>                 if (af->is_any(&addr))
>                         memcpy(&addr.v4, sctp_source(asconf), sizeof(addr));
>
> +               if (security_sctp_bind_connect(asoc->ep->base.sk,
> +                                              SCTP_PARAM_SET_PRIMARY,
> +                                              (struct sockaddr *)&addr,
> +                                              af->sockaddr_len))
> +                       return SCTP_ERROR_REQ_REFUSED;
> +
>                 peer = sctp_assoc_lookup_paddr(asoc, &addr);
>                 if (!peer)
>                         return SCTP_ERROR_DNS_FAILED;
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index b2a74c3..4ba5805 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -314,6 +314,11 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
>         sctp_unrecognized_param_t *unk_param;
>         int len;
>
> +       /* Update socket peer label if first association. */
> +       if (security_sctp_assoc_request((struct sctp_endpoint *)ep,
> +                                       chunk->skb, SCTP_CID_INIT))
> +               return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
> +
>         /* 6.10 Bundling
>          * An endpoint MUST NOT bundle INIT, INIT ACK or
>          * SHUTDOWN COMPLETE with any other chunks.
> @@ -446,7 +451,6 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
>         }
>
>         sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC, SCTP_ASOC(new_asoc));
> -
>         sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
>
>         /*
> @@ -507,6 +511,11 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
>         struct sctp_chunk *err_chunk;
>         struct sctp_packet *packet;
>
> +       /* Update socket peer label if first association. */
> +       if (security_sctp_assoc_request((struct sctp_endpoint *)ep,
> +                                       chunk->skb, SCTP_CID_INIT_ACK))
> +               return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
> +
Just thinking security_sctp_assoc_request hook should also be in
sctp_sf_do_unexpected_init() and sctp_sf_do_5_2_4_dupcook() ?
