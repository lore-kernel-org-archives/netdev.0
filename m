From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: feature suggestion: implement SO_PEERCRED on local
 AF_INET/AF_INET6 sockets (allow uid-based identification on localhost)
Date: Wed, 15 Oct 2014 17:11:53 -0700
Message-ID: <CALCETrX4SjC05CYWfBsTOn-XaBLQLtmHWAd8b+9xONiFB1Soxw@mail.gmail.com>
References: <20141015133518.GA7179@achernar.madore.org> <543E87AC.5090402@amacapital.net>
 <20141015223033.GA11458@achernar.madore.org> <CALCETrXnfU6cGaYNBy-X=GKwBZ07Wf8VvnUz1R-qgKVtGrS=hQ@mail.gmail.com>
 <20141016000705.GA12208@achernar.madore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel mailing-list <linux-kernel@vger.kernel.org>,
	Linux network mailing-list <netdev@vger.kernel.org>
To: David Madore <david+ml@madore.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141016000705.GA12208@achernar.madore.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2014 at 5:07 PM, David Madore <david+ml@madore.org> wrote:
> On Wed, Oct 15, 2014 at 03:54:08PM -0700, Andy Lutomirski wrote:
>> On Wed, Oct 15, 2014 at 3:30 PM, David Madore <david+ml@madore.org> wrote:
>> > Note that since the possibility of using SO_PEERCRED on AF_INET
>> > sockets does not hitherto exist on Linux, we can be sure that nobody
>> > uses it, so it's not like it might open vulnerabilities in existing
>> > code.  If you think it's insecure, it can be documented as such (by
>> > comparing it with identd): I still think it's better than having no
>> > control at all when binding to localhost, which is the present
>> > situation (causing, e.g., CVE-2014-2914).
>>
>> This doesn't follow.  *Everybody* uses connect on AF_INET.
>>
>> IMO anything that sends a caller's credentials needs to be explicit and opt-in.
>
> I'm confused as to whether you mean "opt-in" on the side of the caller
> (=process requesting the endpoint's credentials), or on that of the
> endpoint (=authenticated process).  On the one hand I don't understand
> what it could mean on the caller side, on the other hand you mention
> explicit support in OpenSSH, which would be the caller in my scenario.

I mean the authenticated process, not the process doing the authentication.

>
> So, in case I haven't been clear enough, the situation I have in mind
> is: on "thishost", I run "ssh -L 14321:remotehost:4321 somehost" to
> forward connexions on from the local port 14321 of thishost (where ssh
> listens on the loopback) to the port 4321 of remotehost.
> Unfortunately, now everyone with an acccount on thishost can connect
> to port 14321 and effectively emit a connection from somehost to
> remotehost on my behalf.  I think everyone agrees that this is a huge
> problem.  But I don't understand how you propose to remedy this.

Unfortunately, I think that you need client changes.  These could be
semi-transparent (using LD_PRELOAD) or almost completely transparent
(using network namespaces).

Actually, a network namespace-based proxying tool could be very useful.

>
> Patching ssh is an option, but I don't see how to do it (ssh needs to
> make sure that the connections it receives on 14321 are from the same
> uid, and this seems impossible without the feature I'm discussing).
> Patching the kernel is an option.  Patching clients that connect to
> 14321, on the other hand, is not, because there are many different
> ones, and their protocol is defined by immutable Internet standards,
> so we have no latitude there (for example, we can't ask a Web browser
> to connect to Unix domain sockets: there simply isn't a URL scheme to
> refer to them).  Adding iptables rules is not an option if I'm not the
> system administrator on thishost.

I misunderstood.  I though that you wanted a server-side solution.

>
> So, how can we solve this problem securely?
>
>> I believe that there is no secure way to authenticate clients that
>> currently don't authenticate themselves without changing the clients.
>> That's the whole point: currently-secure are written under the
>> assumption that they are not exercising their credentials.  You can't
>> safely change that without making it opt-in.
>
> Then what are we to do, given that modifying the clients is
> impossible?
>
> What about my proposal that user credentials would be returned only if
> they refer to the same user as the caller user and that the caller is
> permitted to ptrace the endpoint?  This answers your objection of
> leaking credentials: the caller could do anything at all with the
> other side since it could ptrace it - we're just permitting a user to
> authenticate their own sockets.  A further sysctl could enable the use
> of the call in more general cases, for those administrators who think
> it should be allowed.
>

Ugh.

That's probably safe, but it's quite disgusting IMO.

--Andy
