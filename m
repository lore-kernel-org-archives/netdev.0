From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv4: in new netns initialize sysctls in net.ipv4.conf.* with defaults
Date: Sun, 21 Feb 2016 16:06:22 -0600
Message-ID: <87egc5en1d.fsf@x220.int.ebiederm.org>
References: <20160221071102.9686.63148.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	containers@lists.linux-foundation.org,
	Vasily Averin <vvs@virtuozzo.com>, linux-kernel@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38142 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbcBUWQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 17:16:40 -0500
In-Reply-To: <20160221071102.9686.63148.stgit@buzz> (Konstantin Khlebnikov's
	message of "Sun, 21 Feb 2016 10:11:02 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Konstantin Khlebnikov <khlebnikov@yandex-team.ru> writes:

> Currently initial net.ipv4.conf.all.* and net.ipv4.conf.default.* are
> copied from init network namespace because static structures are used
> for init_net. This makes no sense because new netns might be created
> from any netns. This patch makes private copy also for init netns if
> network namespaces are enabled. Other sysctls in net.ipv4 and net.ipv6
> already initialized with default values at namespace creation.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Assuming that this does not cause a regression I am all for this,
as it makes the kernels behavior predictable.

When creating a network namespace we have two predictable choices.
Copy from the current network namespace, or initialize all sysctl values
with the kernel's defaults.  Copying values looks like a way to
introduce subtle hard to debug breakage into existing setups.  So all
else being equal my preference is that we initialize values in new
nework namespaces to their initial defaults.

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 752d14dc6aa9 ("[IPV4]: Move the devinet pointers on the struct net")
> ---
>  net/ipv4/devinet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index cebd9d31e65a..9d73d4bbdba3 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -2290,7 +2290,7 @@ static __net_init int devinet_init_net(struct net *net)
>  	all = &ipv4_devconf;
>  	dflt = &ipv4_devconf_dflt;
>  
> -	if (!net_eq(net, &init_net)) {
> +	if (IS_ENABLED(CONFIG_NET_NS)) {
>  		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
>  		if (!all)
>  			goto err_alloc_all;
