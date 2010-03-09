From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 09 Mar 2010 02:13:08 -0800
Message-ID: <m1ocixn6q3.fsf@fess.ebiederm.org>
References: <4B88E431.6040609@parallels.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <4B8E9370.3050300@parallels.com>
	<m17hptjh3m.fsf@fess.ebiederm.org> <4B9158F5.5040205@parallels.com>
	<m1vdda1pmx.fsf@fess.ebiederm.org> <4B926B1B.5070207@free.fr>
	<m1aaulyy5c.fsf@fess.ebiederm.org> <4B92C886.9020507@free.fr>
	<m1fx4bxlfy.fsf@fess.ebiederm.org> <4B952BBE.6070507@free.fr>
	<m11vfuvi1t.fsf@fess.ebiederm.org> <4B9556A9.60206@free.fr>
	<m11vfusgsa.fsf@fess.ebiederm.org> <4B95611C.5060403@free.fr>
	<m1sk8ar15b.fsf@fess.ebiederm.org> <4B956852.7050804@free.fr>
	<m1lje2qzf4.fsf@fess.ebiederm.org> <4B961D09.4010802@free.fr>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37193 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab0CIKNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 05:13:16 -0500
In-Reply-To: <4B961D09.4010802@free.fr> (Daniel Lezcano's message of "Tue\, 09 Mar 2010 11\:03\:53 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> Eric W. Biederman wrote:
>
> [ ... ]
>> I guess my meaning is I was expecting.
>> child = fork();
>> if (child == 0) {
>> 	execve(...);
>> }
>> waitpid(child);
>>
>> This puts /bin/sh in the container as well.
>>   
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
>    pid_t pid;
>    if (argc != 3) {
>        fprintf(stderr, "mynsenter <pid> <command>\n");
>        exit(1);
>    }
>
>    for (i = 0; i < size; i++) {
>            sprintf(path, "/proc/%s/ns/%s", argv[1], ns[i]);
>
>        fd[i] = open(path, O_RDONLY| FD_CLOEXEC);
>        if (fd[i] < 0) {
>            perror("open");
>            return -1;
>        }
>
>    }
>    for (i = 0; i < size; i++)
>        if (setns(0, fd[i])) {
>            perror("setns");
>            return -1;
>        }
>
>    pid = fork();
>    if (!pid) {
>
>        fprintf(stderr, "mypid is %d\n", syscall(__NR_getpid));
>
>        execve(argv[2], &argv[2], NULL);
>        perror("execve");
>
>    }
>
>    if (pid < 0) {
>        perror("fork");
>        return -1;
>    }
>
>    if (waitpid(&pid, NULL, 0) < 0) {
>        perror("waitpid");
>    }
>
>    return 0;
> }

&pid ???  Isn't that a type error?

> Waitpid returns an error:
>
> waitpid: No child processes
>
> The pid number returned by fork is the pid from the init pid namespace but it
> seems waitpid is waiting for a pid belonging to the child pid namespace.
>
> waitpid
> -> wait4
>   -> find_get_pid
>     -> find_vpid
>       -> find_pid_ns(nr, current->nsproxy->pid_ns);

But it isn't.  It is.
           find_pid_ns(nr, task_active_pid_ns(current));
Which is:
           find_pid_ns(nr, ns_of_pid(task_pid(current)));
           
Which is a value that doesn't change.  When we attach to a pid namespace.

> The current->nsproxy->pid_ns is the one of the namespace we attached to. So the
> real pid returned by the fork does not exist in this pid namespace.
> Maybe fork should return a pid number belonging to the current pid namespace we
> are attached no ?

Do you not have my patch that changed that?

Eric

