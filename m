From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: MLD maturity in kernel version 2.6.32.60
Date: Tue, 19 Nov 2013 08:29:04 +0100
Message-ID: <528B1340.2050807@redhat.com>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16> <20131118221850.GO16541@order.stressinduktion.org> <528AACF4.1090302@redhat.com> <528B0105.1080101@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: simon-schneider@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab3KSH3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 02:29:15 -0500
In-Reply-To: <528B0105.1080101@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2013 07:11 AM, Simon Schneider wrote:
> First of all, many thanks for your quick replies.
>
> Unfortunately, we're only part of a big project, so decision about the kernel version is not really in our hands.
>
> I.e. we're pretty much fixed on 2.6.32.60.
>
> I had a look at the information about Daniel's patches and I also searched CHANGE LOGs for MLD related stuff.
> But I didn't find patches/fixes that seem to address the very basic issues we have seen.

So what's missing in 3.13? Can you elaborate on "very basic issues"?

> Would you say that even in 2.6.32.60:
> - with force_mld_version=0, MLDv2 with fallback to MLDv1 should basically work (apart from "details" like wrong timer calculation)
> - with force_mld_version=1, we should never see MLDv2 messages being generated?

 From the code in 3.10 and earlier (therefore also 2.6.32.60), it seems that even if
we'd be in v1 fallback, nothing prevents us to process a v2 message as we would do
normally at least in igmp6_event_query(), which is not correct as we apply knowledge
how to process a v2 message although we're in v1-only fallback mode.

We have the macro MLD_V1_SEEN(idev) in these versions, which results always to true,
but we shouldn't even process it further at this point in igmp6_event_query(). So,
again, I'd recommend to backport the patchset and its dependencies to your kernel,
or just try out the latest one first.

> best regards, Simon
>
>
> Am 19.11.2013 01:12, schrieb Daniel Borkmann:
>> On 11/18/2013 11:18 PM, Hannes Frederic Sowa wrote:
>>> On Mon, Nov 18, 2013 at 01:17:28PM +0100, Simon Schneider wrote:
>>>> in a development project, we started evaluating MLD functionality.
>>>>
>>>> Our development is based on kernel version 2.6.32.60.
>>>>
>>>> We noticed some pretty basic issues:
>>>>
>>>> - With force_mld_version set to 0 (we expect "MLDv2 with MLDv1 fallback"), we saw only MLDv2 messages, the fallback to MLDv1 didn't seem to work, when we sent MLDv1 messages to the unit.
>>>> - With force_mld_version set to 1 (we expect "MLDv1 only mode"), we also saw MLDv2 messages being generated.
>>>>
>>>> Can someone give a general statement about the MLD implementation maturity in kernel 2.6.32.60? Are there known bugs that would explain the above observations?
>>>>
>>>> We need to see whether it makes sense to put further effort in investigating/fixing any MLD related issue we see.
>>>>
>>>> If this is the wrong list to ask this kind of question, please point me to the correct one.
>>>
>>> It would be great if you could share test results with newer kernel with us.
>>
>> Indeed, please do so, thus in case something is still missing so that we can fix it.
>>
>>> Last time I checked we did correctly fallback to MDLv1 mode but it has been a
>>> while.
>>
>> Yes, the fallback timeout should work now.
>>
>>> If you come up with a specific patch from Daniel's series which fixes the
>>> issues you are seeing, we can think about including this to stable.
>>>
>>> There are still some issues in mld: we are currently a bit too noisy for my
>>> taste (e.g. on re-enabling interfaces). This is a big problem for large
>>> wireless networks e.g.
>>
>> There's also still one issue which I am hesitant to implement, as i) I don't
>> think it's overly useful, ii) nobody complained so far. :-)
>>
>> In RFC2710 (MLD v1 spec), it says:
>>
>> 3.7. Other fields
>>
>>    The length of a received MLD message is computed by taking the IPv6
>>    Payload Length value and subtracting the length of any IPv6 extension
>>    headers present between the IPv6 header and the MLD message. If that
>>    length is greater than 24 octets, that indicates that there are other
>>    fields present beyond the fields described above, perhaps belonging
>>    to a future backwards-compatible version of MLD.  An implementation
>>    of the version of MLD specified in this document MUST NOT send an MLD
>>    message longer than 24 octets and MUST ignore anything past the first
>>    24 octets of a received MLD message.  In all cases, the MLD checksum
>>    MUST be computed over the entire MLD message, not just the first 24
>>    octets.
>>
>> Then, RFC3810 which "updates" RFC2710 obviously has a bigger message length
>> than that. In igmp6_event_query(), we only check for len == MLD_V1_QUERY_LEN
>> and process MLD v1. Now, in case of MLD v1-only fallback, we MUST only
>> operate in v1 mode.
>>
>> Now, in case a v2 message comes in we could assume above statement "if
>> that length is greater than 24 octets, that indicates that there are other
>> fields present beyond the fields described above, perhaps belonging to a
>> future backwards-compatible version of MLD".
>>
>> But then on the other hand, we get completely wrong "Maximum Response Delay"
>> codes in the packet header as they are differently encoded in MLD v1 and MLD
>> v2 thus not really backwards compatible.
>
