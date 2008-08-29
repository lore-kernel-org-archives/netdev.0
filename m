From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 16/37] dccp: API to query the current TX/RX CCID
Date: Fri, 29 Aug 2008 09:26:03 +0200
Message-ID: <20080829072603.GA7311@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-11-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-17-git-send-email-gerrit@erg.abdn.ac.uk> <20080828214725.GU9193@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41882 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750945AbYH2H01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 03:26:27 -0400
Content-Disposition: inline
In-Reply-To: <20080828214725.GU9193@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Arnaldo:
| Em Thu, Aug 28, 2008 at 07:44:51PM +0200, Gerrit Renker escreveu:
| > This provides function to query the current TX/RX CCID dynamically, without
| > reliance on the minisock value, using dynamic information available in the
| > currently loaded CCID module.
| > 
| > This query function is then used to
| >  (a) provide the getsockopt part for getting/setting CCIDs via sockopts;
| >  (b) replace the current test for "which CCID is in use" in probe.c.
| > 
| > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| > Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
| > ---
| >  net/dccp/ccid.h  |    9 +++++++++
| >  net/dccp/probe.c |    7 ++-----
| >  net/dccp/proto.c |    6 ++++++
| >  3 files changed, 17 insertions(+), 5 deletions(-)
| > 
| > --- a/net/dccp/ccid.h
| > +++ b/net/dccp/ccid.h
| > @@ -116,6 +116,15 @@ extern struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk,
| >  extern struct ccid *ccid_hc_tx_new(unsigned char id, struct sock *sk,
| >  				   gfp_t gfp);
| >  
| > +static inline int ccid_get_current_id(struct dccp_sock *dp, bool rx)
| > +{
| > +	struct ccid *ccid = rx ? dp->dccps_hc_rx_ccid : dp->dccps_hc_tx_ccid;
| > +
| > +	if (ccid == NULL || ccid->ccid_ops == NULL)
| > +		return -1;
| > +	return ccid->ccid_ops->ccid_id;
| > +}
| > +
| >  extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
| >  extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
| >  
| > --- a/net/dccp/probe.c
| > +++ b/net/dccp/probe.c
| > @@ -74,14 +74,11 @@ static void printl(const char *fmt, ...)
| >  static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
| >  			 struct msghdr *msg, size_t size)
| >  {
| > -	const struct dccp_minisock *dmsk = dccp_msk(sk);
| >  	const struct inet_sock *inet = inet_sk(sk);
| > -	const struct ccid3_hc_tx_sock *hctx;
| > +	struct ccid3_hc_tx_sock *hctx = NULL;
| >  
| > -	if (dmsk->dccpms_tx_ccid == DCCPC_CCID3)
| > +	if (ccid_get_current_id(dccp_sk(sk), false) == DCCPC_CCID3)
| 
| The use of boolean here also hurts the brain, I guess we could have
| ccid_get_current_rx_id or something along these lines?
| 
The only other place where ccid_get_current_id is called is in
do_dccp_getsockopt.

Rather than a yes/no, I think a third alternative is possible here:
it should actually not be necessary to have CCID-dependent code in
net/dccp/probe.c, i.e. in jdccp_write_xmit() we could have something like

f (!port || ntohs(inet->dport) == port || ntohs(inet->sport) == port) {

                tv  = ktime_to_timespec(ktime_sub(ktime_get(), dccpw.start));
                len = sprintf(buf, "%lu.%09lu %d.%d.%d.%d:%u %d.%d.%d.%d:%u %d",
                               (unsigned long)tv.tv_sec,
                               (unsigned long)tv.tv_nsec,
                               NIPQUAD(inet->saddr), ntohs(inet->sport),
                               NIPQUAD(inet->daddr), ntohs(inet->dport), ccid);

                len += ccid_hc_tx_print_sock_state(sk);
		/*     ^ new CCID-dependent function for printing */

		// ...

