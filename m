From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 08:58:36 -0700
Message-ID: <CALx6S35Y+XsHHKNDkYzyYgbNH3tv4po-ix3GAhrpawbgg2LBXA@mail.gmail.com>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
	<1438124526-2129341-2-git-send-email-tom@herbertland.com>
	<20150729091333.GB13113@pox.localdomain>
	<1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150729095416.GC13113@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36783 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852AbbG2P6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 11:58:36 -0400
Received: by igbij6 with SMTP id ij6so148491575igb.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 08:58:36 -0700 (PDT)
In-Reply-To: <20150729095416.GC13113@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 2:54 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/29/15 at 11:29am, Eric Dumazet wrote:
>> On Wed, 2015-07-29 at 11:13 +0200, Thomas Graf wrote:
>> > On 07/28/15 at 04:02pm, Tom Herbert wrote:
>> > > This patch creates sk_set_txhash and eliminates protocol specific
>> > > inet_set_txhash and ip6_set_txhash. sk_set_txhash simply sets a
>> > > random number instead of performing flow dissection. sk_set_txash
>> > > is also allowed to be called multiple times for the same socket,
>> > > we'll need this when redoing the hash for negative routing advice.
>> > >
>> > > Signed-off-by: Tom Herbert <tom@herbertland.com>
>> >
>> > Doesn't this break TX hashing with SO_REUSEPORT?
>>
>>
>> AFAIK nothing uses sk_txhash yet.
>
> skb_set_hash_from_sk()
> skb_get_hash()
>
> Am I misreading this? I'm not using SO_REUSEPORT and it might be OK
> to assume that different sockets may go to different queues even if
> the L4 tuple is identical.

Hi Thomas,

The salient property of both sk_txhash and skb->hash is that they
provide a uniform distribution over flows. It is incorrect to assume
that either of these immutable during the lifetime of a flow, so yes
this means that packets of a flow may go to different receive queues
when hashes change. SO_REUSEPORT is a process in the receive path but
uses ehashfn over the ports. But even with SO_REUSEPORT we provide no
guarantee that packets of a "flow" will always hit the same socket,
the hashing is not consistent when new reuseport sockets are added or
removed-- this is actually a long standing issue with SO_REUSEPORT in
the TCP case since it is possible to orphan connections in SYN-RECV. I
believe Eric was working toward fixing that, so maybe in the future we
can use skb->hash if it is a savings.

Thanks,
Tom
