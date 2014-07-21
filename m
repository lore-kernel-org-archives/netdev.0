From: Piotr Wilczek <p.wilczek@samsung.com>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Mon, 21 Jul 2014 14:59:54 +0200
Message-ID: <53CD0ECA.7000202@samsung.com>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com> <20140701.163153.30109595101601494.davem@davemloft.net> <CALCETrUQQTsGKyMYM7BLZjFGjy1h_ji0=6E-P53HgXfgmJOWzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	juho80.son@samsung.com, b.zolnierkie@samsung.com,
	jkaluza@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40111 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755209AbaGUNFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 09:05:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1X9DH5-0006BE-Hu
	for netdev@vger.kernel.org; Mon, 21 Jul 2014 15:05:03 +0200
Received: from 217-67-201-162.itsa.net.pl ([217.67.201.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:05:03 +0200
Received: from p.wilczek by 217-67-201-162.itsa.net.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:05:03 +0200
In-Reply-To: <CALCETrUQQTsGKyMYM7BLZjFGjy1h_ji0=6E-P53HgXfgmJOWzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 07/02/2014 01:52 AM, Andy Lutomirski wrote:
> On Tue, Jul 1, 2014 at 4:31 PM, David Miller <davem@davemloft.net> wrote:
>> From: Piotr Wilczek <p.wilczek@samsung.com>
>> Date: Thu, 26 Jun 2014 14:55:52 +0200
>>
>>> Server-like processes in many cases need credentials and other
>>> metadata of the peer, to decide if the calling process is allowed to
>>> request a specific action, or the server just wants to log away this
>>> type of information for auditing tasks.
>>>
>>> The current practice to retrieve such process metadata is to look that
>>> information up in procfs with the $PID received over SCM_CREDENTIALS.
>>> This is sufficient for long-running tasks, but introduces a race which
>>> cannot be worked around for short-living processes; the calling
>>> process and all the information in /proc/$PID/ is gone before the
>>> receiver of the socket message can look it up.
>>>
>>> Changes introduced in this patchset can also increase performance
>>> of such server-like processes, because current way of opening and
>>> parsing /proc/$PID/* files is much more expensive than receiving these
>>> metadata using SCM.
>>>
>>> As an example, this patch set improves systemd-journald performance
>>> by about 20%. Generally, performance improvement depends on how heavily
>>> procfs is read the calling process.
>>> http://comments.gmane.org/gmane.comp.sysutils.systemd.devel/19467
>>>
>>> This patch set is split in two patches:
>>> - the first adds library to retrive process information without
>>> dependency on procfs.
>>> - the second introduces a new SCM type called SCM_PROCINFO to optionally
>>> allow the direct attaching of process status to SCM.
>>
>> I really would like someone smarter than me to review the security
>> implications et al. of these changes before I apply them.
>>
>> Andy?  Maybe you have an opinion?
>>
>
> The degree to which I dislike this depends on what "procinfo" is.
>
>  From the patch, it looks like procinfo includes cmdline.  In which
> case, NAK in almost the strongest possible terms.  (If it includes
> userspace addresses, then I'll upgrade that to the strongest possible
> terms.)  This is a giant information leak.  Imagine what happens when
> a privileged program gets one of these things as stdout.  Keep in mind
> that procfs has an option to hide pids that belong to other users.
>
> Even if procinfo were made relatively innocuous, this is just an
> extension of a bad interface.  If you all really want a way to
> efficiently pass kernel-verified information through a unix socket,
> then add something reasonable.  This means:
>
> 1. It needs to be opt-in, *per send*.  After all of the
> vulnerabilities that have happened due to write(2) capturing
> unexpected credentials of the caller, there's just no excuse for
> adding new examples of this.  Yes, this will prevent you from getting
> a magic speed-up with legacy clients, but I've spent long enough
> battling this sh*t from a security and correctness POV to care.  Fix
> the clients.
>
> 2. It should be easily extensible, because people keep wanting to add
> new things here.
>
> Here's a proposal for how it could work:
>
> Senders can send SCM_VERIFIED_INFO.  The payload is a list of (type,
> flags, value) where type is the type of verified information and value
> is what the sender wants to send.
>
> Flags can include SCMVI_FLAG_MANDATORY: failure to send this attribute
> returns -EPERM.
> SCMVI_FLAG_AUTO: value must be blank; the kernel will fill it in.
> Any other flags: -EINVAL.
>
> This could be in CMSG format or in nlattr format.  Or it could be one
> cmsg per value (which might be easier).
>
> Receivers can set SO_PASS_VERIFIED_INFO.  If so, then they'll receive
> all of the sent values that have recognized types and pass
> verification.
>
> For stream sockets, presumably the sender would send an
> scm_verified_info using setsockopt and the receiver would grab it
> using getsockopt.
>
> Types could include:
>
> SCMVI_UID
> SCMVI_GID
> SCMVI_PID (racy, but still better than SCM_CREDENTIALS)
> SCMVI_LOGONUID (but only if CONFIG_AUDITSYSCALL, and someone needs to
> figure out wtf its semantics are and *document* it before I'd ack such
> a thing)
> SCMVI_CGROUP (sigh)
> SCMVI_AUDIT_SESSIONID (because sessionid is an awful name)
> etc.
>
> I *might* get around to implementing this, but don't expect anything
> soon -- my current kernel hacking bandwidth is well-occupied by
> seccomp.  But I'd be happy to review.
>
> --Andy
>

Thank you for comments. We do understand security issues of that patch. 
For other reasons, the patch is important for us. To speed things up, 
would you consider cooperation in implementing your SCM_IDENTITY?

Piotr
