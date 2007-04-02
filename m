From: Patrick McHardy <kaber@trash.net>
Subject: IPsec PMTUD problem
Date: Mon, 02 Apr 2007 16:10:25 +0200
Message-ID: <46110ED1.9070209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43031 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965483AbXDBOKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 10:10:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed a problem with PMTUD between two IPsec tunnel endpoints.
When sending a packet larger than the PMTU with IP_DF from one
tunnel endpoint to the other, xfrm4_output sends an ICMP frag.
required with the IPsec MTU. Since the addresses match the tunnel
endpoints, this updates the MTU for the XFRM route with the value
that was calculated for the entire bundle, which in turn causes
a decrease for the bundle, resulting in further ICMP frag. required
messages until the minimum is reached.

For example with an IPsec tunnel 10.0.0.1 <-> 10.0.0.2:

uml:~# ping 10.0.0.1 -M do -s 1500 -c 20
PING 10.0.0.1 (10.0.0.1) 1500(1528) bytes of data.
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 1428)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 1356)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 1284)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 1212)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 1140)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 1068)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 996)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 924)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 852)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 780)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 708)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 636)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 564)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 552)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 492)
>From 10.0.0.2 icmp_seq=1 Frag needed and DF set (mtu = 492)
...

I can't come up with a way to fix this, so I'm hoping someone else
has an idea.

