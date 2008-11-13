From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Thu, 13 Nov 2008 14:05:41 -0800
Message-ID: <20081113140541.23754cad.akpm@linux-foundation.org>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	<517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: subrata@linux.vnet.ibm.com, linux-arch@vger.kernel.org,
	drepper@redhat.com, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, linux-api@vger.kernel.org,
	linux-man@vger.kernel.org, davidel@xmailserver.org,
	netdev@vger.kernel.org, roland@redhat.com, oleg@tv-sign.ru,
	hch@lst.de, davem@davemloft.net, alan@redhat.com, jakub@redhat.com,
	mtk.manpages@gmail.com
To: "Michael Kerrisk" <mtk.manpages@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2008 16:51:56 -0500
"Michael Kerrisk" <mtk.manpages@gmail.com> wrote:

> Andrew,
> 
> On 10/26/08, Ulrich Drepper <drepper@redhat.com> wrote:
> > This patch reintroduces accept4, replacing paccept.  It's easy to see that
> > the patch only removes code and then redirects existing code away from the
> > removed functions.  Since the paccept code sans signal handling was never
> > in question I think there is no reason to quarantine the patch first.
> 
> I see you accepted this patch into -mm.  I've finally got to looking
> at and testing this, so:
> 
> Tested-by: Michael Kerrisk <mtk.manpages@gmail.com>
> Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>

Cool, thanks.

> In my tests, everything looks fine.  I'll forward my test program in a
> follow-up mail.

OK, I'll add that to the changelog as well.

> I think Ulrich wanted to try to see this patch in for 2.6.28; it's
> past the merge window of course, so it's up to you, but I have no
> problem with that.

That's easy - I'll send it to Linus and let him decide ;)

Realistically, this isn't likely to get much third-party testing in -rc
anyway.  Our best defence at this time is careful review and developer
runtime testing, which you've done, thanks.

If it's buggy, we can live with that - fix it later, backport the
fixes.  It's security holes (including DoS ones) which we need to be
most concerned about.

>  The API is the one that Ulrich initially proposed,
> before taking a detour into paccept()
> (http://thread.gmane.org/gmane.linux.kernel/671443 ), which I argued
> against (http://thread.gmane.org/gmane.linux.kernel/723952,
> http://thread.gmane.org/gmane.linux.network/106071/), since I (and
> Roland) could see no reason for the added complexity of a signal set
> argument (like pselect()/ppoll()/epoll_pwait()).  (In any case, if
> someone does come up with a compelling reason to add a sigset
> argument, then we can add it via the use of a new flag bit.)
> 
> My only argument is with the name of the new sysytem call.
> 
> > I've updated the test program which now looks as follows:
> 
> (I assume that there had been no testing on x86-32, since, the
> __i386__ ifdef's notwithstanding,  the program below can't work on
> x86-32 -- sys_socketcall() takes its arguments packaged into an array
> on x86-32, not as an inline list.)
> 
> Andrew, you noted a lack of explanation accompanying the original
> patch.  Here's something to fill the gap, and which may be suitable
> for the changelog.
> 
> ==
> Introduce a new accept4() system call.  The addition of this system
> call matches analogous changes in 2.6.27 (dup3(), evenfd2(),
> signalfd4(), inotify_init1(), epoll_create1(), pipe2()) which added
> new system calls that differed from analogous traditional system calls
> in adding a flags argument that can be used to access additional
> functionality. The accept4() system call is exactly the same as
> accept(), except that it adds a flags bit-mask argument.  Two flags
> are initially implemented.  (Most of the new system calls in 2.6.27
> also had both of these flags.)  SOCK_CLOEXEC causes the close-on-exec
> (FD_CLOEXEC) flag to be enabled for the new file descriptor returned
> by accept4().  This is a useful security feature to avoid leaking
> information in a multithreaded program where one thread is doing an
> accept() at the same time as another thread is doing a fork() plus
> exec().  (More details here:
> http://udrepper.livejournal.com/20407.html "Secure File Descriptor
> Handling", Ulrich Drepper)  The other flag is SOCK_NONBLOCK, which
> causes the O_NONBLOCK flag to be enabled on the new open file
> description created by accept4().  (This flag is merely a convenience,
> saving the use of additional calls fcntl(F_GETFL) and fcntl (F_SETFL)
> to achieve the same result.)

I replaced the existing changelog with the above (plus some paragraph
breaks ;)).  Will add the new test app when it comes along.
