From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Fri, 22 May 2015 22:50:35 +0200
Message-ID: <555F969B.3090706@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:56012 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674AbbEVUup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 16:50:45 -0400
Received: from wandq.ahsoftware (p4FC3696B.dip0.t-ipconnect.de [79.195.105.107])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id 04D482C9C1D2
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 22:50:42 +0200 (CEST)
In-Reply-To: <874mnn9t12.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 08.05.2015 um 14:02 schrieb Eric W. Biederman:
>
> So I am dense.  I have read through the patches and I don't see where
> you tag packets from other network namespaces with a network namespace
> id.

Me too,

I've recently written a little tool called snetmanmon (source is
available at github) to monitor and handle network related events
by using rtnetlink.

Having seen this patch series (thanks!), I've played with it.

I've applied the patch series to v4.1-rc4.

Maybe I'm using or holding it wrong, but I've some comments.

First I think if NETLINK_LISTEN_ALL_NSID is enabled, a dump
of the interfaces through RTM_GETLINK together with NLM_F_DUMP and
NLM_F_REQUEST should return all interfaces of all reachable namespaces.

Next, if NETLINK_LISTEN_ALL_NSID is enabled, I receive RTM_NEWLINK
but without any indication of the namespace. E.g. if I do
	ip netns add netns1
	ip netns exec netns1 brctl addbr br0
the RTM_NEWLINK for br0 (received in the root ns, not netns1) doesn't
have the attribute IFLA_LINK_NETNSID.

Same for the RTM_DELLINK msg if I call
	ip netns exec netns1 brctl delbr br0
afterwards. So both netlink messages are looking like br0 was
created in the root ns.

Another problem seems to be with veth devices. E.g. if I do
	ip link add veth0 type veth peer name veth1
	ip link set veth1 netns netns1
I receive
	RTM_NEWLINK for veth0 (no nsid)
	RTM_NEWLINK for veth1 (no nsid)
	RTM_DELLINK for veth1 (no nsid)
	RTM_NEWLINK for veth1 (with nsid 0)
That looks ok, except the missing RTM_NEWLINK for lo in netns1, which
was created together with the namespace. But if I now request a dump,
I get
	RTM_NEWLINK for veth0 (with nsid 0)
which looks like veth0 is part of nsid 0, and I get nothing for veth1.
Of course, that vlan device might be part of nsid 0 too (as veth1),
but its part named veth0 is not part of that namespace. So the
IFLA_LINK_NETNSID attribute received with the RTM_NEWLINK for veth0 through
the dump is misleading.

So it looks like either I missed something, I'm doing something wrong,
or there still is some work todo to make NETLINK_LISTEN_ALL_NSID work
like expected (or like my simple mind would expect it).

Thanks again for the patches, regards,

Alexander Holler
