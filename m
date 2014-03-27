From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net v2] openvswitch: fix a possible deadlock and
 lockdep warning
Date: Thu, 27 Mar 2014 11:32:13 -0700
Message-ID: <CAEP_g=_Mih_UxHfe4tbgG_iBcep-aeVdDi=nNfXtbGEm41XaXA@mail.gmail.com>
References: <1395929134-4487-1-git-send-email-fbl@redhat.com>
 <CALnjE+q41G9KKf_EhTdDvZtX_Xao_WG+KhRZ2fKe0JF8sqjZxw@mail.gmail.com>
 <20140327173344.GK18707@t520.home> <CAEP_g=--TMq8s4JdSTcybXgGM6o8mqrWh1NWGFt2Jy4QQuXjmA@mail.gmail.com>
 <20140327174434.GD2478@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	openvswitch <dev@openvswitch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog014.obsmtp.com ([74.125.150.68]:47935 "HELO
	na6sys009bog014.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756885AbaC0Scf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 14:32:35 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so3869878ieb.0
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 11:32:34 -0700 (PDT)
In-Reply-To: <20140327174434.GD2478@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 10:44 AM, Flavio Leitner <fbl@redhat.com> wrote:
> On Thu, Mar 27, 2014 at 10:37:32AM -0700, Jesse Gross wrote:
>> On Thu, Mar 27, 2014 at 10:33 AM, Flavio Leitner <fbl@redhat.com> wrote:
>> > On Thu, Mar 27, 2014 at 10:19:23AM -0700, Pravin Shelar wrote:
>> >> On Thu, Mar 27, 2014 at 7:05 AM, Flavio Leitner <fbl@redhat.com> wrote:
>> >> > There are two problematic situations.
>> >> >
>> >> > A deadlock can happen when is_percpu is false because it can get
>> >> > interrupted while holding the spinlock. Then it executes
>> >> > ovs_flow_stats_update() in softirq context which tries to get
>> >> > the same lock.
>> >> >
>> >> > The second sitation is that when is_percpu is true, the code
>> >> > correctly disables BH but only for the local CPU, so the
>> >> > following can happen when locking the remote CPU without
>> >> > disabling BH:
>> >> >
>> >> >        CPU#0                            CPU#1
>> >> >   ovs_flow_stats_get()
>> >> >    stats_read()
>> >> >  +->spin_lock remote CPU#1        ovs_flow_stats_get()
>> >> >  |  <interrupted>                  stats_read()
>> >> >  |  ...                       +-->  spin_lock remote CPU#0
>> >> >  |                            |     <interrupted>
>> >> >  |  ovs_flow_stats_update()   |     ...
>> >> >  |   spin_lock local CPU#0 <--+     ovs_flow_stats_update()
>> >> >  +---------------------------------- spin_lock local CPU#1
>> >> >
>> >> > This patch disables BH for both cases fixing the deadlocks.
>> >>
>> >> This bug is already fixed in OVS.
>> >
>> > Could you point me to the commit? I am not finding anything
>> > recent.
>>
>> This is the commit:
>>
>> commit 9d73c9cac76ba557fdac4a89c1b7eafe132b85a3
>> Author: Pravin B Shelar <pshelar@nicira.com>
>> Date:   Tue Dec 17 15:43:30 2013 -0800
>>
>>     datapath: Fix deadlock during stats update.
>>
>> I thought that I had sent it in the most recent batch of changes for
>> net but it looks like I missed it.
>
> That commit is incomplete. Look at the scenario #2 which I explain
> why it is needed to disable bh for all cpus and not just local ones.

OK, I understand the second problem now. OVS master (which I am
currently working to cross-port to net-next) uses a different strategy
that also always disables bottom halves for a different reason. Since
I forgot to send the original patch, maybe we can just apply this one
to net instead and use the new stuff directly everywhere else.

Pravin, any objections?
