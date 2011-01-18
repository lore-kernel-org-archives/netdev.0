From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH] ns83820: Avoid bad pointer deref in ns83820_init_one().
Date: Tue, 18 Jan 2011 14:11:42 +0000
Message-ID: <20110118141142.GA23317@hera.kernel.org>
References: <alpine.LNX.2.00.1101172116330.27021@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ns83820@kvack.org,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Kulikov Vasiliy <segooon@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1101172116330.27021@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 09:24:57PM +0100, Jesper Juhl wrote:
> In drivers/net/ns83820.c::ns83820_init_one() we dynamically allocate 
> memory via alloc_etherdev(). We then call PRIV() on the returned storage 
> which is 'return netdev_priv()'. netdev_priv() takes the pointer it is 
> passed and adds 'ALIGN(sizeof(struct net_device), NETDEV_ALIGN)' to it and 
> returns it. Then we test the resulting pointer for NULL, which it is 
> unlikely to be at this point, and later dereference it. This will go bad 
> if alloc_etherdev() actually returned NULL.
> 
> This patch reworks the code slightly so that we test for a NULL pointer 
> (and return -ENOMEM) directly after calling alloc_etherdev().
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Yeah, the previous code was a little bit ugly.
Good catch!
> ---
>  ns83820.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
>   Compile tested only. I have no way to test this for real.
> 
> diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
> index 84134c7..a41b2cf 100644
> --- a/drivers/net/ns83820.c
> +++ b/drivers/net/ns83820.c
> @@ -1988,12 +1988,11 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
>  	}
>  
>  	ndev = alloc_etherdev(sizeof(struct ns83820));
> -	dev = PRIV(ndev);
> -
>  	err = -ENOMEM;
> -	if (!dev)
> +	if (!ndev)
>  		goto out;
>  
> +	dev = PRIV(ndev);
>  	dev->ndev = ndev;
>  
>  	spin_lock_init(&dev->rx_info.lock);
> 
> 
> -- 
> Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
