From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] openvswitch: call only into reachable nf-nat code
Date: Wed, 16 Mar 2016 14:25:36 +0100
Message-ID: <20160316132536.GA29550@salvia>
References: <1458132481-318209-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Joe Stringer <joestringer@nicira.com>,
	Paolo Abeni <pabeni@redhat.com>,
	Jarno Rajahalme <jarno@ovn.org>, netdev@vger.kernel.org,
	dev@openvswitch.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58685 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965943AbcCPNZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 09:25:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id E6BD9C1266
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 14:25:39 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D633DDA380
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 14:25:39 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C9581DA390
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 14:25:37 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1458132481-318209-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 01:47:13PM +0100, Arnd Bergmann wrote:
> The openvswitch code has gained support for calling into the
> nf-nat-ipv4/ipv6 modules, however those can be loadable modules
> in a configuration in which openvswitch is built-in, leading
> to link errors:
> 
> net/built-in.o: In function `__ovs_ct_lookup':
> :(.text+0x2cc2c8): undefined reference to `nf_nat_icmp_reply_translation'
> :(.text+0x2cc66c): undefined reference to `nf_nat_icmpv6_reply_translation'
> 
> The dependency on (!NF_NAT || NF_NAT) was meant to prevent
> this, but NF_NAT is set to 'y' if any of the symbols selecting
> it are built-in, but the link error happens when any of them
> are modular.
> 
> A second issue is that even if CONFIG_NF_NAT_IPV6 is built-in,
> CONFIG_NF_NAT_IPV4 might be completely disabled. This is unlikely
> to be useful in practice, but the driver currently only handles
> IPv6 being optional.
> 
> This patch improves the Kconfig dependency so that openvswitch
> cannot be built-in if either of the two other symbols are set
> to 'm', and it replaces the incorrect #ifdef in ovs_ct_nat_execute()
> with two "if (IS_ENABLED())" checks that should catch all corner
> cases also make the code more readable.
> 
> The same #ifdef exists ovs_ct_nat_to_attr(), where it does not
> cause a link error, but for consistency I'm changing it the same
> way.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 05752523e565 ("openvswitch: Interface with NAT.")
> ---
>  net/openvswitch/Kconfig     |  3 ++-
>  net/openvswitch/conntrack.c | 16 ++++++++--------
>  2 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
> index 234a73344c6e..961fb60115df 100644
> --- a/net/openvswitch/Kconfig
> +++ b/net/openvswitch/Kconfig
> @@ -7,7 +7,8 @@ config OPENVSWITCH
>  	depends on INET
>  	depends on !NF_CONNTRACK || \
>  		   (NF_CONNTRACK && ((!NF_DEFRAG_IPV6 || NF_DEFRAG_IPV6) && \
> -				     (!NF_NAT || NF_NAT)))
> +				     (!NF_NAT_IPV4 || NF_NAT_IPV4) && \
> +				     (!NF_NAT_IPV6 || NF_NAT_IPV6)))

Not related with this patch, just a side note/recommendation.

I understand this code just got into tree, and that this needs a bit
work/iterations but this thing above is ugly, I wonder if there is a
better way to avoid this.

Probably with some modularization of the openvswitch code this will
look better, I mean:

1) adding Kconfig switches to enable conntrack and NAT support to
   net/openvswitch/Kconfig.

2) Move the NAT code to the corresponding openvswitch/nat.c file.

Just my two cents.
