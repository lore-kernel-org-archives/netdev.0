From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Wed, 14 Sep 2016 13:13:16 +0200
Message-ID: <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47524 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761808AbcINLNT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 07:13:19 -0400
In-Reply-To: <20160913172408.GC6138@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On 09/13/2016 07:24 PM, Pablo Neira Ayuso wrote:
> On Tue, Sep 13, 2016 at 03:31:20PM +0200, Daniel Mack wrote:
>> On 09/13/2016 01:56 PM, Pablo Neira Ayuso wrote:
>>> On Mon, Sep 12, 2016 at 06:12:09PM +0200, Daniel Mack wrote:
>>>> This is v5 of the patch set to allow eBPF programs for network
>>>> filtering and accounting to be attached to cgroups, so that they apply
>>>> to all sockets of all tasks placed in that cgroup. The logic also
>>>> allows to be extendeded for other cgroup based eBPF logic.
>>>
>>> 1) This infrastructure can only be useful to systemd, or any similar
>>>    orchestration daemon. Look, you can only apply filtering policies
>>>    to processes that are launched by systemd, so this only works
>>>    for server processes.
>>
>> Sorry, but both statements aren't true. The eBPF policies apply to every
>> process that is placed in a cgroup, and my example program in 6/6 shows
>> how that can be done from the command line.
> 
> Then you have to explain me how can anyone else than systemd use this
> infrastructure?

I have no idea what makes you think this is limited to systemd. As I
said, I provided an example for userspace that works from the command
line. The same limitation apply as for all other users of cgroups.

> My main point is that those processes *need* to be launched by the
> orchestrator, which is was refering as 'server processes'.

Yes, that's right. But as I said, this rule applies to many other kernel
concepts, so I don't see any real issue.

>> That's a limitation that applies to many more control mechanisms in the
>> kernel, and it's something that can easily be solved with fork+exec.
> 
> As long as you have control to launch the processes yes, but this
> will not work in other scenarios. Just like cgroup net_cls and friends
> are broken for filtering for things that you have no control to
> fork+exec.

Probably, but that's only solvable with rules that store the full cgroup
path then, and do a string comparison (!) for each packet flying by.

>> That's just as transparent as SO_ATTACH_FILTER. What kind of
>> introspection mechanism do you have in mind?
> 
> SO_ATTACH_FILTER is called from the process itself, so this is a local
> filtering policy that you apply to your own process.

Not necessarily. You can as well do it the inetd way, and pass the
socket to a process that is launched on demand, but do SO_ATTACH_FILTER
+ SO_LOCK_FILTER  in the middle. What happens with payload on the socket
is not transparent to the launched binary at all. The proposed cgroup
eBPF solution implements a very similar behavior in that regard.

>> It's about filtering outgoing network packets of applications, and
>> providing them with L2 information for filtering purposes. I don't think
>> that's a very specific use-case.
>>
>> When the feature is not used at all, the added costs on the output path
>> are close to zero, due to the use of static branches.
> 
> *You're proposing a socket filtering facility that hooks layer 2
> output path*!

As I said, I'm open to discussing that. In order to make it work for L3,
the LL_OFF issues need to be solved, as Daniel explained. Daniel,
Alexei, any idea how much work that would be?

> That is only a rough ~30 lines kernel patchset to support this in
> netfilter and only one extra input hook, with potential access to
> conntrack and better integration with other existing subsystems.

Care to share the patches for that? I'd really like to have a look.

And FWIW, I agree with Thomas - there is nothing wrong with having
multiple options to use for such use-cases.


Thanks,
Daniel
