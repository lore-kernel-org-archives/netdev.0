From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] sctp: Implement quick failover draft from tsvwg
Date: Wed, 18 Jul 2012 13:30:58 -0700
Message-ID: <1342643458.2013.32.camel@joe2Laptop>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
	 <1342634466-17930-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54382 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755917Ab2GRUbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:31:00 -0400
In-Reply-To: <1342634466-17930-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0400, Neil Horman wrote:
> I've seen several attempts recently made to do quick failover of sctp transports
> by reducing various retransmit timers and counters.  While its possible to
> implement a faster failover on multihomed sctp associations, its not
> particularly robust, in that it can lead to unneeded retransmits, as well as
> false connection failures due to intermittent latency on a network.

trivia:

> diff --git a/net/sctp/associola.c b/net/sctp/associola.c

> @@ -871,6 +885,10 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>  		spc_state = SCTP_ADDR_UNREACHABLE;
>  		break;
>  
> +	case SCTP_TRANSPORT_PF:
> +		transport->state = SCTP_PF;
> +		ulp_notify = false;
> +		break;

nicer to add a newline here

>  	default:
>  		return;
>  	}
> @@ -878,12 +896,15 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
[]
> +	if (ulp_notify) {
> +		memset(&addr, 0, sizeof(struct sockaddr_storage));
> +		memcpy(&addr, &transport->ipaddr,
> +		       transport->af_specific->sockaddr_len);

Perhaps it's better to do the memcpy then the memset of the
space left instead.

		memcpy(&addr, &transport->ipaddr, transport->af_specific->sockaddr_len);
		memset((char *)&addr) + transport->af_specific->sockaddr_len, 0,
		       sizeof(struct sockaddr_storage) - transport->af_specific->sockaddr_len);
		       
