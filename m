From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 12:22:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008122223.1ba5ac79.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
	<20031008183742.GA24822@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: modica@sgi.com, johnip@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com,
        jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008183742.GA24822@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 20:37:42 +0200
Andi Kleen <ak@suse.de> wrote:

> Maybe you didn't want to change the core stack to use the unaligned
> access mechanism?
> 
> In that case it may be better to fix the stack with some macro
> that expands to the unaligned access on IA64 and a normal load 
> on other architectures.

I have a very strong feeling that we'd really need both options to
arrive at an optimal implementation on all platforms.

Something that makes drivers copy packets, and something else that
traps packet header accesses.

But I don't like any of these solutions (and I know Linus will never
accept a set of changes that puts netdev_get_unaligned() macro usage
all over the entire networking layer).  Instead, we should do what
you proposed long ago.  Seperating the protocol headers from the
packet data.  Then we need only align the protocol headers.

In fact, I can suggest a very efficient implementation:

1) Driver allocates paged SKBs.  There is ~128 bytes of skb->data
   buffer area, and pages are chopped up into MTU'ish sized chunks
   and hung onto SKBs in the frag list.

2) The device is given the page buffers to receive packets into.

3) On RX, align skb->data (ie. skb_reserve(skb, 2) for ethernet
   drivers) and copy the first N bytes from the head of
   the paged buffer to skb->data, point the fraglist entry for the
   page at offset "N" into the page chunk buffer.

Problem solved.
