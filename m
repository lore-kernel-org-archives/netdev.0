From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next] GRE: Use strlcat() for size checking
Date: Wed, 27 Mar 2013 20:06:16 +0000
Message-ID: <1364414776.2922.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <1364410111-29418-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-next@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1364410111-29418-1-git-send-email-geert@linux-m68k.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-03-27 at 19:48 +0100, Geert Uytterhoeven wrote:
> On m68k, gcc tries to be smart and turns
> 
>     strncat(name, "%d", 2);
> 
> into a call to strlen() and a 16-bit store, causing a link failure,
> as arch/m68k/include/asm/string.h provides strlen() using a macro:
> 
>     ERROR: "strlen" [net/ipv4/ip_tunnel.ko] undefined!

Perhaps you should fix the string library for m68k, then!

> Use strlcat() instead to avoid this, which also allows to simplify the
> check for buffer overflows.

It looks like you're also fixing an off-by-one error: the maximum length
of ops->kind will be IFNAMSIZ - 3 (just enough to add "%d" and the null
terminator), rather than IFNAMSIZ - 4.

Ben.

> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> --
> Compile-tested only
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/8462108/
> ---
>  net/ipv4/ip_tunnel.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 9d96b68..8dbe672 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -284,12 +284,11 @@ static struct net_device *__ip_tunnel_create(struct net *net,
>  	if (parms->name[0])
>  		strlcpy(name, parms->name, IFNAMSIZ);
>  	else {
> -		if (strlen(ops->kind) + 3 >= IFNAMSIZ) {
> +		strlcpy(name, ops->kind, IFNAMSIZ);
> +		if (strlcat(name, "%d", IFNAMSIZ) >= IFNAMSIZ) {
>  			err = -E2BIG;
>  			goto failed;
>  		}
> -		strlcpy(name, ops->kind, IFNAMSIZ);
> -		strncat(name, "%d", 2);
>  	}
>  
>  	ASSERT_RTNL();

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
