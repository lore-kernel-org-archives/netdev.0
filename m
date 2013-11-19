From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: MLD maturity in kernel version 2.6.32.60
Date: Tue, 19 Nov 2013 01:12:36 +0100
Message-ID: <528AACF4.1090302@redhat.com>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16> <20131118221850.GO16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Schneider <simon-schneider@gmx.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752798Ab3KSAMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 19:12:48 -0500
In-Reply-To: <20131118221850.GO16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2013 11:18 PM, Hannes Frederic Sowa wrote:
> On Mon, Nov 18, 2013 at 01:17:28PM +0100, Simon Schneider wrote:
>> in a development project, we started evaluating MLD functionality.
>>
>> Our development is based on kernel version 2.6.32.60.
>>
>> We noticed some pretty basic issues:
>>
>> - With force_mld_version set to 0 (we expect "MLDv2 with MLDv1 fallback"), we saw only MLDv2 messages, the fallback to MLDv1 didn't seem to work, when we sent MLDv1 messages to the unit.
>> - With force_mld_version set to 1 (we expect "MLDv1 only mode"), we also saw MLDv2 messages being generated.
>>
>> Can someone give a general statement about the MLD implementation maturity in kernel 2.6.32.60? Are there known bugs that would explain the above observations?
>>
>> We need to see whether it makes sense to put further effort in investigating/fixing any MLD related issue we see.
>>
>> If this is the wrong list to ask this kind of question, please point me to the correct one.
>
> It would be great if you could share test results with newer kernel with us.

Indeed, please do so, thus in case something is still missing so that we can fix it.

> Last time I checked we did correctly fallback to MDLv1 mode but it has been a
> while.

Yes, the fallback timeout should work now.

> If you come up with a specific patch from Daniel's series which fixes the
> issues you are seeing, we can think about including this to stable.
>
> There are still some issues in mld: we are currently a bit too noisy for my
> taste (e.g. on re-enabling interfaces). This is a big problem for large
> wireless networks e.g.

There's also still one issue which I am hesitant to implement, as i) I don't
think it's overly useful, ii) nobody complained so far. :-)

In RFC2710 (MLD v1 spec), it says:

3.7. Other fields

    The length of a received MLD message is computed by taking the IPv6
    Payload Length value and subtracting the length of any IPv6 extension
    headers present between the IPv6 header and the MLD message.  If that
    length is greater than 24 octets, that indicates that there are other
    fields present beyond the fields described above, perhaps belonging
    to a future backwards-compatible version of MLD.  An implementation
    of the version of MLD specified in this document MUST NOT send an MLD
    message longer than 24 octets and MUST ignore anything past the first
    24 octets of a received MLD message.  In all cases, the MLD checksum
    MUST be computed over the entire MLD message, not just the first 24
    octets.

Then, RFC3810 which "updates" RFC2710 obviously has a bigger message length
than that. In igmp6_event_query(), we only check for len == MLD_V1_QUERY_LEN
and process MLD v1. Now, in case of MLD v1-only fallback, we MUST only
operate in v1 mode.

Now, in case a v2 message comes in we could assume above statement "if
that length is greater than 24 octets, that indicates that there are other
fields present beyond the fields described above, perhaps belonging to a
future backwards-compatible version of MLD".

But then on the other hand, we get completely wrong "Maximum Response Delay"
codes in the packet header as they are differently encoded in MLD v1 and MLD
v2 thus not really backwards compatible.
