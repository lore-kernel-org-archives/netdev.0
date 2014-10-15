From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: feature suggestion: implement SO_PEERCRED on local
 AF_INET/AF_INET6 sockets (allow uid-based identification on localhost)
Date: Wed, 15 Oct 2014 15:54:08 -0700
Message-ID: <CALCETrXnfU6cGaYNBy-X=GKwBZ07Wf8VvnUz1R-qgKVtGrS=hQ@mail.gmail.com>
References: <20141015133518.GA7179@achernar.madore.org> <543E87AC.5090402@amacapital.net>
 <20141015223033.GA11458@achernar.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel mailing-list <linux-kernel@vger.kernel.org>,
	Linux network mailing-list <netdev@vger.kernel.org>
To: David Madore <david+ml@madore.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141015223033.GA11458@achernar.madore.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2014 at 3:30 PM, David Madore <david+ml@madore.org> wrote:
> On Wed, Oct 15, 2014 at 07:41:48AM -0700, Andy Lutomirski wrote:
>> On 10/15/2014 06:35 AM, David Madore wrote:
>> > Given an AF_UNIX socket, the getsockopt(, SOL_SOCKET, SO_PEERCRED,,)
>> > call allows one endpoint to authenticate the other endpoint's pid, uid
>> > and gid.
>> >
>> > The call is valid on AF_INET and AF_INET6 sockets but returns no data
>> > (pid=0, uid=-1, gid=-1).  Obviously it is meaningless to try to get
>> > such credentials from a INET/INET6 socket in general, but there is one
>> > case where it would make sense: namely, when the endpoint is local
>> > (i.e., when the socket is a connection to the same machine, e.g., when
>> > connecting to 127.0.0.0/8 or ::1/32).
>>
>> I will object to adding it as described, for the same reason that I
>> object to anything that extends the current model of socket-based
>> credential passing.  Ideally, credentials would *never* be implicitly
>> captured by socket syscalls.  We live in the real world, and SO_****CRED
>> exists, so I think the best we can do is to try to minimize its use.
>>
>> I can elaborate further, or you can IIRC search the archives for
>> SCM_IDENTITY, and you can also look at CVE-2013-1979 for a nasty example
>> of why this model is broken.
>
> From what I understand, what was broken is mainly that the credentials
> were evaluated when the write() system call took place rather than
> when socket() or bind(): this violates the Unix security model
> (privilege control occurs when the file descriptor is created, not
> when it is used).  On the contrary, it is conform to Unix security
> principles that credentials are checked implicitly when binding a
> socket (this happens when permissions are being checked on the path
> when binding or connecting on a Unix domain socket; and to allow
> binding to secure ports in the INET domain; and so on).  It seems to
> me that a suid program that is willing to create or bind a socket on
> behalf of its caller without knowing exactly what it will be
> connecting to, it should intrinsically be treated as a security
> vulnerability, even when it is not obviously exploitable.

socket has little precedent for checking credentials and none in
POSIX.  And you're talking about connect, not bind.

>
> Also, to go along the real world examples, identd exists and is used
> for identification on local networks (e.g. localhost), so the capture
> of credentials already takes place.  Unix programmers are aware of
> this, and know that a privileged program should not bind a socket if
> they don't want to leak privileges.  (Another example is the use of -m
> owner in iptables.)

Ugh.

Identd is completely insecure.  Quite a few years ago personally broke
Stanford's entire single sign-on mechanism by exploiting it, against a
hardened, kerberized version, so less.  And iptables -m owner is all
about what you can connect to, not what is assumed by the recipient.
(And it's probably insecure, too, in many cases.)

>
> And, of course, if Solaris already has this feature, there is some
> experience for it.  Has there been any documented vulnerability
> relating to the fact that Solaris allows getpeerucred() to
> authenticate locally connected AF_INET sockets?

Does it matter?  CVE-2013-1979 existed for many years before anyone noticed.

>
> Note that since the possibility of using SO_PEERCRED on AF_INET
> sockets does not hitherto exist on Linux, we can be sure that nobody
> uses it, so it's not like it might open vulnerabilities in existing
> code.  If you think it's insecure, it can be documented as such (by
> comparing it with identd): I still think it's better than having no
> control at all when binding to localhost, which is the present
> situation (causing, e.g., CVE-2014-2914).

This doesn't follow.  *Everybody* uses connect on AF_INET.

IMO anything that sends a caller's credentials needs to be explicit and opt-in.

>
> Because SO_PEERCRED currently returns {pid=0,uid=-1,gid=-1} on
> AF_INET, we might still return this value if there is any risk that
> the endpoint would be unwilling to share its credentials: for example,
> this value might be returned if the other endpoint is not ptraceable
> by the caller - this would still cover the essential use case, which
> is for unprivileged users to authenticate the connections from their
> own processes.  Would this limitation assuage your worries about the
> proposed feature?
>
> The thing is, I don't see any other way the ssh port forwarding mess
> can ever be improved.  Do you have another solution in mind that?

UNIX sockets.  Firewall rules.  An opt-in mechanism like SCM_IDENTITY
that has explicit support in OpenSSH and doesn't happen unless the
administrator actually requests it in sshd_config.

>
> Any attempt to have some kind of authentication of local sockets that
> required participation on the client (authenticatee)'s part is doomed:
> if modifying the protocol and/or client code is an option, we might as
> well use some form of crypto / TLS.  Or Unix-domain sockets.  But what
> are we supposed to do when modifying the client (to make it send
> credentials, use crypto or connect on AF_UNIX) is not an option?

Exactly.

I believe that there is no secure way to authenticate clients that
currently don't authenticate themselves without changing the clients.
That's the whole point: currently-secure are written under the
assumption that they are not exercising their credentials.  You can't
safely change that without making it opt-in.

--Andy
