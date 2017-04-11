From: Edward Cree <ecree@solarflare.com>
Subject: Re: RFC: Checksum offload and XDP
Date: Tue, 11 Apr 2017 18:13:37 +0100
Message-ID: <21cd2caf-56a8-a330-1260-a55ddf07d854@solarflare.com>
References: <CALx6S357=e3414sPBnW3ajzXfkvVBiGMChx+vgbf9snpe95-aQ@mail.gmail.com>
 <63f0f671-5b33-4895-355c-be6259b16341@solarflare.com>
 <CALx6S347tj_nA0i4naN9SWaGVm27SPid3c=_KJcfQnsYAuqxSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Alexei Starovoitov" <ast@kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from connect-us.pphosted.com ([67.231.154.164]:41582 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751444AbdDKRNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 13:13:49 -0400
In-Reply-To: <CALx6S347tj_nA0i4naN9SWaGVm27SPid3c=_KJcfQnsYAuqxSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/17 17:46, Tom Herbert wrote:
> On Tue, Apr 11, 2017 at 8:55 AM, Edward Cree <ecree@solarflare.com> wrote:
>> The counter-argument, of course, is that if the XDP program edits fields
>>  that are protected by an Internet checksum (which in practice usually
>>  means anything but the Ethernet header) and then fixes up the checksums
>>  itself, we will edit our diff value twice just to conclude that diff==0.
>>  And maybe we are willing to trust root with the ability to lie to the
>>  kernel about incoming packets' checksum_complete values.
>>
> Works for modifying IPv4 or when we are expressly doing a checksum
> neutral operation, but that doesn't cover the general case. Suppose we
> simply want to pop an IPv6 header in IPv6/IPv6 encpasulation (there is
> some push in IETF for expanded use of IPIP tunneling with IPv6 to deal
> with the inserting EH into a packet problem). In that case the bits
> being chucked won't sum to zero and they're probably not also the same
> so the trick for ILA won't work so we need something to rectify the
> checksum if we're doing XDP_PASS for instance.
Oh, I agree that if we don't do the rewriting we have to have some way
 for XDP to output a diff.  I agree with Daniel that a helper function
 seems the obvious way to get this information out.  My "counter-
 argument" was about "user does it" vs. "verifier does it".
> As far as trust is concerned I don't think that is a major issue. The
> XDP program can already modify the packet in arbitrary ways so if the
> checksum is messed up this likely results in unnecessarily dropping
> packets that actually a good checksum (as opposed to allowing packets
> with bad checksum to pass).
I wasn't thinking so much of trust in the security sense (I agree that's
 not much of an argument since XDP programs are privileged already), but
 rather as a reliability thing; it maybe being an easy thing for root to
 get wrong ("hey, this bit only edits Ethernet headers so I don't have
 to fix any checksums, job done.  Why is my network broken?")
So I think we'd have to assume that any program that _doesn't_ call the
 helper function has invalidated any checksum_complete value we had; if
 all the program's changes were balanced, it can call update_csum(0).
> Note that this only applies to
> checksum_complete, if we were to allow XDP program to return
> checksum_unnecessary for instance then it's more a leap of faith that
> things are always correct.
Speaking of checksum_unnecessary, it might still be useful for the
 verifier to tell us whether the program contains any writes, since if
 so any drivers using checksum_unnecessary will have to clear it when
 calling XDP or else do conversion to checksum_complete beforehand.  (We
 at sfc will probably take the latter path.)  But this can be elided if
 the XDP program is known not to do writes or header adjustments,
 potentially speeding things up for the pure drop case.
(Also we wouldn't require such a program to call update_csum for the
 checksum_complete case, of course.)

-Ed
