From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Tue, 8 Dec 2015 15:40:39 -0200
Message-ID: <20151208174039.GB22987@mrl.redhat.com>
References: <56631357.6020304@gmail.com>
 <CACT4Y+YCZO2rfYdO_ACPF1U0p3YyXYJGA_Bhdb8CP8pecLy7SA@mail.gmail.com>
 <20151207131524.GA22989@mrl.redhat.com>
 <CACT4Y+ZhRG-LCdEoF=WusYVUj8gnm16663GcgJ=ztu0QC6r0vg@mail.gmail.com>
 <20151207185218.GB22989@mrl.redhat.com>
 <5665DF20.9020904@gmail.com>
 <20151207195032.GA22987@mrl.redhat.com>
 <5665EE26.3000706@gmail.com>
 <5665F17B.5030908@gmail.com>
 <CACT4Y+ad0YGve+KB8wiv6f1+eHt9Ci19FGM0SMWQvJFSez+Rcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	linux-sctp@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbbLHRkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 12:40:43 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+ad0YGve+KB8wiv6f1+eHt9Ci19FGM0SMWQvJFSez+Rcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 06:30:51PM +0100, Dmitry Vyukov wrote:
> On Mon, Dec 7, 2015 at 9:52 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > Em 07-12-2015 18:37, Vlad Yasevich escreveu:
> >>
> >> On 12/07/2015 02:50 PM, Marcelo Ricardo Leitner wrote:
> >>>
> >>> On Mon, Dec 07, 2015 at 02:33:52PM -0500, Vlad Yasevich wrote:
> >>>>
> >>>> On 12/07/2015 01:52 PM, Marcelo Ricardo Leitner wrote:
> >>>>>
> >>>>> Vlad, I reviewed the places on which it returns SCTP_DISPOSITION_ABORT,
> >>>>> and if I didn't miss something in there all of them either issue
> >>>>> SCTP_CMD_ASSOC_FAILED or SCTP_CMD_INIT_FAILED before returning it, thus
> >>>>> delaying DELETE_TCB and with that the asoc free.
> >>>>
> >>>>
> >>>> They delay it from the perspective of the command interpreter since the
> >>>> command
> >>>> to delete the TCB happens a little later, but status code  is checked
> >>>> after all
> >>>> commands are processed and command processing doesn't change it.  So the
> >>>> 'status'
> >>>> code would still be SCTP_DISPOSITION_ABORT after DELETE_TCB command was
> >>>> processed.
> >>>> So, I think we may still have an use-after-free issue here.
> >>>
> >>>
> >>> Gotcha! That's pretty much it then. From that point of view now, there
> >>> shouldn't be a case that it returns _ABORT without freeing the asoc in
> >>> the same loop. (more below)
> >>>
> >>>>> There is one place,
> >>>>> though, that may not do it that way, it's sctp_sf_abort_violation(),
> >>>>> but
> >>>>> then that code only runs if asoc is already NULL by then.
> >>>>
> >>>>
> >>>> I don't believe so.  The violation state function can run with a
> >>>> non-NULL association
> >>>> if we are encountering protocol violations after the association is
> >>>> established.
> >>>
> >>>
> >>> Yup, that's correct. I just tried to reference one case on which it
> >>> would return _ABORT without issuing any of those _FAILEDs before doing
> >>> so (meaning the association could still be valid) but that in that case,
> >>> the asoc was already NULL.
> >>
> >>
> >> I think it is possible to hit the 'discard:' tag in that function while
> >> still
> >> having a valid association.  That happens when ABORT chunk is required to
> >> be
> >> authenticated.  This that case, instead of generating an ABORT and
> >> terminating the
> >> current association, we just drop the packet, but still report an _ABORT
> >> disposition code.
> >>
> >> This probably need to change if we are going to catch the _ABORT
> >> disposition and
> >> clear the asoc pointer.
> >
> >
> > Oups. Nice one. I'll switch it to SCTP_DISPOSITION_DISCARD if it hits that
> > if() then. Thanks Vlad.
> 
> 
> So I am waiting for a new patch, right?
> Can you please combine all changes into a single patch (as far as I
> understand the previous one must be applied on top of the first one)?

The patches were combined already, but this last pick by Vlad is just
not yet patched. It's not necessary for your testing and I didn't want
to interrupt it in case you were already testing it.

You can use my last patch here, from 2 emails ago, the one which
contains this line:
-       case SCTP_DISPOSITION_ABORT:

  Marcelo
