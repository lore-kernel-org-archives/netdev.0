From: Elad Nachman <EladN@gilat.com>
Subject: RE: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus
 syscall endless loop
Date: Tue, 17 Jan 2017 18:15:19 +0000
Message-ID: <AM5PR0701MB1873F82D61AF17A09F2B0E26A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
References: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
 <20170117.125748.122599514616047216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0060.outbound.protection.outlook.com ([104.47.0.60]:29856
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751095AbdAQSPW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 13:15:22 -0500
In-Reply-To: <20170117.125748.122599514616047216.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any thought about limiting the amount of busy polling?
Say if more than X polls are done within a jiffy, then at least for preempt=
able kernels you can sleep for a jiffy inside the syscall to yield the CPU =
for a while?

Thanks,

Elad.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: =E9=E5=ED =E2 17 =E9=F0=E5=E0=F8 2017 19:58
To: Elad Nachman <EladN@gilat.com>
Cc: netdev@vger.kernel.org
Subject: Re: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus=
 syscall endless loop

From: Elad Nachman <EladN@gilat.com>
Date: Tue, 17 Jan 2017 17:39:03 +0000

> What's more odd about this is that it's very unusual and strange for a
> kernel function to invoke the restart mechanism because a lock is
> being held - the point of the restart mechanism is to allow userspace
> signal handlers to run, so it should only be used when there's a
> signal pending. I think this is a hack in the IPv6 code to work around
> some other issue.

It's not unusal at all, if you actually grep for this under net/ you will s=
ee that it is in fact a common code pattern.

It prevents deadlocks because the sysfs and other nodes that we are operati=
ng with can be unregistered by other threads of control holding the RTNL mu=
tex.  If we don't break out, we won't release our reference and therefore t=
he RTNL mutex holding entity cannot make forward progress.

This behavior is therefore very much intentional.
IMPORTANT - This email and any attachments is intended for the above named =
addressee(s), and may contain information which is confidential or privileg=
ed. If you are not the intended recipient, please inform the sender immedia=
tely and delete this email: you should not copy or use this e-mail for any =
purpose nor disclose its contents to any person.
