From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: fix unix_nr_socks check in unix_create1()
Date: Sat, 25 Aug 2012 08:43:09 +0200
Message-ID: <1345876989.19483.83.camel@edumazet-glaptop>
References: <1345874753-7214-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62324 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab2HYGnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 02:43:15 -0400
Received: by weyx8 with SMTP id x8so1401484wey.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 23:43:14 -0700 (PDT)
In-Reply-To: <1345874753-7214-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-25 at 02:05 -0400, Xi Wang wrote:
> This patch complements 518de9b3 ("fs: allow for more than 2^31 files").
> 
> get_max_files() returns files_stat.max_files, which can be set to any
> value from user space via /proc/sys/fs/file-max.  A large file-max will
> cause an integer overflow in the following check:
> 
> 	if (atomic_long_read(&unix_nr_socks) > 2 * get_max_files())
> 		goto out;
> 
> The kernel will then fail to create a unix domain socket.
> 
> Rewrite the check using "/ 2" on the left-hand side.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/unix/af_unix.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index c5ee4ff..99a8bc9 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -630,9 +630,9 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
>  {
>  	struct sock *sk = NULL;
>  	struct unix_sock *u;
> +	unsigned long nr_socks = atomic_long_inc_return(&unix_nr_socks);
>  
> -	atomic_long_inc(&unix_nr_socks);
> -	if (atomic_long_read(&unix_nr_socks) > 2 * get_max_files())
> +	if (nr_socks / 2 > get_max_files())
>  		goto out;
>  
>  	sk = sk_alloc(net, PF_UNIX, GFP_KERNEL, &unix_proto);

I dont think this patch is right.

atomic_long_inc_return() is expensive, more than atomic_long_inc()

And setting a 2^63 limit for max number of files is plain wrong,
as there is no way a kernel can allocate 2^63 files structures.

(same apply on 32bit arches, but for 2^31)

If you feel you must warn a sysadmin of stupid settings, add sane
boundaries in kernel/sysctl.c, and send your patch to lkml instead.
