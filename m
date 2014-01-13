From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: fix garbled TX error message
Date: Mon, 13 Jan 2014 20:15:19 +0400
Message-ID: <52D41117.3040809@cogentembedded.com>
References: <201401110241.49471.sergei.shtylyov@cogentembedded.com>	 <20140113004532.GJ15296@verge.net.au> <1389576241.24849.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Joe Perches <joe@perches.com>, Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1389576241.24849.10.camel@joe-AO722>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 13-012014 5:24, Joe Perches wrote:

>>> sh_eth_error() in case of a TX error tries to print a message using 2 dev_err()
>>> calls with the first string not finished by '\n', so that the resulting message
>>> would inevitably come out garbled, with something like "3net eth0: " inserted
>>> in the middle.  Avoid that by merging 2 calls into one.

> I believe this interleaving should not happen since
> commit e28d713704117bca0820c732210df6075b09f13b
> (2.6.31 days)

    I believe you have given me the wrong commit, which has nothing to do the 
the newline problem per se. It just adds KERN_DEFAULT. I was able to find the 
correct commit though: it's the parent of the commit you cited, 
5fd29d6ccbc98884569d6f3105aeca70858b3e0f -- so you're probably right, and I 
should have tested my assumption beforehand... (I'd like to merge these 
dev_err() calls still though).

> Perhaps it'd be better to use netdev_<level> and
> netif_<level> instead of dev_<level> and pr_<level>.

    Thank you, I got it the first time you suggested it, I just haven't had 
time to implement it yet.

> uncompiled/untested...

    Thanks for the patch. I don't agree with all of it though...

> ---
>
>   drivers/net/ethernet/renesas/sh_eth.c | 63 ++++++++++++++++-------------------
>   1 file changed, 28 insertions(+), 35 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 8884107..6baad48 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -2691,9 +2683,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   	/* read and set MAC address */
>   	read_mac_address(ndev, pd->mac_addr);
>   	if (!is_valid_ether_addr(ndev->dev_addr)) {
> -		dev_warn(&pdev->dev,
> -			 "no valid MAC address supplied, using a random one.\n");
>   		eth_hw_addr_random(ndev);
> +		dev_warn(&pdev->dev,
> +			 "no valid MAC address supplied, using random %pM\n",
> +			 ndev->dev_addr);

    There's no need to print random MAC address twice. It's already printed 
right below.

WBR, Sergei

