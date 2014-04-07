From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [tipc] dest_name_check() is racy (potential security hole)
Date: Mon, 7 Apr 2014 10:57:56 +0200
Message-ID: <53426894.5000601@ericsson.com>
References: <20140406043934.GW18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:55698 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510AbaDGJNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 05:13:00 -0400
In-Reply-To: <20140406043934.GW18016@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2014 06:39 AM, Al Viro wrote:
> 	dest_name_check() is called by tipc sendmsg(2).  What it does ends
> with
>         if (!m->msg_iovlen || (m->msg_iov[0].iov_len < sizeof(hdr)))
>                 return -EMSGSIZE;
>         if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
>                 return -EFAULT;
>         if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
>                 return -EACCES;
> 
>         return 0;
> IOW, it checks that iovec we'd been given is large enough to contain
> struct tipc_cfg_msg_hdr and that non-priveleged sender doesn't have
> ->tcm_type in that header with bits 14 or 15 set.
> 
> According to the comment in front of it, it "prevents restricted configuration
> commands from being issued by unauthorized users".  Makes sense, right?
> Except that it obviously doesn't provide any security whatsoever, because
> the value we'd read from the iovec is immediately discarded and later
> we reread it again.
> 
> There is nothing to stop the caller from spawning a threar that would flip
> the bits in question back and forth, while the parent keeps calling sendmsg().
> Sooner or later we will have dest_name_check() pick the harmless value,
> with subsequent memcpy_fromiovecend() picking the modified one.

It seems you are right here. I haven't been aware of this kind of attacks.

> 
> AFAICS, that part of dest_name_check() must be delayed until tipc_msg_build(),
> when we read that header for real.  Brute-force way to do that would be to
> pass a flag to tipc_msg_build() ("do we want to check tcm_type?") and have it
> set on call chains coming from tipc_send2name() and tipc_multicast().
> 
> Again, in the current form the check doesn't do much good; I've no idea
> how much nastiness can be achieved by fooling it, but it *can* be fooled.

Not that much, I think, except that the sender can send messages to non-existing
addresses, whereafter they will be dropped.

These addresses are primarily *reserved*, so that only TIPC itself can bind to them.
Only two such addresses are used at the moment. One of the two also had *restricted*
access, in the sense that only privileged users could send messages to it.
The only server binding to that address was the remote configuration server, but we
just removed that one, exactly for security reasons. 
So an option may be to just remove this check altogether at sendto(), but enforce it
more robustly at bind(), maybe the way you suggest.

We will of course fix this, one way or another.

Regards
///jon

> 
> Comments?
> 
