From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: don't allow CAP_NET_ADMIN to load non-netdev
 kernel modules
Date: Tue, 01 Mar 2011 20:13:10 +0000
Message-ID: <1299010390.2529.30.camel@bwh-desktop>
References: <201102272122.52643.arnd@arndb.de>
	 <4D6B6AE7.2050202@msgid.tls.msk.ru> <20110228095133.GA4351@albatros>
	 <20110228.112349.104067277.davem@davemloft.net>
	 <20110301194845.GA3533@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mjt@tls.msk.ru, arnd@arndb.de,
	mirqus@gmail.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110301194845.GA3533@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-03-01 at 22:48 +0300, Vasiliy Kulikov wrote:
> Since a8f80e8ff94ecba629542d9b4b5f5a8ee3eb565c any process with
> CAP_NET_ADMIN may load any module from /lib/modules/.  This doesn't mean
> that CAP_NET_ADMIN is a superset of CAP_SYS_MODULE as modules are
> limited to /lib/modules/**.  However, CAP_NET_ADMIN capability shouldn't
> allow anybody load any module not related to networking.
> 
> This patch restricts an ability of autoloading modules to netdev modules
> with explicit aliases.  This fixes CVE-2011-1019.
> 
> Arnd Bergmann suggested to leave untouched the old pre-v2.6.32 behavior
> of loading netdev modules by name (without any prefix) for processes
> with CAP_SYS_MODULE to maintain the compatibility with network scripts
> that use autoloading netdev modules by aliases like "eth0", "wlan0".
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ae6631..fc6f037 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1119,8 +1119,16 @@ void dev_load(struct net *net, const char *name)
>  	dev = dev_get_by_name_rcu(net, name);
>  	rcu_read_unlock();
>  
> -	if (!dev && capable(CAP_NET_ADMIN))
> -		request_module("%s", name);
> +	if (!dev) {
> +		if (capable(CAP_NET_ADMIN))
> +			request_module("netdev-%s", name);

If this succeeds then the second request_module() should be skipped.

> +		if (capable(CAP_SYS_MODULE)) {
> +			if (!request_module("%s", name))
> +				WARN_ONCE(1, "Loading kernel module for a "
> +"network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias "
> +"netdev-%s instead\n", name);
[...]

If this feature is to be deprecated, there should be an error message
for each interface that depends on it.  However, use of the feature is
not a bug so WARN is not appropriate.  I think pr_err() would be fine.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
