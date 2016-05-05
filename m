From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 03/14] udp: Don't set skb->encapsulation with RCO
Date: Thu, 5 May 2016 08:44:09 -0700
Message-ID: <CAKgT0Uf0Xmjx2=wX=rD8zthm4S83R_ZHi0+YDQfeqkjxGDjgxw@mail.gmail.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	<1462410164-1953217-4-git-send-email-tom@herbertland.com>
	<CAKgT0UeUTpuENPxOr7APFZ1YrVkCha=10qk=hh67eNb1u3Pexg@mail.gmail.com>
	<CALx6S37tNu-F3EU1ES37FCzm6-0TCfuFNig1==hnCa08A3FrQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37835 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbcEEPoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 11:44:10 -0400
Received: by mail-ig0-f169.google.com with SMTP id s8so17271422ign.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 08:44:10 -0700 (PDT)
In-Reply-To: <CALx6S37tNu-F3EU1ES37FCzm6-0TCfuFNig1==hnCa08A3FrQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 5, 2016 at 8:38 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Wed, May 4, 2016 at 7:42 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Wed, May 4, 2016 at 6:02 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> When RCO is in effect we want to ensure that the outer checksum is
>>> properly offloaded. Don't set skb->encapsulation in this case to
>>> ensure that checksum offload is later considered for hw_features
>>> instead of hw_enc_features.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>  net/ipv4/udp_offload.c | 10 ++++++----
>>>  1 file changed, 6 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>>> index b556ef6..4eedec6 100644
>>> --- a/net/ipv4/udp_offload.c
>>> +++ b/net/ipv4/udp_offload.c
>>> @@ -94,11 +94,13 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>>         do {
>>>                 unsigned int len;
>>>
>>> -               if (remcsum)
>>> +               if (remcsum) {
>>>                         skb->ip_summed = CHECKSUM_NONE;
>>> -
>>> -               /* Set up inner headers if we are offloading inner checksum */
>>> -               if (skb->ip_summed == CHECKSUM_PARTIAL) {
>>> +                       skb->encapsulation = 0;
>>> +               } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
>>> +                       /* Set up inner headers if we are offloading inner
>>> +                        * checksum
>>> +                        */
>>>                         skb_reset_inner_headers(skb);
>>>                         skb->encapsulation = 1;
>>>                 }
>>
>>
>> Why are you wasting cycles clearing a value that should have already
>> been cleared?
>>
>> We set skb->encapsulation to 0 for the incoming skb before we segment
>> it.  As such all of the segments we get should also not have it set.
>> It seems like you are just wasting cycles writing it again even though
>> it isn't written.
>>
> I believe this is needed because skb->encapsulation could have been
> set at a lower inner GRO, like if we were encapsulating GRE in UDP...

That cannot happen.  The GRE header processing is completely skipped
as we use the inner_mac_header to determine the next header to jump
to.  The L3 types use encap_level and we reset that as well so there
should be no risk of skb->encapsulation being set for a remote
checksum offloaded frame.

- Alex
