From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Fun with if_bridge.h and br_private.h
Date: Mon, 3 May 2010 13:36:13 -0700
Message-ID: <20100503133613.0f2a61f7@nehalam>
References: <20100503191256.GA18110@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34872 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753783Ab0ECUg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 16:36:28 -0400
In-Reply-To: <20100503191256.GA18110@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 May 2010 12:12:56 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> Hello, Stephen,
> 
> I need some help with #include issues surrounding bridge.
> 
> Arnd has been putting together a sparse-based RCU-checking tool
> that can detect pointer access that should have been protected by an
> rcu_dereference() or rcu_assign_pointer().  On of the side-effects of
> his approach is that rcu_dereference() can no longer handle pointers
> to incomplete types, as Arnd's approach uses the address-space feature
> of sparse, which in turn must tag the type pointed to rather than the
> pointer itself.  And this in turn requires rcu_dereference() and friends
> to see the pointed-to type as well as the pointer type.
> 
> One place affected by this is handle_bridge() in net/core/dev.c, which
> invokes rcu_dereference() on skb->dev->br_port, which is of type struct
> net_bridge_port, which is defined in net/bridge/br_private.h.  This is,
> well, private, but is included into a couple places in netfilter and atm,
> so I tried including it into net/core/dev.c.
> 
> This still left me with forward references:
> 
> In file included from net/core/dev.c:104:
> include/linux/if_bridge.h:106: warning: "struct net_bridge_port" declared inside parameter list
> include/linux/if_bridge.h:106: warning: its scope is only this definition or declaration, which is probably not what you want
> net/core/dev.c:2331: error: conflicting types for "br_handle_frame_hook"
> include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
> net/core/dev.c:2333: error: conflicting types for "br_handle_frame_hook"
> include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
> 
> This happens because net/bridge/br_private.h includes if_bridge.h before
> it defines net_bridge_port.
> 
> Any thoughts on how best to allow handle_bridge() see the definition
> of struct net_bridge_port?
> 

Why not make it a void *, there is no reason to make core code depend
on br_private.h.
