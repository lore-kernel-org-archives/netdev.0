From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Mon, 17 Dec 2012 22:49:57 -0800
Message-ID: <20121217224957.70775f99@nehalam.linuxnetplumber.net>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
	<20121216105451.GA1546@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35962 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233Ab2LRGvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 01:51:16 -0500
In-Reply-To: <20121216105451.GA1546@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2012 11:54:51 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> 
> I see that the patchset is in state "Rejected" in patchwork.
> Stephen convinced me for a moment that the problem can be handled by operstate.
> As it turned out (in last 3-4 emails in thread) operstate use would not
> be an option.
> 
> So how should I proceed? Should I repost the patchset? Anyone has any other
> comments?
> 
> thanks.

Don't take my comments so far as negative. Devices to need to be more controllable
from userspace. But I have concerns about introducing a new way to change state causing
more races.  For example, changing carrier state should cause netlink events to fire and
these should post to routing daemons etc. Also, what happens if some confused developer
mixes operstate and direct carrier control.

The root cause of all this confusion is that their are three ways of expressing
the same state, and they are controlled through different paths:
  a. Old BSD style flag bit IFF_RUNNING
  b. LINK_STATE bit in kernel (netif_carrier_ok)
  c. RFC2863 operational state

The operstate stuff is the most complete, but is the weakest in implementation:
  a. kernel drivers check netif_carrier_ok when they should be using netif_dormant
     (bridge is one example). But what will break if this changes?
  b. lower device state is not tracked correctly by tunnels and a few other layered devices
  c. dormant from kernel space was never used by much.

The good news is that the old BSD style IFF_RUNNING bit is the most commonly
used bit by applications and it works correctly in either carrier or operstate mode.
