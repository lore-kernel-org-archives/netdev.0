From: Richard Haines <richard_c_haines@btinternet.com>
Subject: Re: [RFC PATCH 3/5] sctp: Add LSM hooks
Date: Tue, 24 Oct 2017 21:27:51 +0100
Message-ID: <1508876871.26687.5.camel@btinternet.com>
References: <20171017135833.4292-1-richard_c_haines@btinternet.com>
         <CADvbK_d+LKRQHZXn5LMy+4L0Nq+ZEkvHGk=zn3odUr7FrzvkBQ@mail.gmail.com>
         <20171020111637.GA14713@neilslaptop.think-freely.org>
         <1508501095.8370.7.camel@btinternet.com>
         <CADvbK_cLGA4PH_c4FB0eSUAMoV0XgtyA++cTFsGDkb=nvtR68g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, selinux@tycho.nsa.gov,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CADvbK_cLGA4PH_c4FB0eSUAMoV0XgtyA++cTFsGDkb=nvtR68g@mail.gmail.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-10-20 at 21:14 +0800, Xin Long wrote:
> On Fri, Oct 20, 2017 at 8:04 PM, Richard Haines
> <richard_c_haines@btinternet.com> wrote:
> > On Fri, 2017-10-20 at 07:16 -0400, Neil Horman wrote:
> > > On Wed, Oct 18, 2017 at 11:05:09PM +0800, Xin Long wrote:
> > > > On Tue, Oct 17, 2017 at 9:58 PM, Richard Haines
> > > > <richard_c_haines@btinternet.com> wrote:
> > > > > Add security hooks to allow security modules to exercise
> > > > > access
> > > > > control
> > > > > over SCTP.
> > > > > 
> > > > > Signed-off-by: Richard Haines <richard_c_haines@btinternet.co
> > > > > m>
> > > > > ---
> > > > >  include/net/sctp/structs.h | 10 ++++++++
> > > > >  include/uapi/linux/sctp.h  |  1 +
> > > > >  net/sctp/sm_make_chunk.c   | 12 +++++++++
> > > > >  net/sctp/sm_statefuns.c    | 14 ++++++++++-
> > > > >  net/sctp/socket.c          | 61
> > > > > +++++++++++++++++++++++++++++++++++++++++++++-
> > > > >  5 files changed, 96 insertions(+), 2 deletions(-)
> > > > > 
> > > > > diff --git a/include/net/sctp/structs.h
> > > > > b/include/net/sctp/structs.h
> > > > > index 7767577..6e72e3e 100644
> > > > > --- a/include/net/sctp/structs.h
> > > > > +++ b/include/net/sctp/structs.h
> > > > > @@ -1270,6 +1270,16 @@ struct sctp_endpoint {
> > > > >               reconf_enable:1;
> > > > > 
> > > > >         __u8  strreset_enable;
> > > > > +
> > > > > +       /* Security identifiers from incoming (INIT). These
> > > > > are
> > > > > set by
> > > > > +        * security_sctp_assoc_request(). These will only be
> > > > > used
> > > > > by
> > > > > +        * SCTP TCP type sockets and peeled off connections
> > > > > as
> > > > > they
> > > > > +        * cause a new socket to be generated.
> > > > > security_sctp_sk_clone()
> > > > > +        * will then plug these into the new socket.
> > > > > +        */
> > > > > +
> > > > > +       u32 secid;
> > > > > +       u32 peer_secid;
> > > > >  };
> > > > > 
> > > > >  /* Recover the outter endpoint structure. */
> > > > > diff --git a/include/uapi/linux/sctp.h
> > > > > b/include/uapi/linux/sctp.h
> > > > > index 6217ff8..c04812f 100644
> > > > > --- a/include/uapi/linux/sctp.h
> > > > > +++ b/include/uapi/linux/sctp.h
> > > > > @@ -122,6 +122,7 @@ typedef __s32 sctp_assoc_t;
> > > > >  #define SCTP_RESET_ASSOC       120
> > > > >  #define SCTP_ADD_STREAMS       121
> > > > >  #define SCTP_SOCKOPT_PEELOFF_FLAGS 122
> > > > > +#define SCTP_SENDMSG_CONNECT   123
> > > > > 
> > > > >  /* PR-SCTP policies */
> > > > >  #define SCTP_PR_SCTP_NONE      0x0000
> > > > > diff --git a/net/sctp/sm_make_chunk.c
> > > > > b/net/sctp/sm_make_chunk.c
> > > > > index 6110447..ca4705b 100644
> > > > > --- a/net/sctp/sm_make_chunk.c
> > > > > +++ b/net/sctp/sm_make_chunk.c
> > > > > @@ -3059,6 +3059,12 @@ static __be16
> > > > > sctp_process_asconf_param(struct sctp_association *asoc,
> > > > >                 if (af->is_any(&addr))
> > > > >                         memcpy(&addr, &asconf->source,
> > > > > sizeof(addr));
> > > > > 
> > > > > +               if (security_sctp_bind_connect(asoc->ep-
> > > > > >base.sk,
> > > > > +                                              SCTP_PARAM_ADD
> > > > > _IP,
> > > > > +                                              (struct
> > > > > sockaddr
> > > > > *)&addr,
> > > > > +                                              af-
> > > > > >sockaddr_len))
> > > > > +                       return SCTP_ERROR_REQ_REFUSED;
> > > > > +
> > > > >                 /* ADDIP 4.3 D9) If an endpoint receives an
> > > > > ADD
> > > > > IP address
> > > > >                  * request and does not have the local
> > > > > resources
> > > > > to add this
> > > > >                  * new address to the association, it MUST
> > > > > return
> > > > > an Error
> > > > > @@ -3125,6 +3131,12 @@ static __be16
> > > > > sctp_process_asconf_param(struct sctp_association *asoc,
> > > > >                 if (af->is_any(&addr))
> > > > >                         memcpy(&addr.v4, sctp_source(asconf),
> > > > > sizeof(addr));
> > > > > 
> > > > > +               if (security_sctp_bind_connect(asoc->ep-
> > > > > >base.sk,
> > > > > +                                              SCTP_PARAM_SET
> > > > > _PRI
> > > > > MARY,
> > > > > +                                              (struct
> > > > > sockaddr
> > > > > *)&addr,
> > > > > +                                              af-
> > > > > >sockaddr_len))
> > > > > +                       return SCTP_ERROR_REQ_REFUSED;
> > > > > +
> > > > >                 peer = sctp_assoc_lookup_paddr(asoc, &addr);
> > > > >                 if (!peer)
> > > > >                         return SCTP_ERROR_DNS_FAILED;
> > > > > diff --git a/net/sctp/sm_statefuns.c
> > > > > b/net/sctp/sm_statefuns.c
> > > > > index b2a74c3..4ba5805 100644
> > > > > --- a/net/sctp/sm_statefuns.c
> > > > > +++ b/net/sctp/sm_statefuns.c
> > > > > @@ -314,6 +314,11 @@ sctp_disposition_t
> > > > > sctp_sf_do_5_1B_init(struct net *net,
> > > > >         sctp_unrecognized_param_t *unk_param;
> > > > >         int len;
> > > > > 
> > > > > +       /* Update socket peer label if first association. */
> > > > > +       if (security_sctp_assoc_request((struct sctp_endpoint
> > > > > *)ep,
> > > > > +                                       chunk->skb,
> > > > > SCTP_CID_INIT))
> > > > > +               return sctp_sf_pdiscard(net, ep, asoc, type,
> > > > > arg,
> > > > > commands);
> > > > > +
> > > > >         /* 6.10 Bundling
> > > > >          * An endpoint MUST NOT bundle INIT, INIT ACK or
> > > > >          * SHUTDOWN COMPLETE with any other chunks.
> > > > > @@ -446,7 +451,6 @@ sctp_disposition_t
> > > > > sctp_sf_do_5_1B_init(struct net *net,
> > > > >         }
> > > > > 
> > > > >         sctp_add_cmd_sf(commands, SCTP_CMD_NEW_ASOC,
> > > > > SCTP_ASOC(new_asoc));
> > > > > -
> > > > >         sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
> > > > > SCTP_CHUNK(repl));
> > > > > 
> > > > >         /*
> > > > > @@ -507,6 +511,11 @@ sctp_disposition_t
> > > > > sctp_sf_do_5_1C_ack(struct net *net,
> > > > >         struct sctp_chunk *err_chunk;
> > > > >         struct sctp_packet *packet;
> > > > > 
> > > > > +       /* Update socket peer label if first association. */
> > > > > +       if (security_sctp_assoc_request((struct sctp_endpoint
> > > > > *)ep,
> > > > > +                                       chunk->skb,
> > > > > SCTP_CID_INIT_ACK))
> > > > > +               return sctp_sf_pdiscard(net, ep, asoc, type,
> > > > > arg,
> > > > > commands);
> > > > > +
> > > > 
> > > > Just thinking security_sctp_assoc_request hook should also be
> > > > in
> > > > sctp_sf_do_unexpected_init() and sctp_sf_do_5_2_4_dupcook() ?
> > > 
> > > I agree, i think if this hook is gating on the creation of a new
> > > association,
> > > they should be in all the locations where that happens
> > > Neil
> > 
> > Thanks for the comments. I've just added the hook as requested for
> > my
> > next update, however I have not managed to trigger these areas
> > using
> > the lksctp-tools tests. Can you suggest any suitable tools for
> > testing
> > these scenarios.
> 
> It's all a matter of timing:
> 
> sctp_sf_do_5_2_2_dupinit():
> Case A:
> 
>   Endpoint A                           Endpoint B                ULP
>   (CLOSED)                             (CLOSED)
> 
>   INIT          ----------------->
> 
>                 <-----------------      INIT-ACK
> 
>   COOKIE-ECHO   ----------------->
> 
>                 <-----------------      COOKIE-ACK
>                                          Communication Up ---------->
>   INIT          ----------------->
>   (Different INIT-TAG)
>                 <-----------------      INIT-ACK
> 
>   COOKIE-ECHO   ----------------->
> 
>                 <-----------------      COOKIE-ACK
> 
>   DATA          ----------------->
> 
>                 <-----------------      SACK
> 
> 
> sctp_sf_do_5_2_1_siminit():
>  Case B:
> 
>   Endpoint A                           Endpoint B                ULP
>   (CLOSED)                             (CLOSED)
> 
>                                                    <--
> ---    Associate
>                 <-----------------      INIT
> 
>   INIT          ----------------->
> 
>                 <-----------------      INIT-ACK
> 
>   COOKIE-ECHO   ----------------->
> 
>                 <-----------------      COOKIE-ACK
>                                          Communication Up ---------->
> 
> 
> sctp_sf_do_5_2_4_dupcook():
> Case D:
> 
>   Endpoint A                           Endpoint B                ULP
>   (CLOSED)                             (CLOSED)
> 
>                                                    <--
> ---    Associate
>   INIT          ----------------->
> 
>                 <-----------------      INIT-ACK
> 
>   COOKIE-ECHO   ----------------->
> 
>                 <-----------------      COOKIE-ACK
>                                          Communication Up ---------->
>   COOKIE-ECHO   ----------------->
> 
>                 <-----------------      COOKIE-ACK
> 
> I think scapy could help with 4-shake stuff:
> # iptables -A OUTPUT -p sctp -d 192.0.0.2 --chunk-type only abort -o
> eth1 -j DROP
> and
> something like:
>         def start_assoc(self, target, local):
>                 target_host, target_port = target
>                 local_host,  local_port  = local
> 
>                 # init snd
>                 self._tsn = 2017
>                 self._cnt = 15
> 
>                 SCTP_HEADER = (IP(dst=target_host, flags="DF") /
> SCTP(sport=local_port, dport=target_port, tag=0))
>                 INIT = (SCTP_HEADER / SCTPChunkInit(init_tag=1,
> a_rwnd=106496, n_out_streams=self._cnt, n_in_streams=self._cnt,
> init_tsn=self._tsn,
> 
> params=[SCTPParamSupport(types=[64])]))
>                 INIT_ACK = sr1(INIT, timeout=3, verbose=0)
>                 if INIT_ACK == None or not
> INIT_ACK.haslayer(SCTPChunkInitAck):
>                         return False
> 
>                 # cookie echo snd
>                 SCTP_HEADER[SCTP].tag =
> INIT_ACK[SCTPChunkInitAck].init_tag
>                 COOKIE_ECHO = (SCTP_HEADER /
> SCTPChunkCookieEcho(cookie=INIT_ACK[SCTPChunkParamStateCookie].cookie
> ))
>                 COOKIE_ACK = sr1(COOKIE_ECHO, timeout=3, verbose=0)
>                 if COOKIE_ACK == None or not
> COOKIE_ACK.haslayer(SCTPChunkCookieAck):
>                         return False

That looks a bit complicated for me so I found some SCTP Conformance
Test Tools at: https://github.com/nplab

I added the required hooks as suggested above and then built and ran
"ETSI-SCTP-Conformance-Testsuite" and "sctp-tests" with the following
specific tests for the above scenarios according to RFC2960 sections
5.2.2 and 5.2.4:
sctp-dm-o-4-8
sctp-as-o-1-9-1
sctp-as-o-1-9-2
sctp-dm-o-4-2-1

They all passed except when running:
"sctp-tests" runsctptest sctp-as-o-1-9-2 - TIMEOUT
This is because the SUT needs to reply with a new IP address that
required a modified test server (I just used a simple sctp server),
however the ETSI-SCTP-Conformance-Testsuite did pass as I guess that
provided the required IP address.

Are these tests okay ??
Does anyone on the list use these conformance tools ???

> --
> To unsubscribe from this list: send the line "unsubscribe linux-
> security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
