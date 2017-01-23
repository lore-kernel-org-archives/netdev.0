From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 12:36:08 -0800
Message-ID: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59278 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751669AbdAWUgM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 15:36:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To see how cgroup+bpf interacts with network namespaces, I wrote a
little program called show_bind that calls getsockopt(...,
SO_BINDTODEVICE, ...) and prints the result.  It did this:

 # ./ip link add dev vrf0 type vrf table 10
 # ./ip vrf exec vrf0 ./show_bind
 Default binding is "vrf0"
 # ./ip vrf exec vrf0 unshare -n ./show_bind
 show_bind: getsockopt: No such device

What's happening here is that "ip vrf" looks up vrf0's ifindex in
the init netns and installs a hook that binds sockets to that
ifindex.  When the hook runs in a different netns, it sets
sk_bound_dev_if to an ifindex from the wrong netns, resulting in
incorrect behavior.  In this particular example, the ifindex was 4
and there was no ifindex 4 in the new netns.  If there had been,
this test would have malfunctioned differently

Since it's rather late in the release cycle, let's punt.  This patch
makes it impossible to install cgroup+bpf hooks outside the init
netns and makes them not run on sockets that aren't in the init
netns.

In a future release, it should be relatively straightforward to make
these hooks be local to a netns and, if needed, to add a flag so
that hooks can be made global if necessary.  Global hooks should
presumably be constrained so that they can't write to any ifindex
fields.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---

DaveM, this mitigates a bug in a feature that's new in 4.10, and the
bug can be hit using current iproute2 -git.  please consider this for
-net.

Changes from v1:
 - Fix the commit message.  'git commit' was very clever and thought that
   all the interesting bits of the test case were intended to be comments
   and stripped them.  Whoops!

kernel/bpf/cgroup.c  | 21 +++++++++++++++++++++
 kernel/bpf/syscall.c | 11 +++++++++++
 2 files changed, 32 insertions(+)

diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a515f7b007c6..a824f543de69 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -143,6 +143,17 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 	if (!sk || !sk_fullsock(sk))
 		return 0;
 
+	/*
+	 * For now, socket bpf hooks attached to cgroups can only be
+	 * installed in the init netns and only affect the init netns.
+	 * This could be relaxed in the future once some semantic issues
+	 * are resolved.  For example, ifindexes belonging to one netns
+	 * should probably not be visible to hooks installed by programs
+	 * running in a different netns.
+	 */
+	if (sock_net(sk) != &init_net)
+		return 0;
+
 	if (sk->sk_family != AF_INET &&
 	    sk->sk_family != AF_INET6)
 		return 0;
@@ -186,6 +197,16 @@ int __cgroup_bpf_run_filter_sk(struct sock *sk,
 	struct bpf_prog *prog;
 	int ret = 0;
 
+	/*
+	 * For now, socket bpf hooks attached to cgroups can only be
+	 * installed in the init netns and only affect the init netns.
+	 * This could be relaxed in the future once some semantic issues
+	 * are resolved.  For example, ifindexes belonging to one netns
+	 * should probably not be visible to hooks installed by programs
+	 * running in a different netns.
+	 */
+	if (sock_net(sk) != &init_net)
+		return 0;
 
 	rcu_read_lock();
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index e89acea22ecf..c0bbc55e244d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -902,6 +902,17 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	struct cgroup *cgrp;
 	enum bpf_prog_type ptype;
 
+	/*
+	 * For now, socket bpf hooks attached to cgroups can only be
+	 * installed in the init netns and only affect the init netns.
+	 * This could be relaxed in the future once some semantic issues
+	 * are resolved.  For example, ifindexes belonging to one netns
+	 * should probably not be visible to hooks installed by programs
+	 * running in a different netns.
+	 */
+	if (current->nsproxy->net_ns != &init_net)
+		return -EINVAL;
+
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-- 
2.9.3
