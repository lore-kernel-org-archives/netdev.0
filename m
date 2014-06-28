From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Fri, 27 Jun 2014 22:12:52 -0700
Message-ID: <87vbrl8vmz.fsf@x220.int.ebiederm.org>
References: <87lhskpizv.fsf@x220.int.ebiederm.org>
	<20140626.134335.2147671135749217539.davem@davemloft.net>
	<87egybibh5.fsf@x220.int.ebiederm.org>
	<20140626.154428.1099304313432511688.davem@davemloft.net>
	<CAM_iQpX7iPR=32kog=QJm4G1tgRfg80Hr8Y=BOgUiGnym5EmKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	stephane.graber@canonical.com, chris.j.arges@canonical.com,
	Serge Hallyn <serge.hallyn@canonical.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43083 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaF1FQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 01:16:13 -0400
In-Reply-To: <CAM_iQpX7iPR=32kog=QJm4G1tgRfg80Hr8Y=BOgUiGnym5EmKw@mail.gmail.com>
	(Cong Wang's message of "Fri, 27 Jun 2014 17:09:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Thu, Jun 26, 2014 at 3:44 PM, David Miller <davem@davemloft.net> wrote:
>>
>> First of all it is clear that once you start creating containers on the
>> order of half the global neigh limit, yes you will run into problems as
>> it's easy to have 2 or more outputs in flight.
>>
>> So it would perhaps be wise to scale the limits (in some way) based
>> upon the number of namespaces, but still keep it a global limit.
>>
>> These entries consume a global resource (memory) and benefit from
>> global sharing, so I am still convinced that making the tables
>> themselves per-ns does not make any sense.
>>
>> Secondly, if there are things holding onto neighbour entries for real
>> we should find this out.  Once could audit neigh_lookup*() invocations
>> to see where that might be happening.  Also neigh_create() calls with
>> 'want_ref' set to true.
>>
>
> Hmm, I did overlook the potential DOS problem. But hold on, isn't
> IP fragments have the same problem? The fragment queues are per
> netns, and the thresh is per netns as well, we will eventually have
> memory pressure as well.

Interesting.  It does look like ip fragments are susceptible that way.

Sorting out limits is something that that is still quite rough, in the
code today.

Limits serve two basic purposes.
- Basic sanity limits so that a buggy application can be
  killed/stopped hopefully before they take down the entire machine.

  Think of the file descriptor limit.

- Machine hogging limits to prevent one application from interferring
  with other applications.  This is what the kernel memory limit of
  the memory cgroup tries to implememt.

These purposes aren't entirely distinct.  So it is a bit of a challenge
to separate them.

Basic sanity limits are the easiest to comprehend as the reasoning is
all local.  You just have to say any application that uses more than X
amount of a resource is clearly buggy.  With a sysctl/rlimit knob to
handle those rare applications that legitimately need more than X.

Machine hogging limits are very different as that actually requires
looking at how global state is used.  I would like to say that the
memory cgroup tackles successfully that problem but it last I looked it
has some nasty deadlock potentials when dealing with kernel memory.

I wish I had a clear recipe I could point people at to get all of these
issues sorted correctly, unfortunately all I have is a little bit of
clarity as to what the problems actually are.

Eric
