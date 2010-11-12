From: Eric Paris <eparis@redhat.com>
Subject: RE: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Fri, 12 Nov 2010 11:08:28 -0500
Message-ID: <1289578108.3083.95.camel@localhost.localdomain>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
	 <00c201cb81eb$84e18160$8ea48420$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, paul.moore@hp.com
To: Hua Zhong <hzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757566Ab0KLQKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 11:10:14 -0500
In-Reply-To: <00c201cb81eb$84e18160$8ea48420$@com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-11-11 at 13:58 -0800, Hua Zhong wrote:
> > Yes, I realize this is little different than if the
> > SYN was dropped in the first network device, but it is different
> > because we know what happened!  We know that connect() call failed
> > and that there isn't anything coming back.
> 
> I would argue that -j DROP should behave exactly as the packet is dropped in the network, while -j REJECT should signal the failure to the application as soon as possible (which it doesn't seem to do).
> 
> It does not only make sense, but also is a highly useful testing technique that we use -j DROP in OUTPUT to emulate network losses and see how the application behaves.

I guess I can be a bit more descriptive of my specific situation,
although I'm not sure it matters.  I don't actually plan to drop packets
with -j REJECT or -j DROP, that's just a simple example everyone can see
on their own machine.  I plan to have the packets drop in the selinux
netfilter hook.  The SELinux hook uses NF_DROP/NF_ACCEPT just like any
other netfilter hook.  Maybe the answer is that I need to duplicate the
-j REJECT type operations in the SELinux hook.  -j REJECT doesn't do
what I want today, but if that's the right way forward tell me and I'll
look down that path.

But the path I first started looking down rules in 2 distinct questions:

1) What should netfilter pass back up the stack.  From my looking at
this I see that nf_hook_slow() will convert NF_DROP into -EPERM and pass
that back up the stack.  Is this wrong?  Should it more intelligently
pass errors back up the stack?  Maybe it needs an NF_REJECT as well as
NF_DROP?  NF_DROP returns 0 maybe and NF_REJECT return EPERM?

2) What should the generic TCP code (tcp_connect()) do if the skb failed
to send.  Should it return error codes back up the stack somehow or
should they continue to be ignored?  Obviously continuing to just ignore
information we have doesn't make me happy (otherwise I wouldn't have
started scratching this itch).  But the point about ENOBUFS is well
taken.  Maybe I should make tcp_connect(), or the caller to
tcp_connect() more intelligent about specific error codes?

I'm looking for a path forward.  If SELinux is rejecting the SYN packets
on connect() I want to pass that info to userspace rather than just
hanging.  What's the best way to accomplish that?

-Eric

