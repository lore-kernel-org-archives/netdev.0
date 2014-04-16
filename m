From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 11:59:24 -0700
Message-ID: <CALCETrUKqqh_ktavHtcBQSWYKPtqWdvvDV8KEmzLYcs6rkzTew@mail.gmail.com>
References: <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <1397667766.19767.440.camel@willson.li.ssimo.org> <CALCETrU_yKQVZyVug25cxwQFjWJ7Zf20FY-6ht+RJifXtDdDWg@mail.gmail.com>
 <20140416183614.GH31074@redhat.com> <CALCETrURhBXQaYYJiHq2svPqB3-K7kmgD2QUTT9LCjry=fukWA@mail.gmail.com>
 <20140416185153.GI31074@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simo Sorce <ssorce@redhat.com>, David Miller <davem@davemloft.net>,
	Tejun Heo <tj@kernel.org>, Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140416185153.GI31074@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 11:51 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Wed, Apr 16, 2014 at 11:40:44AM -0700, Andy Lutomirski wrote:
>> On Wed, Apr 16, 2014 at 11:36 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
>> > On Wed, Apr 16, 2014 at 10:29:08AM -0700, Andy Lutomirski wrote:
>> >
>> > [..]
>> >> >> Admittedly cgroups aren't currently as important as uid, but if this
>> >> >> changes, then SO_PASSCGROUP, as currently written, will have *exactly*
>> >> >> the same problem.
>> >> >
>> >> > Which is easy to foil by using SO_PEERCGROUP and find out who originally
>> >> > opened the socket, which is why that is also available!
>> >>
>> >> Then please remove SO_PASSCGROUP.
>> >
>> > SO_PASSCGROUP is important because SO_PEERCGROUP does not work with unix
>> > datagram sockets.
>>
>> Right.  I forgot about that.
>>
>> >
>> > Again going back to logging example, if some clients are logging to unix
>> > datagram sockets, SO_PASSCGROUP is the only option to figure out cgroup
>> > of client.
>>
>> Hmm.  I think that, in your patch, the cgroup that is sent is the
>> cgroup of the caller of write/send/sendmsg.  What if you changed it to
>> use the same cgroup that SO_PEERCRED would use?  Would that still
>> work?
>
> No. SO_PEERCRED stores the cgroup information once at the time of
> connect(). After that it never changes.
>
> What if sender changes the cgroup. That information will not be captured.
> Also what if multiple client use the same socket fd to writer to logger?
> In that case too storing cgroup info in socket will not help.


What is the use case of SO_PEERCRED, then?

Why can't clients that change cgroup reopen the socket?  They're
already cgroup-aware.  As far as I know, there is probably exactly one
client that actually changes cgroups and then tries to log without
execing first: systemd (or journald as used by systemd).  And this is
exactly the component that needs to change to use any new socket
option, no matter what.


>> > How would it work in logging example? Every time logger receives a
>> > message, is it supposed to send another message to client to send
>> > SCM_CGROUP? That does not sound right.
>>
>> No -- just have the logger send the cgroup with every message.  Yes,
>> it seems silly, but it's probably barely more expensive than with the
>> code in your patch.
>
> So receiver gets the cgroup messages even if it might not want to. There
> is no way to say "Hey don't send me SCM_CGROUP's messages".

The receiver would only get SCM_CGROUP messages if it set SO_PASSCGROUP.

>
> Now all loggers need to be modifed to always send SCM_CGROUP messages. And
> all other more complicated cases might need a different consideration and
> clients and servers will need to be modified accordingly.
>
> I think it is much simpler to allow passing of cgroup information and
> once we figure out some concrete cases where passing of that info is
> not desirabe, implement SO_NOPASSCGROUP and modify those *selected few
> corner cases* to set this flag on sockets.

The problem with SO_NOPASSCGROUP is that the programs that would need
to set it are probably already written and don't care about cgroups.

--Andy
