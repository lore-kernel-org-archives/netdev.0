From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Thu, 24 Mar 2016 11:43:45 -0700
Message-ID: <CAKgT0UeW7A6cMRHm8_nEX=op_VAK5wcoYYRTNQVmMQWe02HdfA@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<56F17A13.8090701@solarflare.com>
	<CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
	<56F19FAA.3090005@solarflare.com>
	<CAKgT0UcAuOrBTcmj1ue8mK=j4dCqr-0bydHhRb+ghS1cZaUqrw@mail.gmail.com>
	<56F2C3F8.8070308@solarflare.com>
	<CAKgT0Uei6YrWRPaov3LAFrOima=o4+V4mQcFih-rHZ+w-x4hwA@mail.gmail.com>
	<56F30523.8080108@solarflare.com>
	<CAKgT0UfgKwSRjMwRHbDNawAyJ3jvz937j1jxGvJWRaD39bSSeQ@mail.gmail.com>
	<56F3200C.20200@solarflare.com>
	<CAKgT0UfyOc4tYhZq7CC5G4S5HdzPW3iSifdcwe20Vxsqu8C3LQ@mail.gmail.com>
	<56F41FFF.7000508@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36644 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbcCXSnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:43:46 -0400
Received: by mail-ig0-f169.google.com with SMTP id nk17so117983689igb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:43:46 -0700 (PDT)
In-Reply-To: <56F41FFF.7000508@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 10:12 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 23/03/16 23:15, Alexander Duyck wrote:
>> Right, but the problem becomes how do you identify what tunnel wants
>> what.  So for example we could theoretically have a UDP tunnel in a
>> UDP with checksum.  How would we tell which one want to have the
>> checksum set and which one doesn't?  The fact is we cannot.

> I think we can still handle that, assuming the device is only touching the
> innermost checksum (i.e. it's obeying csum_start/offset).  We don't need
> flags to tell us what to fill in in GSO, we can work it all out:
> Make the series of per-protocol callbacks for GSO partial run inner-
> outwards, by using recursion at the head.  Make each return a csum_edit
> value.  Then for example:
> For IPv4 header, our checksum covers only our header, so we fold any edits
> into our own checksum, and pass csum_edit through unchanged.

Right. IPv4 is easy because it is a localized checksum that is always present.

> For UDP header, we look to see if the current checksum field is zero.  If
> so, we leave it as zero, fold our edits into csum_edit and return the
> result.  Otherwise, we fold our edits and csum_edit into our checksum
> field, and return zero.

This would require changing how we handle partial checksums so that in
the case of UDP we don't allow 0 as a valid value.  Currently we do.
It isn't till we get to the final checksum that we take care of the
bit flip in the case of 0.

> For GRE, we look at the checksumming bit in the GRE header, and behave
> similarly to UDP.
> Etcetera...

Right.  In the case of GRE we at least have a flag we could check.

> This should even be a worthwhile simplification of the non-nested case,
> because (if I understand correctly) it means GSO partial doesn't need the
> various gso_type flags we already have to specify tunnel type and checksum
> status; it just figures it out as it goes.

Yes, but doing packet inspection can get to be expensive as we crawl
through the headers.  In addition it gets into the whole software
versus hardware offloads thing.

> If your device is touching other checksums as well, then of course you need
> to figure that out in your driver so you can cancel it out.  But the device
> will only fiddle with the headers you tell it about (in your case I think
> that's outermost L3), not any others in the middle.  So it should still all
> work, without the driver having to know about the nesting.
>
>> You are
>> looking too far ahead.  We haven't gotten to tunnel in tunnel yet.

> IMHO, if our offloads are truly generic, tunnel in tunnel should be low-
> hanging fruit.  (In principle, "VxLAN + Ethernet + IP + GRE" is just
> another encapsulation header, albeit a rather long one).  Therefore, if
> it _isn't_ low-hanging fruit for us, we should suspect that we aren't
> generic.  So even if it's not currently useful in itself, it's still a
> convenient canary.

Honestly I think tunnel-in-tunnel is not going to be doable due to the
fact that we would have to increment multiple layers of IP ID in order
to do it correctly.  The more I look into the whole DF on outer
headers thing the more I see RFCs such as RFC 2784 that say not to do
it unless you want to implement PMTU discovery, and PMTU discovery is
inherently flawed since it would require ICMP messages to be passed
which may be filtered out by firewalls.

On top of that it occurred to me that GRE cannot be screened in GRO
for the outer-IP-ID check.  Basically what can happen is on devices
that don't parse inner headers for GRE we can end up with two TCP
flows from the same tunnel essentially stomping on each other and
causing one another to get evicted for having an outer IP-ID that
doesn't match up with the expected value.

- Alex
