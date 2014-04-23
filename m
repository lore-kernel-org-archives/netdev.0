From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP socket options
Date: Wed, 23 Apr 2014 10:21:14 -0700
Message-ID: <CALCETrX_+XNr+UGhR5u6d6VNmg6tKoszza6v5A=PC1P_24auHQ@mail.gmail.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
 <20140422.160558.627080587952506099.davem@davemloft.net> <20140423155512.GA24651@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, Simo Sorce <ssorce@redhat.com>,
	lpoetter@redhat.com, kay@redhat.com,
	Daniel Walsh <dwalsh@redhat.com>
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140423155512.GA24651@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 8:55 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Tue, Apr 22, 2014 at 04:05:58PM -0400, David Miller wrote:
>> From: Vivek Goyal <vgoyal@redhat.com>
>> Date: Tue, 15 Apr 2014 17:15:44 -0400
>>
>> > This is another version of patchset to add support passing cgroup
>> > information of client over unix socket API.
>>
>> I'm marking this patch series as "changes requested" in patchwork
>> because if we still end up adding this feature SO_PASSCGROUP needs to
>> be changed to behave like SO_PASSCRED.
>
> Does this concern of passing of real uid apply to cgroups also. Even
> if somebody tricks suid program to write to fd setup by under priviliged
> program how would that pgram force setuid program to change cgroup.
>
> To me passing cgroup information looks more like "pid" information where
> we pass the actual pid of setuid program and not the pid of parent who
> setup fd.
>

Relying on pid from SCM_CREDENTIALS is completely unsafe for the same
reason that relying on euid was very dangerous back when
SCM_CREDENTIALS would send euid.

This is why I think that all transmissions of process identity and
credentials should be intentional on the part of the transmitter.
write(2) is never a good place for this, and connect(2) and socket(2)
are barely good places.  setsockopt and sendmsg are good places, and I
think we should come up with a new, clean way to allow unix socket
users to identify themselves.

For example, you could sendmsg an SCM_IDENTITY on datagram and
seqpacket sockets, and you could setsockopt a SO_IDENTITY on streams;
the receivers would receive SCM_IDENTITY or SO_PEERIDENTITY, *but only
if the sender put an identity there*.  Problem solved completely, at
least for users of the new interface.

For an even bigger improvement, allow SCM_IDENTITY and SO_PEERIDENTITY
to return things like pidfds once we have them.  This requires a bit
of care to avoid fd leaks.

Done right, people could start migrating away from anything that uses
struct ucred.  It's too late to change all the old stuff, but, for
example, the kernel netlink receivers could refuse to do
privilege-requiring things unless the request sends an appropriate
SCM_IDENTITY.  The trick from CVE-2014-0181 would result in a message
with no SCM_IDENTITY at all, so no privileged actions would occur.

If people actually like the explicit identity idea, I could try to prototype it.

--Andy
