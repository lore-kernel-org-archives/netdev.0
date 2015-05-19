From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH 13/13] xen-netfront: implement RX
 persistent grants
Date: Tue, 19 May 2015 10:22:24 +0000
Message-ID: <A2C8157F-880F-4808-BB3F-216A6F641A57@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-14-git-send-email-joao.martins@neclab.eu>
 <555A0D8C.4020309@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:55509 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbbESKWh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 06:22:37 -0400
In-Reply-To: <555A0D8C.4020309@citrix.com>
Content-Language: en-US
Content-ID: <940397253644D24D8FD5B3BAB64FE4A6@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 18 May 2015, at 18:04, David Vrabel <david.vrabel@citrix.com> wrote:
> On 12/05/15 18:18, Joao Martins wrote:
>> It allows a newly allocated skb to reuse the gref taken from the
>> pending_ring, which means xennet will grant the pages once and release
>> them only when freeing the device. It changes how netfront handles news
>> skbs to be able to reuse the allocated pages similarly to how netback
>> is already doing for the netback TX path.
>> 
>> alloc_rx_buffers() will consume pages from the pending_ring to
>> allocate new skbs. When responses are handled we will move the grants
>> from the grant_rx to the pending_grants. The latter is a shadow ring
>> that keeps all grants belonging to inflight skbs. Finally chaining
>> all skbs ubuf_info together to finally pass the packet up to the
>> network stack. We make use of SKBTX_DEV_ZEROCOPY to get notified
>> once the skb is freed to be able to reuse pages. On the destructor
>> callback we will then add the grant to the pending_ring.
>> 
>> The only catch about this approach is: when we orphan frags, there
>> will be a memcpy on skb_copy_ubufs() (if frags bigger than 0).
>> Depending on the CPU and number of queues this leads to a performance
>> drop of between 7-11%. For this reason, SKBTX_DEV_ZEROCOPY skbs will
>> only be used with persistent grants.
> 
> This means that skbs are passed further up the stack while they are
> still granted to the backend.

__pskb_pull_tail copies to skb->data and unref the frag if no data in
frag is remaining pull. When the packet is then delivered to the stack (in 
netif_receive_skb) skb_orphan_frags will be called where it will allocate
pages for frags and memcpy to them (from the granted pages). The zerocopy
callback is then called which then releases the grants. So, in the end the
granted buffers aren't passed up to the protocol stack, but could be the case
that it changes in the future like you said. Would you prefer memcpy explicitly
instead of using SKBTX_DEV_ZEROCOPY?

> I think this makes it too difficult to validate that the backend can't
> fiddle with the skb frags inappropriately (both now in the the future
> when other changes in the network stack are made).

But wouldn't this the case for netback TX as well, since it uses the similar
approach?