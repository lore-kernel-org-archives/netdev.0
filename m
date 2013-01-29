From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next v2] pktgen: support net namespace
Date: Mon, 28 Jan 2013 20:17:10 -0800
Message-ID: <87y5fchbcp.fsf@xmission.com>
References: <1359424389-21919-1-git-send-email-amwang@redhat.com>
	<874ni0k965.fsf@xmission.com> <1359428563.20729.12.camel@cr0>
	<877gmwirx5.fsf@xmission.com> <1359431677.20729.18.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47997 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab3A2ERZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 23:17:25 -0500
In-Reply-To: <1359431677.20729.18.camel@cr0> (Cong Wang's message of "Tue, 29
	Jan 2013 11:54:37 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> On Mon, 2013-01-28 at 19:33 -0800, Eric W. Biederman wrote:
>> Cong Wang <amwang@redhat.com> writes:
>> 
>> > On Mon, 2013-01-28 at 18:36 -0800, Eric W. Biederman wrote:
>> >> Cong Wang <amwang@redhat.com> writes:
>> >> 
>> >> > From: Cong Wang <amwang@redhat.com>
>> >> >
>> >> > v2: remove a useless check
>> >> >
>> >> > This patch add net namespace to pktgen, so that
>> >> > we can use pktgen in different namespaces.
>> >> >
>> >> > Cc: Eric W. Biederman <ebiederm@xmission.com>
>> >> > Cc: David S. Miller <davem@davemloft.net>
>> >> > Signed-off-by: Cong Wang <amwang@redhat.com>
>> >> >
>> >> > ---
>> >> >  net/core/pktgen.c |  123 +++++++++++++++++++++++++++++++++++------------------
>> >> >  1 files changed, 81 insertions(+), 42 deletions(-)
>> >> 
>> >> Skiming through this again I have spotted what looks like a pretty
>> >> major bug.  You are limiting yourself to one network device per network
>> >> namespace when the actual limit is one network device per thread.
>> >> 
>> >> I think you can just kill the dev member of pktgen_net and the two or
>> >> three lines of code that touch it.
>> >
>> > Good point!
>> >
>> > It is used by pktgen_device_event() to check if the device generates the
>> > event is the one in our namespace.
>> 
>> Which of course is trivial with dev_net()...;
>> 
>> > It is safe to continue the search even if it is not in our namespace,
>> > but it is not efficient. Probably we need to make pktgen_threads list
>> > per-namespace.
>> 
>> Having looked at the code a bit more I think the solution really is to
>> make the proc files per network namespace as you are doing, but to leave
>> the threads per cpu.  Then it is just a matter of adding for_each_net
>> loops in the in the paths that add and remove the proc files.
>
> Hmm?
>
> pktgen creates each thread/proc file for each cpu, since proc files are
> per-namespace, we will have nr_cpu*nr_ns such proc files and threads.

I was thinking in pktgen_create_thread to do something like:

	for_each_net(net) {
		struct pktgen_net *pn = net_generic(net, pg_net_id);
		pe = proc_create_data(t->tsk->comm, 0600, pn->proc_dir,
				      &pktgen_thread_fops, t);
		if (!pe) {
			....
                }
        }

And in pktgen_thread_write do something like:
	struct pktgen_net *pn = net_generic(current->nsproxy->net_ns, pg_net_id);
	pktgen_add_device(pn, t, f);

Using the seq_net infrastructure you can avoid using current but that
is not necessary to illustrate the basic idea.

> It hard to improve this due to this kind of design.

Whatever works but I don't think it looks that hard.

> I already finished v3 patch which makes pktgen_threads list per-ns, so
> far it works well. I am still testing it.

Fair enough.  Working code is a good place to start.

Eric
