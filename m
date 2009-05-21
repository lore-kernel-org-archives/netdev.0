From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 11:24:35 -0400
Message-ID: <200905211124.36034.paul.moore@hp.com>
References: <20090520230652.GB5956@ghostprotocols.net> <200905211103.26496.paul.moore@hp.com> <20090521151109.GG5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	linux-security-module@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090521151109.GG5956@ghostprotocols.net>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 May 2009 11:11:09 am Arnaldo Carvalho de Melo wrote:
> Em Thu, May 21, 2009 at 11:03:26AM -0400, Paul Moore escreveu:
> > On Thursday 21 May 2009 10:47:39 am Arnaldo Carvalho de Melo wrote:
> > > Em Thu, May 21, 2009 at 10:16:17AM -0400, Paul Moore escreveu:
> > > > On Wednesday 20 May 2009 07:06:52 pm Arnaldo Carvalho de Melo wrote:
> > > > > Meaning receive multiple messages, reducing the number of syscalls
> > > > > and net stack entry/exit operations.
> > > >
> > > > NOTE: adding the LSM list to the CC line
> > >
> > > thanks!
> > >
> > > > If this approach is accepted I wonder if it would also make sense to
> > > > move the security_socket_recvmsg() hook out of __sock_recvmsg and
> > > > into the callers.  I personally can't see a reason why we would need
> > > > to call into the LSM for each message in the case of the new
> > > > recvmmsg() syscall.  The downside is that there is now some code
> > > > duplication (although we are only talking duplicating ~three lines of
> > > > code) but the upside is that we wont end up calling into the LSM for
> > > > each of the messages when recvmmsg() is called which seems to fit
> > > > well with the performance oriented nature of the new syscall.
> > >
> > > Agreed that we must do this earlier to avoind vlen calls to
> > > security_socket_recvmsg, but there are many callers of sock_recvmsg...
> >
> > Yeah, like I said there is a downside to this approach, the question is
> > how much do we care about performance and what are we willing to give up
> > for it? I don't know the answer but I thought the question needed to be
> > asked.
>
> Well, if we only check if the process can read from the socket, I also
> see no reasons for a new security_socket_recvmmsg nor for checking it
> multiple times in recvmmsg, since what changes (the msg) is of no
> interest to LSM.

Exactly.

> > If I'm wrong I'm sure the LSM brain trust will quickly step in ...
> >
> > > If security_socket_recvmsg receives the msg and inspects it, I think
> > > fully inspecting the mmsg and vlen can be something LSM policies can be
> > > interested in inspecting too, no?
> >
> > Maybe, but not with what we currently have in-tree.  Perhaps this is a
> > sign/opportunity that we can trim the arguments to
> > security_socket_recvmsg() too?
>
> Perhaps, but up to LSM folks to tell if this was really a case where
> passing the msg was something that ended up being overkill.

Yep, and since they are a rather ornery bunch I'm sure they will speak up.  
However, I would say to go ahead and trim the unused args and if we need them 
in the future we can always add them back in; none of this is really visible 
outside the kernel so changes are relatively easy.

I'd hate to see us miss an opportunity to make things better over concerns 
about what might happen at some unknown point in the future.

-- 
paul moore
linux @ hp

