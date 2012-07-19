From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: Implement quick failover draft from tsvwg
Date: Thu, 19 Jul 2012 06:46:31 -0400
Message-ID: <20120719104631.GC2070@hmsreliant.think-freely.org>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
 <1342634466-17930-1-git-send-email-nhorman@tuxdriver.com>
 <50072939.5030600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35268 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646Ab2GSKqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 06:46:38 -0400
Content-Disposition: inline
In-Reply-To: <50072939.5030600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 05:23:05PM -0400, Vlad Yasevich wrote:
> On 07/18/2012 02:01 PM, Neil Horman wrote:
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
> >---
> >  Documentation/networking/ip-sysctl.txt |   14 +++++
> >  include/net/sctp/constants.h           |    1 +
> >  include/net/sctp/structs.h             |   11 +++-
> >  include/net/sctp/user.h                |   11 ++++
> >  net/sctp/associola.c                   |   36 ++++++++++--
> >  net/sctp/outqueue.c                    |    6 +-
> >  net/sctp/sm_sideeffect.c               |   33 ++++++++++-
> >  net/sctp/socket.c                      |   96 ++++++++++++++++++++++++++++++++
> >  net/sctp/sysctl.c                      |    9 +++
> >  net/sctp/transport.c                   |    4 +-
> >  10 files changed, 206 insertions(+), 15 deletions(-)
> >
> 
> [ snip ]
> 
> >diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> >index b3b8a8d..dfffece 100644
> >--- a/net/sctp/socket.c
> >+++ b/net/sctp/socket.c
> >@@ -3470,6 +3470,52 @@ static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
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
> >+			   optlen))
> >+		return -EFAULT;
> 
> What if optlen is bigger?  You going to trash the stack.
> 
> >+
> >+	if (sctp_is_any(sk, (const union sctp_addr *)&val.spt_address)) {
> >+		asoc = sctp_id2assoc(sk, val.spt_assoc_id);
> >+		if (!asoc)
> >+			return -ENOENT;
> >+		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
> >+				    transports) {
> >+			trans->pathmaxrxt = val.spt_pathmaxrxt;
> >+			trans->pf_retrans = val.spt_pathpfthld;
> 
> You want to make sure that the values aren't 0.  Otherwise, you'll
> set the pathmaxrxt to 0 and that would be bad.
> 
> >+		}
> >+
> >+		asoc->pf_retrans = val.spt_pathpfthld;
> >+		asoc->pathmaxrxt = val.spt_pathmaxrxt;
> 
> Ditto.
> 
> >+	} else {
> >+		trans = sctp_addr_id2transport(sk, &val.spt_address,
> >+					       val.spt_assoc_id);
> >+		if (!trans)
> >+			return -ENOENT;
> >+
> >+		trans->pathmaxrxt = val.spt_pathmaxrxt;
> >+		trans->pf_retrans = val.spt_pathpfthld;
> 
> Ditto.
> 
> >+	}
> >+
> >+	return 0;
> >+}
> >+
> >  /* API 6.2 setsockopt(), getsockopt()
> >   *
> >   * Applications use setsockopt() and getsockopt() to set or retrieve
> >@@ -3619,6 +3665,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
> >  	case SCTP_AUTO_ASCONF:
> >  		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
> >  		break;
> >+	case SCTP_PEER_ADDR_THLDS:
> >+		retval = sctp_setsockopt_paddr_thresholds(sk, optval, optlen);
> >+		break;
> >  	default:
> >  		retval = -ENOPROTOOPT;
> >  		break;
> >@@ -5490,6 +5539,50 @@ static int sctp_getsockopt_assoc_ids(struct sock *sk, int len,
> >  	return 0;
> >  }
> >
> >+/*
> >+ * SCTP_PEER_ADDR_THLDS
> >+ *
> >+ * This option allows us to fetch the partially failed threshold for one or all
> >+ * transports in an association.  See Section 6.1 of:
> >+ * http://www.ietf.org/id/draft-nishida-tsvwg-sctp-failover-05.txt
> >+ */
> >+static int sctp_getsockopt_paddr_thresholds(struct sock *sk,
> >+					    char __user *optval,
> >+					    int optlen)
> >+{
> >+	struct sctp_paddrthlds val;
> >+	struct sctp_transport *trans;
> >+	struct sctp_association *asoc;
> >+
> >+	if (optlen < sizeof(struct sctp_paddrthlds))
> >+		return -EINVAL;
> >+	if (copy_from_user(&val, (struct sctp_paddrthlds __user *)optval, optlen))
> >+		return -EFAULT;
> 
> Again, trashing the stack if optlen and optval are bigger.
> 
> -vlad


Ack, I'll fix these up and repost.  Thanks!
Neil
