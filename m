From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/7] net: add netfilter ingress hook
Date: Sat, 11 Apr 2015 15:32:34 +0200
Message-ID: <20150411133234.GA8469@salvia>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <1428668142-4006-6-git-send-email-pablo@netfilter.org>
 <20150410132120.GE23070@casper.infradead.org>
 <20150410133610.GA19454@acer.localdomain>
 <20150410201719.GC5968@salvia>
 <20150410213312.GA23727@acer.localdomain>
 <20150411125502.GA3810@salvia>
 <20150411130648.GA15268@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150411130648.GA15268@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 11, 2015 at 02:06:48PM +0100, Patrick McHardy wrote:
> On 11.04, Pablo Neira Ayuso wrote:
> > On Fri, Apr 10, 2015 at 10:33:12PM +0100, Patrick McHardy wrote:
> > > On 10.04, Pablo Neira Ayuso wrote:
> > > > On Fri, Apr 10, 2015 at 02:36:11PM +0100, Patrick McHardy wrote:
> > > We do support all families using the regular NF_QUEUE verdict of course.
> > > But yes, nf_queue.c will simply drop packets that don't have a netfilter
> > > AF registered.
> > > 
> > > But my question is whether queueing is something that is even worth
> > > considering for the NFPROTO_NETDEV family. As I said, it will at best
> > > work for ingress anyways and that will actually be more tricky than just
> > > calling skb_share_check(), we need to take care of keeping valid
> > > references to all the data you currently store in the CB, including the
> > > packet_type, the device, things attached to the skb at this point to
> > > the stack etc.
> > 
> > I think we only need to hold the reference on orig_dev. The pt_prev
> > pointer in skb CB can actually be removed. Other things attached to
> > the skb we already handle this from nf_queue to make sure they don't
> > vanish.
> 
> Are you sure? What about removable protocols or packet sockets?

pt_prev will be always NULL if we enter the netfilter ingress hook, so
no need to store it.

> > > If we decide not to support queueing for this family we don't have to
> > > use netfilter hooks for this and all the refactoring for async resume
> > > becomes unnecessary.
> > 
> > I think the refactoring is worth. Have a look at the current state of
> > this function. It has grown with features along time and it got many
> > gotos that force you travel back and forth when reading this code.
> > 
> > Regarding the nf_queue support at ingress, I don't see any major
> > technical obstacule at this moment to support this and I think that
> > existing programs that inspect traffic from userspace can benefit from
> > this feature (eg. IPS).
> 
> Yeah, that might be useful, although they seem to be pretty fine with
> getting only IPv4 and IPv6. I guess ARP might be interesting as well,
> but we also have hooks for that already.

For security applications, I guess they will be happy to get pretty
much everything that they can inspect.

> Regarding the refactoring, there seem to be concerns about performance
> impact. My suggestions would be to use nf_hook(), make sure no queueing
> can happen and therefore no okfn invocations and then you can simply
> add this as a function call to the existing code without the need for
> any refactoring or storing state.

I'll come back with numbers and more feedback anyway.

> You don't loose anything, it only massively simplifies the patches. If
> queuing supported is added, you can still change it.

I'll explore this, this seems like a good alternative if performance
becomes a real issue.

Thanks.
