From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: ipv6: add tokenized interface identifier
 support
Date: Tue, 09 Apr 2013 00:27:09 +0200
Message-ID: <5163443D.6050706@redhat.com>
References: <1365429690-17342-1-git-send-email-dborkman@redhat.com> <20130408222154.GA25696@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759625Ab3DHW13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 18:27:29 -0400
In-Reply-To: <20130408222154.GA25696@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 12:21 AM, Hannes Frederic Sowa wrote:
> Sorry, I was a bit busy and just had more time to look at your patch
> again. Perhaps you could look into my comments. (A new patch would be
> needed as it already landed in net-next).

Right, I'll prepare this follow-up patch(es) by tomorrow. Thanks for your
feedback Hannes!

> On Mon, Apr 08, 2013 at 04:01:30PM +0200, Daniel Borkmann wrote:
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index a33b157..65d8139 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -422,6 +422,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>>   		ipv6_regen_rndid((unsigned long) ndev);
>>   	}
>>   #endif
>> +	memset(ndev->token.s6_addr, 0, sizeof(ndev->token.s6_addr));
>
> ndev is allocated with __GFP_ZERO so no need to clear it. Otherwise I would do
>
> ndev->token = in6addr_any;
>
> to make the check in addrconf_prefix_rcv more clear.
>
>> +static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
>> +{
>> +	struct in6_addr ll_addr;
>> +	struct inet6_ifaddr *ifp;
>> +	struct net_device *dev = idev->dev;
>> +
>> +	if (token == NULL)
>> +		return -EINVAL;
>> +	if (ipv6_addr_any(token))
>> +		return -EINVAL;
>> +	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
>> +		return -EINVAL;
>> +	if (idev->dead || !(idev->if_flags & IF_READY))
>> +		return -EINVAL;
>> +	if (!ipv6_accept_ra(idev))
>> +		return -EINVAL;
>> +	if (idev->cnf.rtr_solicits <= 0)
>> +		return -EINVAL;
>
> IF_READY marks an interface which is already up. So we are not allowed to set
> a token on an interface which is down? I would drop this requirement, seems
> like a usability issue. ;)
>
>> +
>> +	write_lock_bh(&idev->lock);
>> +
>> +	BUILD_BUG_ON(sizeof(token->s6_addr) != 16);
>> +	memcpy(idev->token.s6_addr + 8, token->s6_addr + 8, 8);
>> +
>> +	write_unlock_bh(&idev->lock);
>> +
>
> {
>> +	ipv6_get_lladdr(dev, &ll_addr, IFA_F_TENTATIVE | IFA_F_OPTIMISTIC);
>> +	ndisc_send_rs(dev, &ll_addr, &in6addr_linklocal_allrouters);
>> +
>> +	write_lock_bh(&idev->lock);
>> +	idev->if_flags |= IF_RS_SENT;
> }
>
> This should then be only called if IF_READY is set. Otherwise normal ifup
> handling will send out the rs. If one day there is the possibility to add more
> than one token we would actually have to check the minimum solicitation
> intervals. I think this does not matter now.
>
>> +
>> +	/* Well, that's kinda nasty ... */
>> +	list_for_each_entry(ifp, &idev->addr_list, if_list) {
>> +		spin_lock(&ifp->lock);
>> +		if (ipv6_addr_src_scope(&ifp->addr) ==
>> +		    IPV6_ADDR_SCOPE_GLOBAL) {
>> +			ifp->valid_lft = 0;
>> +			ifp->prefered_lft = 0;
>> +		}
>> +		spin_unlock(&ifp->lock);
>> +	}
>
> As I understand this logic it also does deprecate current statically configured ip
> addresses? Perhaps another per-inet6_ifaddr flag to mark the ip address as
> token configured and just clean these address.
>
> The flag would have to be set in addrconf_prefix_rcv if tokens are active.
>
> Thanks,
>
>    Hannes
>
