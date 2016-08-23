From: Daniel Mack <daniel@zonque.org>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Tue, 23 Aug 2016 12:03:03 +0200
Message-ID: <c76cafe1-8803-b5cb-b77d-0fad83db9fd7@zonque.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <20160819162158.GA25083@salvia> <20160819170739.GF29430@pox.localdomain>
 <20160822160610.GA32723@salvia>
 <05bfd5c4-4095-37ff-b7a6-85b8dca8ec70@zonque.org>
 <20160822172040.GA22876@ircssh.c.rugged-nimbus-611.internal>
 <721182c4-7285-c169-d088-c45c81a5219e@zonque.org>
 <20160823095347.GA3070@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Thomas Graf <tgraf@suug.ch>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34803 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754067AbcHWKDH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 06:03:07 -0400
In-Reply-To: <20160823095347.GA3070@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2016 11:54 AM, Sargun Dhillon wrote:
> On Tue, Aug 23, 2016 at 10:27:28AM +0200, Daniel Mack wrote:
>> On 08/22/2016 07:20 PM, Sargun Dhillon wrote:
>>> On Mon, Aug 22, 2016 at 06:22:20PM +0200, Daniel Mack wrote:
>>>> On 08/22/2016 06:06 PM, Pablo Neira Ayuso wrote:
>>
>>>>> This patchset also needs an extra egress hook, not yet known where to
>>>>> be placed, so two hooks in the network stacks in the end, 
>>>>
>>>> That should be solvable, I'm sure. I can as well leave egress out for
>>>> the next version so it can be added later on.
>>>>
>>> Any idea where you might put that yet? Does dev_xmit seems like a reasonable 
>>> place?
>>
>> Ah, yes. Thanks for the pointer, that seems to work fine.
>>
> Daniel pointed out to me that there's already a BPF program that's used there 
> for tc matches. So, it should work fine. I would just verify you can call 
> programs from IRQs, and rcu_bh plays well with it.

IRQs should not matter AFAICS, and for testing, I placed the hook even
outside of rcu_bh. All the program runner needs is rcu_read_lock() to
access the rcu protected pointers.

> Alternatively, if you want to filter only IP traffic, ip_output, and ip6_output 
> are fairly good places. I'm planning on putting some LSM hooks there soon. It's 
> a bit simpler.

If you do that, and that's simpler, we can as well move the hook over at
some point. For now, I think dev_xmit() is sufficient.

> I also suggest you use verdicts rather than trimming for simplicity sake.

That's how it works already. eBPF programs in that context are expected
to either return 0 (reject) or 1 (pass). The may, however cause side
effects such as shared map updates etc, which is what the example
program does for accounting.

> I think that we should just add another pointer to the end of sock_cgroup_data 
> while we're in this state of transition, and nudge people to disable 
> CONFIG_CGROUP_NET_PRIO and CONFIG_CGROUP_NET_CLASSID over time.
> 
> Alternatively, we add these controllers for v2, and we have some kind of marker 
> whether or not they're on v2 in the skcd. If they are, we can find the cgroup, 
> and get the prioidx, and classid from the css. Although the comment in 
> cgroup-defs.h suggests that v2 and classid should never be used concurrently, I 
> can't help but to disagree, given there's legacy infrastructure that leverages 
> classid.

I'll leave that to Tejun to comment on :)


Thanks,
Daniel
