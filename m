From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4] sctp: Implement quick failover draft from tsvwg
Date: Fri, 20 Jul 2012 14:36:29 -0400
Message-ID: <20120720183629.GE22367@hmsreliant.think-freely.org>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
 <1342804752-17044-1-git-send-email-nhorman@tuxdriver.com>
 <50099B97.9070701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, joe@perches.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53915 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab2GTSgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:36:41 -0400
Content-Disposition: inline
In-Reply-To: <50099B97.9070701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 01:55:35PM -0400, Vlad Yasevich wrote:
> On 07/20/2012 01:19 PM, Neil Horman wrote:
> >I've seen several attempts recently made to do quick failover of sctp transports
> >by reducing various retransmit timers and counters.  While its possible to
> >implement a faster failover on multihomed sctp associations, its not
> >particularly robust, in that it can lead to unneeded retransmits, as well as
> >false connection failures due to intermittent latency on a network.
> >
> >Instead, lets implement the new ietf quick failover draft found here:
> >http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
> >
> >This will let the sctp stack identify transports that have had a small number of
> >errors, and avoid using them quickly until their reliability can be
> >re-established.  I've tested this out on two virt guests connected via multiple
> >isolated virt networks and believe its in compliance with the above draft and
> >works well.
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: Vlad Yasevich <vyasevich@gmail.com>
> >CC: Sridhar Samudrala <sri@us.ibm.com>
> >CC: "David S. Miller" <davem@davemloft.net>
> >CC: linux-sctp@vger.kernel.org
> >CC: joe@perches.com
> >
> >---
> >Change notes:
> >
> >V2)
> >- Added socket option API from section 6.1 of the specification, as per
> >request from Vlad. Adding this socket option allows us to alter both the path
> >maximum retransmit value and the path partial failure threshold for each
> >transport and the association as a whole.
> >
> >- Added a per transport pf_retrans value, and initialized it from the
> >association value.  This makes each transport independently configurable as per
> >the socket option above, and prevents changes in the sysctl from bleeding into
> >an already created association.
> >
> >V3)
> >- Cleaned up some line spacing (Joe Perches)
> >- Fixed some socket option user data sanitization (Vlad Yasevich)
> >
> >V4)
> >- Added additional documentation (Flavio Leitner)
> >---
> >  Documentation/networking/ip-sysctl.txt |   14 +++++
> >  include/net/sctp/constants.h           |    1 +
> >  include/net/sctp/structs.h             |   20 ++++++-
> >  include/net/sctp/user.h                |   11 ++++
> >  net/sctp/associola.c                   |   37 ++++++++++--
> >  net/sctp/outqueue.c                    |    6 +-
> >  net/sctp/sm_sideeffect.c               |   33 +++++++++-
> >  net/sctp/socket.c                      |  100 ++++++++++++++++++++++++++++++++
> >  net/sctp/sysctl.c                      |    9 +++
> >  net/sctp/transport.c                   |    4 +-
> >  10 files changed, 220 insertions(+), 15 deletions(-)
> >
> 
> [ snip ]
> 
> >
> >diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> >index b3b8a8d..fef9bfa 100644
> >--- a/net/sctp/socket.c
> >+++ b/net/sctp/socket.c
> >@@ -3470,6 +3470,56 @@ static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
> >  }
> >
> >
> >+/*
> >+ * SCTP_PEER_ADDR_THLDS
> >+ *
> >+ * This option allows us to alter the partially failed threshold for one or all
> >+ * transports in an association.  See Section 6.1 of:
> >+ * http://www.ietf.org/id/draft-nishida-tsvwg-sctp-failover-05.txt
> >+ */
> >+static int sctp_setsockopt_paddr_thresholds(struct sock *sk,
> >+					    char __user *optval,
> >+					    unsigned int optlen)
> >+{
> >+	struct sctp_paddrthlds val;
> >+	struct sctp_transport *trans;
> >+	struct sctp_association *asoc;
> >+
> >+	if (optlen < sizeof(struct sctp_paddrthlds))
> >+		return -EINVAL;
> >+	if (copy_from_user(&val, (struct sctp_paddrthlds __user *)optval,
> >+			   sizeof(struct sctp_paddrthlds)))
> >+		return -EFAULT;
> >+
> >+	/* path_max_retrans shouldn't ever be zero */
> >+	if (!val.spt_pathmaxrxt)
> >+		return -EINVAL;
> 
> I am not sure I like this solution.  This means that the application
> must fetch the pathmaxrx and then write the same value back here.
> Why not simply ignore the patthmaxrxt if it's 0?  That way someone
> can just tweak the pf value without changing the pathmaxrxt.
> 
> 
Yeah, I can make that change.
Neil
