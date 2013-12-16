From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/4] tipc: kill unnecessary goto's
Date: Mon, 16 Dec 2013 13:30:36 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7495@saturn3.aculab.com>
References: <1387197631-17240-1-git-send-email-wangweidong1@huawei.com> <1387197631-17240-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <erik.hugne@ericsson.com>, <maloy@donjonn.com>,
	<netdev@vger.kernel.org>
To: "Wang Weidong" <wangweidong1@huawei.com>, <jon.maloy@ericsson.com>,
	<allan.stephens@windriver.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41602 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754034Ab3LPNb6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:31:58 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04195-09 for <netdev@vger.kernel.org>;
 Mon, 16 Dec 2013 13:31:55 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1387197631-17240-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Wang Weidong
> Sent: 16 December 2013 12:40
> Remove a number of needless 'goto exit' in send_stream
> when the socket is in an unconnected state.
> This patch is cosmetic and does not alter the operation of
> TIPC in any way.
> 
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/tipc/socket.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 32037c5..844bf34 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -751,16 +751,14 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
> 
>  	/* Handle special cases where there is no connection */
>  	if (unlikely(sock->state != SS_CONNECTED)) {
> -		if (sock->state == SS_UNCONNECTED) {
> +		res = -ENOTCONN;
> +
> +		if (sock->state == SS_UNCONNECTED)
>  			res = send_packet(NULL, sock, m, total_len);
> -			goto exit;
> -		} else if () {
> +		else if (sock->state == SS_DISCONNECTING)
>  			res = -EPIPE;
> -			goto exit;
> -		} else {
> -			res = -ENOTCONN;
> -			goto exit;
> -		}
> +
> +		goto exit;

I'm not sure that 'removing needless gotos' is a good description of the change.
Possibly the code is easier to read with only one goto, ymmv.
You could remove the 'else' after the 'goto'.
Maybe the easiest to read is:
	if (sock->state == SS_UNCONNECTED)
		res = send_packet(NULL, sock, m, total_len);
	else
		res = sock->state == SS_DISCONNECTING ? -EPIPE : -ENOTCONN;
	goto exit;

	David
