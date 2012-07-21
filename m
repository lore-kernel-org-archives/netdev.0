From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v5] sctp: Implement quick failover draft from tsvwg
Date: Sat, 21 Jul 2012 02:45:03 -0400
Message-ID: <ab3918ef-84db-413c-93d7-c3b9afe8fa87@email.android.com>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com> <1342810319-27457-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, joe@perches.com
To: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:33543 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767Ab2GUGpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 02:45:09 -0400
In-Reply-To: <1342810319-27457-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>I've seen several attempts recently made to do quick failover of sctp
>transports
>by reducing various retransmit timers and counters.  While its possible
>to
>implement a faster failover on multihomed sctp associations, its not
>particularly robust, in that it can lead to unneeded retransmits, as
>well as
>false connection failures due to intermittent latency on a network.
>
>Instead, lets implement the new ietf quick failover draft found here:
>http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
>
>This will let the sctp stack identify transports that have had a small
>number of
>errors, and avoid using them quickly until their reliability can be
>re-established.  I've tested this out on two virt guests connected via
>multiple
>isolated virt networks and believe its in compliance with the above
>draft and
>works well.
>
>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>CC: Vlad Yasevich <vyasevich@gmail.com>
>CC: Sridhar Samudrala <sri@us.ibm.com>
>CC: "David S. Miller" <davem@davemloft.net>
>CC: linux-sctp@vger.kernel.org
>CC: joe@perches.com
>
>---
>Change notes:
>
>V2)
>- Added socket option API from section 6.1 of the specification, as per
>request from Vlad. Adding this socket option allows us to alter both
>the path
>maximum retransmit value and the path partial failure threshold for
>each
>transport and the association as a whole.
>
>- Added a per transport pf_retrans value, and initialized it from the
>association value.  This makes each transport independently
>configurable as per
>the socket option above, and prevents changes in the sysctl from
>bleeding into
>an already created association.
>
>V3)
>- Cleaned up some line spacing (Joe Perches)
>- Fixed some socket option user data sanitization (Vlad Yasevich)
>
>V4)
>- Added additional documentation (Flavio Leitner)
>
>V5)
>- Modified setsockopt option to ignore 0 pathmaxrxt rather than return
>  error (Vlad Yasevich)
>- Modified getsocopt to return option length written (Vlad Y.)
>---
> Documentation/networking/ip-sysctl.txt |   14 +++++
> include/net/sctp/constants.h           |    1 +
> include/net/sctp/structs.h             |   20 ++++++-
> include/net/sctp/user.h                |   11 ++++
> net/sctp/associola.c                   |   37 ++++++++++--
> net/sctp/outqueue.c                    |    6 +-
> net/sctp/sm_sideeffect.c               |   33 +++++++++-
>net/sctp/socket.c                      |  100
>++++++++++++++++++++++++++++++++
> net/sctp/sysctl.c                      |    9 +++
> net/sctp/transport.c                   |    4 +-
> 10 files changed, 220 insertions(+), 15 deletions(-)
>
>> /* API 6.2 setsockopt(), getsockopt()
>  *
>  * Applications use setsockopt() and getsockopt() to set or retrieve
>@@ -3619,6 +3669,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk,
>int level, int optname,
> 	case SCTP_AUTO_ASCONF:
> 		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
> 		break;
>+	case SCTP_PEER_ADDR_THLDS:
>+		retval = sctp_setsockopt_paddr_thresholds(sk, optval, optlen);
>+		break;
> 	default:
> 		retval = -ENOPROTOOPT;
> 		break;
>@@ -5490,6 +5543,50 @@ static int sctp_getsockopt_assoc_ids(struct sock
>*sk, int len,
> 	return 0;
> }
> 
>+/*
>+ * SCTP_PEER_ADDR_THLDS
>+ *
>+ * This option allows us to fetch the partially failed threshold for
>one or all
>+ * transports in an association.  See Section 6.1 of:
>+ * http://www.ietf.org/id/draft-nishida-tsvwg-sctp-failover-05.txt
>+ */
>+static int sctp_getsockopt_paddr_thresholds(struct sock *sk,
>+					    char __user *optval,
>+					    int optlen)
>+{
>+	struct sctp_paddrthlds val;
>+	struct sctp_transport *trans;
>+	struct sctp_association *asoc;
>+
>+	if (optlen < sizeof(struct sctp_paddrthlds))
>+		return -EINVAL;
>+	optlen = sizeof(struct sctp_paddrthlds);
>+	if (copy_from_user(&val, (struct sctp_paddrthlds __user *)optval,
>optlen))
>+		return -EFAULT;
>+
>+	if (sctp_is_any(sk, (const union sctp_addr *)&val.spt_address)) {
>+		asoc = sctp_id2assoc(sk, val.spt_assoc_id);
>+		if (!asoc)
>+			return -ENOENT;
>+
>+		val.spt_pathpfthld = asoc->pf_retrans;
>+		val.spt_pathmaxrxt = asoc->pathmaxrxt;
>+	} else {
>+		trans = sctp_addr_id2transport(sk, &val.spt_address,
>+					       val.spt_assoc_id);
>+		if (!trans)
>+			return -ENOENT;
>+
>+		val.spt_pathmaxrxt = trans->pathmaxrxt;
>+		val.spt_pathpfthld = trans->pf_retrans;
>+	}
>+
>+	if (copy_to_user(optval, &val, optlen))
>+		return -EFAULT;
>+
>+	return optlen;

I don't think you can simply return this.  You have to call put_user() with the value to write it back to the User.  See how other get calls are done.

-Vlad
>+}
>+
>SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int
>optname,
> 				char __user *optval, int __user *optlen)
> {
>@@ -5628,6 +5725,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk,
>int level, int optname,
> 	case SCTP_AUTO_ASCONF:
> 		retval = sctp_getsockopt_auto_asconf(sk, len, optval, optlen);
> 		break;
>+	case SCTP_PEER_ADDR_THLDS:
>+		retval = sctp_getsockopt_paddr_thresholds(sk, optval, len);
>+		break;
> 	default:
> 		retval = -ENOPROTOOPT;
> 		break;
>diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>index e5fe639..2b2bfe9 100644
>--- a/net/sctp/sysctl.c
>+++ b/net/sctp/sysctl.c
>@@ -141,6 +141,15 @@ static ctl_table sctp_table[] = {
> 		.extra2		= &int_max
> 	},
> 	{
>+		.procname	= "pf_retrans",
>+		.data		= &sctp_pf_retrans,
>+		.maxlen		= sizeof(int),
>+		.mode		= 0644,
>+		.proc_handler	= proc_dointvec_minmax,
>+		.extra1		= &zero,
>+		.extra2		= &int_max
>+	},
>+	{
> 		.procname	= "max_init_retransmits",
> 		.data		= &sctp_max_retrans_init,
> 		.maxlen		= sizeof(int),
>diff --git a/net/sctp/transport.c b/net/sctp/transport.c
>index b026ba0..194d0f3 100644
>--- a/net/sctp/transport.c
>+++ b/net/sctp/transport.c
>@@ -85,6 +85,7 @@ static struct sctp_transport
>*sctp_transport_init(struct sctp_transport *peer,
> 
> 	/* Initialize the default path max_retrans.  */
> 	peer->pathmaxrxt  = sctp_max_retrans_path;
>+	peer->pf_retrans  = sctp_pf_retrans;
> 
> 	INIT_LIST_HEAD(&peer->transmitted);
> 	INIT_LIST_HEAD(&peer->send_ready);
>@@ -585,7 +586,8 @@ unsigned long sctp_transport_timeout(struct
>sctp_transport *t)
> {
> 	unsigned long timeout;
> 	timeout = t->rto + sctp_jitter(t->rto);
>-	if (t->state != SCTP_UNCONFIRMED)
>+	if ((t->state != SCTP_UNCONFIRMED) &&
>+	    (t->state != SCTP_PF))
> 		timeout += t->hbinterval;
> 	timeout += jiffies;
> 	return timeout;
>-- 
>1.7.7.6


-- 
Sent from my Android phone with SkitMail. Please excuse my brevity.
