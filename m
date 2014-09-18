From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv5 net-next 3/3] sunvnet: generate ICMP PTMUD messages
 for smaller port MTUs
Date: Thu, 18 Sep 2014 16:09:26 -0400
Message-ID: <541B3BF6.2020703@oracle.com>
References: <5419F3E5.4050708@oracle.com> <20140917224351.GM26828@oracle.com> <541A1C46.90201@oracle.com> <541B314A.8090203@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37609 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182AbaIRUJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 16:09:31 -0400
In-Reply-To: <541B314A.8090203@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/18/2014 03:23 PM, Sowmini Varadhan wrote:

> by now I am actually quite confused by what the Administrator will see.
> If I do "ifconfig -a" or "ip addr", what is the reported mtu of the interface?

	The interface MTU is whatever the admin sets it to, between 68 bytes (the IPv4 min)
and 64K-1 (the IPv4 max).
	In cases where packets of interface MTU size cannot be delivered because the LDC
MTU is smaller, instead of silently dropping them, we send the ICMP errors which allow
PMTUD updates per-destination. Subsequent packets will be segmented or fragmented at that
(lower) value for that destination, and use other MTUs up to the interface MTU for other
destinations.

> Interesting. So if the Administrator sets up ICMP filters for outbound/inbound (at the IP layer), what will be the observed behavior?

If an administrator drops PMTUD packets, then TCP won't work, even without this patch set, for any
destinations that cause PMTUD. It's explicitly not optional in IPv6; in IPv4, fragmenting TCP
packets could hide it as long as IP_DF is not set, but the only thing this code could do for
packets too big is to drop them -- exactly what we'd do whether or not we send the ICMP error to
tell the sender what MTU we can send.

								+-DLS
