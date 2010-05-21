From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: bug fix patch lost: git problem or just incorrect merge?
Date: Fri, 21 May 2010 09:45:49 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005210931010.4243@i5.linux-foundation.org>
References: <1274456515.9022.14.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1274456515.9022.14.camel@mulgrave.site>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 21 May 2010, James Bottomley wrote:
>
> The patch in question is this one (upstream for a while):
> 
> commit d7d05548a62c87ee55b0c81933669177f885aa8d
> Author: Mike Christie <michaelc@cs.wisc.edu>
> Date:   Wed Mar 31 14:41:35 2010 -0500
> 
>     [SCSI] iscsi_tcp: fix relogin/shutdown hang
> 
> It's a simple one line change in iscsi_tcp.c (diff clipped):
> 
> --- a/drivers/scsi/iscsi_tcp.c
> +++ b/drivers/scsi/iscsi_tcp.c
> @@ -599,7 +599,7 @@ static void iscsi_sw_tcp_conn_stop(struct iscsi_cls_conn *cls_conn, int flag)
> -       if (sock->sk->sk_sleep && waitqueue_active(sock->sk->sk_sleep)) {
> +       if (sock->sk->sk_sleep) {
> 
> It was killed by this merge commit in the net-next tree:
> 
> commit 278554bd6579206921f5d8a523649a7a57f8850d
> Merge: 5a147e8 cea0d76
> Author: David S. Miller <davem@davemloft.net>
> Date:   Wed May 12 00:05:35 2010 -0700
> 
> However, the curious thing is that git seems to have lost trace of the
> missing patch entirely

No, it's there, and the bug is that David doesn't do merges well.

One of the reasons I ask people to let me merge is that it results in 
cleaner history to not have criss-cross merges. And another is that I'm 
pretty good at it, and letting me make merges also means that I am more 
aware of problem spots.

> if I try to find it in linus' tree with a git log -- 
> drivers/scsi/iscsi_tcp.c, it doesn't show up.

That is because "git log" will see the merge, see that _all_ history came 
from the other side, and ignore the side that was ignored. Because 
clearly, that other side didn't actually contribute anything.

Now, the _reason_ that other side didn't contribute anything is that David 
messed up the merge, and took just his own sides changes.

> The merge commit which killed it does list iscsi_tcp.c as a file 
> conflict

Yes. I re-did the merge, and the result looks like this (cut-and-paste 
whitespace damage, I'm just illustrating he point):

	diff --cc drivers/scsi/iscsi_tcp.c
	index 9eae04a,02143af..0000000
	--- a/drivers/scsi/iscsi_tcp.c
	+++ b/drivers/scsi/iscsi_tcp.c
	@@@ -599,9 -599,9 +599,13 @@@ static void iscsi_sw_tcp_conn_stop(stru
	        set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
	        write_unlock_bh(&tcp_sw_conn->sock->sk->sk_callback_lock);
	  
	++<<<<<<< HEAD
	 +      if (sk_sleep(sock->sk) && waitqueue_active(sk_sleep(sock->sk))) {
	++=======
	+       if (sock->sk->sk_sleep) {
	++>>>>>>> cea0d76
	                sock->sk->sk_err = EIO;
	 -              wake_up_interruptible(sock->sk->sk_sleep);
	 +              wake_up_interruptible(sk_sleep(sock->sk));
	        }
	  
	        iscsi_conn_stop(cls_conn, flag);

and David picked his side of things, not your side.

The _correct_ merge would have been to take both changes, as is quite 
obvious if you do

	gitk 5a147e8...cea0d76 drivers/scsi/iscsi_tcp.c

and see that the conflict comes because:

 - one side (David's) changed

	sock->sk->sk_sleep

   into

	sk_sleep(sock->sk)

   in commit aa395145165cb06a0d0885221bbe0ce4a564391d

 - the other side (your) removed the 'waitqueue_active()' part in commit 
   d7d05548a62c87ee55b0c81933669177f885aa8d.

So the end result _should_ have been this merge resolution:

	diff --cc drivers/scsi/iscsi_tcp.c
	index 9eae04a,02143af..0000000
	--- a/drivers/scsi/iscsi_tcp.c
	+++ b/drivers/scsi/iscsi_tcp.c
	@@@ -599,9 -599,9 +599,9 @@@ static void iscsi_sw_tcp_conn_stop(stru
	        set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
	        write_unlock_bh(&tcp_sw_conn->sock->sk->sk_callback_lock);
	  
	-       if (sk_sleep(sock->sk) && waitqueue_active(sk_sleep(sock->sk))) {
	 -      if (sock->sk->sk_sleep) {
	++      if (sk_sleep(sock->sk)) {
	                sock->sk->sk_err = EIO;
	 -              wake_up_interruptible(sock->sk->sk_sleep);
	 +              wake_up_interruptible(sk_sleep(sock->sk));
	        }
	  
	        iscsi_conn_stop(cls_conn, flag);

but David just picked his side entirely. And that is also the reason for:

> but git show on that commit doesn't list that file in the resolution 
> diff ... even though this is where it actually got killed.

A merge diff ("combined diff") only shows conflicts as defined by "you 
resolved it to something that didn't match either side". That's a _real_ 
conflict. If you just end up picking one side, there is no diff.

> Is this a git problem ... or is it just a mismerge in the net tree?

So it's a mis-merge. You can see the commit with

	gitk v2.6.34.. --full-history drivers/scsi/iscsi_tcp.c

which doesn't do the "ignore the side of a merge that didn't bring any new 
data in". Or, with any recent git, you can use "--simplify-merges" instead 
of full-history, which only simplifies trivial merges where neither side 
really touched things at all.

If you do that, you'll also see why git doesn't show the uninteresting 
side of a merge by default. Just for fun, compare the graphs of

	gitk v2.6.34.. drivers/scsi/iscsi_tcp.c
	gitk v2.6.34.. --simplify-merges drivers/scsi/iscsi_tcp.c
	gitk v2.6.34.. --full-history drivers/scsi/iscsi_tcp.c

and ask yourself: do you normally want to see _all_ the history, even 
stuff that didn't end up affecting the end result?

> Either way, of course, we need the patch back ...

I'll fix it up.

			Linus
