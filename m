From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv3 net-next 4/4] sctp: implement sender-side procedures
 for Add Incoming/Outgoing Streams Request Parameter
Date: Mon, 23 Jan 2017 09:50:16 -0500
Message-ID: <20170123145016.GA31445@hmswarspite.think-freely.org>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
 <20170119201718.GA21836@hmswarspite.think-freely.org>
 <20170119221812.GP3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        davem@davemloft.net
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41758 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdAWOvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 09:51:19 -0500
Content-Disposition: inline
In-Reply-To: <20170119221812.GP3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 08:18:13PM -0200, Marcelo Ricardo Leitner wrote:
> On Thu, Jan 19, 2017 at 03:17:18PM -0500, Neil Horman wrote:
> > On Fri, Jan 20, 2017 at 01:19:14AM +0800, Xin Long wrote:
> > > This patch is to implement Sender-Side Procedures for the Add
> > > Outgoing and Incoming Streams Request Parameter described in
> > > rfc6525 section 5.1.5-5.1.6.
> > > 
> > > It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
> > > 6.3.4 for users.
> > > 
> > > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > > ---
> > >  include/net/sctp/sctp.h   |  2 +
> > >  include/uapi/linux/sctp.h |  7 ++++
> > >  net/sctp/socket.c         | 29 ++++++++++++++
> > >  net/sctp/stream.c         | 99 +++++++++++++++++++++++++++++++++++++++++++++++
> > >  4 files changed, 137 insertions(+)
> > > 
> > > diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> > > index b93820f..68ee1a6 100644
> > > --- a/include/net/sctp/sctp.h
> > > +++ b/include/net/sctp/sctp.h
> > > @@ -199,6 +199,8 @@ int sctp_offload_init(void);
> > >  int sctp_send_reset_streams(struct sctp_association *asoc,
> > >  			    struct sctp_reset_streams *params);
> > >  int sctp_send_reset_assoc(struct sctp_association *asoc);
> > > +int sctp_send_add_streams(struct sctp_association *asoc,
> > > +			  struct sctp_add_streams *params);
> > >  
> > >  /*
> > >   * Module global variables
> > > diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> > > index c0bd8c3..a91a9cc 100644
> > > --- a/include/uapi/linux/sctp.h
> > > +++ b/include/uapi/linux/sctp.h
> > > @@ -118,6 +118,7 @@ typedef __s32 sctp_assoc_t;
> > >  #define SCTP_ENABLE_STREAM_RESET	118
> > >  #define SCTP_RESET_STREAMS	119
> > >  #define SCTP_RESET_ASSOC	120
> > > +#define SCTP_ADD_STREAMS	121
> > >  
> > >  /* PR-SCTP policies */
> > >  #define SCTP_PR_SCTP_NONE	0x0000
> > > @@ -1027,4 +1028,10 @@ struct sctp_reset_streams {
> > >  	uint16_t srs_stream_list[];	/* list if srs_num_streams is not 0 */
> > >  };
> > >  
> > > +struct sctp_add_streams {
> > > +	sctp_assoc_t sas_assoc_id;
> > > +	uint16_t sas_instrms;
> > > +	uint16_t sas_outstrms;
> > > +};
> > > +
> > >  #endif /* _UAPI_SCTP_H */
> > > diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> > > index 2c5c9ca..ae0a99e 100644
> > > --- a/net/sctp/socket.c
> > > +++ b/net/sctp/socket.c
> > > @@ -3838,6 +3838,32 @@ static int sctp_setsockopt_reset_assoc(struct sock *sk,
> > >  	return retval;
> > >  }
> > >  
> > > +static int sctp_setsockopt_add_streams(struct sock *sk,
> > > +				       char __user *optval,
> > > +				       unsigned int optlen)
> > > +{
> > you are going to need to provide some locking here or in sctp_send_add_streams.
> > By replacing the in/out streams pointer you run the risk of multiple callers
> > modifying the pointers in parallel, or in the sctp state machine reading it
> > while you do.
> 
> There can't be multiple callers here because the socket is locked before
> calling this function, in sctp_setsockopt().
> I also don't see how a BH handler, timers or sleeping call (recvmsg)
> could trip on this.
You're right, I missed the socket lock in sctp_setsockopt, that covers us both
from multiple processes and bottom halves.

> 
>   Marcelo
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
