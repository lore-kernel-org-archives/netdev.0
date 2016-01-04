From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Tue, 05 Jan 2016 00:25:06 +0100
Message-ID: <1451949906.2606240.482870994.43973946@webmail.messagingengine.com>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
 <56826754.2060003@stressinduktion.org>
 <87ege2xve5.fsf@doppelsaurus.mobileactivedefense.com>
 <87ziwmk0b7.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dvyukov@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ziwmk0b7.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sun, Jan 3, 2016, at 19:03, Rainer Weikusat wrote:
> Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> 
> > Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> >> On 27.12.2015 21:13, Rainer Weikusat wrote:
> >>> -static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
> >>> +static int unix_mknod(struct dentry *dentry, struct path *path, umode_t mode,
> >>> +		      struct path *res)
> >>>   {
> >>> -	struct dentry *dentry;
> >>> -	struct path path;
> >>> -	int err = 0;
> >>> -	/*
> >>> -	 * Get the parent directory, calculate the hash for last
> >>> -	 * component.
> >>> -	 */
> >>> -	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
> >>> -	err = PTR_ERR(dentry);
> >>> -	if (IS_ERR(dentry))
> >>> -		return err;
> >>> +	int err;
> >>>
> >>> -	/*
> >>> -	 * All right, let's create it.
> >>> -	 */
> >>> -	err = security_path_mknod(&path, dentry, mode, 0);
> >>> +	err = security_path_mknod(path, dentry, mode, 0);
> >>>   	if (!err) {
> >>> -		err = vfs_mknod(d_inode(path.dentry), dentry, mode, 0);
> >>> +		err = vfs_mknod(d_inode(path->dentry), dentry, mode, 0);
> >>>   		if (!err) {
> >>> -			res->mnt = mntget(path.mnt);
> >>> +			res->mnt = mntget(path->mnt);
> >>>   			res->dentry = dget(dentry);
> >>>   		}
> >>>   	}
> >>> -	done_path_create(&path, dentry);
> >>> +
> >>
> >> The reordered call to done_path_create will change the locking
> >> ordering between the i_mutexes and the unix readlock. Can you comment
> >> on this? On a first sight this looks like a much more dangerous change
> >> than the original deadlock report. Can't this also conflict with
> >> splice code deep down in vfs layer?
> >
> > Practical consideration
> 
> [...]
> 
> > A deadlock was possible here if the thread doing the bind then blocked
> > when trying to acquire the readlock while the thread holding the
> > readlock is blocked on another lock held by a thread trying to perform
> > an operation on the same directory as the bind (possibly with some
> > indirection).
> 
> Since this was probably pretty much a "write only" sentence, I think I
> should try this again (with apologies in case a now err on the other
> side and rather explain to much --- my abilities to express myself such
> that people understand what I mean to express instead of just getting
> mad at me are not great).
> 
> For a deadlock to happen here, there needs to be a cycle (circle?) of
> threads each holding one lock and blocking while trying to acquire
> another lock which ultimatively ends with a thread trying to acquire the
> i_mutex of the directory where the socket name is to be created. The
> binding thread would need to block when trying to acquire the
> readlock. But (contrary to what I originally wrote[*]) this cannot happen
> because the af_unix code doesn't lock anything non-socket related while
> holding the readlock. The only instance of that was in _bind and caused
> the deadlock.
> 
> [*] I misread
> 
> static ssize_t skb_unix_socket_splice(struct sock *sk,
> 				      struct pipe_inode_info *pipe,
> 				      struct splice_pipe_desc *spd)
> {
> 	int ret;
> 	struct unix_sock *u = unix_sk(sk);
> 
> 	mutex_unlock(&u->readlock);
> 	ret = splice_to_pipe(pipe, spd);
> 	mutex_lock(&u->readlock);
> 
> 	return ret;
> }
> 
> as 'lock followed by unlock' instead of 'unlock followed by lock'.

I agree with your arguments but haven't finished researching enough of
how i_mutex is handled in all regards. I will have to do further
research on this.

I was concerned because of the comment in skb_socket_splice:

        /* Drop the socket lock, otherwise we have reverse
         * locking dependencies between sk_lock and i_mutex
         * here as compared to sendfile(). We enter here
         * with the socket lock held, and splice_to_pipe() will
         * grab the pipe inode lock. For sendfile() emulation,
         * we call into ->sendpage() with the i_mutex lock held
         * and networking will grab the socket lock.
         */

Thanks,
Hannes
