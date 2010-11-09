From: Thomas Graf <tgraf@infradead.org>
Subject: Re: Netlink limitations
Date: Tue, 9 Nov 2010 16:40:39 -0500
Message-ID: <20101109214039.GA11005@canuck.infradead.org>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
 <4CD6DF37.6010800@trash.net>
 <20101108151635.GA20629@canuck.infradead.org>
 <4CD91406.4000603@trash.net>
 <20101109144941.GA4018@canuck.infradead.org>
 <alpine.LNX.2.01.1011092113420.10710@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, pablo@netfilter.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:37521 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791Ab0KIVlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 16:41:02 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1011092113420.10710@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 09:20:09PM +0100, Jan Engelhardt wrote:
> What's more, there is no way to specify a remote host in sockaddr_nl
> right now, so all communication is necessarily being local - that is,
> unless you add a hidden forwarder in kernel space that transparently
> tunnels it into IPv6 or something.

That's fine. I don't expect the kernel to send netlink message to
other machines directly but rather have a userspace daemon handle
this. 

> I do not believe that encoding the attribute type into the protocol
> itself is going to be such a big win. You still need a local
> authoritative database (struct nla_policy[] or some representation of
> it, nevermind I'm thinking "XML-DTD"-like) to do the verification
> against because some NL messages may be purposely forged. If you have
> an nlattr that says it is a string, how do you know that it is in
> fact a string rather than a blob that happens to have a trailing \0.

True, we will never be able to verify the contents of attributes but
what we can do is give the sender the ability to specify what type of
attribute he was meant to send. This can be a big advantage as it
limits the possibliy of misinterpreting messages which may have been
corrupted because we can match the expected attribute type against
the attribute type supplied by the sender. Of course this doesn't
protect against forged messages at all, we will never be able to do
that.

The addition won't be a revolution but it the increased header size,
8 vs. 12 bytes isn't a big deal and gives us some additional room to
work with in the future.

struct nlattr_ext {
	u16	oldlen;		/* 0 */
	u16	kind;		/* TCA_* */
	u8	type;		/* NLA_U32 */
	u8	flags;		/* NLA_F_* */
	u16	reserved;
	u32	length;
};

There has been more than one debate whether to share nla_policy between
kernel and userspace. There is nothing which prevents people from doing
so. But typically the semantics between kernel->userspace and vice versa
are slightly different and require a different policy to be applied.
