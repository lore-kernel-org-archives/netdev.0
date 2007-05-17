From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: select(0, ..) is valid ?
Date: Wed, 16 May 2007 17:59:12 -0700
Message-ID: <1179363553.16195.10.camel@dyn9047017100.beaverton.ibm.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
	 <20070515104453.f901e91f.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com>
	 <20070516153703.GA26912@kryten>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hugh Dickins <hugh@veritas.com>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	sfr@canb.auug.org.au, ak@suse.de
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:53952 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521AbXEQA6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 20:58:36 -0400
In-Reply-To: <20070516153703.GA26912@kryten>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-16 at 10:37 -0500, Anton Blanchard wrote:
> Hi Hugh,
> 
> > It's interesting that compat_core_sys_select() shows this kmalloc(0)
> > failure but core_sys_select() does not.  That's because core_sys_select()
> > avoids kmalloc by using a buffer on the stack for small allocations (and
> > 0 sure is small).  Shouldn't compat_core_sys_select() do just the same?
> > Or is SLUB going to be so efficient that doing so is a waste of time?
> 
> Nice catch, the original optimisation from Andi is:
> 
> http://git.kernel.org/git-new/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=70674f95c0a2ea694d5c39f4e514f538a09be36f
> 
> And I think it makes sense for the compat code to do it too.
> 
> Anton

Here it is ..

Should I do one for poll() also ?

Thanks,
Badari

Optimize select by a using stack space for small fd sets.
core_sys_select() already has this optimization. This is
for compat version. 

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 fs/compat.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

Index: linux-2.6.22-rc1/fs/compat.c
===================================================================
--- linux-2.6.22-rc1.orig/fs/compat.c	2007-05-12 18:45:56.000000000 -0700
+++ linux-2.6.22-rc1/fs/compat.c	2007-05-16 17:50:39.000000000 -0700
@@ -1544,9 +1544,10 @@ int compat_core_sys_select(int n, compat
 	compat_ulong_t __user *outp, compat_ulong_t __user *exp, s64 *timeout)
 {
 	fd_set_bits fds;
-	char *bits;
+	void *bits;
 	int size, max_fds, ret = -EINVAL;
 	struct fdtable *fdt;
+	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
 
 	if (n < 0)
 		goto out_nofds;
@@ -1564,11 +1565,14 @@ int compat_core_sys_select(int n, compat
 	 * since we used fdset we need to allocate memory in units of
 	 * long-words.
 	 */
-	ret = -ENOMEM;
 	size = FDS_BYTES(n);
-	bits = kmalloc(6 * size, GFP_KERNEL);
-	if (!bits)
-		goto out_nofds;
+	bits = stack_fds;
+	if (size > sizeof(stack_fds) / 6) {
+		bits = kmalloc(6 * size, GFP_KERNEL);
+		ret = -ENOMEM;
+		if (!bits)
+			goto out_nofds;
+	}
 	fds.in      = (unsigned long *)  bits;
 	fds.out     = (unsigned long *) (bits +   size);
 	fds.ex      = (unsigned long *) (bits + 2*size);
@@ -1600,7 +1604,8 @@ int compat_core_sys_select(int n, compat
 	    compat_set_fd_set(n, exp, fds.res_ex))
 		ret = -EFAULT;
 out:
-	kfree(bits);
+	if (bits != stack_fds)
+		kfree(bits);
 out_nofds:
 	return ret;
 }



