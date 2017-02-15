From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V3 3/7] net/sched: Reflect HW offload status
Date: Wed, 15 Feb 2017 23:56:53 +0200
Message-ID: <CAJ3xEMgu+BUaUgyziqiLy+WU6x=1kHgL=kNqhQj-+xumq2OH3Q@mail.gmail.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
 <1487148757-24809-4-git-send-email-ogerlitz@mellanox.com> <CAJ3xEMg32qMp0Hh+BQbHdoMCKwX_ivvZVwo30njvXubR7ZQ8xA@mail.gmail.com>
 <20170215102821.12f419e7@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Roi Dayan <roid@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:35879 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdBOV4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 16:56:54 -0500
Received: by mail-ot0-f196.google.com with SMTP id l26so8450858ota.3
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 13:56:54 -0800 (PST)
In-Reply-To: <20170215102821.12f419e7@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 8:28 PM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
> On Wed, 15 Feb 2017 18:19:17 +0200, Or Gerlitz wrote:
>> On Wed, Feb 15, 2017 at 10:52 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> Currently there is no way of querying whether a filter is
>>> offloaded to HW or not when using "both" policy (where none
>>> of skip_sw or skip_hw flags are set by user-space).

>>> Add two new flags, "in hw" and "not in hw" such that user
>>> space can determine if a filter is actually offloaded to
>>> hw or not. The "in hw" UAPI semantics was chosen so it's
>>> similar to the "skip hw" flag logic.

>> To make things a bit more clear, the semantics of the "in hw"
>> thing relates to the time of dumping the rule.

>> Note that this future change doesn't change the UAPI, it will still
>> have two values, "in hw" and "not in hw".
>> The values with this series are the actual values and later with that change,
>> they will keep being the actual values, just the kernel method to
>> retrieve them will be different.

> Thanks for explaining this, I was actually hoping to take this in
> slightly different direction.

> What worries me is that the moment we started offloading packet
> modification we run at the risk of modifying packets twice.  This used
> to be a problem only for eBPF but now mlx5 can also offload things like
> ttl decrement.

hey, did you broke into my private git... joking, we submitted the tc
pedit enhancements for easy enablement of hw offloading but not yet
the offloading bits... but this is indeed coming up.

When the HW terminates packets that were matched by an offloaded
filter - e.g drop, encap/decap and/or push/pop vlan + fwd to wire/VM,
the SW TC DP (data path) will not see them and the problem doesn't
exist. In the case of non SRIOV NIC header re-write on RX, indeed, the
packet will be seen by the SW DP and if the SW control plane
programmed the rule to the SW DP too they could have a problem.

Re your TTL example, if we're offloading router, with matching on L2
src/dst addresses following by HW re-write of the L2 addresses and
decrements of TTL, the SW DP will not match and the action will not be
carried out twice.

Same for offloading NAT, if the matching is on L3/L4 addresses and
then the HW action is to re-write them, the SW DP will not match and
not re-write again.

So this is not very common to happen, but possible -- user space
application can avoid that by having such filters be set to only one
of the DPs, SW or HW.

> For filters which have no skip_* flags set and get
> offloaded if packet doesn't get redirected or modified significantly it
> will match the filter both in HW and on the host and therefore have the
> actions applied twice.  And it will get counted twice.  (It seems nobody
> ever raised this so perhaps I'm mistaken in thinking that this can happen?)

see above this is very rare and donno if there are real life examples
for such cases, but if it happens, yes, will be counted twice.

> Back to your patch set, I was hoping we will be able to use the new
> IN_HW flag to skip filters in software even if they don't have skip_sw
> set.  If we need to eject actions from HW based on external events, that
> obviously complicates things.  Three trivial solutions to the problem

can you clarify what is the precise problem you refer to? is that the
two DPs working on the same packet you mentioned above?

> I could think of are:
>  - pass a pointer to filter's flags down to the driver and let it do
>    atomic bitops? on it to set/clear the IN_HW status;
>  - add a way of driver calling back into TC;
>  - use one of recently freed skb TC bits to mark packets which were
>    supposed to be processed in HW by could not as needing software
>    fallback (I think this could work for you without parsing the packet
>    in the driver, you could replace the tunnel action with mark action
>    and leave the matching rule in HW classifier/TCAM; for BPF I have a
>    descriptor flag telling me if offloaded BPF completed successfully).


> FWIW this patch set looks good to me!

thanks, so you are okay we move forward with this series and if needed
address the matters you raised here in follow ups?
