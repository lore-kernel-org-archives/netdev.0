From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Fri, 25 Jul 2014 19:23:58 +0400
Message-ID: <53D2768E.2040902@samsung.com>
References: <53C2FF3D.4030201@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=------------060401010001020104050602
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>
To: Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <53C2FF3D.4030201@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060401010001020104050602
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 07/14/14 01:50, Sasha Levin wrote:

> 
> I've tried debugging it, but I don't see a code path that could lead to that.
> 

I finally found some time to take look at this and I've found where the problem is.

Sasha, I suppose there was no usual "Unable to handle NULL pointer deference" after KASAN's report, right?

This gave me a clue that address 0 is actually mapped and contains valid socket address structure in it.
I've managed to write a simple code (in attachment), which could easily reproduce this bug.

I've fixed it with the following patch, please take a look.


From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] net: sendmsg: fix NULL pointer dereference

Sasha's report:
	> While fuzzing with trinity inside a KVM tools guest running the latest -next
	> kernel with the KASAN patchset, I've stumbled on the following spew:
	>
	> [ 4448.949424] ==================================================================
	> [ 4448.951737] AddressSanitizer: user-memory-access on address 0
	> [ 4448.952988] Read of size 2 by thread T19638:
	> [ 4448.954510] CPU: 28 PID: 19638 Comm: trinity-c76 Not tainted 3.16.0-rc4-next-20140711-sasha-00046-g07d3099-dirty #813
	> [ 4448.956823]  ffff88046d86ca40 0000000000000000 ffff880082f37e78 ffff880082f37a40
	> [ 4448.958233]  ffffffffb6e47068 ffff880082f37a68 ffff880082f37a58 ffffffffb242708d
	> [ 4448.959552]  0000000000000000 ffff880082f37a88 ffffffffb24255b1 0000000000000000
	> [ 4448.961266] Call Trace:
	> [ 4448.963158] dump_stack (lib/dump_stack.c:52)
	> [ 4448.964244] kasan_report_user_access (mm/kasan/report.c:184)
	> [ 4448.965507] __asan_load2 (mm/kasan/kasan.c:352)
	> [ 4448.966482] ? netlink_sendmsg (net/netlink/af_netlink.c:2339)
	> [ 4448.967541] netlink_sendmsg (net/netlink/af_netlink.c:2339)
	> [ 4448.968537] ? get_parent_ip (kernel/sched/core.c:2555)
	> [ 4448.970103] sock_sendmsg (net/socket.c:654)
	> [ 4448.971584] ? might_fault (mm/memory.c:3741)
	> [ 4448.972526] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3740)
	> [ 4448.973596] ? verify_iovec (net/core/iovec.c:64)
	> [ 4448.974522] ___sys_sendmsg (net/socket.c:2096)
	> [ 4448.975797] ? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
	> [ 4448.977030] ? lock_release_holdtime (kernel/locking/lockdep.c:273)
	> [ 4448.978197] ? lock_release_non_nested (kernel/locking/lockdep.c:3434 (discriminator 1))
	> [ 4448.979346] ? check_chain_key (kernel/locking/lockdep.c:2188)
	> [ 4448.980535] __sys_sendmmsg (net/socket.c:2181)
	> [ 4448.981592] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2600)
	> [ 4448.982773] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
	> [ 4448.984458] ? syscall_trace_enter (arch/x86/kernel/ptrace.c:1500 (discriminator 2))
	> [ 4448.985621] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2600)
	> [ 4448.986754] SyS_sendmmsg (net/socket.c:2201)
	> [ 4448.987708] tracesys (arch/x86/kernel/entry_64.S:542)
	> [ 4448.988929] ==================================================================

This reports means that we've come to netlink_sendmsg() with msg->msg_name == NULL and msg->msg_namelen > 0.

After this report there was no usual "Unable to handle kernel NULL pointer dereference"
and this gave me a clue that address 0 is mapped and contains valid socket address structure in it.

