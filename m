From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] mpls: allow TTL propagation to/from IP packets
 to be configured
Date: Mon, 30 Jan 2017 17:41:43 -0700
Message-ID: <ba156f62-975d-bfbf-0912-e470ce9143b3@cumulusnetworks.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>,
        ebiederm@xmission.com
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33229 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754475AbdAaAvL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 19:51:11 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so96094569pfb.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 16:50:53 -0800 (PST)
In-Reply-To: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 1:36 PM, Robert Shearman wrote:
> It is sometimes desirable to present an MPLS transport network as a
> single hop to traffic transiting it because it prevents confusion when
> diagnosing failures. An example of where confusion can be generated is
> when addresses used in the provider network overlap with addresses in
> the overlay network and the addresses get exposed through ICMP errors
> generated as packets transit the provider network.
> 
> Therefore, provide the ability to control whether the TTL value from
> an MPLS packet is propagated to an IPv4/IPv6 packet when the last
> label is popped through the addition of a new per-namespace sysctl:
> "net.mpls.ip_ttl_propagate" which defaults to enabled.
> 
> Use the same sysctl to control whether the TTL is propagated from IP
> packets into the MPLS header. If the TTL isn't propagated then a
> default TTL value is used which can be configured via a new sysctl:
> "net.mpls.default_ttl".
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  Documentation/networking/mpls-sysctl.txt | 19 +++++++++
>  include/net/netns/mpls.h                 |  3 ++
>  net/mpls/af_mpls.c                       | 70 ++++++++++++++++++++++++--------
>  net/mpls/mpls_iptunnel.c                 | 12 +++++-
>  4 files changed, 85 insertions(+), 19 deletions(-)
> 
> diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
> index 15d8d16934fd..b8f0725ff09e 100644
> --- a/Documentation/networking/mpls-sysctl.txt
> +++ b/Documentation/networking/mpls-sysctl.txt
> @@ -19,6 +19,25 @@ platform_labels - INTEGER
>  	Possible values: 0 - 1048575
>  	Default: 0
>  
> +ip_ttl_propagate - BOOL
> +	Control whether TTL is propagated from the IPv4/IPv6 header to
> +	the MPLS header on imposing labels and propagated from the
> +	MPLS header to the IPv4/IPv6 header on popping the last label.
> +
> +	If disabled, the MPLS transport network will appear as a
> +	single hop to transit traffic.
> +
> +	0 - disabled
> +	1 - enabled (default)
> +

It seems like you are going after RFC 3443 with this change. Can you add comment to that effect? i.e.,  ip_ttl_propagate enabled is the Uniform Model and ip_ttl_propagate disabled is the Short Pipe Model.
