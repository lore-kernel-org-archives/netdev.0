From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 08:52:06 -0700
Message-ID: <562E4C26.3030501@gmail.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34838 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbJZPwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 11:52:08 -0400
Received: by pasz6 with SMTP id z6so191906244pas.2
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 08:52:08 -0700 (PDT)
In-Reply-To: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2015 07:36 AM, Hannes Frederic Sowa wrote:
> Take into consideration that the interface might be disabled for IPv6,
> thus switch event type.
>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>   net/ipv6/addrconf.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index d0c685c..c2dcebe 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3149,6 +3149,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>   
>   	case NETDEV_UP:
>   	case NETDEV_CHANGE:
> +netdev_change:
>   		if (dev->flags & IFF_SLAVE)
>   			break;
>   
> @@ -3244,8 +3245,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>   
>   		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
>   			idev = ipv6_add_dev(dev);
> -			if (!IS_ERR(idev))
> -				break;
> +			if (!IS_ERR(idev)) {
> +				event = NETDEV_UP;
> +				goto netdev_change;
> +			}
>   		}
>   
>   		/*

Seems like this code isn't quite correct.  You are calling ipv6_add_dev 
for slave devices, and if I understand things correctly I don't believe 
that was happening before and may be an unintended side effect.

You might want to instead just make it so that you only do the jump, and 
perhaps change the code in the NETDEV_UP/NETDEV_CHANGE section so that 
you test for NETDEV_CHANGE instead of NETDEV_UP.  That should be enough 
to get the effect you are looking for and I believe there would be no 
change to behaviour other than adding IPv6 link-local addresses when the 
MTU is increased.

Give me a bit and I can submit an alternative that may actually work out 
a bit better I think.

- Alex
