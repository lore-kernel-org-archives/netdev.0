From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net 0/2] netns: audit netdevice creation with
 IFLA_NET_NS_[PID|FD]
Date: Tue, 27 Jan 2015 15:06:36 +0100
Message-ID: <20150127140620.GA8941@omega>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150127093425.GA2698@omega>
 <54C7694C.2060709@6wind.com>
 <20150127122340.GA4338@omega>
 <54C7928F.9010002@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, arvid.brodin@alten.se,
	linux-wpan@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38452 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbbA0OGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 09:06:44 -0500
Content-Disposition: inline
In-Reply-To: <54C7928F.9010002@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jan 27, 2015 at 02:28:47PM +0100, Nicolas Dichtel wrote:
...
> >With the check of "!net_eq(src_net, &init_net)" we need to be sure
> >that the wpan interface is always in "init_net". This means we need
> >definitely a dev->features |= NETIF_F_NETNS_LOCAL; somewhere in [0].
> >
> >To adding "dev->features |= NETIF_F_NETNS_LOCAL;" for a 6LoWPAN interface,
> >I am not sure about this. I didn't test it yet and it will not break
> >anything, but we will lost the support for making net namespaces stuff
> >inside the IPv6/(netfilter) stack.
> Adding NETIF_F_NETNS_LOCAL does not mean that the netdevice can be used only
> in init_net, this flag means that the netdevice cannot be moved to another
> netns. You can still create a netdevice in another netns (if wpan0 is in netns
> foo):
> 
> $ ip netns exec foo ip link add link wpan0 name lowpan0 type lowpan
> 
> I don't know how wpan0 is created and if this interface can be created directly
> in another netns than init_net.
> 

no it can't. The wpan0 interface can be created via the 802.15.4
userspace tools and we don't have such option for namespaces. It
should be always to init_net while creation.

> >
> >
> >Summarize:
> >
> >I would add the dev->features |= NETIF_F_NETNS_LOCAL; while wpan
> >interface generation and add only the !net_eq(src_net, &init_net) check
> >above. I suppose that src_net is the net namespace from "underlaying"
> >interface wpan by calling:
> >
> >$ ip link add link wpan0 name lowpan0 type lowpan
> No. src_net is the netns where the ip command is launched. With this patch, my

ah, and when no "ip netns" is given it's default to init_net?


Okay, then I agree with that both interfaces should be set

dev->features |= NETIF_F_NETNS_LOCAL

because both interfaces should started with "init_net" as default
namespace. For wpan interface this should always be in "init_net",
because we don't set anything while creation.

For 6LoWPAN interface this should also always in the same namespace like
the wpan interface and not diffrent namespace between link (wpan) and
virtual (6LoWPAN) interface.

Do you agree with that?

- Alex
