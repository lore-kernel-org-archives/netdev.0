From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sun, 13 Jan 2013 12:57:08 +0900
Message-ID: <50F23094.9040003@linux-ipv6.org>
References: <50F17178.3090705@linux-ipv6.org> <20130112164741.1a0ab7bb@stein> <50F191CF.3060803@linux-ipv6.org> <50F192DF.9090100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37525 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754258Ab3AMD5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 22:57:11 -0500
In-Reply-To: <50F192DF.9090100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
>> How about putting EUI64, maxrec, sspd and fifo in dev->dev_addr?
>> This enable us to send NDISC/ARP packet easily (based on neighbor
>> cache entry), and driver can be notified for new neighbors (thus
>> new peers).
> Hm, that looks a bit strange to me, because we need that only for link layer option packets and not for every IPv6 packet transmitted via firewire.

It seems the stack will be clearner, overall.

In addition to ARP/NDP things, for example, it will become easier to
implement multicast as well; IP layer can tell net_device layer
multicast listener information via special mapping.

Given multicast bit is disabled in the Unique ID (well, it should be
disabled; otherwise, disable multicast bit and trun on locally
administrated bit), IP layer can tell full IPv6 address via
ip6_mc_map() by copying full IPv6 address to EUI-64 + additional
space, e.g: 
  IPv6: FF xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx (IPv6 mutlicast address (FF00::/8))
Similar in IPv4:
  IPv4: 01 00 00 00 00 00 00 00 00 00 00 00 xx xx xx xx (IPv4 multicast address)

Device will be notified via dev_mc_add() / dev_mc_del(),
then net_device_opts->ndo_set_rx_mode(), and you can manage
multicast lists based on that.

When sending the driver can determine if the packet is multicast or not
by seeing 0x01 bit in the first octet in the destination virtual
"MAC" address, and then MCAP manager can determine IP version by seeing
the first octet of our virtual "MAC" address.

--yoshfuji
