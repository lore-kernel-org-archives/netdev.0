From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [BUG] VPN broken in net-next
Date: Thu, 3 Mar 2011 14:41:55 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
References: <20110302.164333.116393112.davem@davemloft.net> <20110302164637.6651b34f@nehalam> <20110302.165009.200353108.davem@davemloft.net> <20110302.165421.258093056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39778 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751753Ab1CCMhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 07:37:41 -0500
In-Reply-To: <20110302.165421.258093056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Wed, 2 Mar 2011, David Miller wrote:

>> I really need to know what addresses interfaces have the time of the
>> __ip_dev_find() call which, if I'm not mistaken, is before the VPN is
>> up.
>
> Looking at pptp_connect(), it seems to be trying to do a route lookup
> using the source address, before it registers the PPP channel and that
> even gets brought up.
>
> I suspect that was working by luck previously, and it was getting the
> default route out perhaps another interface.  If that is the case,
> removing the explicit "fl4_src" source address specification in the lookup
> flow pptp_connect() uses should fix the problem.

 	May be the problem is in inet_hash_insert(), it should
hash ifa_local, not ifa_address. May be they are equal for
the common case but not for peer addresses. In devinet_ioctl()
we can see they are equal initially:

ifa->ifa_address = ifa->ifa_local = sin->sin_addr.s_addr;

 	but later SIOCSIFDSTADDR can change ifa_address which
is destination address from the same prefix:

ifa->ifa_address = sin->sin_addr.s_addr;

 	fib_add_ifaddr() does more things but not for this
case with /32 mask, so the problem should be in using
ifa_address instead of ifa_local.

Regards

--
Julian Anastasov <ja@ssi.bg>
