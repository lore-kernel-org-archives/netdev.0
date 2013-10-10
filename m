From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Thu, 10 Oct 2013 14:52:55 -0700
Message-ID: <20131010145255.16cf7c09@nehalam.linuxnetplumber.net>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org>
	<20131010133646.1bdd42c1@nehalam.linuxnetplumber.net>
	<52571481.5010907@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45634 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376Ab3JJVw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 17:52:58 -0400
Received: by mail-pd0-f171.google.com with SMTP id g10so3212010pdj.2
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 14:52:58 -0700 (PDT)
In-Reply-To: <52571481.5010907@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Oct 2013 22:56:33 +0200
Felix Fietkau <nbd@openwrt.org> wrote:

> On 2013-10-10 10:36 PM, Stephen Hemminger wrote:
> > On Thu, 10 Oct 2013 14:52:50 +0200
> > Felix Fietkau <nbd@openwrt.org> wrote:
> > 
> >> When an ethernet device is enslaved to a bridge, and the bridge STP
> >> detects loss of carrier (or operational state down), then normally
> >> packet receiption is blocked.
> >> 
> >> This breaks control applications like WPA which maybe expecting to
> >> receive packets to negotiate to bring link up. The bridge needs to
> >> block forwarding packets from these disabled ports, but there is no
> >> hard requirement to not allow local packet delivery.
> >> 
> >> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> >> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> > 
> > No. This will cause duplicate packets to be delivered.
> How? I haven't observed any duplications in my tests with this patch.

The purpose of DISABLED state is to break loops in the bridge tree.
If packet is flooded by another bridge (Broadcast Unknown or Multicast)
then it will go down both paths.

> 
> > If doing a link layer protocol like WPA then it should be done directly
> > on the underlying device, not the bridge itself.
> When the ETH_P_PAE protocol is set for the packet socket inside
> wpa_supplicant, the bridge steals all packets before the protocol
> handler gets them.
> In __netif_receive_skb_core, only ptype_all gets processed before the rx
> handler, not ptype_base.

Thought it was using direct type all. Or at least the link local multicast
address.

Can you revise it to only accept packets directed to link local multicast
address or local address, and go through the local_finish handler.
