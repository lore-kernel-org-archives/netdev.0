From: Aleksa Sarai <asarai@suse.de>
Subject: RFC: making cn_proc work in {pid,user} namespaces
Date: Sun, 15 Oct 2017 21:05:49 +1100
Message-ID: <a2fa1602-2280-c5e8-cac9-b718eaea5d22@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        Christian Brauner <christian.brauner@ubuntu.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Evgeniy Polyakov <zbr@ioremap.net>,
        dev <dev@opencontainers.org>,
        "cyphar@cyphar.com >> Aleksa Sarai" <cyphar@cyphar.com>
To: Linux Containers <containers@lists.linux-foundation.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

At the moment, cn_proc is not usable by containers or container 
runtimes. In addition, all connectors have an odd relationship with 
init_net (for example, /proc/net/connectors only exists in init_net). 
There are two main use-cases that would be perfect for cn_proc, which is 
the reason for me pushing this:

First, when adding a process to an existing container, in certain modes 
runc would like to know that process's exit code. But, when joining a 
PID namespace, it is advisable[1] to always double-fork after doing the 
setns(2) to reparent the joining process to the init of the container 
(this causes the SIGCHLD to be received by the container init). It would 
also be useful to be able to monitor the exit code of the init process 
in a container without being its parent. At the moment, cn_proc doesn't 
allow unprivileged users to use it (making it a problem for user 
namespaces and "rootless containers"). In addition, it also doesn't 
allow nested containers to use it, because it requires the process to be 
in init_pid. As a result, runc cannot use cn_proc and relies on SIGCHLD 
(which can only be used if we don't double-fork, or keep around a 
long-running process which is something that runc also cannot do).

Secondly, there are/were some init systems that rely on cn_proc to 
manage service state. From a "it would be neat" perspective, I think it 
would be quite nice if such init systems could be used inside 
containers. But that requires cn_proc to be able to be used as an 
unprivileged user and in a pid namespace other than init_pid.

The /proc/net/connectors thing is quite easily resolved (just make it 
the connector driver perdev and make some small changes to make sure the 
interfaces stay sane inside of a container's network namespace). I'm 
sure that we'll probably have to make some changes to the registration 
API, so that a connector can specify whether they want to be visible to 
non-init_net namespaces.

However, the cn_proc problem is a bit harder to resolve nicely and there 
are quite a few interface questions that would need to be agreed upon. 
The basic idea would be that a process can only get cn_proc events if it 
has ptrace_may_access rights over said process (effectively a forced 
filter -- which would ideally be done send-side but it looks like it 
might have to be done receive-side). This should resolve possible 
concerns about an unprivileged process being able to inspect (fairly 
granular) information about the host. And obviously the pids, uids, and 
gids would all be translated according to the receiving process's user 
namespaces (if it cannot be translated then the message is not 
received). I guess that the translation would be done in the same way as 
SCM_CREDENTIALS (and cgroup.procs files), which is that it's done on the 
receive side not the send side.

My reason for sending this email rather than just writing the patch is 
to see whether anyone has any solid NACKs against the use-case or 
whether there is some fundamental issue that I'm not seeing. If nobody 
objects, I'll be happy to work on this.

[1]: https://lwn.net/Articles/532748/

-- 
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
