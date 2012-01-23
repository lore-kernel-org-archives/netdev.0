From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Mon, 23 Jan 2012 08:30:08 +0100
Message-ID: <201201230830.08993.hans.schillstrom@ericsson.com>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net> <201201230758.55200.hans.schillstrom@ericsson.com> <m1ipk2riqb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox@diac24.net" <equinox@diac24.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:61921 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab2AWHaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 02:30:12 -0500
In-Reply-To: <m1ipk2riqb.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 23 January 2012 08:17:00 Eric W. Biederman wrote:
> Hans Schillstrom <hans.schillstrom@ericsson.com> writes:
> 
> > On Monday 23 January 2012 07:25:52 Eric W. Biederman wrote:
> >> Hans Schillstrom <hans.schillstrom@ericsson.com> writes:
> >> 
> >> > On Friday 20 January 2012 21:55:27 Eric W. Biederman wrote:
> >> >> My current hypothesis is that the namespace actually didn't get freed
> >> >> until the tcp socket finished closing.  You can check by looking at when
> >> >> __put_net and then cleanup_net are called.
> >> >
> >> > __put_net() is called just after tcp_write_timer() fires and then
> >> > cleanup_net()
> >> 
> >> Hypothesis confirmed.  Your speed problem is that it is taking 2 minutes
> >> in the pathological case for your tcp socket to close.
> >> 
> >> Do you have any clue why it is taking your sockets so long to close?
> >> Is the other side simply not responding?
> >> 
> >
> > The root cause of death is that the other side (init_net namespace) dies first 
> > and when it dies all containers will be killed ...
> 
> ?????
> 
> init_net can not die.  init_net must not die.  It makes no sense for the
> ref count on init_net to drop to 0.  Among other places every kernel
> thread uses init_net.  Furthermore the network namespaces are
> independent so even the impossible death of the initial network
> namespace should not kill a child network namespace.
> 
> Did I misunderstand what you said?

Yes you did, sorry for my bad expl.

> 
> If you have a setup where you stop being able to talk to the outside
> world because you were relaying through the initial network namespace
> and the relay through the initial network namespace stopped functioning
> that makes sense.  So effectively all of your packets are being dropped
> on the floor the tcp retransmit behavior on closing a socket makes
> sense.  I just don't get how you have triggered that state.
> 

We  have a process in root name space (init_net) that have 
tcp connections into a number of containers (in the same machine)

If the control process in root ns dies all containers will also be killed
i.e. there can easilly be out standing messages to and from the containers.
So I guess that's why I see the tcp_write_timer()

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
