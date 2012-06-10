From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] ieee802154: verify packet size before trying to
 allocate it
Date: Sun, 10 Jun 2012 12:24:35 +0100
Message-ID: <20120610122435.7d5c8fa7@pyramind.ukuu.org.uk>
References: <1339326619-1753-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, slapin@ossfans.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339326619-1753-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Jun 2012 13:10:19 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Currently when sending data over datagram, the send function will attempt to
> allocate any size passed on from the userspace.
> 
> We should make sure that this size is checked and limited. The maximum size
> of an IP packet seemed like the safest limit here.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
> 
> Change in v2:
>  - Limit by maximum size the protocol supports.
> 
>  net/ieee802154/dgram.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
> index 6fbb2ad..628498c 100644
> --- a/net/ieee802154/dgram.c
> +++ b/net/ieee802154/dgram.c
> @@ -232,6 +232,11 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
>  
>  	hlen = LL_RESERVED_SPACE(dev);
>  	tlen = dev->needed_tailroom;
> +	if (hlen + tlen + size > IEEE802154_MTU) {
> +		err = -EMSGSIZE;
> +		goto out;

What stops an overflow at this point. We'll then pass a small value to
sock_alloc_send_skb/sock_alloc_send_pskb and copy a large number of bytes
into it.

This does seem to be already broken, and not fixed by the patch ?

Alan
