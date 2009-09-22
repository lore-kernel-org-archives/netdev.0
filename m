From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 13/13] TProxy: use the interface primary IP address as
 a default value for --on-ip
Date: Tue, 22 Sep 2009 10:17:19 -0400
Message-ID: <4AB8DC6F.90602@hp.com>
References: <1253548005.12519.13.camel@bzorp.balabit>	 <4AB7BF47.2030404@hp.com> <1253601509.6883.5.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1253601509.6883.5.camel@bzorp.balabit>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Balazs Scheidler wrote:
> On Mon, 2009-09-21 at 14:00 -0400, Brian Haley wrote:
>> Balazs Scheidler wrote: 
>>>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>> +
>>> +static inline const struct in6_addr *
>>> +tproxy_laddr6(struct sk_buff *skb, const struct in6_addr *user_laddr, const struct in6_addr *daddr)
>>> +{
>>> +	struct inet6_dev *indev;
>>> +	struct inet6_ifaddr *ifa;
>>> +	struct in6_addr *laddr;
>>> +	
>>> +        if (!ipv6_addr_any(user_laddr))
>>> +                return user_laddr;
>>> +	
>>> +        laddr = NULL;
>>> +        rcu_read_lock();
>>> +        indev = __in6_dev_get(skb->dev);
>>> +        if (indev && (ifa = indev->addr_list)) {
>>> +		laddr = &ifa->addr;
>>> +	}
>>> +        rcu_read_unlock();
>>> +        
>>> +        return laddr ? laddr : daddr;
>>> +}
>> You should call ipv6_dev_get_saddr() to get a source address based on the target
>> destination address.
> 
> Thanks for this hint, however this is not selecting a source address for
> a given destination, rather it selects the address where tproxy is
> redirecting the connection in case the user specified no --on-ip
> parameter.
> 
> e.g. 
> 
> ip6tables -A PREROUTING -p tcp --dport 80 -j TPROXY --on-port 50080
> 
> This should redirect the connection to the primary IP address of the
> incoming interface. In fact I spent 2 hours to figure out how to find
> the proper address, and at the end I used the first IP address
> configured to the interface, seeing that those addresses are sorted in
> 'scope' order, e.g. link-local and site-local addresses are at the end
> of the list, thus the front should be ok.

Yes, the addresses are sorted by scope, but just because they're in the
list doesn't mean they can be used, for example that address might have
failed DAD or be Deprecated.  ipv6_dev_get_saddr() will follow the rules
from RFC 3484 in picking the best address to use, or none if there isn't
anything appropriate.

> Since I'm not that much into IPv6, I'd appreciate some help, is
> ipv6_dev_get_saddr(client_ip_address) indeed the best solution here?

Probably.  An alternative might be to use ip6_dst_lookup() (see tcp_v6_connect()),
but a lot more code for you.

-Brian
