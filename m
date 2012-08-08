From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [RFC PATCH] tun: don't zeroize sock->file on detach
Date: Wed, 8 Aug 2012 16:53:27 +0400
Message-ID: <50226147.3010309@parallels.com>
References: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ruanzhijie@hotmail.com" <ruanzhijie@hotmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120711114753.24395.53193.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Dave.
What about this patch?

On Wed, Jul 11, 2012 at 03:48:20PM +0400, Stanislav Kinsbursky wrote:
> This is a fix for bug, introduced in 3.4 kernel by commit
> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things, replaced
> simple sock_put() by sk_release_kernel(). Below is sequence, which leads to
> oops for non-persistent devices:
>
> tun_chr_close()
> tun_detach()				<== tun->socket.file = NULL
> tun_free_netdev()
> sk_release_sock()
> sock_release(sock->file == NULL)
> iput(SOCK_INODE(sock))			<== dereference on NULL pointer
>
> This patch just removes zeroing of socket's file from __tun_detach().
> sock_release() will do this.
>
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  drivers/net/tun.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 987aeef..c1639f3 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -185,7 +185,6 @@ static void __tun_detach(struct tun_struct *tun)
>  	netif_tx_lock_bh(tun->dev);
>  	netif_carrier_off(tun->dev);
>  	tun->tfile = NULL;
> -	tun->socket.file = NULL;
>  	netif_tx_unlock_bh(tun->dev);
