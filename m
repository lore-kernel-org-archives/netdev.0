From: Li Zefan <lizefan@huawei.com>
Subject: Re: [BUG] Bug in netprio_cgroup and netcls_cgroup ?
Date: Mon, 21 Jan 2013 17:57:39 +0800
Message-ID: <50FD1113.6010402@huawei.com>
References: <50FCDB5C.4050608@huawei.com> <50FD0144.1000401@monom.org> <50FD0402.6060400@huawei.com> <50FD09FD.4010804@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Cgroups <cgroups@vger.kernel.org>
To: Daniel Wagner <wagi@monom.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50FD09FD.4010804@monom.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/1/21 17:27, Daniel Wagner wrote:
> On 21.01.2013 10:01, Li Zefan wrote:
>> On 2013/1/21 16:50, Daniel Wagner wrote:
>>> Hi Li,
>>>
>>> On 21.01.2013 07:08, Li Zefan wrote:
>>>> I'm not a network developer, so correct me if I'm wrong.
>>>>
>>>> Since commit 7955490f732c2b8
>>>> ("net: netprio_cgroup: rework update socket logic"), sock->sk->sk_cgrp_prioidx
>>>> is set when the socket is created, and won't be updated unless the task is
>>>> moved to another cgroup.
>>>>
>>>> Now the problem is, a socket can be _shared_ by multiple processes (fork, SCM_RIGHT).
>>>> If we place those processes in different cgroups, and each cgroup has
>>>> different configs, but all of the processes will send data via this socket
>>>> with the same network priority.
>>>
>>> Wouldn't that be addressed by 48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8
>>>
>>>     net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
>>>
>>>      A socket fd passed in a SCM_RIGHTS datagram was not getting
>>>      updated with the new tasks cgrp prioidx. This leaves IO on
>>>      the socket tagged with the old tasks priority.
>>>
>>>      To fix this add a check in the scm recvmsg path to update the
>>>      sock cgrp prioidx with the new tasks value.
>>>
>>> As I read this this should work for net_prio.
>>>
>>
>> But after process A passed the socket fd to B, both A and B can use the
>> same socket to send data, right? Then if A and B were placed in different
>> cgroups with differnt configs, A's config won't take effect anymore.
>>
>> Am I missing something?
> 
> I don't know. I guess at one point the socket resources are shared and then
> one configuration is taking preference. As you can see I am far away of
> being
> an expert in this field. Hopefully someone who understands this bits
> can chip in.
> 
> BTW, isn't this a similar to what should happen with the block io cgroup?
> What is the behavior with a fd writing to a file in the scenario you
> describe above?
> 

It forbids task moving in this case:

/*
 * We cannot support shared io contexts, as we have no mean to support
 * two tasks with the same ioc in two different groups without major rework
 * of the main cic data structures.  For now we allow a task to change
 * its cgroup only if it's the only owner of its ioc.
 */
static int blkcg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
