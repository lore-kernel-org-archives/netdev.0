From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Tue, 16 Sep 2008 14:17:05 +1000
Message-ID: <20080916041705.GB23389@verge.net.au>
References: <1221387956.9204.7.camel@fry>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49644 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbYIPERK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 00:17:10 -0400
Content-Disposition: inline
In-Reply-To: <1221387956.9204.7.camel@fry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 12:25:56PM +0200, Johann Baudy wrote:
> Hi All,
> 
> Sendfile() over UDP socket are currently limited to ~ 64KBytes file (max cork.length).
> Indeed, if you run sendfile() with a file size > 64KBytes over UDP socket, system call will stop and return ~64KBytes without sending anything on the network.
> This patch is pushing ongoing frames when frames buffer is full, to prevent overflow.
> 
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

Hi,

I wonder if it is slightly nicer to do without the opt variable.
I _think_ its safe to access inet->cork.opt->optlen based
on the (inet->cork.flags & IPCORK_OPT) check.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8e42fbb..969f6cd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -743,7 +743,21 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
 {
 	struct udp_sock *up = udp_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int ret;
+	int fragheaderlen;
+
+	fragheaderlen = sizeof(struct iphdr);
+	lock_sock(sk);
+	if (inet->cork.flags & IPCORK_OPT)
+		fragheaderlen += inet->cork.opt->optlen;
+
+	if (inet->cork.length + size >= 0xFFFF - fragheaderlen) {
+		ret = udp_push_pending_frames(sk);
+		if (ret)
+			goto out;
+	}
+	release_sock(sk);
 
 	if (!up->pending) {
 		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

