From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 55861] New: PMTU discovery no longer works in Linux 3.6+
 with routers that do not send next hop MTU information
Date: Wed, 27 Mar 2013 22:24:15 -0400 (EDT)
Message-ID: <20130327.222415.476535684177218299.davem@davemloft.net>
References: <20130327083127.0740d793@nehalam.linuxnetplumber.net>
	<5153A3E8.9000004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174Ab3C1CYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 22:24:17 -0400
In-Reply-To: <5153A3E8.9000004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 28 Mar 2013 09:59:04 +0800

> It seems to be in icmp_unreach():
> 
> 		case ICMP_FRAG_NEEDED:
> 			if (ipv4_config.no_pmtu_disc) {
> 				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
> 					       &iph->daddr);
> 			} else {
> 				info = ntohs(icmph->un.frag.mtu);
> 				if (!info)
> 					goto out;
> 
> When MTU is zero, we skip the process in icmp_socket_deliver() which propagate
> this error to transport protocols.

No, really, MTU field should not be set to zero.  It should be set to
the actual MTU value we should use.

If you remove this check then we'll go down to the ipv4 routing code
and use the minimum ipv4 MTU, you absolutely do not want that.

The old code, that was removed, would try to guess in this case using
a table, the guard for this code path had comment:

			/* BSD 4.2 derived systems incorrectly adjust
			 * tot_len by the IP header length, and report
			 * a zero MTU in the ICMP message.
			 */

So the machines sending these zero MTUs are very broken.

I'm not accomodating such broken systems, sorry.
