From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, inode: disallow userns mounts
Date: Sun, 22 May 2016 23:16:18 +0200
Message-ID: <2e93b4dc22940025ef082970cbab0f499e1e9726.1463950945.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36697 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbcEVVQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 17:16:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow-up to commit e27f4a942a0e ("bpf: Use mount_nodev not mount_ns
to mount the bpf filesystem"), which removes the FS_USERNS_MOUNT flag.

The original idea was to have a per mountns instance instead of a
single global fs instance, but that didn't work out and we had to
switch to mount_nodev() model. The intent of that middle ground was
that we avoid users who don't play nice to create endless instances
of bpf fs which are difficult to control and discover from an admin
point of view, but at the same time it would have allowed us to be
more flexible with regard to namespaces.

Therefore, since we now did the switch to mount_nodev() as a fix
where individual instances are created, we also need to remove userns
mount flag along with it to avoid running into mentioned situation.
I don't expect any breakage at this early point in time with removing
the flag and we can revisit this later should the requirement for
this come up with future users. This and commit e27f4a942a0e have
been split to facilitate tracking should any of them run into the
unlikely case of causing a regression.

Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/inode.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 04be702..318858e 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -365,7 +365,6 @@ static struct file_system_type bpf_fs_type = {
 	.name		= "bpf",
 	.mount		= bpf_mount,
 	.kill_sb	= kill_litter_super,
-	.fs_flags	= FS_USERNS_MOUNT,
 };
 
 MODULE_ALIAS_FS("bpf");
-- 
1.9.3
