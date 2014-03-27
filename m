From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH net v2] openvswitch: fix a possible deadlock and
 lockdep warning
Date: Thu, 27 Mar 2014 14:18:29 -0700
Message-ID: <CALnjE+qGTK0KsZ1Q+Uky45VEYk=Eg7gbPs=SwcQyZtTs21wn2A@mail.gmail.com>
References: <1395929134-4487-1-git-send-email-fbl@redhat.com>
	<CALnjE+q41G9KKf_EhTdDvZtX_Xao_WG+KhRZ2fKe0JF8sqjZxw@mail.gmail.com>
	<20140327173344.GK18707@t520.home>
	<CAEP_g=--TMq8s4JdSTcybXgGM6o8mqrWh1NWGFt2Jy4QQuXjmA@mail.gmail.com>
	<20140327174434.GD2478@t520.home>
	<CAEP_g=_Mih_UxHfe4tbgG_iBcep-aeVdDi=nNfXtbGEm41XaXA@mail.gmail.com>
	<CALnjE+rdBo=hB128cpD_0sZkLEoaVCh3a8Z1HZb28-3hkJ3kEA@mail.gmail.com>
	<CAEP_g=_qAxU1s2DY43EpMXyJJS9sSAZLfz=OMVbV-rbdWWXy+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, openvswitch <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog032.obsmtp.com ([74.125.150.106]:33005 "HELO
	na6sys009bog032.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755086AbaC0VSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 17:18:30 -0400
Received: by mail-vc0-f170.google.com with SMTP id hu19so4985053vcb.15
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 14:18:29 -0700 (PDT)
In-Reply-To: <CAEP_g=_qAxU1s2DY43EpMXyJJS9sSAZLfz=OMVbV-rbdWWXy+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 1:01 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Mar 27, 2014 at 11:40 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Thu, Mar 27, 2014 at 11:32 AM, Jesse Gross <jesse@nicira.com> wrote:
>>> On Thu, Mar 27, 2014 at 10:44 AM, Flavio Leitner <fbl@redhat.com> wrote:
>>>> On Thu, Mar 27, 2014 at 10:37:32AM -0700, Jesse Gross wrote:
>>>>> On Thu, Mar 27, 2014 at 10:33 AM, Flavio Leitner <fbl@redhat.com> wrote:
>>>>> > On Thu, Mar 27, 2014 at 10:19:23AM -0700, Pravin Shelar wrote:
>>>>> >> On Thu, Mar 27, 2014 at 7:05 AM, Flavio Leitner <fbl@redhat.com> wrote:
>>>>> >> > There are two problematic situations.
>>>>> >> >
>>>>> >> > A deadlock can happen when is_percpu is false because it can get
>>>>> >> > interrupted while holding the spinlock. Then it executes
>>>>> >> > ovs_flow_stats_update() in softirq context which tries to get
>>>>> >> > the same lock.
>>>>> >> >
>>>>> >> > The second sitation is that when is_percpu is true, the code
>>>>> >> > correctly disables BH but only for the local CPU, so the
>>>>> >> > following can happen when locking the remote CPU without
>>>>> >> > disabling BH:
>>>>> >> >
>>>>> >> >        CPU#0                            CPU#1
>>>>> >> >   ovs_flow_stats_get()
>>>>> >> >    stats_read()
>>>>> >> >  +->spin_lock remote CPU#1        ovs_flow_stats_get()
>>>>> >> >  |  <interrupted>                  stats_read()
>>>>> >> >  |  ...                       +-->  spin_lock remote CPU#0
>>>>> >> >  |                            |     <interrupted>
>>>>> >> >  |  ovs_flow_stats_update()   |     ...
>>>>> >> >  |   spin_lock local CPU#0 <--+     ovs_flow_stats_update()
>>>>> >> >  +---------------------------------- spin_lock local CPU#1
>>>>> >> >
>>>>> >> > This patch disables BH for both cases fixing the deadlocks.
>>>>> >>
>>>>> >> This bug is already fixed in OVS.
>>>>> >
>>>>> > Could you point me to the commit? I am not finding anything
>>>>> > recent.
>>>>>
>>>>> This is the commit:
>>>>>
>>>>> commit 9d73c9cac76ba557fdac4a89c1b7eafe132b85a3
>>>>> Author: Pravin B Shelar <pshelar@nicira.com>
>>>>> Date:   Tue Dec 17 15:43:30 2013 -0800
>>>>>
>>>>>     datapath: Fix deadlock during stats update.
>>>>>
>>>>> I thought that I had sent it in the most recent batch of changes for
>>>>> net but it looks like I missed it.
>>>>
>>>> That commit is incomplete. Look at the scenario #2 which I explain
>>>> why it is needed to disable bh for all cpus and not just local ones.
>>>
>>> OK, I understand the second problem now. OVS master (which I am
>>> currently working to cross-port to net-next) uses a different strategy
>>> that also always disables bottom halves for a different reason. Since
>>> I forgot to send the original patch, maybe we can just apply this one
>>> to net instead and use the new stuff directly everywhere else.
>>>
>>
>> The ovs patch fixes locking issue.
>>
>> local cpu check is optimization for better latency which can be
>> significant on large SMP system. I think we should fix lockdep rather
>> than adding latency for ovs packet processing. But all this is going
>> to change with NUMA stats anyways, so I do not have any problem
>> pushing this new patch.
>
> I think there is actually a possible deadlock here, not just a lockdep
> warning. If you look at Flavio's diagram, it's a rather complicated
> series of events that would be necessary but it seems theoretically
> possible.

Right, I missed v2 commit msg. This patch is required to fix all deadlock cases.
