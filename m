From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 02 Dec 2014 19:23:11 -0800 (PST)
Message-ID: <20141202.192311.1226452173523245977.davem@davemloft.net>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaLCDSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 22:18:52 -0500
In-Reply-To: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>
Date: Fri, 28 Nov 2014 14:33:05 +0800

> Test scenario: two KVM guests sitting in different
> hosts communicate to each other with a vxlan tunnel.
> 
> All interface MTU is default 1500 Bytes, from guest point
> of view, its skb gso_size could be as bigger as 1448Bytes,
> however after guest skb goes through vxlan encapuslation,
> individual segments length of a gso packet could exceed
> physical NIC MTU 1500, which will be lost at recevier side.
> 
> So it's possible in virtualized environment, locally created
> skb len after encapslation could be bigger than underlayer
> MTU. In such case, it's reasonable to do GSO first,
> then fragment any packet bigger than MTU as possible.
> 
> +---------------+ TX     RX +---------------+
> |   KVM Guest   | -> ... -> |   KVM Guest   |
> +-+-----------+-+           +-+-----------+-+
>   |Qemu/VirtIO|               |Qemu/VirtIO|
>   +-----------+               +-----------+
>        |                            |
>        v tap0                  tap0 v
>   +-----------+               +-----------+
>   | ovs bridge|               | ovs bridge|
>   +-----------+               +-----------+
>        | vxlan                vxlan |
>        v                            v
>   +-----------+               +-----------+
>   |    NIC    |    <------>   |    NIC    |
>   +-----------+               +-----------+
> 
> Steps to reproduce:
>  1. Using kernel builtin openvswitch module to setup ovs bridge.
>  2. Runing iperf without -M, communication will stuck.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>

I really don't like this at all.

If guest sees a 1500 byte MTU, that's it's link layer MTU and it had
better be able to send 1500 byte packets onto the "wire".

If you cannot properly propagate the vxlan encapsulation overhead back
into the guest's MTU you must hide this problem from the rest of our
stack somehow.

Nothing we create inside the host should need the change that you
are making.
