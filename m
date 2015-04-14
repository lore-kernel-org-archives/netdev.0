From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 15/17] switch kernel_sendmsg() and kernel_recvmsg() to
 iov_iter_kvec()
Date: Tue, 14 Apr 2015 16:21:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1DD9D@AcuExch.aculab.com>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:54947 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786AbbDNQW5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 12:22:57 -0400
In-Reply-To: <1428787108-13650-15-git-send-email-viro@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro
> Sent: 11 April 2015 22:18
> From: Al Viro <viro@zeniv.linux.org.uk>
> 
> For kernel_sendmsg() that eliminates the need to play with setfs();
> for kernel_recvmsg() it does *not* - a couple of callers are using
> it with non-NULL ->msg_control, which would be treated as userland
> address on recvmsg side of things.
> 
> In all cases we are really setting a kvec-backed iov_iter, though.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  net/socket.c | 20 +++-----------------
>  1 file changed, 3 insertions(+), 17 deletions(-)
> 
> diff --git a/net/socket.c b/net/socket.c
> index e5669ce..b6ceeda 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -627,18 +627,8 @@ EXPORT_SYMBOL(sock_sendmsg);
>  int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
>  		   struct kvec *vec, size_t num, size_t size)
>  {
> -	mm_segment_t oldfs = get_fs();
> -	int result;
> -
> -	set_fs(KERNEL_DS);
> -	/*
> -	 * the following is safe, since for compiler definitions of kvec and
> -	 * iovec are identical, yielding the same in-core layout and alignment
> -	 */
> -	iov_iter_init(&msg->msg_iter, WRITE, (struct iovec *)vec, num, size);
> -	result = sock_sendmsg(sock, msg, size);
> -	set_fs(oldfs);
> -	return result;
> +	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
> +	return sock_sendmsg(sock, msg, size);

Massive NAK.
This breaks any code that is using msg_control to set SCTP parameters
when sending data.

	David
