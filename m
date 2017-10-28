From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: intel i40e buggy driver question
Date: Fri, 27 Oct 2017 17:23:50 -0700
Message-ID: <CAKgT0Udz6iWi5pO2k8or1MEHxtUq9vgjYUkFjvzi2ta94qO=-Q@mail.gmail.com>
References: <3a5e66fb-8751-cce4-59de-b3915c01b5ac@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:50166 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdJ1AXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:23:51 -0400
Received: by mail-qt0-f182.google.com with SMTP id k31so10418368qta.6
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:23:51 -0700 (PDT)
In-Reply-To: <3a5e66fb-8751-cce4-59de-b3915c01b5ac@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 3:34 PM, Pawe=C5=82 Staszewski <pstaszewski@itcare.=
pl> wrote:
> Hi
>
>
>
>
> I have many problems with 40e driver
>
> memleaks , kernel panics , stack traces , tx hungx , tx timeouts and many
> many others :)
>
>
> But the main problem that can't be resolved in linux is resolved in freeb=
sd
>
> problem in freebsd with this:
>
> [2501243.181829] i40e 0000:01:00.1 eno2: VSI_seid 390, Hung TX queue 17,
> tx_pending_hw: 1, NTC:0x16b, HWB: 0x16b, NTU: 0x16c, TAIL: 0x16c
> [2501243.181835] i40e 0000:01:00.1 eno2: VSI_seid 390, Issuing force_wb f=
or
> TX queue 17, Interrupt Reg: 0x0
>
>
> Was solved by this:
>
>
> "
>
> change this piece in ixl_tso_detect_sparse() in ixl_txrx.c:
>
>             if (mss < 1) {
>                     if (num > IXL_SPARSE_CHAIN)
>                             return (true);
>                     num =3D (mss =3D=3D 0) ? 0 : 1;
>                     mss +=3D mp->m_pkthdr.tso_segsz;
>             }
>
> to
>
>             if (num > IXL_SPARSE_CHAIN)
>                     return (true);
>             if (mss < 1) {
>                     num =3D (mss =3D=3D 0) ? 0 : 1;
>                     mss +=3D mp->m_pkthdr.tso_segsz;
>             }
>
> Intel FreeBSD Team: This will definitely prevent MDDs on the buffers you
> sent me.
>
> "
>
>
> An I have a question - how to do the same in linux ? :)

The same fix is already there. All this is checking for is to make
certain we don't span too many descriptors. We added that fix close to
a year ago. Take a look at the following, it is the last fix in the
set for the same issue:
commit 841493a3f64395b60554afbcaa17f4350f90e764
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Tue Sep 6 18:05:04 2016 -0700

    i40e: Limit TX descriptor count in cases where frag size is greater tha=
n 16K

Like I told you we need to look into this. A Tx hang can have many
causes. It is just a common symptom.

The crashes you included is not Tx hangs. It is something else
entirely and is only reproduced on 4.12.X.

> Cause i have same problem in Linux with this i40e buggy driver:

No, this is not the same issue. This is the same symptom. This is the
equivalent of running to the doctor and demanding antibiotics because
someone has a cough and insisting it is pneumonia, when for all we
know it is the common cold or an allergy.

If you want help, my advice is to focus on one issue, document how you
get into that state completely, and don't try to throw everything and
the kitchen sink in with it. Once you have one trace you can stop
there as emailing daily with multiple copies of the same or similar
trace, or worse yet unrelated traces, doesn't help anything unless
that is specifically being asked for by the person doing the debug.

> More here:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D197325

Yes, we are aware of this bugzilla. We are still trying to sort the
contents at this point. Unfortunately it is difficult to sort out as
from what I can tell there are about 3 or 4 different issues and you
jump in-between them somewhat randomly and incoherently so it is hard
to sort out what is data for what issue.

> Thanks
> Pawel

I appreciate that you want this fixed, but emailing multiple times a
day with a trace but no background, or background and no trace, and
then injecting random unrelated questions doesn't help to clarify
anything. Essentially it is just trolling.

>From what I can tell you have 3 issues that I am aware of:

One is that with team driver running on top of the i40e ports you are
seeing a NETDEV WATCHDOG being triggered, and we don't know if it is a
regression or not as you stated you are seeing it on 4.11.X now with
the latest firmware, and the issue didn't previously occur with your
previous firmware so we are working to determine if this is a firmware
regression and what can be done to resolve it.

There is a second issue which is occurring on the latest kernels as a
result of the first issue in which the PF is failing to come back up
when the issue occurs. This one is being handled as a part of the
first issue for now.

The third issue is an issue with the Rx ring rx_bi value not being
NULL when the interface is being reset in response to the watchdog,
and that appears to only happen on something like 4.12 if I recall.
The issue appears to be already resolved in 4.13 so there is not much
need for us to investigate it unless we need to generate a back-port
for 4.12 stable.

Does that pretty much sum up everything you are seeing? Is it clear
what the status is of us looking into it? If so you don't need to send
any more traces or any more updates as we are aware of the issues. We
will update the bugzilla if we need more information, or if we have
additional information to provide to you.

Thanks.

- Alex
