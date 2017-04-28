From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Strange samples/bpf loading error for maps on net-next?
Date: Fri, 28 Apr 2017 08:28:16 +0200
Message-ID: <20170428082816.20a34395@redhat.com>
References: <20170427131542.3c8dfa24@redhat.com>
        <20170428054950.teh53ssg6ei4xkvx@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>, eric@regit.org,
        brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932078AbdD1G2X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 02:28:23 -0400
In-Reply-To: <20170428054950.teh53ssg6ei4xkvx@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Apr 2017 22:49:51 -0700
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Thu, Apr 27, 2017 at 01:15:42PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > To provoke this bug, remember that you MUST call:
> > 
> >  make headers_install
> > 
> > In the kernels root directory, else you will be compiling samples/bpf/
> > against the older headers previously installed.
> > 
> > The error looks like:
> > 
> >  $ sudo ./sockex1
> >  bpf_load_program() err=22
> >  fd 0 is not pointing to valid bpf_map
> >  sockex1: [...]/samples/bpf/sockex1_user.c:26: main: Assertion `setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd, sizeof(prog_fd[0])) == 0' failed.
> >  Aborted
> > 
> > I've found that the bug were introduced in
> >  commit: fb30d4b71214 ("bpf: Add tests for map-in-map")  
> 
> Great debugging!
> Indeed that change made samples/bpf/bpf_load.c to be incompatible with .o
> generated earlier. We should really get rid of that loader and
> switch to tools/lib/bpf/. I believe Eric Leblond already made it
> resilient to 'struct bpf_map_def' changes.

Yes, exactly it is problem in samples/bpf/bpf_load.c.  As it assumes
the contents of the ELF file maps section will always chunks in
sizeof(struct bpf_map_def) and just uses that directly as a pointer to
an array of type struct bpf_map_def, which of-cause silently blows up
when changing struct bpf_map_def.  That cost me many hours to discover
that yesterday.

I started implementing more correct parsing of the ELF maps section, it
is doable, but as you say, maybe we should just get rid of this loader?
I will at least fixup bpf_load.c and perhaps just abort the program the
program if I detect a difference between the ELF size and struct size.
And send this as a patch later today...

I've also looked at the loaded Daniel implemented[1] in iproute2, and
it is much cleaner.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/tree/lib/bpf.c
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
