From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net] bpf: Use mount_nodev not mount_ns to mount the bpf filesystem
Date: Fri, 20 May 2016 17:22:48 -0500
Message-ID: <874m9sfjyf.fsf_-_@x220.int.ebiederm.org>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>
	<79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
	<87inybv2hv.fsf@x220.int.ebiederm.org>
	<573CD3D8.3030308@iogearbox.net>
	<bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39644 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcETWdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 18:33:43 -0400
In-Reply-To: <bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
	(Hannes Frederic Sowa's message of "Wed, 18 May 2016 22:46:57 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While reviewing the filesystems that set FS_USERNS_MOUNT I spotted the
bpf filesystem.  Looking at the code I saw a broken usage of mount_ns
with current->nsproxy->mnt_ns. As the code does not acquire a
reference to the mount namespace it can not possibly be correct to
store the mount namespace on the superblock as it does.

Replace mount_ns with mount_nodev so that each mount of the bpf
filesystem returns a distinct instance, and the code is not buggy.

In discussion with Hannes Frederic Sowa it was reported that the use
of mount_ns was an attempt to have one bpf instance per mount
namespace, in an attempt to keep resources that pin resources from
hiding.  That intent simply does not work, the vfs is not built to
allow that kind of behavior.  Which means that the bpf filesystem
really is buggy both semantically and in it's implemenation as it does
not nor can it implement the original intent.

This change is userspace visible, but my experience with similar
filesystems leads me to believe nothing will break with a model of each
mount of the bpf filesystem is distinct from all others.

Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/bpf/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 8f94ca1860cf..55d923688f85 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -378,7 +378,7 @@ static int bpf_fill_super(struct super_block *sb, void *data, int silent)
 static struct dentry *bpf_mount(struct file_system_type *type, int flags,
 				const char *dev_name, void *data)
 {
-	return mount_ns(type, flags, current->nsproxy->mnt_ns, bpf_fill_super);
+	return mount_nodev(type, flags, data, bpf_fill_super);
 }
 
 static struct file_system_type bpf_fs_type = {
-- 
2.8.1
