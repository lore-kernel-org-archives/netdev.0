From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Mon, 22 Aug 2016 14:21:24 +0200
Message-ID: <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        buytenh@wantstofly.org, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36516 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752807AbcHVMV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 08:21:27 -0400
Received: by mail-wm0-f50.google.com with SMTP id q128so118362117wma.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 05:21:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 10:09:01AM -0700, David Ahern wrote:
> As reported by Lennert the MPLS GSO code is failing to properly segment
> large packets. There are a couple of problems:
> 
> 1. the inner protocol is not set so the gso segment functions for inner
>    protocol layers are not getting run, and
> 
> 2  MPLS labels for packets that use the "native" (non-OVS) MPLS code
>    are not properly accounted for in mpls_gso_segment.
> 
> The MPLS GSO code was added for OVS. It is re-using skb_mac_gso_segment
> to call the gso segment functions for the higher layer protocols. That
> means skb_mac_gso_segment is called twice -- once with the network
> protocol set to MPLS and again with the network protocol set to the
> inner protocol.
> 
> This patch sets the inner skb protocol addressing item 1 above and sets
> the network_header and inner_network_header to mark where the MPLS labels
> start and end. The MPLS code in OVS is also updated to set the two
> network markers.
> 
> From there the MPLS GSO code uses the difference between the network
> header and the inner network header to know the size of the MPLS header
> that was pushed. It then pulls the MPLS header, resets the mac_len and
> protocol for the inner protocol and then calls skb_mac_gso_segment
> to segment the skb.
> 
> Afterward the inner protocol segmentation is done the skb protocol
> is set to mpls for each segment and the network and mac headers
> restored.
> 
> Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/mpls/mpls_gso.c       | 38 +++++++++++++++++++++++++++-----------
>  net/mpls/mpls_iptunnel.c  |  4 ++++
>  net/openvswitch/actions.c |  6 ++++++
>  3 files changed, 37 insertions(+), 11 deletions(-)
> 
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index 2055e57ed1c3..2aa4beaa0e4f 100644

...

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1ecbd7715f6d..6d78f162a88b 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>  		skb->mac_len);
>  	skb_reset_mac_header(skb);
>  
> +	/* for GSO: set MPLS as network header and encapsulated protocol
> +	 * header as inner network header
> +	 */
> +	skb_set_network_header(skb, skb->mac_len);
> +	skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
> +
>  	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>  	*new_mpls_lse = mpls->mpls_lse;

Is the above calculation correct if push_mpls() is called multiple times?