This bug was introduced in f3d3342602f8bcbf37d7c46641cb9bca7618eb1c
(net: rework recvmsg handler msg_name and msg_namelen logic).
Commit message states that:
	"Set msg->msg_name = NULL if user specified a NULL in msg_name but had a
	 non-null msg_namelen in verify_iovec/verify_compat_iovec. This doesn't
	 affect sendto as it would bail out earlier while trying to copy-in the
	 address."
But in fact this affects sendto when address 0 is mapped and contains
socket address structure in it. In such case copy-in address will succeed,
verify_iovec() function will successfully exit with msg->msg_namelen > 0
and msg->msg_name == NULL.

This patch fixes it by assigning m->msg_name to address if move_addr_to_kernel()
was successful.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: <stable@vger.kernel.org>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 net/compat.c     | 6 ++++--
 net/core/iovec.c | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 9a76eaf..eefd989 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -92,9 +92,11 @@ int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
 						      kern_address);
 			if (err < 0)
 				return err;
-		}
-		if (kern_msg->msg_name)
+
 			kern_msg->msg_name = kern_address;
+		} else
+			if (kern_msg->msg_name)
+				kern_msg->msg_name = kern_address;
 	} else
 		kern_msg->msg_name = NULL;

diff --git a/net/core/iovec.c b/net/core/iovec.c
index 827dd6b..16bd954 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -47,9 +47,11 @@ int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *a
 						  address);
 			if (err < 0)
 				return err;
-		}
-		if (m->msg_name)
+
 			m->msg_name = address;
+		} else
+			if (m->msg_name)
+				m->msg_name = address;
 	} else {
 		m->msg_name = NULL;
 	}
-- 
1.8.5.5




--------------060401010001020104050602
Content-Type: text/x-csrc;
 name="sendmsg_nl.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="sendmsg_nl.c"

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <linux/netlink.h>

#define PAYLOAD 1024

int main(void)
{
	struct sockaddr_nl src_addr;
	struct sockaddr_nl *dest_addr;
	struct nlmsghdr *nlh = NULL;
	struct iovec iov;
	struct msghdr msg;
	int fd;

	memset(&msg, 0, sizeof(msg));

	fd = socket(PF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
	if (fd < 0) {
		perror("socket:");
		return -1;
	}

	dest_addr = mmap(0, sizeof(*dest_addr), PROT_READ|PROT_WRITE,
			MAP_FIXED|MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	if (dest_addr == MAP_FAILED) {
		perror("mmap:");
		close(fd);
		return -1;
	}

	memset(&src_addr, 0, sizeof(src_addr));
	src_addr.nl_family = AF_NETLINK;
	src_addr.nl_pid = getpid();

	bind(fd, (struct sockaddr*)&src_addr, sizeof(src_addr));

	memset(dest_addr, 0, sizeof(*dest_addr));
	dest_addr->nl_family = AF_NETLINK;
	dest_addr->nl_pid = 0;
	dest_addr->nl_groups = 0;

	nlh = (struct nlmsghdr *)malloc(NLMSG_SPACE(PAYLOAD));
	memset(nlh, 0, NLMSG_SPACE(PAYLOAD));
	nlh->nlmsg_len = NLMSG_SPACE(PAYLOAD);
	nlh->nlmsg_pid = getpid();
	nlh->nlmsg_flags = 0;

	strcpy(NLMSG_DATA(nlh), "Die kernel! Die!");

	iov.iov_base = (void *)nlh;
	iov.iov_len = nlh->nlmsg_len;
	msg.msg_name = dest_addr;
	msg.msg_namelen = sizeof(*dest_addr);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;

	if (sendmsg(fd, &msg, 0) < 0) {
		perror("sendmsg:");
		close(fd);
		return -1;
	}

	close(fd);
	return 0;
}

--------------060401010001020104050602--
