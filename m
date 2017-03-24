From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Fri, 24 Mar 2017 10:17:51 -0700
Message-ID: <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost> <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com> <20170324094530.GE8192@localhost>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp002.me.com ([17.172.125.150]:38720 "EHLO
        st11p06im-asmtp002.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966927AbdCXRR7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:17:59 -0400
Received: from process-dkim-sign-daemon.st11p06im-asmtp002.me.com by
 st11p06im-asmtp002.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0ONB00P00WT3G000@st11p06im-asmtp002.me.com> for netdev@vger.kernel.org;
 Fri, 24 Mar 2017 17:17:55 +0000 (GMT)
In-reply-to: <20170324094530.GE8192@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 24, 2017, at 02:45, Miroslav Lichvar <mlichvar@redhat.com> =
wrote:
>=20
> On Thu, Mar 23, 2017 at 10:08:00AM -0700, Denny Page wrote:
>>> On Mar 23, 2017, at 09:21, Miroslav Lichvar <mlichvar@redhat.com> =
wrote:
>>>=20
>>> After becoming a bit more familiar with the code I don't think this =
is
>>> a good idea anymore :). I suspect there would be a noticeable
>>> performance impact if each timestamped packet could trigger reading =
of
>>> the current link speed. If the value had to be cached it would make
>>> more sense to do it in the application.
>>=20
>> I am very surprised at this. The application caching approach =
requires the application retrieve the value via a system call. The =
system call overhead is huge in comparison to everything else. More =
importantly, the application cached value may be wrong. If the =
application takes a sample every 5 seconds, there are 5 seconds of =
timestamps that can be wildly wrong.
>=20
> I'm just trying to be practical and minimize the performance impact
> and the amount of code that needs to be written, reviewed and
> maintained.
>=20
> How common is to have link speed changing in normal operation on LAN?

In my case, it=E2=80=99s currently every few minutes because I=E2=80=99m =
doing hw timestamp testing. :)

But this does speak to my point. If it=E2=80=99s cached by the =
application, the application has to check it regularly to minimize the =
possibility of bad timestamps. If the link speed doesn=E2=80=99t change, =
every call by the application is wasted overhead. If it=E2=80=99s cached =
by the driver, there is no waste, and the stamps are always correct.

I should have remembered this yesterday... I went and looked at my =
favorite driver, Intel's igb. Not only is the igb driver already caching =
link speed, it is also performing timestamp correction based on that =
link speed. It appears that all Intel drivers are caching link speed. I =
looked at a few other popular manufacturers, and it appears that caching =
link speed is common. The only one I quickly found that didn=E2=80=99t =
cache was realtek.

I believe that timestamp correction, whether it be speed based latency, =
header -> trailer, or whatever else might be needed later down the line, =
are properly done in the driver. It=E2=80=99s a lot for the application =
to try and figure out if it should or should not be doing corrections =
and what correction to apply. The driver knows.
