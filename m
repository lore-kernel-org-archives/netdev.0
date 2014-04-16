From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 10:29:08 -0700
Message-ID: <CALCETrU_yKQVZyVug25cxwQFjWJ7Zf20FY-6ht+RJifXtDdDWg@mail.gmail.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <1397667766.19767.440.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>, Tejun Heo <tj@kernel.org>,
	Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Simo Sorce <ssorce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397667766.19767.440.camel@willson.li.ssimo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 10:02 AM, Simo Sorce <ssorce@redhat.com> wrote:
> On Wed, 2014-04-16 at 09:31 -0700, Andy Lutomirski wrote:
>> On Wed, Apr 16, 2014 at 9:13 AM, Simo Sorce <ssorce@redhat.com> wrote:
>> > On Wed, 2014-04-16 at 07:37 -0700, Andy Lutomirski wrote:
>> >> On Wed, Apr 16, 2014 at 5:57 AM, David Miller <davem@davemloft.net> wrote:
>> >> >
>> >> > Please, just stop.
>> >>
>> >> No.
>> >>
>> >> This thread is proposing an ABI.  This means that, if the ABI ends up
>> >> in Linus's kernel, then it has to be supported forever.  Now is the
>> >> time to find and fix any issues with it before they become much harder
>> >> to fix.
>> >
>> > Ok, but so far I haven't seen a single objection from you that has solid
>> > grounds.
>>
>> CVE-2013-1959 was caused by a new kernel feature causing a call to
>> write(2) to behave as though the caller was authenticating itself to
>> something else where, in previous kernels, write(2) did not
>> authenticate.
>>
>> Admittedly cgroups aren't currently as important as uid, but if this
>> changes, then SO_PASSCGROUP, as currently written, will have *exactly*
>> the same problem.
>
> Which is easy to foil by using SO_PEERCGROUP and find out who originally
> opened the socket, which is why that is also available!

Then please remove SO_PASSCGROUP.

>> The issue here is that the receiver sets SO_(PASS|PEER)CGROUP, forcing
>> the sender to identify or authenticate itself.  The sender might not
>> want to identify itself.
>
> You need to explain, why, on a host, when an application connects to
> another, it is ok to make it anonymous. If you do not want to expose
> yourself, do not talk to other applications in the first place.

Why is anonymity harmful here?  I don't have a great argument off the
top of my head for why it's necessary, but neither do I see why it's
bad.  And I think a lack of anonymity is asking for trouble (see
below).

>
>> the sender might not intend to authenticate.  Certainly no existing
>> callers of connect or write intend to authenticate using their cgroup,
>> since current kernels don't have those semantics.
>
> This is a passive check, it's the receiver that wants to make decisions
> about who is connecting, again if you do not want to "disclose"
> information do not connect in the first place ?
>

Let's say I have a receiver.  I'll call it journald, since I think
that's one of the eventual use cases.

Let's also say I some random program on my box.  It is willing to
answer requests on behalf of anyone else with the same uid, and it
will happily open a given unix socket and send the requester the file
descriptor.  Such a program is a bit odd, but it's perfectly safe
right now.

Now add a malicious program into the mix.  It asks the daemon to open
/run/systemd/journal/socket.  Then it starts writing to the fd.

Whoops, now the malicious program can impersonate the helper.  This
happens because SO_PEERCGROUP (and journald's use of SO_PEERCGROUP)
caused connect(2) to produce a descriptor that carries a permission
that the descriptor did not carry in the past, and because the caller
of connect(2) did not need to opt in to the new behavior.

I still haven't seen any explanation for what's wrong with requiring
senders to ask the kernel to transmit their cgroup.

--Andy
