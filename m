From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 11:03:26 -0400
Message-ID: <200905211103.26496.paul.moore@hp.com>
References: <20090520230652.GB5956@ghostprotocols.net> <200905211016.17328.paul.moore@hp.com> <20090521144739.GF5956@ghostprotocols.net>
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
In-Reply-To: <20090521144739.GF5956@ghostprotocols.net>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 May 2009 10:47:39 am Arnaldo Carvalho de Melo wrote:
> Em Thu, May 21, 2009 at 10:16:17AM -0400, Paul Moore escreveu:
> > On Wednesday 20 May 2009 07:06:52 pm Arnaldo Carvalho de Melo wrote:
> > > Meaning receive multiple messages, reducing the number of syscalls and
> > > net stack entry/exit operations.
> >
> > NOTE: adding the LSM list to the CC line
>
> thanks!
>
> > If this approach is accepted I wonder if it would also make sense to move
> > the security_socket_recvmsg() hook out of __sock_recvmsg and into the
> > callers.  I personally can't see a reason why we would need to call into
> > the LSM for each message in the case of the new recvmmsg() syscall.  The
> > downside is that there is now some code duplication (although we are only
> > talking duplicating ~three lines of code) but the upside is that we wont
> > end up calling into the LSM for each of the messages when recvmmsg() is
> > called which seems to fit well with the performance oriented nature of
> > the new syscall.
>
> Agreed that we must do this earlier to avoind vlen calls to
> security_socket_recvmsg, but there are many callers of sock_recvmsg...

Yeah, like I said there is a downside to this approach, the question is how 
much do we care about performance and what are we willing to give up for it?  
I don't know the answer but I thought the question needed to be asked.

> Also shouldn't recvmmsg have a different LSM hook? It doesn't look right
> at first sight to reuse security_socket_recvmsg, as we now are passing
> many msghdrs and sockaddrs, etc.

Well, right now the only LSM of the three in the mainline kernel that makes 
use of the recvmsg hook is SELinux and in SELinux the recvmsg hook really only 
checks to see if the process can read from the socket - there is no access 
check against the message itself.  In general, all of the per-packet/message 
access controls happen below the socket layer in SELinux so I see no reason 
why we would need to execute the recvmsg hook multiple times for each 
recvmmsg() syscall.

If I'm wrong I'm sure the LSM brain trust will quickly step in ...

> If security_socket_recvmsg receives the msg and inspects it, I think
> fully inspecting the mmsg and vlen can be something LSM policies can be
> interested in inspecting too, no?

Maybe, but not with what we currently have in-tree.  Perhaps this is a 
sign/opportunity that we can trim the arguments to security_socket_recvmsg() 
too?

-- 
paul moore
linux @ hp

