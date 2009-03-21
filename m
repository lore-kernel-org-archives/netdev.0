From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/2] sysctl: Don't take the use count of multiple heads at a time.
Date: Sat, 21 Mar 2009 00:40:58 -0700
Message-ID: <m1eiwrxr05.fsf_-_@fess.ebiederm.org>
References: <49B91A7E.76E4.0078.0@novell.com>
	<tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	<1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	<1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	<m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	<m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	<1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	<m1iqm3xr2n.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	linux-kernel@vger.kernel.org, Gautham R Shenoy <ego@in.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43452 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbZCUHlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 03:41:05 -0400
In-Reply-To: <m1iqm3xr2n.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 21 Mar 2009 00\:39\:28 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The current code works fine, and is actually not buggy but it
does prevent enabling the use of lockdep to check refcounting
vs lock holding ordering problems.   So since we can ensure
that we are only hold a single sysctl_head at a time.  Allowing
lockdep to complain.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 fs/proc/proc_sysctl.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 94fcfff..46eb34c 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -79,7 +79,6 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 {
 	struct ctl_table_header *head = grab_header(dir);
 	struct ctl_table *table = PROC_I(dir)->sysctl_entry;
-	struct ctl_table_header *h = NULL;
 	struct qstr *name = &dentry->d_name;
 	struct ctl_table *p;
 	struct inode *inode;
@@ -97,10 +96,11 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 
 	p = find_in_table(table, name);
 	if (!p) {
-		for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
-			if (h->attached_to != table)
+		sysctl_head_finish(head);
+		for (head = sysctl_head_next(NULL); head; head = sysctl_head_next(head)) {
+			if (head->attached_to != table)
 				continue;
-			p = find_in_table(h->attached_by, name);
+			p = find_in_table(head->attached_by, name);
 			if (p)
 				break;
 		}
@@ -110,9 +110,7 @@ static struct dentry *proc_sys_lookup(struct inode *dir, struct dentry *dentry,
 		goto out;
 
 	err = ERR_PTR(-ENOMEM);
-	inode = proc_sys_make_inode(dir->i_sb, h ? h : head, p);
-	if (h)
-		sysctl_head_finish(h);
+	inode = proc_sys_make_inode(dir->i_sb, head, p);
 
 	if (!inode)
 		goto out;
@@ -243,7 +241,6 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	struct inode *inode = dentry->d_inode;
 	struct ctl_table_header *head = grab_header(inode);
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
-	struct ctl_table_header *h = NULL;
 	unsigned long pos;
 	int ret = -EINVAL;
 
@@ -277,14 +274,13 @@ static int proc_sys_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	if (ret)
 		goto out;
 
-	for (h = sysctl_head_next(NULL); h; h = sysctl_head_next(h)) {
-		if (h->attached_to != table)
+	sysctl_head_finish(head);
+	for (head = sysctl_head_next(NULL); head; head = sysctl_head_next(head)) {
+		if (head->attached_to != table)
 			continue;
-		ret = scan(h, h->attached_by, &pos, filp, dirent, filldir);
-		if (ret) {
-			sysctl_head_finish(h);
+		ret = scan(head, head->attached_by, &pos, filp, dirent, filldir);
+		if (ret)
 			break;
-		}
 	}
 	ret = 1;
 out:
-- 
1.6.1.2.350.g88cc

