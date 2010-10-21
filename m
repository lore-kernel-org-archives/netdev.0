From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH 9/9] tproxy: use the interface primary IP address as a
 default value for --on-ip
Date: Thu, 21 Oct 2010 12:32:08 +0200
Message-ID: <1287657128.13326.42.camel@este.odu>
References: <20101020112118.6260.31618.stgit@este.odu>
	 <20101020112118.6260.54362.stgit@este.odu>
	 <alpine.LNX.2.01.1010211051560.22922@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brother.balabit.com ([195.70.62.219]:35891 "EHLO
	lists.balabit.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801Ab0JUKcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:32:13 -0400
In-Reply-To: <alpine.LNX.2.01.1010211051560.22922@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 2010-10-21 at 11:12 +0200, Jan Engelhardt wrote:
> On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
> >+
> >+	if (!ipv6_addr_any(user_laddr))
> >+		return user_laddr;
> >+	laddr = NULL;
> >+
> >+	rcu_read_lock();
> >+	indev = __in6_dev_get(skb->dev);
> >+	if (indev)
> >+		list_for_each_entry(ifa, &indev->addr_list, if_list) {
> >+			/* FIXME: address selection */
> 
> Per our realworld discussion, I believe we should add checks for
> some conditions (RFC 4862 section 2):
> 
> 1. ignore tentative addresses
> 
> 	if (ifa->ifa_flags & IFA_F_TENTATIVE)
> 		continue;

Yep, we should definitely do that.

> 2. tests for when the interface's ifa->preferred_lft == 0/deprecatedness:
> 
> 	if (ctinfo == IP_CT_NEW/RELATED && (ifa->ifa_flags & IFA_F_DEPRECATED))
> 		continue;

Well, we can use the TPROXY target without conntrack so we cannot really
check if ctinfo==IP_CT_NEW/RELATED. However, we do address selection
only in case no established socket was found for the skb, so I think
it's safe to ignore addresses with IFA_F_DEPRECATED set.

Something like

	if (ifa->ifa_flags & (IFA_F_TENTATIVE | IFA_F_DEPRECATED))
		continue;

> 3. check for invalid addresses
> (There might be a flag like tentative..)
> 
> 	if (ifa->valid_lft == 0)
> 		continue;

I didn't find such a flag and it seems that valid_lft contains the
lifetime in seconds, so I think it's not that simple. The addrconf.c
code does something like this:

	unsigned long age = (jiffies - ifp->tstamp) / HZ;
	if (age >= ifp->valid_lft) {
		/* not valid */
	}

The code also sets the deprecated flag when the preferred lifetime
expires and I think valid_lft must be less or equal to prefered_lft. If
this is the case then I think this case should be already covered by
checking for IFA_F_DEPRECATED above.

--KK


