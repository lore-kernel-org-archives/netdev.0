From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 0/2] af_mpls: fix undefined reference to ip6_route_output
 with CONFIG_IPV6=n
Date: Thu, 30 Jul 2015 13:38:14 -0700
Message-ID: <55BA8B36.9030402@cumulusnetworks.com>
References: <1438122461-8350-1-git-send-email-roopa@cumulusnetworks.com>  <20150729.224223.1592092790674598920.davem@davemloft.net>  <55BA252F.3070601@cumulusnetworks.com> <1438268245.17421.5.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	rshearma@brocade.com, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jon.maloy@ericsson.com,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34294 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbG3UiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 16:38:16 -0400
Received: by pdbbh15 with SMTP id bh15so29784505pdb.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 13:38:16 -0700 (PDT)
In-Reply-To: <1438268245.17421.5.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/15, 7:57 AM, Hannes Frederic Sowa wrote:
> On Thu, 2015-07-30 at 06:22 -0700, roopa wrote:
>> On 7/29/15, 10:42 PM, David Miller wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> Date: Tue, 28 Jul 2015 15:27:39 -0700
>>>
>>>> v4 - v5: Use ipv6_stub_impl.ipv6_dst_lookup as suggested by Hannes
>>> I think this might not work.
>>>
>>> The ipv6_stub pointer is NULL until the ipv6 module is loaded.
>>>
>>> VXLAN can safely call through ipv6_stub->foo() because it _knows_
>>> the
>>> ipv6 module has been loaded, and will not go away, because it is
>>> working with an ipv6 socket.
>>>
>>> You don't have that set of preconditions here, and thus it is pretty
>>> easy to generate a scenerio where ipv6_stub will be NULL at your
>>> call
>>> sites.
>> v4 seems to be a better/safe option in that case. I can resubmit v4 if
>> that is acceptable.
>>
>>> This is starting to get really messy, to be honest.  And we've been
>>> harboring this build failure for several days now.
>>>
>> please revert the commit that introduced the IPV6 dependency. I will
>> resubmit if needed.
>> I don't feel good about the build failure either.
>>
>> Thanks and apologies.
> Of course you have to guard the NULL pointer dereference. Something simple like that will do:
>
> --- a/net/ipv6/addrconf_core.c
> +++ b/net/ipv6/addrconf_core.c
> @@ -107,7 +107,15 @@ int inet6addr_notifier_call_chain(unsigned long val, void *v)
>   }
>   EXPORT_SYMBOL(inet6addr_notifier_call_chain);
>   
> -const struct ipv6_stub *ipv6_stub __read_mostly;
> +static int eafnosupport_ipv6_dst_lookup(struct sock *u1, struct dst_entry **u2,
> +                                       struct flowi6 *u3)
> +{
> +       return -EAFNOSUPPORT;
> +}
> +
> +const struct ipv6_stub *ipv6_stub __read_mostly = &(struct ipv6_stub){
> +       .ipv6_dst_lookup = eafnosupport_ipv6_dst_lookup,
> +};
>   EXPORT_SYMBOL_GPL(ipv6_stub);
>   
>   /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
>
I have submitted a v6 with this. I had a NULL check in my v5 for 
ipv6_stub and i had thought
that should suffice...but was only concerned about ipv6 module unload.
If v6 is no good, i plan to re-post my v4 patch as v7.

thanks.
