From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Fri, 22 Apr 2016 20:40:13 -0700
Message-ID: <CAOrHB_DXzE8XNBmMc_VLzz+hkJCUmMVT2uMhWORCgq+g7ym9HA@mail.gmail.com>
References: <cover.1461346798.git.jbenc@redhat.com>
	<017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
	<CAOrHB_DrFXg=nQAdscOgX8nbUoOC4fMsWiN6R4n907zB5rtD=g@mail.gmail.com>
	<20160422232732.7dfd0ec3@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:54199 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbcDWDkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 23:40:18 -0400
Received: from mfilter26-d.gandi.net (mfilter26-d.gandi.net [217.70.178.154])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 9E91641C086
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 05:40:16 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter26-d.gandi.net (mfilter26-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id vMwtRU89sim6 for <netdev@vger.kernel.org>;
	Sat, 23 Apr 2016 05:40:15 +0200 (CEST)
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1D6D241C074
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 05:40:14 +0200 (CEST)
Received: by mail-io0-f178.google.com with SMTP id u185so137511196iod.3
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 20:40:14 -0700 (PDT)
In-Reply-To: <20160422232732.7dfd0ec3@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 2:27 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 22 Apr 2016 14:07:01 -0700, pravin shelar wrote:
>> On Fri, Apr 22, 2016 at 10:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
>> > For ipgre interfaces in collect metadata mode, receive also traffic with
>> > encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
>> > out correctly. This allows to have mixed Ethernet + L3-only traffic on the
>> > same lwtunnel interface.
>> >
>> How user is suppose to sort out the type of packet? whether it is L2 or L3.
>
> By skb->protocol, of course. Will be ETH_P_TEB if the inner packet was
> Ethernet. There's no problem with this, for lwtunnels used with encap
> routes, such packets are just discarded (which is the expected
> behavior), as there's no protocol handler for ETH_P_TEB. More clever
> lwtunnel users (such as openvswitch) can process the packets. This is
> important in order to have a single tunnel interface for everything.
>

But skb->protocol is not set to ETH_P_TEB anywhere in ip-gre module.
Am I missing something?


>> Is it fine to receive L2 packet over L3 device?
>> At least ip_tunnel_rcv() is not ready to handle such packet.
>
> I don't see why. Could you please elaborate? Seems safe to me. The
> desired result is skb->protocol == htons(ETH_P_TEB), network header(!)
> pointing to the start of the Ethernet frame (because we're tunneling
> Ethernet via ARPHRD_IPGRE interface, there's no L2 header to have), mac
> header not being set.
>

ip_tunnel_rcv() checks device type (tunnel->dev->type) to perform
ethernet specific processing on packet. I think that should be changed
to check packet type.
