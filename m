From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next] vxlan: set mac_header correctly in GPE mode
Date: Thu, 12 May 2016 09:47:58 +0300
Message-ID: <20160512094758.32bd517c@halley>
References: <3b9c5ffd8085c0af7072960865883a23be0d0a32.1462974886.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33698 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbcELGsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 02:48:10 -0400
Received: by mail-wm0-f65.google.com with SMTP id r12so13871251wme.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 23:48:09 -0700 (PDT)
In-Reply-To: <3b9c5ffd8085c0af7072960865883a23be0d0a32.1462974886.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Wed, 11 May 2016 15:55:06 +0200 Jiri Benc <jbenc@redhat.com> wrote:
> For VXLAN-GPE, the interface is ARPHRD_NONE, thus we need to reset
> mac_header after pulling the outer header.
> 
> Fixes: e1e5314de08b ("vxlan: implement GPE")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/vxlan.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 2f29d20aa08f..e030a804b772 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1338,6 +1338,8 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
>  	if (__iptunnel_pull_header(skb, VXLAN_HLEN, protocol, raw_proto,
>  				   !net_eq(vxlan->net, dev_net(vxlan->dev))))
>  			goto drop;
> +	if (raw_proto)
> +		skb_reset_mac_header(skb);

Would it make sense to perform this within __iptunnel_pull_header (in
case raw_proto is true) for all __iptunnel_pull_header callers?

If not (meaning vxlan specific), in next few lines we have:

	if (!raw_proto) {
		if (!vxlan_set_mac(vxlan, vs, skb))
			goto drop;
	} else {
		skb->dev = vxlan->dev;
		skb->pkt_type = PACKET_HOST;
	}

Seems more appropriate to place the missing 'skb_reset_mac_header'
within the "else" part, which logically holds all "things to initialize
in the skb if raw_proto is true, thus havn't called vxlan_set_mac".

Regards,
Shmulik
