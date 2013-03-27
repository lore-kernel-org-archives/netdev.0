From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] netlink: replace obsolete NLMSG_* with type
 safe nlmsg_*
Date: Wed, 27 Mar 2013 12:46:08 +0000
Message-ID: <20130327124608.GA20739@casper.infradead.org>
References: <1364342762-26861-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57201 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab3C0MqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 08:46:12 -0400
Content-Disposition: inline
In-Reply-To: <1364342762-26861-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/13 at 08:06am, Hong Zhiguo wrote:
> Thomas, please review it. Next should we made nlmsg_* available
> for uapi?

Comments like this should go below the '---' line so they don't
become part of the commit message.

See comments below, I have only listed each point once even though most
of them apply to multiple chunks. So please go over your patch and look
for other occurances for each comment made.

Also, you might have to split up your patch into different non networking
subsystems to get it routed via the respective trees.

> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  drivers/connector/connector.c        |    8 ++---
>  drivers/scsi/scsi_netlink.c          |    4 +--
[...]
> @@ -162,7 +162,7 @@ static void cn_rx_skb(struct sk_buff *__skb)
>  
>  	skb = skb_get(__skb);
>  
> -	if (skb->len >= NLMSG_SPACE(0)) {
> +	if (skb->len >= nlmsg_total_size(0)) {

Can we just replace nlmsg_total_size(0) with NLMSG_HDRLEN. Seems a lot
clearer to me.

> diff --git a/drivers/scsi/scsi_transport_fc.c b/drivers/scsi/scsi_transport_fc.c
> index e894ca7..394aedb 100644
> --- a/drivers/scsi/scsi_transport_fc.c
> +++ b/drivers/scsi/scsi_transport_fc.c
> @@ -35,7 +35,7 @@
>  #include <scsi/scsi_transport.h>
>  #include <scsi/scsi_transport_fc.h>
>  #include <scsi/scsi_cmnd.h>
> -#include <linux/netlink.h>
> +#include <net/netlink.h>
>  #include <net/netlink.h>

You are including <net/netlink.h> twice now.

> @@ -124,7 +124,7 @@ int netlink_send(struct sock *sock, int group, u16 type, void *msg, int len)
>  		return -EINVAL;
>  	}
>  
> -	skb = alloc_skb(NLMSG_SPACE(len), GFP_ATOMIC);
> +	skb = alloc_skb(nlmsg_total_size(len), GFP_ATOMIC);

We can convert these to nlmsg_new(len, GFP_ATOMIC);

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index aeb8131..1ba25fb 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2613,10 +2613,10 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	type -= RTM_BASE;
>  
>  	/* All the messages must have at least 1 byte length */
> -	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct rtgenmsg)))
> +	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(struct rtgenmsg)))

This can be written more clearly as:

        if (nlmsg_len(nlh) < sizeof(struct rtgenmsg))

> diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
> index fc42a0a..d98563a 100644
> --- a/net/decnet/dn_table.c
> +++ b/net/decnet/dn_table.c
> @@ -19,7 +19,7 @@
>  #include <linux/sockios.h>
>  #include <linux/init.h>
>  #include <linux/skbuff.h>
> -#include <linux/netlink.h>
> +#include <net/netlink.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/proc_fs.h>
>  #include <linux/netdevice.h>
> @@ -492,7 +492,7 @@ int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  	if (!net_eq(net, &init_net))
>  		return 0;
>  
> -	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
> +	if (nlmsg_attrlen(cb->nlh, 0) >= sizeof(struct rtmsg) &&

nlmsg_attrlen(cb->nlh, 0) is identical to nlmsg_len(cb->nlh) which is
easier to read.
