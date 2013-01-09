From: Paul Pearce <pearce@cs.berkeley.edu>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Tue, 8 Jan 2013 21:15:11 -0800
Message-ID: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dborkman <dborkman@redhat.com>, edumazet <edumazet@google.com>,
	Ani Sinha <ani@aristanetworks.com>, jpirko@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:49557 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab3AIFPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 00:15:53 -0500
Received: by mail-oa0-f52.google.com with SMTP id o6so596926oag.39
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 21:15:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 19:51 +0100, Daniel Borkmann wrote:
> VLAN packets that are locally injected through taps will loose their
> skb->vlan_tci value when they pass dev_hard_start_xmit and get looped
> back to a packet sniffer via dev_queue_xmit_nit. Besides others, this
> meta data is used in Linux socket filtering for VLANs. Tested with a
> VLAN ancillary ops filter.
>
> Patch is based on a previous version by Jiri Pirko.

I think there may be issues with the patch beyond Eric's comments. It
seems to trash packet contents.

I applied this patch to Fedora flavored kernel 3.6.11-1.fc16.x86_64.
vlan tagged packets injected via libpcap's pcap_inject() came out
mangled at the packet filters.

The following injected packet:

01:01:01:01:01:01 > 02:02:02:02:02:02, ethertype 802.1Q (0x8100),
length 64: vlan 99, p 0, ethertype ARP, Request who-has 192.168.0.1
tell 192.168.0.1, length 46
0x0000:  0202 0202 0202 0101 0101 0101 8100 0063
0x0010:  0806 0001 0800 0604 0001 0025 6438 8afc
0x0020:  c0a8 0001 0000 0000 0000 c0a8 0001 0000
0x0030:  0000 0000 0000 0000 0000 0000 0000 0000

Arrived as this:

01:01:81:00:00:63 > 02:02:01:01:01:01, ethertype 802.1Q (0x8100),
length 64: vlan 514, p 0, ethertype ARP, Request who-has 192.168.0.1
tell 192.168.0.1, length 46
0x0000:  0202 0101 0101 0101 8100 0063 8100 0202
0x0010:  0806 0001 0800 0604 0001 0025 6438 8afc
0x0020:  c0a8 0001 0000 0000 0000 c0a8 0001 0000
0x0030:  0000 0000 0000 0000 0000 0000 0000 0000

It also might be worth noting the modified libpcap is able to identify
this packet with the filter "vlan" or "vlan 514". Prior to this kernel
patch such a packet could not be identified with any vlan filter.

If this isn't a problem with the patch, perhaps I'm missing a
necessary post-3.6.11 patch?

Thoughts?
