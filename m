From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 51/51] lib/bpf: Check return value of write()
Date: Mon, 14 Aug 2017 19:25:26 +0200
Message-ID: <20170814172526.GW16375@orbyte.nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-52-phil@nwl.cc>
 <59916AB3.1010001@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39943 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751501AbdHNRZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 13:25:28 -0400
Content-Disposition: inline
In-Reply-To: <59916AB3.1010001@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 11:17:39AM +0200, Daniel Borkmann wrote:
> On 08/12/2017 02:05 PM, Phil Sutter wrote:
> > This is merely to silence the compiler warning. If write to stderr
> > failed, assume that printing an error message will fail as well so don't
> > even try.
> >
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >   lib/bpf.c | 3 ++-
> >   1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/lib/bpf.c b/lib/bpf.c
> > index 1dcb261dc915f..825e071cea572 100644
> > --- a/lib/bpf.c
> > +++ b/lib/bpf.c
> > @@ -591,7 +591,8 @@ int bpf_trace_pipe(void)
> >
> >   		ret = read(fd, buff, sizeof(buff) - 1);
> >   		if (ret > 0) {
> > -			write(2, buff, ret);
> > +			if (write(STDERR_FILENO, buff, ret) != ret)
> > +				return -1;
> 
> Quite unlikely to fail, but we should probably bark loudly
> here instead of just returning -1. Perhaps assert() would
> suit better.

Well, according to assert(3), it will print to stderr before aborting
the program. So if writing STDERR_FILENO failed, I guess it won't
provide much more detail to the user, either. If bpf_trace_pipe()
returns non-zero, parse_bpf() prints an error message to stderr and
returns -1. Ultimately tc will return non-zero. With stderr unfit for
writing into, I doubt there's anything left we could do besides that.

But I really think we shouldn't make such a fuss about it - writing to
stderr either always works or we're in trouble everywhere. This patch
was merely to shut gcc up, so no need to waste much energy on a scenario
which won't happen anyway.

Thanks, Phil
