From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 16 Sep 2008 21:01:17 +0900 (JST)
Message-ID: <20080916.210117.31865904.taka@valinux.co.jp>
References: <1221387956.9204.7.camel@fry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: johaahn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:44506 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751665AbYIPMBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 08:01:21 -0400
In-Reply-To: <1221387956.9204.7.camel@fry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Johann,

> Hi All,
> 
> Sendfile() over UDP socket are currently limited to ~ 64KBytes file (max cork.length).
> Indeed, if you run sendfile() with a file size > 64KBytes over UDP socket, system call will stop and return ~64KBytes without sending anything on the network.
> This patch is pushing ongoing frames when frames buffer is full, to prevent overflow.

UDP is a datagram protocol, so I think applications using UDP should
care about the size of packets they are going to send rather than
expecting that the messages will be split into several packets automatically.
If some of the packets have lost, it will be really hard for the
applications to re-create the same ones to send again.

You can pass "offset" of the file you are going to send and "count"
to be sent to sendfile systemcall, so you can split the file into
several pieces and send each of them.

If you want send a large file over UDP, the typical code will be like:

while (...) {
        setsockopt(fd, UDP_CORK, 1);
        sendmsg(fd, &apl_header, sizeof(apl_header));
        offset += sendfile(fd, offset, count);
        setsockopt(fd, UDP_CORK, 0);
}

or:

while (...) {
        sendmsg(fd, &apl_header, sizeof(apl_header), MSG_MORE);
        offset += sendfile(fd, offset, count);
}


> Signed-off-by: Johann Baudy <johann.baudy@gmail.com>
> 
>  net/ipv4/udp.c |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 8e42fbb..64e0857 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -743,7 +743,22 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>  		 size_t size, int flags)
>  {
>  	struct udp_sock *up = udp_sk(sk);
> +	struct inet_sock *inet = inet_sk(sk);
>  	int ret;
> +	int fragheaderlen;
> +	struct ip_options *opt = NULL;
> +
> +	lock_sock(sk);
> +	if (inet->cork.flags & IPCORK_OPT)
> +		opt = inet->cork.opt;
> +	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
> +
> +	if (inet->cork.length + size >= 0xFFFF - fragheaderlen) {
> +		ret = udp_push_pending_frames(sk);
> +		if (ret)
> +			goto out;
> +	}
> +	release_sock(sk);
>  
>  	if (!up->pending) {
>  		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
