From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv4: arp: Always update neighbour address when a gratuitous arp is received
Date: Sat, 21 Dec 2013 01:36:10 +0100
Message-ID: <20131221003610.GE14073@order.stressinduktion.org>
References: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43779 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201Ab3LUAgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 19:36:12 -0500
Content-Disposition: inline
In-Reply-To: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 10:59:22AM -0800, Salam Noureddine wrote:
> Gratuitous arp packets are useful in switchover scenarios to update
> client arp tables as quickly as possible. Currently, the mac address
> of a neighbour is only updated after a locktime period has elapsed
> since the last update. In most use cases such delays are unacceptable
> for network admins. Moreover, the "updated" field of the neighbour
> stucture doesn't record the last time the address of a neighbour
> changed but records any change that happens to the neighbour. This is
> clearly a bug since locktime uses that field as meaning "addr_updated".
> With this observation, I was able to perpetuate a stale address by
> sending a stream of gratuitous arp packets spaced less than locktime
> apart.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
> ---
>  net/ipv4/arp.c |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 7808093..6597708 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -904,13 +904,19 @@ static int arp_process(struct sk_buff *skb)
>  	if (n) {
>  		int state = NUD_REACHABLE;
>  		int override;
> +		bool is_garp = tip == sip &&
> +			       inet_addr_type(net, sip) == RTN_UNICAST;

Would it make sense to add the following?

				&& arp->arp_op == htons(ARPOP_REQUEST);

Maybe we could also check that target hardware address is the broadcast
address, so we don't accept targetted arp spoofing attempts?

Just extract *tha like we did for sha.

Otherwise I am fine with that.

Thanks,

  Hannes
