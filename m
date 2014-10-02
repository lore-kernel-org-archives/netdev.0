From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Thu, 2 Oct 2014 10:35:35 -0700
Message-ID: <CA+mtBx_wUeROF33pcxF5+08HcpPkK4mOsR-3gxmVJtxbHgi4HA@mail.gmail.com>
References: <20141001203345.3321.99675.stgit@dragon>
	<CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
	<20141002165215.GJ1803@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34580 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbaJBRfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:35:36 -0400
Received: by mail-oi0-f44.google.com with SMTP id x69so2243563oia.31
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 10:35:35 -0700 (PDT)
In-Reply-To: <20141002165215.GJ1803@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 2, 2014 at 9:52 AM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <therbert@google.com> wrote:
>> On Wed, Oct 1, 2014 at 1:35 PM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
>> > from the qdisc layer, to implement dequeue bulking.
>> >
>> > Patch01: "qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE"
>> >  - Implement basic qdisc dequeue bulking
>> >  - This time, 100% relying on BQL limits, no magic safe-guard constants
>> >
>> > Patch02: "qdisc: dequeue bulking also pickup GSO/TSO packets"
>> >  - Extend bulking to bulk several GSO/TSO packets
>> >  - Seperate patch, as it introduce a small regression, see test section.
>> >
>> > We do have a patch03, which exports a userspace tunable as a BQL
>> > tunable, that can byte-cap or disable the bulking/bursting.  But we
>> > could not agree on it internally, thus not sending it now.  We
>> > basically strive to avoid adding any new userspace tunable.
>> >
>> Unfortunately we probably still need something. If BQL were disabled
>> (by setting BQL min_limit to infinity) then we'll always dequeue all
>> the packets in the qdisc. Disabling BQL might be legitimate in
>> deployment if say a bug is found in a device that prevents prompt
>> transmit completions for some corner case.
>
> Hmm.  Thats confusing.
>
> So you are saying to disable bql one should do
>
> cat limit_max > limit_min ?
>
echo max > limit_min
echo max > limit_max

"Disables" BQL by forcing the limit to be really big.

> But thats not the same as having a bql-unaware driver.
>
Yes, that's true. This does not disable the accounting and limit check
which is where a bug would manifest itself.

> Seems to get same behavior as non-bql aware driver (where
> dql_avail always returns 0 since num_queued and adj_limit remain at 0)
> is to set
>
That doesn't work for BQL, if dql_avail returning zero means we can
queue only one packet.

> echo 0 > limit_max
>
> ... which makes dql_avail() return 0, which then also turns off bulk
> dequeue.
>
> Confused,
> Florian

I withdraw my comment.
