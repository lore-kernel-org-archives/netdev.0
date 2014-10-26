From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] ipv6: notify userspace when we added or changed an
 ipv6 token
Date: Mon, 27 Oct 2014 00:22:28 +0100
Message-ID: <544D8234.5060504@redhat.com>
References: <1412950112-15593-1-git-send-email-lkundrak@v3.sk> <1414363283-31410-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751718AbaJZXWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2014 19:22:40 -0400
In-Reply-To: <1414363283-31410-1-git-send-email-lkundrak@v3.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2014 11:41 PM, Lubomir Rintel wrote:
> NetworkManager might want to know that it changed when the router advertisement
> arrives.
>
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Daniel Borkmann <dborkman@redhat.com>

The reason why I asked regarding the rtmsg_ifinfo() vs inet6_ifinfo_notify()
in v1 is actually that this is an idev-only specific action. By using
inet6_ifinfo_notify() for notification, the kernel would actually need to do
much less work: the notification only needs inet6_fill_ifinfo() as that would
contain the new token, while the rtmsg_ifinfo() is rather dev-centric and
fills out attributes about the _whole_ device (which surely includes the IPv6
idev attributes, but also a lot more, which might actually be unnecessary
here), see also:

$ git grep -n rtmsg_ifinfo net/ipv6/
$ git grep -n inet6_ifinfo_notify net/ipv6/
net/ipv6/addrconf.c:2919:                       inet6_ifinfo_notify(RTM_NEWLINK, idev);
net/ipv6/addrconf.c:4650:void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
net/ipv6/ndisc.c:1239:                  inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
net/ipv6/ndisc.c:1256:                          inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
net/ipv6/ndisc.c:1712:          inet6_ifinfo_notify(RTM_NEWLINK, idev);

Maybe I'm missing something, so can you elaborate why it's _absolutely not_
possible to use inet6_ifinfo_notify()?

> ---
> Changes since v1:
>      - Do not call device notifier chain with netdev_state_change()
>
>   net/ipv6/addrconf.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3e118df..f6f92f5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4528,6 +4528,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
>   	}
>
>   	write_unlock_bh(&idev->lock);
> +	rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
>   	addrconf_verify_rtnl();
>   	return 0;
>   }
>
