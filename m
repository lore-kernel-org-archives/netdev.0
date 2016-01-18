From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: net: GPF in __netlink_ns_capable
Date: Mon, 18 Jan 2016 14:21:37 -0600
Message-ID: <878u3m7i5q.fsf@x220.int.ebiederm.org>
References: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
	<CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
	<20160118092047.GA30682@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160118092047.GA30682@gondor.apana.org.au> (Herbert Xu's
	message of "Mon, 18 Jan 2016 17:20:47 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Sat, Jan 16, 2016 at 01:08:33AM +0100, Richard Weinberger wrote:
>> On Fri, Jan 15, 2016 at 11:31 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> > Call Trace:
>> >  [<     inline     >] netlink_ns_capable net/netlink/af_netlink.c:1417
>> >  [<ffffffff8529c0a5>] netlink_capable+0x25/0x30 net/netlink/af_netlink.c:1432
>> 
>> Hmm, we're crashing because NETLINK_CB(skb).sk is NULL.
>> netlink_dump() creates a new skb without a netlink control block,
>> but infiniband's dump functions use netlink_capable() which needs a valid
>> NETLINK_CB(skb).sk.
>> 
>> What about something like that?
>
> No you can't do it here as netlink_unicast also calls this and for
> that case you'd be overwriting the original sending user-space
> socket with the kernel socket.
>
> I'm adding Eric Bierderman as he wrote some of the code in question.

*Scratches my head*

I think I am just going to recommend removing that bit of code from
the infiniband stack.

There are several things very wrong here.

First netlinnk_capable and it's ilk are for the very specific purpose of
handling backwards compatibility as a truly clean solution of checking
at open or connect time would break existing applications.
ib_nl_handle_resolv_resp is new code.  So it can almost certainly do
something cleaner.

netlink_capable is very much not for filtering netlink dumps, but for
filtering the queries themselves.  So it appears the capability check is
very much in the wrong place.

All of this is newish code and apparently never even tested as this code
should have failed this way for everyone.  So since the code does not
work not apparently has never worked, it is probably easiest just to
remove the problematic code (AKA revert), and start fresh and not
something that requires backwards compatibility hacks from day one.

By new I mean code that came in through the commit below.

commit 2ca546b92a024d07adedd15b4c262b1c2c0786ec
Author: Kaike Wan <kaike.wan@intel.com>
Date:   Fri Aug 14 08:52:09 2015 -0400

    IB/sa: Route SA pathrecord query through netlink
    
    This patch routes a SA pathrecord query to netlink first and processes the
    response appropriately. If a failure is returned, the request will be sent
    through IB. The decision whether to route the request to netlink first is
    determined by the presence of a listener for the local service netlink
    multicast group. If the user-space local service netlink multicast group
    listener is not present, the request will be sent through IB, just like
    what is currently being done.
    
    Signed-off-by: Kaike Wan <kaike.wan@intel.com>
    Signed-off-by: John Fleck <john.fleck@intel.com>
    Signed-off-by: Ira Weiny <ira.weiny@intel.com>
    Signed-off-by: Doug Ledford <dledford@redhat.com>

Eric
