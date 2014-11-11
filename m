From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix memory leak in auth key management
Date: Tue, 11 Nov 2014 07:06:00 -0500
Message-ID: <20141111120600.GB31973@hmsreliant.think-freely.org>
References: <1415638809-20288-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39527 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbaKKMGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 07:06:21 -0500
Content-Disposition: inline
In-Reply-To: <1415638809-20288-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 06:00:09PM +0100, Daniel Borkmann wrote:
> A very minimal and simple user space application allocating an SCTP
> socket, setting SCTP_AUTH_KEY setsockopt(2) on it and then closing
> the socket again will leak the memory containing the authentication
> key from user space:
> 
> unreferenced object 0xffff8800837047c0 (size 16):
>   comm "a.out", pid 2789, jiffies 4296954322 (age 192.258s)
>   hex dump (first 16 bytes):
>     01 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff816d7e8e>] kmemleak_alloc+0x4e/0xb0
>     [<ffffffff811c88d8>] __kmalloc+0xe8/0x270
>     [<ffffffffa0870c23>] sctp_auth_create_key+0x23/0x50 [sctp]
>     [<ffffffffa08718b1>] sctp_auth_set_key+0xa1/0x140 [sctp]
>     [<ffffffffa086b383>] sctp_setsockopt+0xd03/0x1180 [sctp]
>     [<ffffffff815bfd94>] sock_common_setsockopt+0x14/0x20
>     [<ffffffff815beb61>] SyS_setsockopt+0x71/0xd0
>     [<ffffffff816e58a9>] system_call_fastpath+0x12/0x17
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> This is bad because of two things, we can bring down a machine from
> user space when auth_enable=1, but also we would leave security sensitive
> keying material in memory without clearing it after use. The issue is
> that sctp_auth_create_key() already sets the refcount to 1, but after
> allocation sctp_auth_set_key() does an additional refcount on it, and
> thus leaving it around when we free the socket.
> 
> Fixes: 65b07e5d0d0 ("[SCTP]: API updates to suport SCTP-AUTH extensions.")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> ---
>  net/sctp/auth.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/sctp/auth.c b/net/sctp/auth.c
> index 0e85291..fb7976a 100644
> --- a/net/sctp/auth.c
> +++ b/net/sctp/auth.c
> @@ -862,8 +862,6 @@ int sctp_auth_set_key(struct sctp_endpoint *ep,
>  		list_add(&cur_key->key_list, sh_keys);
>  
>  	cur_key->key = key;
> -	sctp_auth_key_hold(key);
> -
>  	return 0;
>  nomem:
>  	if (!replace)
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
