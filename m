From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Staging: dst: fix 'Client is not allowed' on sparc
Date: Wed, 16 Dec 2009 21:24:33 +0300
Message-ID: <20091216182433.GA28134@ioremap.net>
References: <1260716147-1569-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sparclinux@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:50851 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762773AbZLPSYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 13:24:36 -0500
Content-Disposition: inline
In-Reply-To: <1260716147-1569-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander.

Sorry for late response.
Your patch looks good, I will forward it to GregKH for inclusion.
Thank you.

On Sun, Dec 13, 2009 at 05:55:47PM +0300, Alexander Beregalov (a.beregalov@gmail.com) wrote:
> 
> Not for applying, only describe the problem.
> 
> 
> There is a warning on sparc
>  Kernel unaligned access at TPC[6c0dec] inet_getname+0x4c/0xc0
> which goes from
> 	net/ipv4/af_inet.c:
> 	int inet_getname(
> 		...
> 		*uaddr_len = sizeof(*sin);
> 
> sizeof(*sin) is 16, but inet_getname sets sa_data_len to 0.
> That is why client is denied to access the device.
> inet_getname() does not read uaddr_len, only
> writes, so move initialization of sa_data_len after it.
> Make struct saddr aligned similar to
> struct __kernel_sockaddr_storage. This fixes the warning.
> 
> ---
>  drivers/staging/dst/export.c |    2 +-
>  include/linux/dst.h          |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/dst/export.c b/drivers/staging/dst/export.c
> index c324230..4644804 100644
> --- a/drivers/staging/dst/export.c
> +++ b/drivers/staging/dst/export.c
> @@ -166,12 +166,12 @@ static struct dst_state *dst_accept_client(struct dst_state *st)
>  	}
>  	new->socket = sock;
>  
> -	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);
>  	err = kernel_getpeername(sock, (struct sockaddr *)&new->ctl.addr,
>  			(int *)&new->ctl.addr.sa_data_len);
>  	if (err)
>  		goto err_out_put;
>  
> +	new->ctl.addr.sa_data_len = sizeof(struct sockaddr);	
>  	new->permissions = dst_check_permissions(st, new);
>  	if (new->permissions == 0) {
>  		err = -EPERM;
> diff --git a/include/linux/dst.h b/include/linux/dst.h
> index e26fed8..454b15a 100644
> --- a/include/linux/dst.h
> +++ b/include/linux/dst.h
> @@ -74,10 +74,10 @@ struct saddr {
>  	/* address family, AF_xxx	*/
>  	unsigned short		sa_family;
>  	/* 14 bytes of protocol address	*/
> -	char			sa_data[SADDR_MAX_DATA];
> +	char			sa_data[SADDR_MAX_DATA - sizeof(unsigned short)];
>  	/* Number of bytes used in sa_data */
>  	unsigned short		sa_data_len;
> -};
> +} __attribute__((aligned(16)));	/* sizeof(struct sockaddr) */
>  
>  /* Address structure */
>  struct dst_network_ctl
> -- 
> 1.6.5.6

-- 
	Evgeniy Polyakov
