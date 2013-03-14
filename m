From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink: Mask the rta_type when range checking
Date: Thu, 14 Mar 2013 21:28:21 +0000
Message-ID: <20130314212821.GC25591@casper.infradead.org>
References: <1363184338-15781-1-git-send-email-vyasevic@redhat.com>
 <20130313083654.01d9c924@nehalam.linuxnetplumber.net>
 <51420B75.9060209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43677 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142Ab3CNV21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 17:28:27 -0400
Content-Disposition: inline
In-Reply-To: <51420B75.9060209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/13 at 01:40pm, Vlad Yasevich wrote:
> So let me rebuff this a bit more intelligently.
> 
> 1) NLA_F_NESTED is used by netfilter in a lot of places.  It seems that
> only rtnetlink interface doesn't account for it.

Stephen is not wrong, strictly speaking this is an ABI breaker.

However, we have been applying NLA_TYPE_MASK in nla_type() and
thus in nla_parse(), nlmsg_find_attr(), etc. since the
introduction of the current kernel netlink API.

static inline int nla_type(const struct nlattr *nla)
{
        return nla->nla_type & NLA_TYPE_MASK;
}

I have been attempting to get rid of that ugly attribute parsing
code in rtnetlink_rcv_msg() but it's hard to get rid of. I shall
give this another try.

> 2) The following commit:
> 
> commit 25c71c75ac87508528db053b818944f3650dd7a6
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Tue Nov 13 07:53:05 2012 +0000
> 
>     bridge: bridge port parameters over netlink
> 
> introduced NLA_F_NESTED usage in rtnetlink for both setlink and
> getlink, so one could argue that was an ABI change.

You are right, user space applications that do not apply
NLA_TYPE_MASK will no longer see the IFLA_PROTINFO attribute
with the above commit.

> prove that without the change I am introducing, one can not use the
> above mentioned bridge API.  Feel free to try it with iproute2
> patches
> I sent earlier ([PATCH iproute2 0/2] Add support for bridge port
> link information).

I am not against your patch but I would love to see the affected
code paths to no longer rely on the attribute array provided by
the rtnetlink doit function but instead call nla_parse() themselves
for the sake of proper validation.
