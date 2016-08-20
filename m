From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Re: [PATCH] wan-cosa: Use memdup_user() rather than duplicating its
 implementation
Date: Sat, 20 Aug 2016 10:42:54 +0200
Message-ID: <np956e$tnp$1@blaine.gmane.org>
References: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 20/08/2016 à 10:25, SF Markus Elfring a écrit :
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 20 Aug 2016 10:10:12 +0200
>
> Reuse existing functionality from memdup_user() instead of keeping
> duplicate source code.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>   drivers/net/wan/cosa.c | 12 +++---------
>   1 file changed, 3 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
> index b87fe0a..02f5809 100644
> --- a/drivers/net/wan/cosa.c
> +++ b/drivers/net/wan/cosa.c
> @@ -875,16 +875,10 @@ static ssize_t cosa_write(struct file *file,
>   	if (count > COSA_MTU)
>   		count = COSA_MTU;
>   	
> -	/* Allocate the buffer */
> -	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
In this case, 'memdup_user()' has a different meaning, as GFP_DMA will 
no more be used for this memory allocation.

> -	if (kbuf == NULL) {
> +	kbuf = memdup_user(buf, count);
> +	if (IS_ERR(kbuf)) {
>   		up(&chan->wsem);
> -		return -ENOMEM;
> -	}
> -	if (copy_from_user(kbuf, buf, count)) {
> -		up(&chan->wsem);
> -		kfree(kbuf);
> -		return -EFAULT;
> +		return PTR_ERR(kbuf);
>   	}
>   	chan->tx_status=0;
>   	cosa_start_tx(chan, kbuf, count);



---
L'absence de virus dans ce courrier électronique a été vérifiée par le logiciel antivirus Avast.
https://www.avast.com/antivirus
