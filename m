From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next V7 2/2] openvswitch: 802.1ad: Flow handling,
 actions, and vlan parsing
Date: Tue, 5 May 2015 16:27:27 -0700
Message-ID: <CALnjE+oeqX+7Lkmkw0yvLNCeaoHZ5kQjbPthdxPhkvW=OS2zBA@mail.gmail.com>
References: <1430261059-7920-1-git-send-email-thomasfherbert@gmail.com>
	<1430261059-7920-3-git-send-email-thomasfherbert@gmail.com>
	<CALnjE+qtYW4JE5TT3WiOofe=Q+YkLEZ7e+MpJQYLs5f6wD3nvw@mail.gmail.com>
	<5548F210.3010808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, therbert@redhat.com,
	ccp@atcnet.net, Flavio Leitner <fbl@redhat.com>
To: Thomas F Herbert <thomasfherbert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:45893 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752666AbbEEX12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:27:28 -0400
Received: by mail-ig0-f178.google.com with SMTP id pi8so88230610igb.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 16:27:27 -0700 (PDT)
In-Reply-To: <5548F210.3010808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 9:38 AM, Thomas F Herbert
<thomasfherbert@gmail.com> wrote:
> On 4/29/15 9:27 PM, Pravin Shelar wrote:
>>
>> On Tue, Apr 28, 2015 at 3:44 PM, Thomas F Herbert
>> <thomasfherbert@gmail.com> wrote:
>>
>> +
>> +       if (likely(skb_vlan_tag_present(skb))) {
>> +
>> +               key->eth.tci = htons(skb->vlan_tci);
>> +
>> I think there is bug in existing OVS where it does not check
>> vlan_proto before populating the flow key. Can you send a separate
>> patch to fix this issue?.
>
> Pravin, I realized I needed to address this  comment in more detail. I would
> appreciate your and anybody
> else's thoughts on the following:
> 1. the newer if_vlan header in the upstream kernel has a function that
> probably should be used here and
> elsewhere when checking for tags, skb_vlan_tagged() which also checks
> skb->protocol field.
When we populate flow key, we need to check skb->vlan_proto if it is
8021Q. This bug fix should be targeted to net tree.

> 2.  What about the compat "stuff" in the linux datapath of openvswitch?
> Should any fix for this issue also be
> applied to the compat layer which has different semantics for vlans or
> should the compat layer be updated to
> be the same as the 3.19, 4.0 kernel semantics?
I think compat layer is fine. But if you find any issue you can send fix.

> 3.  In spite of my comment #2 above, I am not convinced that the generalized
> skb vlan functions in if_vlan.h are truly
> independent of hardware acceleration. I can see cases where the vlan headers
> in the payload of the skb are not
> checked. I am thinking a patch to the upstream kernel may also be necessary.

ok.

>>
>>
>>> +               /*
>>> +                * Case where upstream
>>> +                * processing has already stripped the outer vlan tag.
>>> +                */
>>> +               if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
>>> +
>>> +                       if (unlikely(skb->len < sizeof(struct
>>> qtag_prefix) +
>>> +                                       sizeof(__be16)))
>>> +                               return 0;
>>> +
>>
>> If this returns from here then it can match on flow with tci which
>> expect vlan_proto to be 8021Q but with vlan_proto equal to 8021AD.
>
> I did not fix this. This double checking has come up before when I submitted
> an earlier revision of this patch.
> The double checking done here is also used in the single tagged vlan code. I
> think that the consensus is that
> Open vSwitch wants to allow incomplete headers to allow user space
> processing to decide how to
> process incomplete vlan tags. For more discussion, see the following thread:
> http://openvswitch.org/pipermail/dev/2014-December/049984.html
>
When you return from error case you need to clear the key->eth.tci, so
that it does not match on wrong flow.
