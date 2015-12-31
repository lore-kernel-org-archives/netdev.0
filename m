From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Thu, 31 Dec 2015 19:36:50 +0000
Message-ID: <87ege2xve5.fsf@doppelsaurus.mobileactivedefense.com>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
	<56826754.2060003@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	David Miller <davem@davemloft.net>, dvyukov@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56826754.2060003@stressinduktion.org> (Hannes Frederic Sowa's
	message of "Tue, 29 Dec 2015 11:58:28 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On 27.12.2015 21:13, Rainer Weikusat wrote:
>> -static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
>> +static int unix_mknod(struct dentry *dentry, struct path *path, umode_t mode,
>> +		      struct path *res)
>>   {
>> -	struct dentry *dentry;
>> -	struct path path;
>> -	int err = 0;
>> -	/*
>> -	 * Get the parent directory, calculate the hash for last
>> -	 * component.
>> -	 */
>> -	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
>> -	err = PTR_ERR(dentry);
>> -	if (IS_ERR(dentry))
>> -		return err;
>> +	int err;
>>
>> -	/*
>> -	 * All right, let's create it.
>> -	 */
>> -	err = security_path_mknod(&path, dentry, mode, 0);
>> +	err = security_path_mknod(path, dentry, mode, 0);
>>   	if (!err) {
>> -		err = vfs_mknod(d_inode(path.dentry), dentry, mode, 0);
>> +		err = vfs_mknod(d_inode(path->dentry), dentry, mode, 0);
>>   		if (!err) {
>> -			res->mnt = mntget(path.mnt);
>> +			res->mnt = mntget(path->mnt);
>>   			res->dentry = dget(dentry);
>>   		}
>>   	}
>> -	done_path_create(&path, dentry);
>> +
>
> The reordered call to done_path_create will change the locking
> ordering between the i_mutexes and the unix readlock. Can you comment
> on this? On a first sight this looks like a much more dangerous change
> than the original deadlock report. Can't this also conflict with
> splice code deep down in vfs layer?

Practical consideration
-----------------------

kern_path_create acquires the i_mutex of the parent directory of the
to-be-created directory entry (via filename_create/ namei.c), as
required for reading a directory or creating a new entry in a directory
(as per Documentation/filesystems/directory-locking). A deadlock was
possible here if the thread doing the bind then blocked when trying to
acquire the readlock while the thread holding the readlock is blocked on
another lock held by a thread trying to perform an operation on the same
directory as the bind (possibly with some indirection). The only 'other
lock' which could come into play here is the pipe lock of a pipe
partaking in a splice_to_pipe from the same AF_UNIX socket. But the idea
that some thread would need to take a pipe lock prior to performing a
directory operation is quite odd (splice_from_pipe_to_directory?
openatparentoffifo?). I've also checked all existing users
of pipe_lock and at least, I didn't find one performing a directory
operation.


Theoretical consideration
-------------------------

NB: The text below represents my opinion on this after spending a few
days thinking about it (on and of, of course). Making an argument for
the opposite position is also possible.

The filesystem (namespace) is a shared namespace accessible to all
currently running threads/ processes. Whoever uses the filesystem may
have to wait for other filesystem users but threads not using it
shouldn't have to. Because of this and because the filesystem is a
pretty central facility, an operation needing 'some filesystem lock' and
also some other lock (or locks) should always acquire the filesystem
ones before any more specialized locks (as do_splice does when splicing
to a file). If 'filesystem locks' are always acquired first, there's
also no risk of a deadlock because code holding a filesystem lock is
blocked on a more specialized lock (eg, a pipe lock or the readlock
mutx) while some other thread holding the/ a more specialized lock wants
the already held filesystem lock.
