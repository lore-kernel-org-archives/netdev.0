From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] proc: Fix the threaded /proc/self.
Date: Tue, 20 Nov 2007 15:41:12 -0700
Message-ID: <m1k5ocr14n.fsf_-_@ebiederm.dsl.xmission.com>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org>
	<m11wakshyz.fsf@ebiederm.dsl.xmission.com>
	<20071120215914.GE24156@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40447 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbXKTWmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 17:42:21 -0500
In-Reply-To: <20071120215914.GE24156@elte.hu> (Ingo Molnar's message of "Tue,
	20 Nov 2007 22:59:14 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Long ago when the CLONE_THREAD support first went it someone
thought it would be wise to point /proc/self at /proc/<tgid>
instead of /proc/<pid>.

Given that /proc/<tgid> can return information about a very different
task (if enough things have been unshared) then our current process
/proc/<tgid> seems blatantly wrong.  So far I have yet to think up
an example where the current behavior would be advantageous, and
I can see several places where it is seriously non-intuitive.

We may be stuck with the current broken behavior for backwards
compatibility reasons but lets try fixing our ancient bug for the
2.6.25 time frame and see if anyone screams.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/base.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 34a1821..8502436 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2050,22 +2050,22 @@ static int proc_self_readlink(struct dentry *dentry, char __user *buffer,
 			      int buflen)
 {
 	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
-	pid_t tgid = task_tgid_nr_ns(current, ns);
+	pid_t pid = task_pid_nr_ns(current, ns);
 	char tmp[PROC_NUMBUF];
-	if (!tgid)
+	if (!pid)
 		return -ENOENT;
-	sprintf(tmp, "%d", tgid);
+	sprintf(tmp, "%d", pid);
 	return vfs_readlink(dentry,buffer,buflen,tmp);
 }
 
 static void *proc_self_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
-	pid_t tgid = task_tgid_nr_ns(current, ns);
+	pid_t pid = task_pid_nr_ns(current, ns);
 	char tmp[PROC_NUMBUF];
-	if (!tgid)
+	if (!pid)
 		return ERR_PTR(-ENOENT);
-	sprintf(tmp, "%d", task_tgid_nr_ns(current, ns));
+	sprintf(tmp, "%d", pid);
 	return ERR_PTR(vfs_follow_link(nd,tmp));
 }
 
-- 
1.5.3.rc6.17.g1911

