From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 9/9] tproxy: use the interface primary IP address as a
 default value for --on-ip
Date: Thu, 21 Oct 2010 11:12:55 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010211051560.22922@obet.zrqbmnf.qr>
References: <20101020112118.6260.31618.stgit@este.odu> <20101020112118.6260.54362.stgit@este.odu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:40336 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754954Ab0JUJM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 05:12:57 -0400
In-Reply-To: <20101020112118.6260.54362.stgit@este.odu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
>+
>+	if (!ipv6_addr_any(user_laddr))
>+		return user_laddr;
>+	laddr = NULL;
>+
>+	rcu_read_lock();
>+	indev = __in6_dev_get(skb->dev);
>+	if (indev)
>+		list_for_each_entry(ifa, &indev->addr_list, if_list) {
>+			/* FIXME: address selection */

Per our realworld discussion, I believe we should add checks for
some conditions (RFC 4862 section 2):

1. ignore tentative addresses

	if (ifa->ifa_flags & IFA_F_TENTATIVE)
		continue;

2. tests for when the interface's ifa->preferred_lft == 0/deprecatedness:

	if (ctinfo == IP_CT_NEW/RELATED && (ifa->ifa_flags & IFA_F_DEPRECATED))
		continue;

3. check for invalid addresses
(There might be a flag like tentative..)

	if (ifa->valid_lft == 0)
		continue;

