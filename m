From: "Steve French" <smfrench@gmail.com>
Subject: Re: [PATCH] CIFS: make cifsd (more)
Date: Sat, 30 Jun 2007 08:32:10 -0500
Message-ID: <524f69650706300632p1f4fb3e0l23bd017672b77baf@mail.gmail.com>
References: <524f69650706251525g7b17ea02o5fb3e637615fe542@mail.gmail.com>
	 <20070630084209.GA21186@infradead.org>
	 <20070630071514.514d4833.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-cifs-client@lists.samba.org, netdev@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070630071514.514d4833.jlayton@redhat.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reason that cifs switched from wait_for_completion to the kthread
call to cifs_demultiplex_thread in the first place is because without
use of kthread it won't work with a linux-vserver.   See the thread:

http://marc.info/?l=linux-cifs-client&m=117552761703381&w=2

If we take out the kthread call, we break those guys.

I agree that using sk_callbacks is worth looking into - I only found
ocfs2 and SunRPC (NFS) though that used it.   Is there a better
example though?   The NFS socket handling code is huge
(net/sunrpc/xprtsck.c) - something seems wrong when replacing a few
lines of code with a new 1675 line file.  There must be a better
example of doing what you suggest...

I am tempted to drop the socket timeout (which cifs sets to 7 seconds)
to a smaller number and not use signals at all rather than add that
much complexity

On 6/30/07, Jeff Layton <jlayton@redhat.com> wrote:
> On Sat, 30 Jun 2007 09:42:09 +0100
> Christoph Hellwig <hch@infradead.org> wrote:
>
> > On Mon, Jun 25, 2007 at 05:25:00PM -0500, Steve French wrote:
> > > Jeff,
> > > Not seeing any objections to your revised approach (to not allowing
> > > signals for cifsd kernel thread), I just merged something similar to
> > > your patch to the cifs-2.6.git tree (also fixed some nearby lines that
> > > went past 80 columns).
> >
> > Ok, I'm back to this.
> >
> > As I said mixing force_sig with the kthread infrastructure is a bad idea.
> > The proper short-term (aka 2.6.22) fix is to revert the kthread conversion
> > for this particular thread.  Just go back to what worked before.
>
> Could you clarify why this is? It looks like kthreads and signalling
> should be more or less orthogonal. Or is it just an issue of the
> complexity added when you mix signalling into kthreads?
>
> Note that the problem of insulation from userspace signals predates the
> conversion to using the kthreads interface for cifsd. So even if we
> revert the switch of the demultiplexer thread to kthreads in the near
> term, I'd like to keep the recent change to block all signals from
> userspace and use force_sig in lieu of send_sig.
>
> Does that sound reasonable?
>
> >
> > Now the right fix is a lot more complicated and involved:
> >
> >       Stop using blocking recvmsg (or read) in kernel threads!
> >
> > If you look at what the other consumers of networking reads from kernel
> > threads do is they either use tcp_read_sock and hooks into the sk_ callbacks
> > which would be nice for high performance reads in cifs aswell, but probably
> > not the demultiplexer thread, or they use MSG_DONTWAIT to avoid this problems
> > and deal with the blocking behaviour on a higher level.
>
> --
> Jeff Layton <jlayton@redhat.com>
>


-- 
Thanks,

Steve
