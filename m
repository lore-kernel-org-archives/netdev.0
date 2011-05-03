From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC v3 00/10] snet: Security for NETwork syscalls
Date: Tue, 03 May 2011 09:53:32 -0700
Message-ID: <4DC0330C.60208@schaufler-ca.com>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Casey Schaufler <casey@schaufler-ca.com>
To: Samir Bellabes <sam@synack.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304432663-1575-1-git-send-email-sam@synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/3/2011 7:24 AM, Samir Bellabes wrote:
> Hello lsm and netdev people,
> This set of patches is the version 3 of snet, which I would like to submit as a
> RFC.
>
> snet is a linux security module. It provides a mecanism defering syscall
> security hooks and decision (verdict) to userspace.

As you have submitted this as a Request For Comments I will make one.

I first saw this approach in 1987, on Unix, from a company called
SecureWare (long completely assimilated into HP). The potential for
deadlock, where the system prevents the decision making application
from accessing the information it needs to grant itself access is
great. The performance impact of making security checks in user
space is appalling. The exposure for attack, especially regarding
denial of service, is enormous. I do not recommend this approach.

There are cases where user space access control assistance could
be appropriate, in particular controls based on the data involved.
Even those controls must be very carefully crafted to avoid
impacting the correct function of the system in the unhappily
likely event of the access control enforcing applications being
unavailable or incapable of keeping up with demand.

> snet has some subsystems :
>     - snet_core     : init and exit the system
>     - snet_hooks    : LSM hooks
>     - snet_netlink  : kernel-user communication (genetlink)
>     - snet_event    : manages the list of protected syscalls
>     - snet_verdict  : provides a waitqueue for syscalls and manage verdicts
>     - snet_ticket   : provides a granted-access ticket mecanism
>
> I believe that snet will help to get over the classical configuration
> complexity of others security modules, by providing interactivity to users.
> I also think that monolithic strategy is broken with snet, as we can provide
> security for others syscall's categories:
>  - sfs  : security for filesystem,
>  - stask: security for task,
>  - smem : security for memory
>  ..
>
> In this way, and by putting abstraction on how this subsystems can talk to each
> others, we may use the security combinaison we want: choose to run sfs,
> stask, but not snet nor smem. Better, developpers may investigated how to build
> another security subsystem for tasks, and use others existing (smem, snet..)
> which they don't want to modify
>
> I think that interactivity is very usefull for users, as they may be notify when
> something is wrong and take decision, and from userspace, the decision may be
> defered to another box. In this way, snet also have a advantage for mobile
> devices as the policy decision will be push to a distant server, mobile device
> will then wait for verdicts and as policy strategies are centralized.
>
> Interactivity is *not* only clicking a Yes/No question, as said, we
> can centralised previous locals LSM security subsytems, and make the
> network aware of events occuring on it.
>
> Finally, and a important point: snet integration respects the LSM framework idea
> of using LSM hooks.
>
> New feature from the previous version:
>  * Building a ticket mecanism for each task_struct using pointer void *security
>    Use the pointer (void*) security related to task_struct to provides
>    granted-acces tickets: if two identical requests are coming, ask the user
>    for the first one, store the result in a ticket and for the second request,
>    just look in the tickets owned by the task-struct
>  * send data buffer of sendmsg to userspace
>    this may provide a way to look inside the data (as a anti-virus do)
>
> roadmap:
>  * find a way to send data buffer of sendmsg to userspace (using netfilter)
>  * adding other security systems
>    we can think about adding fork(), exec(), open(), close()..
>
> I'm Ccing netfilter-devel, as snet may be seen as a way to do filtering.
>
> Last devel patchs were:
>  * using kmem_cache instead of kmalloc
>  * remove attend to send buffer socker to userspace
>
> Samir Bellabes (10):
>   lsm: add security_socket_closed()
>   Revert "lsm: Remove the socket_post_accept() hook"
>   snet: introduce snet_core
>   snet: introduce snet_event
>   snet: introduce snet_hooks
>   snet: introduce snet_netlink
>   snet: introduce snet_verdict
>   snet: introduce snet_ticket
>   snet: introduce snet_utils
>   snet: introduce security/snet, Makefile and Kconfig changes
>
>  include/linux/security.h            |   23 ++
>  include/linux/snet.h                |  117 ++++++
>  net/socket.c                        |    3 +
>  security/Kconfig                    |    6 +
>  security/Makefile                   |    2 +
>  security/capability.c               |   10 +
>  security/security.c                 |   10 +
>  security/snet/Kconfig               |   11 +
>  security/snet/Makefile              |   14 +
>  security/snet/snet_core.c           |   82 ++++
>  security/snet/snet_event.c          |  201 ++++++++++
>  security/snet/snet_event.h          |   21 +
>  security/snet/snet_hooks.c          |  722 +++++++++++++++++++++++++++++++++++
>  security/snet/snet_hooks.h          |   10 +
>  security/snet/snet_netlink.c        |  442 +++++++++++++++++++++
>  security/snet/snet_netlink.h        |   17 +
>  security/snet/snet_netlink_helper.c |  220 +++++++++++
>  security/snet/snet_netlink_helper.h |    7 +
>  security/snet/snet_ticket.c         |  195 ++++++++++
>  security/snet/snet_ticket.h         |   37 ++
>  security/snet/snet_ticket_helper.c  |  127 ++++++
>  security/snet/snet_ticket_helper.h  |    8 +
>  security/snet/snet_utils.c          |   38 ++
>  security/snet/snet_utils.h          |    9 +
>  security/snet/snet_verdict.c        |  203 ++++++++++
>  security/snet/snet_verdict.h        |   23 ++
>  26 files changed, 2558 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/snet.h
>  create mode 100644 security/snet/Kconfig
>  create mode 100644 security/snet/Makefile
>  create mode 100644 security/snet/snet_core.c
>  create mode 100644 security/snet/snet_event.c
>  create mode 100644 security/snet/snet_event.h
>  create mode 100644 security/snet/snet_hooks.c
>  create mode 100644 security/snet/snet_hooks.h
>  create mode 100644 security/snet/snet_netlink.c
>  create mode 100644 security/snet/snet_netlink.h
>  create mode 100644 security/snet/snet_netlink_helper.c
>  create mode 100644 security/snet/snet_netlink_helper.h
>  create mode 100644 security/snet/snet_ticket.c
>  create mode 100644 security/snet/snet_ticket.h
>  create mode 100644 security/snet/snet_ticket_helper.c
>  create mode 100644 security/snet/snet_ticket_helper.h
>  create mode 100644 security/snet/snet_utils.c
>  create mode 100644 security/snet/snet_utils.h
>  create mode 100644 security/snet/snet_verdict.c
>  create mode 100644 security/snet/snet_verdict.h
>
