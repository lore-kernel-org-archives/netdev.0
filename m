From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4
 devices
Date: Fri, 8 Mar 2013 10:37:39 +0100
Message-ID: <20130308093739.GB788@x61s.8.8.8.8>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
 <20130307204120.GA3808@x61s.8.8.8.8>
 <51394B32.9090807@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:56301 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933431Ab3CHJgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 04:36:22 -0500
Received: by mail-bk0-f50.google.com with SMTP id jg9so608528bkc.23
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 01:36:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <51394B32.9090807@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Mar 08, 2013 at 11:21:38AM +0900, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> Alexander Aring wrote:
> > Hi,
> > 
> > I don't know if this is a right solution for that, because other
> > functions like addrconf_ifid_infiniband to manipulate eui after memcpy,
> > too.
> > 
> > But this patch solves my problems with ieee802154 stack.
> 
> What kind of problems do you have?
>

I compile with #define DEBUG enabled in net/ieee802154/6lowpan.c

The problem is the address compression in 6lowpan.

First device has address fe80::a000:0:0:1/64. Second device has address
fe80::a000:0:0:2/64. I use only a ping6 to check connection.

Debug Information on the receiving side:
Without your patch which is working.

iphc0 = 7a, iphc1 = 11
NH flag is set, next header carried inline: 3a
source address stateless compression
(lowpan_uncompress_addr) linklocal address: 
a0 00 00 00 00 00 00 02
uncompressing 2 + 8 => 
fe 80 00 00 00 00 00 00 a0 00 00 00 00 00 00 02
dest: stateless compression
(lowpan_uncompress_addr) linklocal address: 
a0 00 00 00 00 00 00 01
uncompressing 2 + 8 => 
fe 80 00 00 00 00 00 00 a0 00 00 00 00 00 00 01
skb headroom size = 40, data length = 64
IPv6 header dump:
	version = 6
	length  = 64
	nexthdr = 0x3a
	hop_lim = 64


With your patch, which isn't working anymore:

iphc0 = 7b, iphc1 = 3b
NH flag is set, next header carried inline: 3a
source address stateless compression
(lowpan_uncompress_addr) linklocal address: 
02 85 00 3a 20 00 00 00
uncompressing 2 + 0 => 
fe 80 00 00 00 00 00 00 00 85 00 3a 20 00 00 00
dest: non context-based mcast compression
uncompressing 2 + 1 => 
ff 02 00 00 00 00 00 00 00 00 00 00 00 00 00 02
skb headroom size = 25, data length = 24
IPv6 header dump:
	version = 6
	length  = 24
	nexthdr = 0x3a
	hop_lim = 255

And for every ipv6 packet I got:
ICMPv6 checksum failed [fe80:0000:0000:0000:0001:ff00:0001:8700 > ff02:0000:0000:0000:0000:0001:ff00:0001]

I seems that the reconstructed destination address and header length are
not right.

I will try to figure out this problem. Hope this information helps you to
know more about my problems.

Regards
Alex
