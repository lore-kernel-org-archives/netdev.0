From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix NULL pointer dereference in
 af->from_addr_param on malformed packet
Date: Tue, 11 Nov 2014 07:05:17 -0500
Message-ID: <20141111120517.GA31973@hmsreliant.think-freely.org>
References: <1415638466-20176-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39504 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbaKKMFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 07:05:31 -0500
Content-Disposition: inline
In-Reply-To: <1415638466-20176-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 05:54:26PM +0100, Daniel Borkmann wrote:
> An SCTP server doing ASCONF will panic on malformed INIT ping-of-death
> in the form of:
> 
>   ------------ INIT[PARAM: SET_PRIMARY_IP] ------------>
> 
> While the INIT chunk parameter verification dissects through many things
> in order to detect malformed input, it misses to actually check parameters
> inside of parameters. E.g. RFC5061, section 4.2.4 proposes a 'set primary
> IP address' parameter in ASCONF, which has as a subparameter an address
> parameter.
> 
> So an attacker may send a parameter type other than SCTP_PARAM_IPV4_ADDRESS
> or SCTP_PARAM_IPV6_ADDRESS, param_type2af() will subsequently return 0
> and thus sctp_get_af_specific() returns NULL, too, which we then happily
> dereference unconditionally through af->from_addr_param().
> 
> The trace for the log:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000078
> IP: [<ffffffffa01e9c62>] sctp_process_init+0x492/0x990 [sctp]
> PGD 0
> Oops: 0000 [#1] SMP
> [...]
> Pid: 0, comm: swapper Not tainted 2.6.32-504.el6.x86_64 #1 Bochs Bochs
> RIP: 0010:[<ffffffffa01e9c62>]  [<ffffffffa01e9c62>] sctp_process_init+0x492/0x990 [sctp]
> [...]
> Call Trace:
>  <IRQ>
>  [<ffffffffa01f2add>] ? sctp_bind_addr_copy+0x5d/0xe0 [sctp]
>  [<ffffffffa01e1fcb>] sctp_sf_do_5_1B_init+0x21b/0x340 [sctp]
>  [<ffffffffa01e3751>] sctp_do_sm+0x71/0x1210 [sctp]
>  [<ffffffffa01e5c09>] ? sctp_endpoint_lookup_assoc+0xc9/0xf0 [sctp]
>  [<ffffffffa01e61f6>] sctp_endpoint_bh_rcv+0x116/0x230 [sctp]
>  [<ffffffffa01ee986>] sctp_inq_push+0x56/0x80 [sctp]
>  [<ffffffffa01fcc42>] sctp_rcv+0x982/0xa10 [sctp]
>  [<ffffffffa01d5123>] ? ipt_local_in_hook+0x23/0x28 [iptable_filter]
>  [<ffffffff8148bdc9>] ? nf_iterate+0x69/0xb0
>  [<ffffffff81496d10>] ? ip_local_deliver_finish+0x0/0x2d0
>  [<ffffffff8148bf86>] ? nf_hook_slow+0x76/0x120
>  [<ffffffff81496d10>] ? ip_local_deliver_finish+0x0/0x2d0
> [...]
> 
> A minimal way to address this is to check for NULL as we do on all
> other such occasions where we know sctp_get_af_specific() could
> possibly return with NULL.
> 
> Fixes: d6de3097592b ("[SCTP]: Add the handling of "Set Primary IP Address" parameter to INIT")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> ---
>  net/sctp/sm_make_chunk.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index ab734be..9f32741 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2609,6 +2609,9 @@ do_addr_param:
>  		addr_param = param.v + sizeof(sctp_addip_param_t);
>  
>  		af = sctp_get_af_specific(param_type2af(param.p->type));
> +		if (af == NULL)
> +			break;
> +
>  		af->from_addr_param(&addr, addr_param,
>  				    htons(asoc->peer.port), 0);
>  
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
