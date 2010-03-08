From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 12:47:44 -0800
Message-ID: <m1sk8ar15b.fsf@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>
	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>
	<m1aaulyy5c.fsf@fess.ebiederm.org> <4B92C886.9020507@free.fr>
	<m1fx4bxlfy.fsf@fess.ebiederm.org> <4B952BBE.6070507@free.fr>
	<m11vfuvi1t.fsf@fess.ebiederm.org> <4B9556A9.60206@free.fr>
	<m11vfusgsa.fsf@fess.ebiederm.org> <4B95611C.5060403@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B95611C.5060403@free.fr> (Daniel Lezcano's message of "Mon\, 08 Mar 2010 21\:42\:04 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> Eric W. Biederman wrote:
>> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>>
>>   
>>> Eric W. Biederman wrote:
>>>     
>>>> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>>>>
>>>>         
>>>>> Eric W. Biederman wrote:
>>>>>             
>>>>>> I have take an snapshot of my development tree and placed it at.
>>>>>>
>>>>>>
>>>>>> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
>>>>>>                   
>>>>> Hi Eric,
>>>>>
>>>>> thanks for the pointer.
>>>>>
>>>>> I tried to boot the kernel under qemu and I got this oops:
>>>>>             
>>>> I am clearly running an old userspace on my test machine.  No udev.
>>>> It looks like udev has a long standing netlink misfeature, where
>>>> it does not initializing NETLINK_CB....
>>>>
>>>>
>>>> >From 8d85e3ab88718eda3d94cf8e1be14b69dae2b8f1 Mon Sep 17 00:00:00 2001
>>>> From: Eric W. Biederman <ebiederm@xmission.com>
>>>> Date: Mon, 8 Mar 2010 09:25:20 -0800
>>>> Subject: [PATCH] kobject_uevent:  Use the netlink allocator helper...
>>>>
>>>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>>>>         
>>> Thanks.
>>>
>>> I was able to boot but I have the following warning:
>>>     
>>
>> Thanks for the bug report.
>>   
> Thanks to you for the patchset :)
>
>> For the moment you might want to drop:
>> af_netlink:  Allow credentials to work across namespaces.
>> af_netlink: Debugging in case I have missed something.
>>
>> Although I am curious if you hit my debugging messages in
>> netlink recv.
>>   
> No, it does not appear (looked for "missing NETLINK_CB proto").
>
>> I guess if the goal is to test my nsfd bits you can drop everything
>> starting with my 'scm: Reorder scm_cookie.' commit.  The rest is what
>> it takes to get get uids, gid and pids translated when the cross
>> namespaces on an af_unix of an af_netlink socket.
>>
>> At least in the af_netlink case it appears clear I am have missed
>> something.
>>
>> This is a warning that netlink throws when the packet accounting messed
>> up.  So it sounds like you are exercising another path that I failed
>> to exercise and fix.
>>   
> I will look forward if I find more clues for this warning.
>
> In the meantime  was able to enter the container with the ugly following
> program:
>
> #include <unistd.h>
> #include <stdlib.h>
> #include <stdio.h>
> #include <syscall.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <sys/param.h>
>
> #define __NR_setns 300
>
> int setns(int nstype, int fd)
> {
>    return syscall (__NR_setns, nstype, fd);
> }
>
> int main(int argc, char *argv[])
> {
>    char path[MAXPATHLEN];
>    char *ns[] = { "pid", "mnt", "net", "pid", "uts" };
>    const int size = sizeof(ns) / sizeof(char *);
>    int fd[size];
>    int i;
>
>    if (argc != 3) {
>        fprintf(stderr, "mynsenter <pid> <command>\n");
>        exit(1);
>    }
>
>    for (i = 0; i < size; i++) {
>            sprintf(path, "/proc/%s/ns/%s", argv[1], ns[i]);
>
>        fd[i] = open(path, O_RDONLY);
>        if (fd[i] < 0) {
>            perror("open");
>            return -1;
>        }
>
>    }
>
>    for (i = 0; i < size; i++) {
>
>        if (setns(0, fd[i])) {
>            perror("setns");
>            return -1;
>        }
>    }
>
>    execve(argv[2], &argv[2], NULL);
>    perror("execve");
>
>    return 0;
> }
>
> At the fist glance, no problem :)

No fork() so your processes is completely in the pid namespace?

Eric

