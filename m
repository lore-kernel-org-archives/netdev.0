From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 26 Jul 2016 13:22:25 +0000
Message-ID: <CO2PR03MB218213882E0C6F9B00E62683BF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.173701.1282720667210726281.davem@davemloft.net>
 <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.213822.1745865660912873332.davem@davemloft.net>
 <CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160726095637.GC8749@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"dave.scott@docker.com" <dave.scott@docker.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0138.outbound.protection.outlook.com ([104.47.36.138]:60724
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754085AbcGZNW2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 09:22:28 -0400
In-Reply-To: <20160726095637.GC8749@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Michal Kubecek [mailto:mkubecek@suse.cz]
> Sent: Tuesday, July 26, 2016 17:57
>  ...
> On Tue, Jul 26, 2016 at 07:09:41AM +0000, Dexuan Cui wrote:
> > ... I don't think Michal
> > Kubecek was suggesting I build my code using the existing AF_VSOCK
> > code(?)  I think he was only asking me to clarify the way I used to write
> > the text to explain why I can't fit my code into the existing AF_VSOCK
> > code. BTW, AF_VSOCK is not on S390, I think.
> 
> Actually, I believe building on top of existing AF_VSOCK should be the
> first thought and only if this way shows unfeasible, one should consider
> a completely new implementation from scratch. After all, when VMware
> was upstreaming vsock, IIRC they had to work hard on making it
> a generic solution rather than a one purpose tool tailored for their specific use
> case.
> 
> What I wanted to say in that mail was that I didn't find the reasoning
> very convincing. The only point that wasn't like "AF_VSOCK has many
> features we don't need" was the incompatible addressing scheme. The
> cover letter text didn't convince me it was given as much thought as it
> deserved. I felt - and it still feel - that the option of building on
> top of vsock wasn't considered seriously enough.
Hi Michal,
Thank you very much for the detailed explanation!

Just now I read your previous reply again and I think I actually failed to
get your point and my reply was inappropriate. I'm sorry about that.
 
When I firstly made the patch last July, I did try to build it on AF_VSOCK, 
but my feeling was that I had to made big changes to AF_VSOCK
code and its related transport layer driver's code. My feeling was that
the AF_VSOCK solution's implementation is not so generic that I can fit
mine in (easily).

To make my feeling more concrete so I can answer your question
properly, I'll be figuring out exactly how big the required changes will
be -- I'm afraid this would take non-trivial time, but I'll try to finish the
investigation ASAP.

The biggest challenge is the incompatible addressing scheme.
If you could give some advice, I would be very grateful.

> I must also admit I'm a bit confused by your response to the issue of
> socket lookup performance. I always thought the main reason to use
> special hypervisor sockets instead of TCP/IP over virtual network
> devices was efficiency (to avoid the overhead of network protocol
> processing). 
Yes, I agree with you.

BTW, IMO hypervisor sockets have an advantage of "zero-configuration".
To make TCP/IP work between host/guest, we need to add a NIC to
the guest, configure the NIC properly in the guest and find a way to
let the host/guest know each other's IP address, etc.

With hypervisor sockets, there is almost no such configuration effort.

> The fact that traversing a linear linked list under
> a global mutex for each socket lookup is not an issue as opening
> a connection is going to be slow anyway surprised me therefore. 
This is because, the design of AF_HYPERV in the Hyper-V host side is
suboptimal IMHO (the current host side design requires the least
change in the host side, but it makes my life difficult. :-(  It may
change in the future, but luckily we have to live with it at present):

1) A new connection is treated as a new Hyper-V device, so it has to
go through the slow device_register(). Please see
vmbus_device_register().

2) A connection/device must have its own ringbuffer that is shared
between host/guest. Allocating the ringbuffer memory in the VM 
and sharing the memory with the host by messages are both slow,
though I didn't measure the exact cost. Please see
hvsock_open_connection() -> vmbus_open().

3) The max length of the linear linked list is 2048, and in practice,
typically I guess the length should be small, so my gut feeling is that
the list traversing shouldn't be the bottleneck.
Having said that, I agree it's good to use some mechanism, like 
hash table, to speed up the lookup. I'll add this.

> But
> maybe it's fine as the typical use case is going to be small number of
> long running connections and traffic performance is going to make for
> the connection latency. 
Yeah, IMO it seems traffic performance and zero-configuration came
first when the current host side design was made.

> Or there are other advantages, I don't know.
> But if that is the case, it would IMHO deserve to be explained.
> 
>                                 Michal Kubecek

Thanks,
-- Dexuan
