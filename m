From: "Wan, Kaike" <kaike.wan@intel.com>
Subject: RE: net: GPF in __netlink_ns_capable
Date: Tue, 19 Jan 2016 20:47:54 +0000
Message-ID: <3F128C9216C9B84BB6ED23EF16290AFB185A40F6@CRSMSX101.amr.corp.intel.com>
References: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
	<CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
	<20160118092047.GA30682@gondor.apana.org.au>
	<878u3m7i5q.fsf@x220.int.ebiederm.org> <87vb6q63co.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	"Nicolas Dichtel" <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	"Alexander Potapenko" <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	"Eric Dumazet" <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"Fleck, John" <john.fleck@intel.com>,
	"Weiny, Ira" <ira.weiny@intel.com>,
	"Doug Ledford" <dledford@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:21620 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbcASUr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 15:47:58 -0500
In-Reply-To: <87vb6q63co.fsf@x220.int.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need to do some more investigation before getting back.  The original patches were tested in Kernel 4.3 and apparently no crash was observed at the time.  Adding netlink_capable() in the patch was meant to make sure that only admin has access to the IB netlink service.

Kaike

> -----Original Message-----
> From: Eric W. Biederman [mailto:ebiederm@xmission.com]
> Sent: Monday, January 18, 2016 3:27 PM
> To: Herbert Xu
> Cc: Richard Weinberger; David S. Miller; Thomas Graf; Daniel Borkmann;
> Ken-ichirou MATSUZAWA; Nicolas Dichtel; Florian Westphal; netdev; LKML;
> syzkaller; Kostya Serebryany; Alexander Potapenko; Sasha Levin; Eric
> Dumazet; Dmitry Vyukov; Wan, Kaike; Fleck, John; Weiny, Ira; Doug Ledford
> Subject: Re: net: GPF in __netlink_ns_capable
> 
> 
> Apparently we have missed entirely the folks who added this chunk of this
> code to the kernel on this thread, so adding them now.
> 
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
> > Herbert Xu <herbert@gondor.apana.org.au> writes:
> >
> >> On Sat, Jan 16, 2016 at 01:08:33AM +0100, Richard Weinberger wrote:
> >>> On Fri, Jan 15, 2016 at 11:31 PM, Dmitry Vyukov <dvyukov@google.com>
> wrote:
> >>> > Call Trace:
> >>> >  [<     inline     >] netlink_ns_capable net/netlink/af_netlink.c:1417
> >>> >  [<ffffffff8529c0a5>] netlink_capable+0x25/0x30
> >>> > net/netlink/af_netlink.c:1432
> >>>
> >>> Hmm, we're crashing because NETLINK_CB(skb).sk is NULL.
> >>> netlink_dump() creates a new skb without a netlink control block,
> >>> but infiniband's dump functions use netlink_capable() which needs a
> >>> valid NETLINK_CB(skb).sk.
> >>>
> >>> What about something like that?
> >>
> >> No you can't do it here as netlink_unicast also calls this and for
> >> that case you'd be overwriting the original sending user-space socket
> >> with the kernel socket.
> >>
> >> I'm adding Eric Bierderman as he wrote some of the code in question.
> >
> > *Scratches my head*
> >
> > I think I am just going to recommend removing that bit of code from
> > the infiniband stack.
> >
> > There are several things very wrong here.
> >
> > First netlinnk_capable and it's ilk are for the very specific purpose
> > of handling backwards compatibility as a truly clean solution of
> > checking at open or connect time would break existing applications.
> > ib_nl_handle_resolv_resp is new code.  So it can almost certainly do
> > something cleaner.
> >
> > netlink_capable is very much not for filtering netlink dumps, but for
> > filtering the queries themselves.  So it appears the capability check
> > is very much in the wrong place.
> >
> > All of this is newish code and apparently never even tested as this
> > code should have failed this way for everyone.  So since the code does
> > not work not apparently has never worked, it is probably easiest just
> > to remove the problematic code (AKA revert), and start fresh and not
> > something that requires backwards compatibility hacks from day one.
> >
> > By new I mean code that came in through the commit below.
> >
> > commit 2ca546b92a024d07adedd15b4c262b1c2c0786ec
> > Author: Kaike Wan <kaike.wan@intel.com>
> > Date:   Fri Aug 14 08:52:09 2015 -0400
> >
> >     IB/sa: Route SA pathrecord query through netlink
> >
> >     This patch routes a SA pathrecord query to netlink first and processes the
> >     response appropriately. If a failure is returned, the request will be sent
> >     through IB. The decision whether to route the request to netlink first is
> >     determined by the presence of a listener for the local service netlink
> >     multicast group. If the user-space local service netlink multicast group
> >     listener is not present, the request will be sent through IB, just like
> >     what is currently being done.
> >
> >     Signed-off-by: Kaike Wan <kaike.wan@intel.com>
> >     Signed-off-by: John Fleck <john.fleck@intel.com>
> >     Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> >     Signed-off-by: Doug Ledford <dledford@redhat.com>
> 
> What was this code trying to do with netlink_capable besides oops the kernel?
> 
> Eric
