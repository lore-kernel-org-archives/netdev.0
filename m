From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Wed, 30 Nov 2011 01:06:46 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>
References: <1322585087.25018.115.camel@icts-sp-039>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeroen van Ingen <jeroen@zijndomein.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40458 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753645Ab1K2XGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 18:06:02 -0500
In-Reply-To: <1322585087.25018.115.camel@icts-sp-039>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 29 Nov 2011, Jeroen van Ingen wrote:

> Hi,
> 
> We're having an issue on our Linux PPTP servers. After the first PPTP
> client is connected, locally generated broadcast packets go out the ppp0
> interface while the routing rules should select eth0.
> 
> Some details were already mentioned on the linux-kernel list, see eg
> http://lkml.indiana.edu/hypermail/linux/kernel/1111.2/00290.html for
> reference.
> 
> Finally we were able to narrow it down to one specific commit:
> e066008b38ca9ace1b6de8dbbac8ed460640791d ("ipv4: Fix __ip_dev_find() to
> use ifa_local instead of ifa_address."). With all recent kernels (tested
> up to 3.2.0rc3) we observe this issue and it's solved by reverting this
> single patch.
> 
> This is the first time we've had to debug a kernel issue. Any advice on
> how to proceed would be very welcome. If it's not possible to have this
> patch reverted in the kernel, hopefully someone can explain how to work
> around this behavior.

	__ip_dev_find can cause problem if same IP is added on many
interfaces because it uses hash table implemented with hlist.
Old versions used only routing lookup and the routing returns
the first created local route, i.e. the first device where this
IP was added is returned.

	And now it is risky to use __ip_dev_find in
ip_route_output_slow when:

- saddr is provided
- desired oif is 0
- daddr is multicast/lbcast

	We select oif by ignoring route ordering. May be some
ppp device wins here because it has this saddr added last but
is first in hlist.

	What is the case after first client is connected, can
you show output from:

ip addr show
ip route list table local

	If the above is true may be we have to find a
way to return the first device where the IP is added.
May be this is the main rule that is used when one adds
same IP on many interfaces.

	May be the solution is to convert inet_addr_lst
from hlist to normal list, so that we can append new
addresses at tail and __ip_dev_find to find the first
device where IP was added.

Regards

--
Julian Anastasov <ja@ssi.bg>
