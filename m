From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [ABI REVIEW][PATCH 0/8] Namespace file descriptors
Date: Fri, 24 Sep 2010 09:02:39 -0400
Message-ID: <4C9CA16F.3000505@mit.edu>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ocborgq7.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Introduce file for manipulating namespaces and related syscalls.
> files:
> /proc/self/ns/<nstype>
> 
> syscalls:
> int setns(unsigned long nstype, int fd);
> socketat(int nsfd, int family, int type, int protocol);
> 

How does security work?  Are there different kinds of fd that give (say) pin-the-namespace permission, socketat permission, and setns permission?

--Andy

> Netlink attribute:
> IFLA_NS_FD int fd.
> 
> Name space file descriptors address three specific problems that
> can make namespaces hard to work with.
> - Namespaces require a dedicated process to pin them in memory.
> - It is not possible to use a namespace unless you are the child of the
>   original creator.
> - Namespaces don't have names that userspace can use to talk about them.
> 
> Opening of the /proc/self/ns/<nstype> files return a file descriptor
> that can be used to talk about a specific namespace, and to keep the
> specified namespace alive.
> 
> /proc/self/ns/<nstype> can be bind mounted as:
> mount --bind /proc/self/ns/net /some/filesystem/path
> to keep the namespace alive as long as the mount exists.
> 
> setns() as a companion to unshare allows changing the namespace
> of the current process, being able to unshare the namespace is
> a requirement.
> 
> There are two primary envisioned uses for this functionality.
> o ``Entering'' an existing container.
> o Allowing multiple network namespaces to be in use at once on
>   the same machine, without requiring elaborate infrastructure.
> 
> Overall this received positive reviews on the containers list but this
> needs a wider review of the ABI as this is pretty fundamental kernel
> functionality.
> 
> 
> I have left out the pid namespaces bits for the moment because the pid
> namespace still needs work before it is safe to unshare, and my concern
> at the moment is ensuring the system calls seem reasonable.
> 
> Eric W. Biederman (8):
>       ns: proc files for namespace naming policy.
>       ns: Introduce the setns syscall
>       ns proc: Add support for the network namespace.
>       ns proc: Add support for the uts namespace
>       ns proc: Add support for the ipc namespace
>       ns proc: Add support for the mount namespace
>       net: Allow setting the network namespace by fd
>       net: Implement socketat.
> 
> ---
>  fs/namespace.c              |   57 +++++++++++++
>  fs/proc/Makefile            |    1 +
>  fs/proc/base.c              |   22 +++---
>  fs/proc/inode.c             |    7 ++
>  fs/proc/internal.h          |   18 ++++
>  fs/proc/namespaces.c        |  193 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/if_link.h     |    1 +
>  include/linux/proc_fs.h     |   20 +++++
>  include/net/net_namespace.h |    1 +
>  ipc/namespace.c             |   31 +++++++
>  kernel/nsproxy.c            |   39 +++++++++
>  kernel/utsname.c            |   32 +++++++
>  net/core/net_namespace.c    |   56 +++++++++++++
>  net/core/rtnetlink.c        |    4 +-
>  net/socket.c                |   26 ++++++-
>  15 files changed, 494 insertions(+), 14 deletions(-)
> 
