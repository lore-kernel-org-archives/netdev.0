From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Update the sysctl permissions handler to test effective uid/gid
Date: Sat, 05 Oct 2013 13:15:30 -0700
Message-ID: <87y567lbj1.fsf@xmission.com>
References: <52139BE4.4020208@redhat.com>
	<20130820100113.2a2455aa.akpm@linux-foundation.org>
	<87bo4s1de6.fsf@xmission.com>
	<20130829074622.GZ13998@dhcp-25-225.brq.redhat.com>
	<87fvtihptr.fsf_-_@xmission.com> <5249DAA7.9050304@redhat.com>
	<CAGXu5j+88Bb0Mnbiyq-bTzkn59YXOefCrXtht-evYhq-yUfYFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Sandeen <sandeen@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"security\@kernel.org" <security@kernel.org>,
	Petr Matousek <pmatouse@redhat.com>, <netdev@vger.kernel.org>,
	Kees Cook <keescook@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60931 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366Ab3JEUPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 16:15:52 -0400
In-Reply-To: <CAGXu5j+88Bb0Mnbiyq-bTzkn59YXOefCrXtht-evYhq-yUfYFg@mail.gmail.com>
	(Kees Cook's message of "Wed, 2 Oct 2013 13:58:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 20 Aug 2013 11:40:04 -0500 Eric Sandeen <sandeen@redhat.com> wrote:
> This was brought up in a Red Hat bug (which may be marked private, I'm sorry):
>
> Bug 987055 - open O_WRONLY succeeds on some root owned files in /proc for process running with unprivileged EUID
>
> "On RHEL7 some of the files in /proc can be opened for writing by an unprivileged EUID."
>
> The flaw existed upstream as well last I checked.
>
> This commit in kernel v3.8 caused the regression:
>
> commit cff109768b2d9c03095848f4cd4b0754117262aa
> Author: Eric W. Biederman <ebiederm@xmission.com>
> Date:   Fri Nov 16 03:03:01 2012 +0000
>
>     net: Update the per network namespace sysctls to be available to the network namespace owner
>
>     - Allow anyone with CAP_NET_ADMIN rights in the user namespace of the
>       the netowrk namespace to change sysctls.
>     - Allow anyone the uid of the user namespace root the same
>       permissions over the network namespace sysctls as the global root.
>     - Allow anyone with gid of the user namespace root group the same
>       permissions over the network namespace sysctl as the global root group.
>
>     Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> because it changed /sys/net's special permission handler to test current_uid, not
> current_euid; same for current_gid/current_egid.
>
> So in this case, root cannot drop privs via set[ug]id, and retains all privs
> in this codepath.

Modify the code to use current_euid(), and in_egroup_p, as in done
in fs/proc/proc_sysctl.c:test_perm()

Cc: stable@vger.kernel.org
Reviewed-by: Eric Sandeen <sandeen@redhat.com>
Reported-by: Eric Sandeen <sandeen@redhat.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

Resubmitting as it looks like this fix got lost.  This patch applies
cleanly against both net-next and linux-3.12-rc1, and likely quite a few
early kernel revisions.

 net/sysctl_net.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 9bc6db04be3e..e7000be321b0 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -47,12 +47,12 @@ static int net_ctl_permissions(struct ctl_table_header *head,
 
 	/* Allow network administrator to have same access as root. */
 	if (ns_capable(net->user_ns, CAP_NET_ADMIN) ||
-	    uid_eq(root_uid, current_uid())) {
+	    uid_eq(root_uid, current_euid())) {
 		int mode = (table->mode >> 6) & 7;
 		return (mode << 6) | (mode << 3) | mode;
 	}
 	/* Allow netns root group to have the same access as the root group */
-	if (gid_eq(root_gid, current_gid())) {
+	if (in_egroup_p(root_gid)) {
 		int mode = (table->mode >> 3) & 7;
 		return (mode << 3) | mode;
 	}
-- 
1.7.5.4
