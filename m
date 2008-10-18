From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: 2.6.27 [BUG-FIX] [PATCH 1/1] dccp: Port redirection support
 =?iso-8859-1?q?for=09DCCP?=
Date: Sat, 18 Oct 2008 11:48:14 +0200
Message-ID: <200810181148.14620@nessa>
References: <20081018092118.GA22685@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:65346 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbYJRJsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 05:48:16 -0400
Received: from nessa.odu ([89.132.101.55])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTPSA id <0K8X00KCTHV7NB30@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 18 Oct 2008 11:47:31 +0200 (CEST)
In-reply-to: <20081018092118.GA22685@gerrit.erg.abdn.ac.uk>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Saturday 18 October 2008, Gerrit Renker wrote:
> Commit a3116ac5c216fc3c145906a46df9ce542ff7dcf2 from 1st October ("tcp:
> Port redirection support for TCP") broke DCCP skb lookup by changing
> inet_csk_clone, which is used by DCCP to generate the child socket
> after the handshake.
>
> This patch updates DCCP to use 'loc_port' instead of 'sport', which
> fixes the problem, and thus inheriting port redirection support via the
> new interface.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Yeah, Gerrit and me simultaneously found this to be the culprit.
One minor comment below.

> ---
>  net/dccp/ipv6.c      |    2 +-
>  net/dccp/minisocks.c |    1 +
>  net/dccp/output.c    |    2 +-
>  3 files changed, 3 insertions(+), 2 deletions(-)
>
> --- a/net/dccp/minisocks.c
> +++ b/net/dccp/minisocks.c
> @@ -309,6 +309,7 @@ void dccp_reqsk_init(struct request_sock
>  	struct dccp_request_sock *dreq = dccp_rsk(req);
>
>  	inet_rsk(req)->rmt_port	  = dccp_hdr(skb)->dccph_sport;
> +	inet_rsk(req)->loc_port	  = dccp_hdr(skb)->dccph_dport;
>  	inet_rsk(req)->acked	  = 0;
>  	req->rcv_wnd		  = sysctl_dccp_feat_sequence_window;
>  	dreq->dreq_timestamp_echo = 0;
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -259,7 +259,7 @@ static int dccp_v6_send_response(struct
>  	fl.fl6_flowlabel = 0;
>  	fl.oif = ireq6->iif;
>  	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
> -	fl.fl_ip_sport = inet_sk(sk)->sport;
> +	fl.fl_ip_sport = inet_rsk(req)->loc_port;
>  	security_req_classify_flow(req, &fl);
>
>  	opt = np->opt;
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -347,7 +347,7 @@ struct sk_buff *dccp_make_response(struc
>  	/* Build and checksum header */
>  	dh = dccp_zeroed_hdr(skb, dccp_header_size);
>
> -	dh->dccph_sport	= inet_sk(sk)->sport;
> +	dh->dccph_sport	= inet_rsk(req)->loc_port;
>  	dh->dccph_dport	= inet_rsk(req)->rmt_port;
>  	dh->dccph_doff	= (dccp_header_size +
>  			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;

I think we're still missing this one:

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1106278..aa00cdd 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -558,7 +558,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		ipv6_addr_copy(&fl.fl6_src, &ireq6->loc_addr);
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
-		fl.fl_ip_sport = inet_sk(sk)->sport;
+		fl.fl_ip_sport = inet_rsk(req)->loc_port;
 		security_sk_classify_flow(sk, &fl);
 
 		if (ip6_dst_lookup(sk, &dst, &fl))

What do you think?

-- 
KOVACS Krisztian
