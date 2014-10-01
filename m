From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH 1/1 linux-next] ieee802154: add __init to
 lowpan_frags_sysctl_register
Date: Wed, 1 Oct 2014 02:25:01 +0200
Message-ID: <20141001002459.GA1007@omega>
References: <1412109249-7432-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36944 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaJAAZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:25:09 -0400
Content-Disposition: inline
In-Reply-To: <1412109249-7432-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Sep 30, 2014 at 10:34:08PM +0200, Fabian Frederick wrote:
> lowpan_frags_sysctl_register is only called by __init lowpan_net_frag_init
> (part of the lowpan module).
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> This is untested.
> 
>  net/ieee802154/reassembly.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
> index 32755cb..30ec608 100644
> --- a/net/ieee802154/reassembly.c
> +++ b/net/ieee802154/reassembly.c
> @@ -485,7 +485,7 @@ static void __net_exit lowpan_frags_ns_sysctl_unregister(struct net *net)
>  
>  static struct ctl_table_header *lowpan_ctl_header;
>  
> -static int lowpan_frags_sysctl_register(void)
> +static int __init lowpan_frags_sysctl_register(void)

yes right, but there is more lacks of missing "__init". See below.

>  {
>  	lowpan_ctl_header = register_net_sysctl(&init_net,
>  						"net/ieee802154/6lowpan",
> @@ -498,7 +498,7 @@ static void lowpan_frags_sysctl_unregister(void)
>  	unregister_net_sysctl_table(lowpan_ctl_header);
>  }
>  #else
> -static inline int lowpan_frags_ns_sysctl_register(struct net *net)
> +static inline int __init lowpan_frags_ns_sysctl_register(struct net *net)

This is wrong, it's callback from "struct pernet_operations lowpan_frags_ops".

>  {
>  	return 0;
>  }


Your patch adds "__init" now for two different functions and we have
two different declarations for these functions, depends if CONFIG_SYSCTL is
enabled.

Now if CONFIG_SYSCTL select we have as lowpan_frags_sysctl_register declaration:

static int __init lowpan_frags_sysctl_register(void)

if not:

static inline int lowpan_frags_sysctl_register(void)

Same for lowpan_frags_ns_sysctl_register and vice versa for CONFIG_SYSCTL.

Your changes are for two different functions (Don't know if you realized that):

"lowpan_frags_sysctl_register" and "lowpan_frags_ns_sysctl_register",
which makes no sense. Also lowpan_frags_ns_sysctl_register isn't called
by module init which is wrong.


To make "correct" cleanup for this "__init" should be add to the functions, for
both declarations if CONFIG_SYSCTL is set or not:

 - lowpan_net_frag_init
 - lowpan_frags_sysctl_register


I see now it's already applied, David please revert this change. Are you
fine to apply a correct version of this to wpan-next tree, next time?

- Alex
