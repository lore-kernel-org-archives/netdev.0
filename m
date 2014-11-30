From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Sun, 30 Nov 2014 11:26:40 +0100
Message-ID: <20141130102640.GA19726@breakpoint.cc>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48316 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbaK3K0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 05:26:46 -0500
Content-Disposition: inline
In-Reply-To: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fan Du <fan.du@intel.com> wrote:
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

Hmm, do we really want to suport bridges containing interfaces with
different MTUs?

It seems to me to only clean solution is to set tap0 MTU so that it
accounts for the bridge encap overhead.
