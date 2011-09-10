From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -next] drivers/net: Makefile, fix netconsole link order
Date: Fri, 9 Sep 2011 21:10:29 -0700
Message-ID: <20110909211029.69dfd68d.akpm@linux-foundation.org>
References: <1315298129.16061.24.camel@snb>
	<20110909170027.c4bf6151.akpm@linux-foundation.org>
	<1315622612.2425.16.camel@hp6530s>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Lin Ming <ming.m.lin@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315622612.2425.16.camel@hp6530s>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 10 Sep 2011 10:43:32 +0800 Lin Ming <ming.m.lin@intel.com> wrote:

> On Sat, 2011-09-10 at 08:00 +0800, Andrew Morton wrote:
>
> > > +obj-$(CONFIG_NETCONSOLE) += netconsole.o
> > 
> > It would be preferable to fix this with initcall ordering.  Perhaps by
> > switching init_netconsole() to subsys_initcall.
> 
> subsys_initcall is defined as __define_initcall("4",fn,4).
> In !MODULE case, device driver module_int() is defined as
> __define_initcall("6",fn,6)

oop, yes, I am chronologically challenged.

> If we use subsys_initcall for init_netconsole, it will still be called
> before network device driver is initialized.
> 
> How about late_initcall?
> 
> (Not tested yet)
> 
> >From 11f4f035e96ff430192d0a75552dd715acb5f3b8 Mon Sep 17 00:00:00 2001
> From: Lin Ming <ming.m.lin@intel.com>
> Date: Sat, 10 Sep 2011 10:36:10 +0800
> Subject: [PATCH] drivers/net: Makefile, fix netconsole link order
> 
> Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
> regression that netconsole does not work if netconsole and network
> device driver are build into kernel, because netconsole is linked before
> network device driver.
> 
> Fixes it by switching init_netconsole() to late_initcall if it's
> build-in.
> 
> Signed-off-by: Lin Ming <ming.m.lin@intel.com>
> ---
>  drivers/net/netconsole.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> index dfc8272..914be29 100644
> --- a/drivers/net/netconsole.c
> +++ b/drivers/net/netconsole.c
> @@ -799,5 +799,9 @@ static void __exit cleanup_netconsole(void)
>  	}
>  }
>  
> +#ifdef MODULE
>  module_init(init_netconsole);
>  module_exit(cleanup_netconsole);
> +#else
> +late_initcall(init_netconsole);
> +#endif /* !MODULE */

That should work, unless any net driver is weirdly also using
late_initcall.  But if there are such drivers, they would have failed
with the old Makefile ordering.
