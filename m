From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv3 net-next 2/7] sctp: add support for generating stream
 reconf ssn reset request chunk
Date: Tue, 17 Jan 2017 11:20:26 -0200
Message-ID: <20170117132026.GI3781@localhost.localdomain>
References: <cover.1484334002.git.lucien.xin@gmail.com>
 <6c991b81f4a92cec3da773bae9b19e878e810c88.1484334002.git.lucien.xin@gmail.com>
 <20170115155150.GG3781@localhost.localdomain>
 <CADvbK_cLGNyCWCHJ1pcMxxuqFvGABKBOS36_ekJhYsrd30nc3g@mail.gmail.com>
 <CADvbK_dE6h1JQAKytA332jLKiW2UA9+A3QQKdO-e-hExgJ=NQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        davem <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750967AbdAQNUu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 08:20:50 -0500
Content-Disposition: inline
In-Reply-To: <CADvbK_dE6h1JQAKytA332jLKiW2UA9+A3QQKdO-e-hExgJ=NQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 12:27:48PM +0800, Xin Long wrote:
> On Mon, Jan 16, 2017 at 11:56 AM, Xin Long <lucien.xin@gmail.com> wrote:
> > On Sun, Jan 15, 2017 at 11:51 PM, Marcelo Ricardo Leitner
> > <marcelo.leitner@gmail.com> wrote:
> >> On Sat, Jan 14, 2017 at 03:15:36AM +0800, Xin Long wrote:
> >>> This patch is to add asoc strreset_outseq and strreset_inseq for
> >>> saving the reconf request sequence, initialize them when create
> >>> assoc and process init, and also to define Incoming and Outgoing
> >>> SSN Reset Request Parameter described in rfc6525 section 4.1 and
> >>> 4.2, As they can be in one same chunk as section rfc6525 3.1-3
> >>> describes, it makes them in one function.
> >>>
> >>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> >>> ---
> >>>  include/linux/sctp.h       | 26 ++++++++++++++
> >>>  include/net/sctp/sm.h      |  5 ++-
> >>>  include/net/sctp/structs.h |  3 ++
> >>>  net/sctp/associola.c       |  1 +
> >>>  net/sctp/sm_make_chunk.c   | 88 ++++++++++++++++++++++++++++++++++++++++++++++
> >>>  5 files changed, 122 insertions(+), 1 deletion(-)
> >>>
> >>> diff --git a/include/linux/sctp.h b/include/linux/sctp.h
> >>> index cdc3b05..d5da19c 100644
> >>> --- a/include/linux/sctp.h
> >>> +++ b/include/linux/sctp.h
> >>> @@ -200,6 +200,13 @@ typedef enum {
> >>>       SCTP_PARAM_SUCCESS_REPORT       = cpu_to_be16(0xc005),
> >>>       SCTP_PARAM_ADAPTATION_LAYER_IND = cpu_to_be16(0xc006),
> >>>
> >>> +     /* RE-CONFIG. Section 4 */
> >>> +     SCTP_PARAM_RESET_OUT_REQUEST            = cpu_to_be16(0x000d),
> >>> +     SCTP_PARAM_RESET_IN_REQUEST             = cpu_to_be16(0x000e),
> >>> +     SCTP_PARAM_RESET_TSN_REQUEST            = cpu_to_be16(0x000f),
> >>> +     SCTP_PARAM_RESET_RESPONSE               = cpu_to_be16(0x0010),
> >>> +     SCTP_PARAM_RESET_ADD_OUT_STREAMS        = cpu_to_be16(0x0011),
> >>> +     SCTP_PARAM_RESET_ADD_IN_STREAMS         = cpu_to_be16(0x0012),
> >>>  } sctp_param_t; /* enum */
> >>>
> >>>
> >>> @@ -716,4 +723,23 @@ struct sctp_reconf_chunk {
> >>>       __u8 params[0];
> >>>  } __packed;
> >>>
> >>> +struct sctp_strreset_req {
> >>> +     sctp_paramhdr_t param_hdr;
> >>> +     __u32 request_seq;
> >>> +} __packed;
> >>> +
> >>> +struct sctp_strreset_outreq {
> >>> +     sctp_paramhdr_t param_hdr;
> >>> +     __u32 request_seq;
> >>
> >> This should be:
> >> +       struct sctp_strreset_req strreset_req;
> >> Use the definition you created above for the encapsulation and make the
> >> embedding evident.
> >> Like it's done for sctp_chunkhdr_t.
> > I'm not sure if it's good to do it like sctp_chunkhdr_t.
> >
> > As sctp_chunkhdr is a very common data:
> > Chunk Type  | Chunk  Flags  |  Chunk Length
> > and the next must be "Chunk Value"
> >
> > But here sctp_strreset_req is more used to access
> > the request_seq of the params in asoc->strreset_chunk
> > without knowing params' type. like in sctp_chunk_lookup_strreset_param()

Exactly.

> > and sctp_process_strreset_resp() [see it from the big patchset].
> >
> > struct sctp_strreset_outreq {
> >         sctp_paramhdr_t param_hdr;
> >         __u32 request_seq;
> >         ------------------------------------[1]
> >         __u32 response_seq;
> >         __u32 send_reset_at_tsn;
> >         __u16 list_of_streams[0];
> > } __packed;
> >
> > it seems not good to split it by [1].
> >         __u32 request_seq;
> >         __u32 response_seq;
> >         __u32 send_reset_at_tsn;
> >         __u16 list_of_streams[0];
> > these should to together and equal.
> >
> > what do you think ?
> >
> Hi, Marcelo, I'm planning to drop "struct sctp_strreset_req" so
> that it will not be confusing here, and only introduce it when
> it's used somewhere. agreed ?

Works for me. Then we will check about this part:

from sctp_process_strreset_resp:
+       if (req->param_hdr.type == SCTP_PARAM_RESET_OUT_REQUEST) {
+               struct sctp_strreset_outreq *outreq;
+               __u16 *str_p = NULL;
+
+               outreq = (struct sctp_strreset_outreq *)req;

If the structs could be embedded, such cast would be clearer to be safe.

  Marcelo
