From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC][PATCH net] bpf: Use mount_nodev not mount_ns to mount the
 bpf filesystem
Date: Wed, 18 May 2016 22:43:04 +0200
Message-ID: <573CD3D8.3030308@iogearbox.net>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>	<79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org> <87inybv2hv.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55789 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbcERUnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 16:43:21 -0400
In-Reply-To: <87inybv2hv.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2016 04:56 PM, Eric W. Biederman wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>> On 18.05.2016 01:12, Eric W. Biederman wrote:
>>>
>>> While reviewing the filesystems that set FS_USERNS_MOUNT I spotted the
>>> bpf filesystem.  Looking at the code I saw a broken usage of mount_ns
>>> with current->nsproxy->mnt_ns. As the code does not acquire a reference
>>> to the mount namespace it can not possibly be correct to store the mount
>>> namespace on the superblock as it does.
>>>
>>> Replace mount_ns with mount_nodev so that each mount of the bpf
>>> filesystem returns a distinct instance, and the code is not utterly
>>> broken.
>>>
>>> Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>> ---
>>>
>>> No one should care about this change, as userspace typically only mounts
>>> things once and does not depend on things in one mount do not showing up
>>> in another.  Can someone who actually uses the bpf filesystem please
>>> verify this.
[...]

LGTM.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

>> The idea is to have the bpf filesystem as a singeleton per mnt-namespace
>> to prevent endless instances being created and kernel resources being
>> hogged by pinning them to hard to discover bpf mounts.

Eric, please send the patch officially and feel free to add my Ack. Given
the circumstances, moving to mount_nodev() seems the best way forward. To
also address above mentioned concern from Hannes, we need to remove the
FS_USERNS_MOUNT flag along with the change. It looks like the fix is best
addressed in a single patch if you want to include it. If not, we can
otherwise send it separately as well, I don't mind.

Thanks for your feedback!

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 8f94ca1..b2aefa2 100644
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
@@ -386,7 +386,6 @@ static struct file_system_type bpf_fs_type = {
  	.name		= "bpf",
  	.mount		= bpf_mount,
  	.kill_sb	= kill_litter_super,
-	.fs_flags	= FS_USERNS_MOUNT,
  };

  MODULE_ALIAS_FS("bpf");
-- 
1.9.3
