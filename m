From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Aw: Re: MLD maturity in kernel version 2.6.32.60
Date: Fri, 6 Dec 2013 08:40:16 +0100 (CET)
Message-ID: <trinity-cb6e2f21-801a-4eaa-80f7-74348e998e46-1386315616016@3capp-gmx-bs22>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16>
 <20131118221850.GO16541@order.stressinduktion.org>
 <528AACF4.1090302@redhat.com> <528B0105.1080101@gmx.net>,
 <528B1340.2050807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: "Daniel Borkmann" <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:57712 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958Ab3LFHkR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 02:40:17 -0500
Received: from 3capp-gmx-bs22.server.lan ([172.19.170.74]) by
 mrigmx.server.lan (mrigmx002) with ESMTP (Nemesis) id
 0MC6kY-1Vg0Jc0aEi-008vqF for <netdev@vger.kernel.org>; Fri, 06 Dec 2013
 08:40:16 +0100
In-Reply-To: <528B1340.2050807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel and Hannes,
thanks for your help so far.
=C2=A0
We start with IPv6 now on a different product, which already uses kerne=
l version 3.8.4.
=C2=A0
Can we expect that the existing MLD patches are already integrated in t=
hat kernel?
=C2=A0
Or are there still major differences between that kernel and the latest=
 one, regarding MLD?
=C2=A0
I think we will be able to do some MLD testing on that product.
=C2=A0
best regards, Simon
=C2=A0

Gesendet:=C2=A0Dienstag, 19. November 2013 um 08:29 Uhr
Von:=C2=A0"Daniel Borkmann" <dborkman@redhat.com>
An:=C2=A0simon-schneider@gmx.net
Cc:=C2=A0"Hannes Frederic Sowa" <hannes@stressinduktion.org>, netdev@vg=
er.kernel.org
Betreff:=C2=A0Re: MLD maturity in kernel version 2.6.32.60
On 11/19/2013 07:11 AM, Simon Schneider wrote:
> First of all, many thanks for your quick replies.
>
> Unfortunately, we're only part of a big project, so decision about th=
e kernel version is not really in our hands.
>
> I.e. we're pretty much fixed on 2.6.32.60.
>
> I had a look at the information about Daniel's patches and I also sea=
rched CHANGE LOGs for MLD related stuff.
> But I didn't find patches/fixes that seem to address the very basic i=
ssues we have seen.

So what's missing in 3.13? Can you elaborate on "very basic issues"?

> Would you say that even in 2.6.32.60:
> - with force_mld_version=3D0, MLDv2 with fallback to MLDv1 should bas=
ically work (apart from "details" like wrong timer calculation)
> - with force_mld_version=3D1, we should never see MLDv2 messages bein=
g generated?

=46rom the code in 3.10 and earlier (therefore also 2.6.32.60), it seem=
s that even if
we'd be in v1 fallback, nothing prevents us to process a v2 message as =
we would do
normally at least in igmp6_event_query(), which is not correct as we ap=
ply knowledge
how to process a v2 message although we're in v1-only fallback mode.

We have the macro MLD_V1_SEEN(idev) in these versions, which results al=
ways to true,
but we shouldn't even process it further at this point in igmp6_event_q=
uery(). So,
again, I'd recommend to backport the patchset and its dependencies to y=
our kernel,
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
>>>> - With force_mld_version set to 0 (we expect "MLDv2 with MLDv1 fal=
lback"), we saw only MLDv2 messages, the fallback to MLDv1 didn't seem =
to work, when we sent MLDv1 messages to the unit.
>>>> - With force_mld_version set to 1 (we expect "MLDv1 only mode"), w=
e also saw MLDv2 messages being generated.
>>>>
>>>> Can someone give a general statement about the MLD implementation =
maturity in kernel 2.6.32.60? Are there known bugs that would explain t=
he above observations?
>>>>
>>>> We need to see whether it makes sense to put further effort in inv=
estigating/fixing any MLD related issue we see.
>>>>
>>>> If this is the wrong list to ask this kind of question, please poi=
nt me to the correct one.
>>>
>>> It would be great if you could share test results with newer kernel=
 with us.
>>
>> Indeed, please do so, thus in case something is still missing so tha=
t we can fix it.
>>
>>> Last time I checked we did correctly fallback to MDLv1 mode but it =
has been a
>>> while.
>>
>> Yes, the fallback timeout should work now.
>>
>>> If you come up with a specific patch from Daniel's series which fix=
es the
>>> issues you are seeing, we can think about including this to stable.
>>>
>>> There are still some issues in mld: we are currently a bit too nois=
y for my
>>> taste (e.g. on re-enabling interfaces). This is a big problem for l=
arge
>>> wireless networks e.g.
>>
>> There's also still one issue which I am hesitant to implement, as i)=
 I don't
>> think it's overly useful, ii) nobody complained so far. :-)
>>
>> In RFC2710 (MLD v1 spec), it says:
>>
>> 3.7. Other fields
>>
>> The length of a received MLD message is computed by taking the IPv6
>> Payload Length value and subtracting the length of any IPv6 extensio=
n
>> headers present between the IPv6 header and the MLD message. If that
>> length is greater than 24 octets, that indicates that there are othe=
r
>> fields present beyond the fields described above, perhaps belonging
>> to a future backwards-compatible version of MLD. An implementation
>> of the version of MLD specified in this document MUST NOT send an ML=
D
>> message longer than 24 octets and MUST ignore anything past the firs=
t
>> 24 octets of a received MLD message. In all cases, the MLD checksum
>> MUST be computed over the entire MLD message, not just the first 24
>> octets.
>>
>> Then, RFC3810 which "updates" RFC2710 obviously has a bigger message=
 length
>> than that. In igmp6_event_query(), we only check for len =3D=3D MLD_=
V1_QUERY_LEN
>> and process MLD v1. Now, in case of MLD v1-only fallback, we MUST on=
ly
>> operate in v1 mode.
>>
>> Now, in case a v2 message comes in we could assume above statement "=
if
>> that length is greater than 24 octets, that indicates that there are=
 other
>> fields present beyond the fields described above, perhaps belonging =
to a
>> future backwards-compatible version of MLD".
>>
>> But then on the other hand, we get completely wrong "Maximum Respons=
e Delay"
>> codes in the packet header as they are differently encoded in MLD v1=
 and MLD
>> v2 thus not really backwards compatible.
>
