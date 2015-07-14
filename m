From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Tue, 14 Jul 2015 15:42:03 +0200
Message-ID: <20150714134203.GG25674@breakpoint.cc>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150714122311.8DA8EA0C9A-OEaqT8BN2ewCVLCxKZUutA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org> wrote:
> +	case SCTP_CID_HEARTBEAT:
> +		pr_debug("SCTP_CID_HEARTBEAT");
> +		i = 9;
> +		break;
> +	case SCTP_CID_HEARTBEAT_ACK:
> +		pr_debug("SCTP_CID_HEARTBEAT_ACK");
> +		i = 10;
> +		break;
>  	default:
>  		/* Other chunks like DATA, SACK, HEARTBEAT and
>  		its ACK do not cause a change in state */
> @@ -329,6 +351,8 @@ static int sctp_packet(struct nf_conn *ct,
>  	    !test_bit(SCTP_CID_COOKIE_ECHO, map) &&
>  	    !test_bit(SCTP_CID_ABORT, map) &&
>  	    !test_bit(SCTP_CID_SHUTDOWN_ACK, map) &&
> +	    !test_bit(SCTP_CID_HEARTBEAT, map) &&
> +	    !test_bit(SCTP_CID_HEARTBEAT_ACK, map) &&
>  	    sh->vtag != ct->proto.sctp.vtag[dir]) {
>  		pr_debug("Verification tag check failed\n");
>  		goto out;
> @@ -357,6 +381,16 @@ static int sctp_packet(struct nf_conn *ct,
>  			/* Sec 8.5.1 (D) */
>  			if (sh->vtag != ct->proto.sctp.vtag[dir])
>  				goto out_unlock;
> +		} else if (sch->type == SCTP_CID_HEARTBEAT ||
> +			   sch->type == SCTP_CID_HEARTBEAT_ACK) {
> +			if (ct->proto.sctp.vtag[dir] == 0) {
> +				pr_debug("Setting vtag %x for dir %d\n",
> +					 sh->vtag, dir);
> +				ct->proto.sctp.vtag[dir] = sh->vtag;

Could you please elaborate on the [dir] == 0 test?

I see this might happen for SCTP_CID_HEARTBEAT_ACK, but why is this
needed for SCTP_CID_HEARTBEAT ?

We found a conntrack entry so shouldn't the vtag[dir] already be > 0?
