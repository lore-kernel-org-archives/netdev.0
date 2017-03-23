From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 23 Mar 2017 11:54:12 -0700
Message-ID: <D61353C1-3CA6-48D5-AAFB-BBD3E95E1A06@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost> <20170323162145.GB8192@localhost>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:56225 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932579AbdCWSyQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 14:54:16 -0400
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0ONA01E0072K7F00@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Thu, 23 Mar 2017 18:54:14 +0000 (GMT)
In-reply-to: <20170323162145.GB8192@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend as plain text for netdev]


> On Mar 23, 2017, at 09:21, Miroslav Lichvar <mlichvar@redhat.com> =
wrote:
>=20
> After becoming a bit more familiar with the code I don't think this is
> a good idea anymore :). I suspect there would be a noticeable
> performance impact if each timestamped packet could trigger reading of
> the current link speed. If the value had to be cached it would make
> more sense to do it in the application.


I am very surprised at this. The application caching approach requires =
the application retrieve the value via a system call. The system call =
overhead is huge in comparison to everything else. More importantly, the =
application cached value may be wrong. If the application takes a sample =
every 5 seconds, there are 5 seconds of timestamps that can be wildly =
wrong.

At the driver level, if the speed check is done on packet receive, =
retrieving the link speed is a single register read which is a small =
overhead compared with processing the timestamp. The alternative =
approach of caching still makes more sense in the driver rather than the =
application. The driver receives an interrupt when negotiation happens, =
and It=E2=80=99s trivial to cache the value at that point. And a cached =
value by the driver will always be correct. Implementing it in the =
driver also allows for hardware to provide the functionality where =
available. Yes, there is only one chip that provides this currently, but =
if there is sufficient demand others will appear. There is no way to =
take advantage of this functionality unless this is handled by the =
driver.

I think it makes a lot of sense to leave this to the driver developer.=
