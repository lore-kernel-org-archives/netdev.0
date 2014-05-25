From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] netlink: Only check file credentials for implicit destinations
Date: Sun, 25 May 2014 16:44:43 -0700
Message-ID: <874n0ds9sk.fsf@x220.int.ebiederm.org>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
	<20140522170505.64ef87a2@griffin>
	<87ioow6pt6.fsf@x220.int.ebiederm.org>
	<CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
	<87zji6v2mk.fsf_-_@x220.int.ebiederm.org>
	<CALCETrVezgCY61wSO_5kTJz-tX5HdYwbEPpS-HAy8bg7KEqibA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Jorge Boncompte \[DTI2\]" <jorge@dti2.net>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51952 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaEYXpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 19:45:39 -0400
In-Reply-To: <CALCETrVezgCY61wSO_5kTJz-tX5HdYwbEPpS-HAy8bg7KEqibA@mail.gmail.com>
	(Andy Lutomirski's message of "Sun, 25 May 2014 09:50:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Sat, May 24, 2014 at 10:38 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> It was possible to get a setuid root or setcap executable to write to
>> it's stdout or stderr (which has been set made a netlink socket) and
>> inadvertently reconfigure the networking stack.
>>
>> To prevent this we check that both the creator of the socket and
>> the currentl applications has permission to reconfigure the network
>> stack.
>>
>> Unfortunately this breaks Zebra which always uses sendto/sendmsg
>> and creates it's socket without any privileges.
>>
>> To keep Zebra working don't bother checking if the creator of the
>> socket has privilege when a destination address is specified.  Instead
>> rely exclusively on the privileges of the sender of the socket.
>>
>
> Cute.
>
>> +       NETLINK_SKB_DST         = 0x8,          /* Packet not socket destination */
>
> How about "sendto/sendmsg with explicit destination"

That is a better comment. 

> Whatever we settle on, I think this'll need to end up in the man
> pages.  Cc: Michael Kerrisk.  I hereby volunteer to write something
> up.
>
> Michael, for background: Pre-linux-3.15, sending netlink messages to
> the kernel checked the credentials of the sender.  This is a security
> bug: the sender might be a setuid-root program with stdout or stderr
> redirected to a netlink socket (or an SCM_RIGHTS user, etc).
>
> The proposal in this patch is that doing privileged things using a
> netlink socket will require the sender to have capabilities and
> (either sendto/sendmsg with an explicit destination or a connected
> socket that was created by a privileged user).
>
> This is still not great from a security POV: if you can get a hold of
> a privileged socket (i.e. a socket created with CAP_NET_ADMIN
> available), then you can connect it and try to attack the kernel.
> This issue would go away if we hooked netlink_connect.  I can try
> writing up that version of the patch tomorrow.

The really important part technically is skipping the socket based check
in sendto and sendmsg as I have done, as it fixes the one known
regression, and yields comprehensible semantics.

But I agree that since connect on sockets is really the equivalent of
open on files, and unprivileged users can change where a socket is
connected to, using a struct cred captured at connect() time is better
than the struct cred captured at socket() time.

Eric
