From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/7] net: add netfilter ingress hook
Date: Sat, 11 Apr 2015 14:55:02 +0200
Message-ID: <20150411125502.GA3810@salvia>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-6-git-send-email-pablo@netfilter.org>
 <20150410132120.GE23070@casper.infradead.org>
 <20150410133610.GA19454@acer.localdomain>
 <20150410201719.GC5968@salvia>
 <20150410213312.GA23727@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48744 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190AbbDKMuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 08:50:50 -0400
Content-Disposition: inline
In-Reply-To: <20150410213312.GA23727@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 10:33:12PM +0100, Patrick McHardy wrote:
> On 10.04, Pablo Neira Ayuso wrote:
> > On Fri, Apr 10, 2015 at 02:36:11PM +0100, Patrick McHardy wrote:
> > > 
> > > I'm wondering if the hook is the right abstraction at all. Netfilter hooks
> > > require async resumption (okfn) support, which is why all the refactoring is
> > > needed. Is that something that we need for NF_PROTO_NETDEV? For ingress
> > > userspace queueing *might* actually work if the missing pieces are added,
> > > but for offloaded rules it obviously can not work.
> > 
> > For userspace queueing from ingress we still have to call
> > skb_share_check() and hold a reference to orig_dev from the escape
> > path. But this support is still missing in nf_tables (actually, we
> > only support NFPROTO_IPV4 and NFPROTO_IPV6 at this moment, see patch
> > attached). Regarding offload, this path will not see any packet.
> 
> We do support all families using the regular NF_QUEUE verdict of course.
> But yes, nf_queue.c will simply drop packets that don't have a netfilter
> AF registered.
> 
> But my question is whether queueing is something that is even worth
> considering for the NFPROTO_NETDEV family. As I said, it will at best
> work for ingress anyways and that will actually be more tricky than just
> calling skb_share_check(), we need to take care of keeping valid
> references to all the data you currently store in the CB, including the
> packet_type, the device, things attached to the skb at this point to
> the stack etc.

I think we only need to hold the reference on orig_dev. The pt_prev
pointer in skb CB can actually be removed. Other things attached to
the skb we already handle this from nf_queue to make sure they don't
vanish.

> If we decide not to support queueing for this family we don't have to
> use netfilter hooks for this and all the refactoring for async resume
> becomes unnecessary.

I think the refactoring is worth. Have a look at the current state of
this function. It has grown with features along time and it got many
gotos that force you travel back and forth when reading this code.

Regarding the nf_queue support at ingress, I don't see any major
technical obstacule at this moment to support this and I think that
existing programs that inspect traffic from userspace can benefit from
this feature (eg. IPS).
