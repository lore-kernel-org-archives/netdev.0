From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 5/6] bridge: new function to pack vlans using both
 IFLA_BRIDGE_VLAN_INFO and IFLA_BRIDGE_VLAN_RANGE_INFO
Date: Tue, 30 Dec 2014 00:04:05 -0800
Message-ID: <CAE4R7bAG2xdKDwXfFS=r4Vyk7hBF6dwRwfKVm0cSM2fTM0OHUw@mail.gmail.com>
References: <1419887132-7084-6-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bC63CpvpAuakFvEtEJvOsowjP40q1cs2eh0R=bf-F6w=Q@mail.gmail.com>
	<54A238BD.7050707@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson kok <wkok@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36732 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbaL3IEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 03:04:07 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so23612577wiv.14
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 00:04:05 -0800 (PST)
In-Reply-To: <54A238BD.7050707@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 9:31 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 12/29/14, 3:25 PM, Scott Feldman wrote:
>>
>> On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch adds new function to compress vlans into ranges.
>>> Vlans are compressed into ranges only if the fill request is called with
>>> RTEXT_FILTER_BRVLAN_COMPRESSED in filtermask.
>>>
>>> Old vlan packing code is moved to a new function and continues to be
>>> called when filter_mask is RTEXT_FILTER_BRVLAN
>>>
>>> Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>>   net/bridge/br_netlink.c |  157
>>> +++++++++++++++++++++++++++++++++++++++++------
>>>   1 file changed, 137 insertions(+), 20 deletions(-)
>>>
>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>> index 4c47ba0..16bdd5a 100644
>>> --- a/net/bridge/br_netlink.c
>>> +++ b/net/bridge/br_netlink.c
>>> @@ -67,6 +67,133 @@ static int br_port_fill_attrs(struct sk_buff *skb,
>>>          return 0;
>>>   }
>>>
>>> +static int br_fill_ifvlaninfo_bitmap(struct sk_buff *skb,
>>> +                                    const unsigned long *vlan_bmp, u16
>>> flags)
>>> +{
>>> +       struct bridge_vlan_range_info vinfo_range;
>>> +       struct bridge_vlan_info vinfo;
>>> +       u16 vid, start = 0, end = 0;
>>
>> One per line?
>
> ack
>
>>> +       u16 pvid;
>>
>> Aren't you getting an "unused" compile warning on this ^^^?
>
> will double check..
>
>>> +
>>> +       /* handle the untagged */
>>
>> This comment ^^^ doesn't make sense here.
>>
>>> +       for_each_set_bit(vid, vlan_bmp, VLAN_N_VID) {
>>> +               if (start == 0) {
>>> +                       start = vid;
>>> +                       end = vid;
>>> +               }
>>> +               if ((vid - end) > 1) {
>>> +                       memset(&vinfo_range, 0, sizeof(vinfo_range));
>>> +                       vinfo_range.flags |= flags;
>>> +                       vinfo_range.vid = start;
>>> +                       vinfo_range.vid_end = end;
>>> +                       if (nla_put(skb, IFLA_BRIDGE_VLAN_RANGE_INFO,
>>> +                                   sizeof(vinfo_range), &vinfo_range))
>>> +                               goto nla_put_failure;
>>> +                       start = vid;
>>> +                       end = vid;
>>> +               } else {
>>> +                       end = vid;
>>> +               }
>>> +       }
>>
>> What happens with this set {1-10, 12, 20-25, 30}?  On vid 12, will
>> that put a VLAN_RANGE_INFO with start=end=12?  Seems strange to use
>> RANGE_INFO for single vlan.
>>
>> Can the algorithm be simplified?  Maybe there are other examples in
>> the kernel of finding ranges/singles from a bitmap we could borrow
>> code from?
>
> let me see...
>
>>> +       if (start != 0 && end != 0) {
>>> +               if (start != end) {
>>> +                       memset(&vinfo_range, 0, sizeof(vinfo_range));
>>> +                       vinfo_range.flags |= flags;
>>> +                       vinfo_range.vid = start;
>>> +                       vinfo_range.vid_end = end;
>>> +                       if (nla_put(skb, IFLA_BRIDGE_VLAN_RANGE_INFO,
>>> +                                   sizeof(vinfo_range), &vinfo_range))
>>> +                               goto nla_put_failure;
>>> +               } else {
>>> +                       memset(&vinfo, 0, sizeof(vinfo));
>>> +                       vinfo.flags |= flags;
>>> +                       vinfo.vid = start;
>>> +                       if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
>>> +                                   sizeof(vinfo), &vinfo))
>>> +                               goto nla_put_failure;
>>
>> How many IFLA_BRIDGE_VLAN_INFOs can you fit into skb?   It seems the
>> worst case is you'll have 4094/2 = 2047 VLAN_INFOs if using all
>> even-numbered vids, for example.  Will that fit?  I guess the original
>> code had the same concern...wonder if anyone checked this worst-case?
>
>
> I will check this again. Remember doing worst case tests for setlinks. will
> get back with some worst cases tests in the next submission.
>>
>>
>>> +               }
>>> +       }
>>> +
>>> +nla_put_failure:
>>> +       return -EMSGSIZE;
>>> +}
>>> +
>>> +static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
>>> +                                        const struct net_port_vlans *pv)
>>> +{
>>> +       unsigned long vlan_bmp_copy[BR_VLAN_BITMAP_LEN];
>>> +       unsigned long untagged_bmp_copy[BR_VLAN_BITMAP_LEN];
>>
>> Lots of automatic space on the stack...can you use dynamic mem
>> (kzalloc) for these?
>
> Let me see. Or make it a static global ?

Static global would be bad news for multiple threads doing a vlan fill.
