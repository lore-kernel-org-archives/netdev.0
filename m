From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] net: netfilter: Fix undefined reference to
 nf_nat_redirect_* functions
Date: Wed, 26 Nov 2014 12:24:49 +0100
Message-ID: <20141126112449.GA4700@salvia>
References: <1416928034-10882-1-git-send-email-rupran@einserver.de>
 <1416994537-1592-1-git-send-email-rupran@einserver.de>
 <20141126102402.GA24801@breakpoint.cc>
 <5475AC6F.9010902@einserver.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andreas Ruprecht <rupran@einserver.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5475AC6F.9010902@einserver.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 26, 2014 at 11:33:19AM +0100, Andreas Ruprecht wrote:
> Sure.
> 
> When the file is compiled, i.e. CONFIG_NETFILTER_XT_TARGET_REDIRECT is
> selected, all headers will be included and all functions inside the file
> will be compiled, regardless of other Kconfig options.
> 
> This means redirect_tg6 and redirect_tg4 will be compiled (which doesn't
> necessarily mean they will be _called_) but the linker needs to resolve
> nf_nat_redirect_ipv4() due to the compilation of the redirect_tg4()
> function.
> 
> nf_nat_redirect_ip4() is defined in
> net/ipv4/netfilter/nf_nat_redirect_ipv4.c but this file is only included
> into the build when CONFIG_NF_NAT_REDIRECT_IPV4 is enabled.
> 
> Now when a kernel config enables CONFIG_NETFILTER_XT_TARGET_REDIRECT but
> _not_ CONFIG_NF_NAT_REDIRECT_IPV4, the declaration of
> nf_nat_redirect_ipv4() from the header
> <net/netfilter/ipv4/nf_nat_redirect.h> will have no definition (i.e., no
> implementation), causing the linker to report an "undefined reference".
> 
> Same logic goes for nf_nat_redirect_ipv6().

I'd suggest alternatives to resolve this problem:

1) Split xt_REDIRECT into ipt_REDIRECT and ip6t_REDIRECT, so we
restore the state of how this was back in 2012. The main motivation
behind that change was to reduce memory consumption by combining both
modules. In other modules, these combinations have been causing us
problems specifically when IPv6 symbols are used and it's not that
clean since IPv6 specific code remains there unused in the module even
if CONFIG_IPV6=n.

2) Merge nf_nat_redirect_ipv4 and nf_nat_redirect_ipv6 into
nf_nat_redirect, so we inconditionally build IPv6 redirect code, thus
xt_REDIRECT always finds the IPv6 symbol that needs even if it doesn't
use it.

3) Add #ifdef to xt_REDIRECT.c to make IPv6 specific code, this should
be a simple and small patch, but it results in #ifdef pollution.

Comments?

Thanks.
