From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Fri, 04 Jul 2014 19:58:57 +0200
Message-ID: <1546483.blK5usQ45h@amdc1032>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
 <2651461.geYqK2uuT8@amdc1032>
 <CALCETrUfPg4Avn+D5q_dzyqLK4b88VWJOw4ncyW11VAZ_BT_nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7Bit
Cc: Piotr Wilczek <p.wilczek@samsung.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	juho80.son@samsung.com, jkaluza@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:42914 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbaGDR7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 13:59:15 -0400
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N870016G8MOKY10@mailout4.samsung.com> for
 netdev@vger.kernel.org; Sat, 05 Jul 2014 02:59:12 +0900 (KST)
In-reply-to: <CALCETrUfPg4Avn+D5q_dzyqLK4b88VWJOw4ncyW11VAZ_BT_nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, July 04, 2014 10:07:24 AM Andy Lutomirski wrote:
> On Fri, Jul 4, 2014 at 9:55 AM, Bartlomiej Zolnierkiewicz
> <b.zolnierkie@samsung.com> wrote:
> > On Friday, July 04, 2014 08:15:24 AM Andy Lutomirski wrote:
> >> On Fri, Jul 4, 2014 at 6:26 AM, Bartlomiej Zolnierkiewicz
> >> <b.zolnierkie@samsung.com> wrote:
> >> >
> >> > Hi,
> >> >
> >> > On Thursday, July 03, 2014 09:14:56 AM Andy Lutomirski wrote:
> >> >> On Wed, Jul 2, 2014 at 11:00 PM, Piotr Wilczek <p.wilczek@samsung.com> wrote:
> >> >> >
> >> >> >
> >> >> >> -----Original Message-----
> >> >> >> From: Andy Lutomirski [mailto:luto@amacapital.net]
> >> >> >> Sent: Wednesday, July 02, 2014 1:52 AM
> >> >> >> To: David Miller
> >> >> >> Cc: Piotr Wilczek; Network Development; Kyungmin Park;
> >> >> >> juho80.son@samsung.com; Bartlomiej Zolnierkiewicz; jkaluza@redhat.com
> >> >> >> Subject: Re: [PATCH net-next V2 0/2] send process status in
> >> >> >> SCM_PROCINFO
> >> >> >>
> >> >> >> On Tue, Jul 1, 2014 at 4:31 PM, David Miller <davem@davemloft.net>
> >> >> >> wrote:
> >> >> >> > From: Piotr Wilczek <p.wilczek@samsung.com>
> >> >> >> > Date: Thu, 26 Jun 2014 14:55:52 +0200
> >> >> >> >
> >> >> >> >> Server-like processes in many cases need credentials and other
> >> >> >> >> metadata of the peer, to decide if the calling process is allowed to
> >> >> >> >> request a specific action, or the server just wants to log away this
> >> >> >> >> type of information for auditing tasks.
> >> >> >> >>
> >> >> >> >> The current practice to retrieve such process metadata is to look
> >> >> >> >> that information up in procfs with the $PID received over
> >> >> >> SCM_CREDENTIALS.
> >> >> >> >> This is sufficient for long-running tasks, but introduces a race
> >> >> >> >> which cannot be worked around for short-living processes; the
> >> >> >> calling
> >> >> >> >> process and all the information in /proc/$PID/ is gone before the
> >> >> >> >> receiver of the socket message can look it up.
> >> >> >> >>
> >> >> >> >> Changes introduced in this patchset can also increase performance of
> >> >> >> >> such server-like processes, because current way of opening and
> >> >> >> >> parsing /proc/$PID/* files is much more expensive than receiving
> >> >> >> >> these metadata using SCM.
> >> >> >> >>
> >> >> >> >> As an example, this patch set improves systemd-journald performance
> >> >> >> >> by about 20%. Generally, performance improvement depends on how
> >> >> >> >> heavily procfs is read the calling process.
> >> >> >> >> http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19467
> >> >> >> >>
> >> >> >> >> This patch set is split in two patches:
> >> >> >> >> - the first adds library to retrive process information without
> >> >> >> >> dependency on procfs.
> >> >> >> >> - the second introduces a new SCM type called SCM_PROCINFO to
> >> >> >> >> optionally allow the direct attaching of process status to SCM.
> >> >> >> >
> >> >> >> > I really would like someone smarter than me to review the security
> >> >> >> > implications et al. of these changes before I apply them.
> >> >> >> >
> >> >> >> > Andy?  Maybe you have an opinion?
> >> >> >> >
> >> >> >>
> >> >> >> The degree to which I dislike this depends on what "procinfo" is.
> >> >> >>
> >> >> >> From the patch, it looks like procinfo includes cmdline.  In which
> >> >> >> case, NAK in almost the strongest possible terms.  (If it includes
> >> >> >> userspace addresses, then I'll upgrade that to the strongest possible
> >> >> >> terms.)  This is a giant information leak.  Imagine what happens when a
> >> >> >> privileged program gets one of these things as stdout.  Keep in mind
> >> >> >> that procfs has an option to hide pids that belong to other users.
> >> >> >>
> >> >> >> Even if procinfo were made relatively innocuous, this is just an
> >> >> >> extension of a bad interface.  If you all really want a way to
> >> >> >> efficiently pass kernel-verified information through a unix socket,
> >> >> >> then add something reasonable.  This means:
> >> >> >>
> >> >> >> 1. It needs to be opt-in, *per send*.  After all of the vulnerabilities
> >> >> >> that have happened due to write(2) capturing unexpected credentials of
> >> >> >> the caller, there's just no excuse for adding new examples of this.
> >> >> >> Yes, this will prevent you from getting a magic speed-up with legacy
> >> >> >> clients, but I've spent long enough battling this sh*t from a security
> >> >> >> and correctness POV to care.  Fix the clients.
> >> >> >>
> >> >> >> 2. It should be easily extensible, because people keep wanting to add
> >> >> >> new things here.
> >> >> >>
> >> >> >> Here's a proposal for how it could work:
> >> >> >>
> >> >> >> Senders can send SCM_VERIFIED_INFO.  The payload is a list of (type,
> >> >> >> flags, value) where type is the type of verified information and value
> >> >> >> is what the sender wants to send.
> >> >> >>
> >> >> >> Flags can include SCMVI_FLAG_MANDATORY: failure to send this attribute
> >> >> >> returns -EPERM.
> >> >> >> SCMVI_FLAG_AUTO: value must be blank; the kernel will fill it in.
> >> >> >> Any other flags: -EINVAL.
> >> >> >>
> >> >> >> This could be in CMSG format or in nlattr format.  Or it could be one
> >> >> >> cmsg per value (which might be easier).
> >> >> >>
> >> >> >> Receivers can set SO_PASS_VERIFIED_INFO.  If so, then they'll receive
> >> >> >> all of the sent values that have recognized types and pass
> >> >> >> verification.
> >> >> >>
> >> >> >> For stream sockets, presumably the sender would send an
> >> >> >> scm_verified_info using setsockopt and the receiver would grab it using
> >> >> >> getsockopt.
> >> >> >>
> >> >> >> Types could include:
> >> >> >>
> >> >> >> SCMVI_UID
> >> >> >> SCMVI_GID
> >> >> >> SCMVI_PID (racy, but still better than SCM_CREDENTIALS) SCMVI_LOGONUID
> >> >> >> (but only if CONFIG_AUDITSYSCALL, and someone needs to figure out wtf
> >> >> >> its semantics are and *document* it before I'd ack such a thing)
> >> >> >> SCMVI_CGROUP (sigh) SCMVI_AUDIT_SESSIONID (because sessionid is an
> >> >> >> awful name) etc.
> >> >> >>
> >> >> >> I *might* get around to implementing this, but don't expect anything
> >> >> >> soon -- my current kernel hacking bandwidth is well-occupied by
> >> >> >> seccomp.  But I'd be happy to review.
> >> >> >>
> >> >> >> --Andy
> >> >> >
> >> >> > In this patch the kernel sends information about the sender. In your proposal, the sender sends the information and the kernel maybe completes the missing data. Could you please explain why your solution is secure? Is the source or the range of information sent the security problem?
> >> >> >
> >> >>
> >> >> The problem is neither; it's the sending of information that's
> >> >> unexpected by the sender that's a problem.  Here are two concrete
> >> >> issues:
> >> >>
> >> >> 1. Information leaks.  Currently, sending on a UNIX socket reveals
> >> >> your uid, gid, and pid.  I would argue that that is already a mistake,
> >> >> but it's well-enshrined in the API.  But imagine if sending on a UNIX
> >> >> socket suddenly started revealing, say, a few bytes of sender memory
> >> >> -- this would have huge security implications.  This code doesn't do
> >> >> that, but it's not clear to me that revealing cmdline or random bits
> >> >> of process status is much better.
> >> >
> >> > The current patch doesn't reveal any new information about process that
> >> > is currently not revealed by procfs already by default and if necessary
> >> > we can add a procfs (or sysfs) entry for disabling SCM_PROCINFO feature
> >> > completely.
> >>
> >> Ugh.  We should cautious by default, not the other way around.  Also,
> >> if you add a sysctl like that, it'll be worthless because I'm sure
> >> it'll break systemd in a year.
> >
> > How is the disabling of the new option different from disabling current
> > procfs support?  Isn't the option to disable it useless because it can
> > break systemd?
> >
> > Also SCM_PROCINFO feature is completely optional for systemd.  When it is
> > not available systemd fails back to the old (slower) way of obtaining
> > the needed info using procfs.  Unless systemd wants to drop support for
> > older kernels there should be no problem with supporting procfs way.
> >
> >> >> 2. Inadvertent assertions of authority.  In Unix (and most, but not
> >> >> all, other OSes), for better or for worse, many APIs implicitly use
> >> >> the caller's credentials.  For the most part, these are
> >> >> well-understood, and the caller intends to use the credential.  For
> >> >> example, open(2) is expected to use euid/egid (or fsuid/fsgid) to
> >> >> check access.  bind(2) checks capabilities to determine whether
> >> >> binding low-numbered ports is okay.  write(2) *does not check* the
> >> >> caller's authority.  (Except for SCM_CREDENTIALS, which I would argue
> >> >> is a mistake.)  Because everyone knows that write(2) does not use the
> >> >> caller's authority in a potentially dangerous way, no one takes any
> >> >> precautions against it.  For example, basically every setuid program
> >> >> on anyone's system will happily write untrusted data to stdout or
> >> >> stderr.
> >> >>
> >> >> The problem here is that there have been multiple vulnerabilities that
> >> >> result from the kernel assuming that a program that calls write(2)
> >> >> actually *intends* to use its authority.  For example, at one point,
> >> >> writes to /proc/PID/uid_map checked capabilities at write(2) time.
> >> >> That was a root hole.  There are probably real root holes due to the
> >> >> same effect on UNIX datagram sockets.
> >> >
> >> > From what I understand about the current patch it doesn't change
> >> > anything from the application POV and it doesn't cause write(2) to
> >> > send any additional information (all SCM_PROCINFO data on socket
> >> > read comes from kernel).
> >>
> >> This one isn't about revealing information.  It's about the recipient
> >> trusting that information.
> >
> > Then why this should be a problem?  All information obtained through
> > SCM_PROCINFO comes from the kernel not the application itself.
> 
> So what?  The information is correct in the sense of correctly
> identifying who called write(2).  The problem is that any code (user
> or kernel) that thinks it cares who called write(2) is *wrong*.  Full
> stop.  That code cares about who intended the message to be send,
> which may or not be the same entity that called write(2).

Do you mean that the process doing write(2) can be different from the one
intending it?  How is that a problem in our case?  We only care about info
about entity that actually called write(2).  We completely don't care about
the intent in the kernel and any code doing any authorization based on
the obtained information in user-space would be seriously wrong because
the information is stale once it leaves kernel and has only historic value.
Am I missing something?

> >> >> If senders have to explicitly ask to use credentials, then this type
> >> >> of attack can't happen.
> >> >
> >> > Could you also please be more specific and tell what kind of attacks
> >> > exactly is made possible by the current patch?
> >>
> >> CVE-2013-1959 and CVE-2014-0181 were both examples of this type of attack.
> >
> > I was asking about what specific problems do you seen with the actual
> > SCM_PROCINFO patches.  Given CVEs are for problems which are related to
> > unauthorized _sending_ of information to the kernel.  The current patches
> > doesn't allow sending of any additional information to the kernel.
> 
> Userspace will be just as vulnerable.  Some day I'll go exploit the
> same thing to break udev or dbus or something like that.
> 
> I have a 10% written SCM_IDENTITY thing.  Maybe I'll try to finish it.

That is good to hear. :)

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics
