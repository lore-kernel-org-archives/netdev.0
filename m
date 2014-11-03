From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Mon, 3 Nov 2014 17:55:37 +0000
Message-ID: <1415037337.1411.9.camel@citrix.com>
References: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
	 <1415036346.1411.3.camel@citrix.com> <5457BF80.2000205@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:19287 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbaKCSGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 13:06:47 -0500
In-Reply-To: <5457BF80.2000205@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 17:46 +0000, David Vrabel wrote:
> On 03/11/14 17:39, Ian Campbell wrote:
> > On Mon, 2014-11-03 at 17:23 +0000, David Vrabel wrote:
> >> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> >>
> >> Unconditionally pulling 128 bytes into the linear buffer is not
> >> required. Netback has already grant copied up-to 128 bytes from the
> >> first slot of a packet into the linear buffer. The first slot normally
> >> contain all the IPv4/IPv6 and TCP/UDP headers.
> > 
> > What about when it doesn't? It sounds as if we now won't pull up, which
> > would be bad.
> 
> The network stack will always pull any headers it needs to inspect (the
> frag may be a userspace page which has the same security issues as a
> frag with a foreign page).

I don't believe it will, unless something changed since I last looked.
The kernel assumes that it has been sensible enough to put the headers
in the linear area, since it is the one which generates them in most
cases. In other cases its up to the relevant driver to make sure this is
true.

> e.g., see skb_checksum_setup() called slightly later on in netback.

This however is what will make things safe for us (note that this is
only used by xen-net* in practice), it is this which should be mentioned
in the commit message I think.

> > To avoid the pull up the code would need to grant copy up-to 128 bytes
> > from as many slots as needed, not only the first.
> > 
> > Also, if the grant copy has already placed 128 bytes in the linear area,
> > why is the pull up touching anything in the first place? Shouldn't it be
> > a nop in that case?
> 
> The grant copy only copies from the first frag which may be less than
> 128 bytes in length.
> 
> David
