From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: feature suggestion: implement SO_PEERCRED on local AF_INET/AF_INET6
 sockets (allow uid-based identification on localhost)
Date: Wed, 15 Oct 2014 07:41:48 -0700
Message-ID: <543E87AC.5090402@amacapital.net>
References: <20141015133518.GA7179@achernar.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Madore <david+ml@madore.org>,
	Linux Kernel mailing-list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141015133518.GA7179@achernar.madore.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2014 06:35 AM, David Madore wrote:
> Given an AF_UNIX socket, the getsockopt(, SOL_SOCKET, SO_PEERCRED,,)
> call allows one endpoint to authenticate the other endpoint's pid, uid
> and gid.
> 
> The call is valid on AF_INET and AF_INET6 sockets but returns no data
> (pid=0, uid=-1, gid=-1).  Obviously it is meaningless to try to get
> such credentials from a INET/INET6 socket in general, but there is one
> case where it would make sense: namely, when the endpoint is local
> (i.e., when the socket is a connection to the same machine, e.g., when
> connecting to 127.0.0.0/8 or ::1/32).
> 
> Being able to authenticate local INET/INET6 sockets would be immensely
> valuable for a number of programs, to provide some kind of access
> control to local sockets.  For example, ssh allows port forwarding
> using the -L and -D options: by default or by option (cf. the
> GatewayPorts option of ssh), these port-forwarding sockets can be
> restricted to localhost, but of course they cannot be restricted to
> the user running ssh, which makes them a huge security problem.  Many
> programs suffer from the same problem (they restrict some kind of
> connection to localhost, but they of course cannot make a restriction
> on which user will be able to connect).
> 
> One cannot simply retort "these programs should be using Unix-domain
> sockets instead": I don't think many browsers support using a SOCKS
> proxy or an HTTP proxy over a Unix-domain socket, and in the latter
> case I'm not even sure it would make sense (protocol-wise).
> 
> If I believe <URL:
> http://www.lehman.cuny.edu/cgi-bin/man-cgi?getpeerucred+3
>  > ("The system currently supports both sides of connection end-points
> for local AF_UNIX, AF_INET, and AF_INET6 sockets"), Solaris, or at
> least some version thereof, support authentication of local AF_INET
> and AF_INET6 sockets.
> 
> I think it would be wonderful if Linux had this.  I'm willing to work
> on the implementation if it is considered *a priori* acceptable for
> inclusion.
> 
> The data seems to be available, since it is exposed in /proc/net/tcp
> and /proc/net/tcp6 and whatnots (implementation details left aside, it
> is merely a question of matching a line with opposite endpoints to the
> current socket and returning it).
> 
> [In principle, a userland program can parse /proc/net/tcp so it does
> not need the feature I am suggesting, but in practice parsing a text
> file to communicate with the kernel is yucky at best, and probably not
> very robust (e.g., /proc might not be mounted), and it would be very
> difficult to convince, say, the OpenSSH authors to include code that
> parses the Linux /proc/net/tcp format (or even link with a library
> which does this) in order to add access-control on ssh port-forwards:
> having this under a more standard getsockpot() interface is cleaner
> and opens at least some kind of hope that programs would agree to use
> it.]
> 
> Question number 1: If this feature were implemented, would it be
> considered acceptable for inclusion in the kernel?  (If there is some
> reason why it can't be accepted, I'd like to know in advance, to avoid
> working in vain.)

I will object to adding it as described, for the same reason that I
object to anything that extends the current model of socket-based
credential passing.  Ideally, credentials would *never* be implicitly
captured by socket syscalls.  We live in the real world, and SO_****CRED
exists, so I think the best we can do is to try to minimize its use.

I can elaborate further, or you can IIRC search the archives for
SCM_IDENTITY, and you can also look at CVE-2013-1979 for a nasty example
of why this model is broken.

That being said, if anyone ever finished the SCM_IDENTITY work, I think
I'd be okay with allowing it over TCP.  I can't speak for the network
people, though, and you should ask on netdev (cc'd).

> 
> Question number 2: A priori, how difficult would it be to implement
> this?  (As mentioned above, it seems trivial in principle to merely go
> through the local endpoints to find a matching connection, but maybe
> there are locking issues that I don't understand that make it much
> more difficult than it would seem.)  Any guidelines on implementation?
> (I imagine one should try to fill sk->sk_peer_cred at connect time,
> but I don't really know how difficult this might turn out.)

Dunno.

--Andy
