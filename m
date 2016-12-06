From: Tejun Heo <tj@kernel.org>
Subject: Re: [RESEND][PATCH v4] cgroup: Use CAP_SYS_RESOURCE to allow a
 process to migrate other tasks between cgroups
Date: Tue, 6 Dec 2016 13:23:15 -0500
Message-ID: <20161206182315.GB2625@mtj.duckdns.org>
References: <CALCETrU5fCWoe0RXfKWuN7Zt9vLvoyHFcZnVqeqiKBpSKrMrxA@mail.gmail.com>
 <20161109000342.GA42532@ast-mbp.thefacebook.com>
 <CALCETrW_mPHneTvcAM6HyBLCJqcwKmcYEoC+kseyuyQZzj2a=A@mail.gmail.com>
 <CALAqxLXk+A9=A0oXGEduphXOQdbMg-wuGxmLkEk9cPHyn44X5Q@mail.gmail.com>
 <CALAqxLW-mq4Lnudtn5KMBPdzBTg5bhTXV9QmUC2vfabVru+fUA@mail.gmail.com>
 <CALCETrWuKpmXQqoQmcy4Va8abdpfCnMBYHWSD0nK5pocj2nfXA@mail.gmail.com>
 <20161206165519.GA17648@mtj.duckdns.org>
 <CALCETrV3Yrq1hRcoGCTU_z-T-6hmq-gY-HytR2HGkvnRK-W1SQ@mail.gmail.com>
 <20161206181221.GA2625@mtj.duckdns.org>
 <CALCETrUmwPaWbN_U2XAsg6Z0UGBJ=Ou7BoD09-GZFdRVT5Y-EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S. Miller" <davem@davemloft.net>, kafai@fb.com,
        Florian Westphal <fw@strlen.de>,
        Harald Hoyer <harald@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Li Zefan <lizefan@huawei.com>,
        Jonathan Corbet <corbet@lwn.net>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        Android Kernel Team <kernel-team@android.com>,
        Rom Lemarchand <romlem@android.com>,
        Colin Cross <ccross@android.com>,
        Dmitry Shmidt
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrUmwPaWbN_U2XAsg6Z0UGBJ=Ou7BoD09-GZFdRVT5Y-EQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Dec 06, 2016 at 10:13:53AM -0800, Andy Lutomirski wrote:
> > Delegation is an explicit operation and reflected in the ownership of
> > the subdirectories and cgroup interface files in them.  The
> > subhierarchy containment is achieved by requiring the user who's
> > trying to migrate a process to have write perm on cgroup.procs on the
> > common ancestor of the source and target in addition to the target.
> 
> OK, I see what you're doing.  That's interesting.

It's something born out of usages of cgroup v1.  People used it that
way (chowning files and directories) and combined with the uid checksn
it yielded something which is useful sometimes, but it always had
issues with hierarchical behaviors, which files to chmod and the weird
combination of uid checks.  cgroup v2 has a clear delegation model but
the uid checks are still left in as not changing was the default.

It's not necessary and I'm thinking about queueing something like the
following in the next cycle.

As for the android CAP discussion, I think it'd be nice to share an
existing CAP but if we can't find a good one to share, let's create a
new one.

Thanks.

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 4cc07ce..34b4b44 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -328,14 +328,12 @@ a process with a non-root euid to migrate a target process into a
 cgroup by writing its PID to the "cgroup.procs" file, the following
 conditions must be met.
 
-- The writer's euid must match either uid or suid of the target process.
-
 - The writer must have write access to the "cgroup.procs" file.
 
 - The writer must have write access to the "cgroup.procs" file of the
   common ancestor of the source and destination cgroups.
 
-The above three constraints ensure that while a delegatee may migrate
+The above two constraints ensure that while a delegatee may migrate
 processes around freely in the delegated sub-hierarchy it can't pull
 in from or push out to outside the sub-hierarchy.
 
@@ -350,10 +348,10 @@ all processes under C0 and C1 belong to U0.
 
 Let's also say U0 wants to write the PID of a process which is
 currently in C10 into "C00/cgroup.procs".  U0 has write access to the
-file and uid match on the process; however, the common ancestor of the
-source cgroup C10 and the destination cgroup C00 is above the points
-of delegation and U0 would not have write access to its "cgroup.procs"
-files and thus the write will be denied with -EACCES.
+file; however, the common ancestor of the source cgroup C10 and the
+destination cgroup C00 is above the points of delegation and U0 would
+not have write access to its "cgroup.procs" files and thus the write
+will be denied with -EACCES.
 
 
 2-6. Guidelines
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 85bc9be..49384ff 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2854,12 +2854,18 @@ static int cgroup_procs_write_permission(struct task_struct *task,
 	 * even if we're attaching all tasks in the thread group, we only
 	 * need to check permissions on one of them.
 	 */
-	if (!uid_eq(cred->euid, GLOBAL_ROOT_UID) &&
-	    !uid_eq(cred->euid, tcred->uid) &&
-	    !uid_eq(cred->euid, tcred->suid))
-		ret = -EACCES;
 
-	if (!ret && cgroup_on_dfl(dst_cgrp)) {
+	/* root is allowed to do anything */
+	if (uid_eq(cred->euid, GLOBAL_ROOT_UID))
+		goto out;
+
+	/*
+	 * On v2, follow the delegation model.  Inside a delegated subtree,
+	 * the delegatee can move around the processes however it sees fit.
+	 *
+	 * On v1, a process should match one of the target's uids.
+	 */
+	if (cgroup_on_dfl(dst_cgrp)) {
 		struct super_block *sb = of->file->f_path.dentry->d_sb;
 		struct cgroup *cgrp;
 		struct inode *inode;
@@ -2877,8 +2883,11 @@ static int cgroup_procs_write_permission(struct task_struct *task,
 			ret = inode_permission(inode, MAY_WRITE);
 			iput(inode);
 		}
+	} else if (!uid_eq(cred->euid, tcred->uid) &&
+		   !uid_eq(cred->euid, tcred->suid)) {
+		ret = -EACCES;
 	}
-
+out:
 	put_cred(tcred);
 	return ret;
 }
