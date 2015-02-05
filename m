From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] NetCP: Deletion of unnecessary checks before two
 function calls
Date: Thu, 5 Feb 2015 15:01:38 +0300
Message-ID: <20150205120138.GD5336@mwanda>
References: <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <54D11FEF.10804@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Murali Karicheri <m-karicheri2@ti.com>,
	Wingman Kwok <w-kwok2@ti.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Wingman Kwok <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54D11FEF.10804@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wingman,

There are some bugs in this error handling.

On Tue, Feb 03, 2015 at 08:22:23PM +0100, SF Markus Elfring wrote:
> diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
> index fa1041a..cbd6dde 100644
> --- a/drivers/net/ethernet/ti/netcp_ethss.c
> +++ b/drivers/net/ethernet/ti/netcp_ethss.c
> @@ -2010,12 +2010,10 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
>  quit:
>  	if (gbe_dev->hw_stats)
>  		devm_kfree(dev, gbe_dev->hw_stats);
> -	if (gbe_dev->ale)
> -		cpsw_ale_destroy(gbe_dev->ale);
> +	cpsw_ale_destroy(gbe_dev->ale);
>  	if (gbe_dev->ss_regs)
>  		devm_iounmap(dev, gbe_dev->ss_regs);
> -	if (interfaces)
> -		of_node_put(interfaces);
> +	of_node_put(interfaces);
                    ^^^^^^^^^^
"interfaces" is sometimes unintialized in this code.  I don't know why
GCC doesn't catch this...  :(

This is a "one rrr bug", which is caused because you just have one error
label "quit" which handles all the error handling.  Please read my
Google+ comment on error handling.

https://plus.google.com/106378716002406849458/posts/dnanfhQ4mHQ

>  	devm_kfree(dev, gbe_dev);
        ^^^^^^^^^^^^^^^^^^^^^^^^
This is not the right way to use the devm_ interface.  These things are
freed automatically on error or when we are done with them.  This driver
is double freeing pretty much everything.  Grep for devm_kfree() and
fix everything.

I don't know why kbuild didn't catch this...

regards
dan carpenter
