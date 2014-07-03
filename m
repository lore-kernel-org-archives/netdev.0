From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Thu, 3 Jul 2014 09:14:56 -0700
Message-ID: <CALCETrW0Fib+dMb7LWjsyd+hJ9KUYzf0kFjeekWi596aQD+V1Q@mail.gmail.com>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
 <20140701.163153.30109595101601494.davem@davemloft.net> <CALCETrUQQTsGKyMYM7BLZjFGjy1h_ji0=6E-P53HgXfgmJOWzw@mail.gmail.com>
 <001101cf9684$10c4dbe0$324e93a0$%wilczek@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	juho80.son@samsung.com,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	jkaluza@redhat.com
To: Piotr Wilczek <p.wilczek@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:57413 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbaGCQPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 12:15:18 -0400
Received: by mail-lb0-f180.google.com with SMTP id w7so345014lbi.11
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 09:15:16 -0700 (PDT)
In-Reply-To: <001101cf9684$10c4dbe0$324e93a0$%wilczek@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 2, 2014 at 11:00 PM, Piotr Wilczek <p.wilczek@samsung.com> wrote:
>
>
>> -----Original Message-----
>> From: Andy Lutomirski [mailto:luto@amacapital.net]
>> Sent: Wednesday, July 02, 2014 1:52 AM
>> To: David Miller
>> Cc: Piotr Wilczek; Network Development; Kyungmin Park;
>> juho80.son@samsung.com; Bartlomiej Zolnierkiewicz; jkaluza@redhat.com
>> Subject: Re: [PATCH net-next V2 0/2] send process status in
>> SCM_PROCINFO
>>
>> On Tue, Jul 1, 2014 at 4:31 PM, David Miller <davem@davemloft.net>
>> wrote:
>> > From: Piotr Wilczek <p.wilczek@samsung.com>
>> > Date: Thu, 26 Jun 2014 14:55:52 +0200
>> >
>> >> Server-like processes in many cases need credentials and other
>> >> metadata of the peer, to decide if the calling process is allowed to
>> >> request a specific action, or the server just wants to log away this
>> >> type of information for auditing tasks.
>> >>
>> >> The current practice to retrieve such process metadata is to look
>> >> that information up in procfs with the $PID received over
>> SCM_CREDENTIALS.
>> >> This is sufficient for long-running tasks, but introduces a race
>> >> which cannot be worked around for short-living processes; the
>> calling
>> >> process and all the information in /proc/$PID/ is gone before the
>> >> receiver of the socket message can look it up.
>> >>
>> >> Changes introduced in this patchset can also increase performance of
>> >> such server-like processes, because current way of opening and
>> >> parsing /proc/$PID/* files is much more expensive than receiving
>> >> these metadata using SCM.
>> >>
>> >> As an example, this patch set improves systemd-journald performance
>> >> by about 20%. Generally, performance improvement depends on how
>> >> heavily procfs is read the calling process.
>> >> http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19467
>> >>
>> >> This patch set is split in two patches:
>> >> - the first adds library to retrive process information without
>> >> dependency on procfs.
>> >> - the second introduces a new SCM type called SCM_PROCINFO to
>> >> optionally allow the direct attaching of process status to SCM.
>> >
>> > I really would like someone smarter than me to review the security
>> > implications et al. of these changes before I apply them.
>> >
>> > Andy?  Maybe you have an opinion?
>> >
>>
>> The degree to which I dislike this depends on what "procinfo" is.
>>
>> From the patch, it looks like procinfo includes cmdline.  In which
>> case, NAK in almost the strongest possible terms.  (If it includes
>> userspace addresses, then I'll upgrade that to the strongest possible
>> terms.)  This is a giant information leak.  Imagine what happens when a
>> privileged program gets one of these things as stdout.  Keep in mind
>> that procfs has an option to hide pids that belong to other users.
>>
>> Even if procinfo were made relatively innocuous, this is just an
>> extension of a bad interface.  If you all really want a way to
>> efficiently pass kernel-verified information through a unix socket,
>> then add something reasonable.  This means:
>>
>> 1. It needs to be opt-in, *per send*.  After all of the vulnerabilities
>> that have happened due to write(2) capturing unexpected credentials of
>> the caller, there's just no excuse for adding new examples of this.
>> Yes, this will prevent you from getting a magic speed-up with legacy
>> clients, but I've spent long enough battling this sh*t from a security
>> and correctness POV to care.  Fix the clients.
>>
>> 2. It should be easily extensible, because people keep wanting to add
>> new things here.
>>
>> Here's a proposal for how it could work:
>>
>> Senders can send SCM_VERIFIED_INFO.  The payload is a list of (type,
>> flags, value) where type is the type of verified information and value
>> is what the sender wants to send.
>>
>> Flags can include SCMVI_FLAG_MANDATORY: failure to send this attribute
>> returns -EPERM.
>> SCMVI_FLAG_AUTO: value must be blank; the kernel will fill it in.
>> Any other flags: -EINVAL.
>>
>> This could be in CMSG format or in nlattr format.  Or it could be one
>> cmsg per value (which might be easier).
>>
>> Receivers can set SO_PASS_VERIFIED_INFO.  If so, then they'll receive
>> all of the sent values that have recognized types and pass
>> verification.
>>
>> For stream sockets, presumably the sender would send an
>> scm_verified_info using setsockopt and the receiver would grab it using
>> getsockopt.
>>
>> Types could include:
>>
>> SCMVI_UID
>> SCMVI_GID
>> SCMVI_PID (racy, but still better than SCM_CREDENTIALS) SCMVI_LOGONUID
>> (but only if CONFIG_AUDITSYSCALL, and someone needs to figure out wtf
>> its semantics are and *document* it before I'd ack such a thing)
>> SCMVI_CGROUP (sigh) SCMVI_AUDIT_SESSIONID (because sessionid is an
>> awful name) etc.
>>
>> I *might* get around to implementing this, but don't expect anything
>> soon -- my current kernel hacking bandwidth is well-occupied by
>> seccomp.  But I'd be happy to review.
>>
>> --Andy
>
> In this patch the kernel sends information about the sender. In your proposal, the sender sends the information and the kernel maybe completes the missing data. Could you please explain why your solution is secure? Is the source or the range of information sent the security problem?
>

The problem is neither; it's the sending of information that's
unexpected by the sender that's a problem.  Here are two concrete
issues:

1. Information leaks.  Currently, sending on a UNIX socket reveals
your uid, gid, and pid.  I would argue that that is already a mistake,
but it's well-enshrined in the API.  But imagine if sending on a UNIX
socket suddenly started revealing, say, a few bytes of sender memory
-- this would have huge security implications.  This code doesn't do
that, but it's not clear to me that revealing cmdline or random bits
of process status is much better.

2. Inadvertent assertions of authority.  In Unix (and most, but not
all, other OSes), for better or for worse, many APIs implicitly use
the caller's credentials.  For the most part, these are
well-understood, and the caller intends to use the credential.  For
example, open(2) is expected to use euid/egid (or fsuid/fsgid) to
check access.  bind(2) checks capabilities to determine whether
binding low-numbered ports is okay.  write(2) *does not check* the
caller's authority.  (Except for SCM_CREDENTIALS, which I would argue
is a mistake.)  Because everyone knows that write(2) does not use the
caller's authority in a potentially dangerous way, no one takes any
precautions against it.  For example, basically every setuid program
on anyone's system will happily write untrusted data to stdout or
stderr.

The problem here is that there have been multiple vulnerabilities that
result from the kernel assuming that a program that calls write(2)
actually *intends* to use its authority.  For example, at one point,
writes to /proc/PID/uid_map checked capabilities at write(2) time.
That was a root hole.  There are probably real root holes due to the
same effect on UNIX datagram sockets.

If senders have to explicitly ask to use credentials, then this type
of attack can't happen.

--Andy


-- 
Andy Lutomirski
AMA Capital Management, LLC
