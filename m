From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/6] bridge: add support to parse multiple vlan info attributes
 in IFLA_AF_SPEC
Date: Mon, 29 Dec 2014 21:25:35 -0800
Message-ID: <54A2374F.6050901@cumulusnetworks.com>
References: <1419887132-7084-2-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bAyWy83S-K_XtiRNJO2rZXtVpijPxqj_oq_sZqPKW-h-Q@mail.gmail.com> <54A1D157.1000002@cumulusnetworks.com> <CAE4R7bDiRd6WY7ry-vFCj2HgAFtxWznwJTX4vqxt_v5Q8LXdOg@mail.gmail.com> <CAE4R7bAHSNePcX3aAa72kYReC4c8fRKF+BzL1f-bdk-M_pLxUg@mail.gmail.com> <CAE4R7bC7pgH35pkduV0n3G0UpoXoAUeJzmLE8ucJAwONJB2BZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:64050 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbaL3FZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 00:25:38 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so18833491pad.41
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 21:25:37 -0800 (PST)
In-Reply-To: <CAE4R7bC7pgH35pkduV0n3G0UpoXoAUeJzmLE8ucJAwONJB2BZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/14, 4:26 PM, Scott Feldman wrote:
> On Mon, Dec 29, 2014 at 4:07 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>> On Mon, Dec 29, 2014 at 3:47 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>>> On Mon, Dec 29, 2014 at 2:10 PM, roopa <roopa@cumulusnetworks.com> wrote:
>>>> On 12/29/14, 1:40 PM, Scott Feldman wrote:
>>>>> On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
>>>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>>
>>>>>> This patch changes bridge IFLA_AF_SPEC netlink attribute parser to
>>>>>> look for more than one IFLA_BRIDGE_VLAN_INFO attribute. This allows
>>>>>> userspace to pack more than one vlan in the setlink msg.
>>>>>>
>>>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>> ---
>>>>>>    net/bridge/br_netlink.c |   18 +++++++++---------
>>>>>>    1 file changed, 9 insertions(+), 9 deletions(-)
>>>>>>
>>>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>>>>> index 9f5eb55..75971b1 100644
>>>>>> --- a/net/bridge/br_netlink.c
>>>>>> +++ b/net/bridge/br_netlink.c
>>>>>> @@ -230,18 +230,18 @@ static int br_afspec(struct net_bridge *br,
>>>>>>                        struct nlattr *af_spec,
>>>>>>                        int cmd)
>>>>>>    {
>>>>>> -       struct nlattr *tb[IFLA_BRIDGE_MAX+1];
>>>>>> +       struct bridge_vlan_info *vinfo;
>>>>>>           int err = 0;
>>>>>> +       struct nlattr *attr;
>>>>>> +       int err = 0;
>>>>>> +       int rem;
>>>>>> +       u16 vid;
>>>>>>
>>>>>> -       err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec,
>>>>>> ifla_br_policy);
>>>>> Removing this call orphans ifla_br_policy...should ifla_br_policy be
>>>>> removed?
>>>>
>>>> good question. Its a good place to see the type. In-fact userspace programs
>>>> also copy the same policy to parse netlink attributes. hmmm..
>>>> I would like to keep it if it does not throw a warning.
>>> I don't know what the policy (sorry, no pun intended) on leaving dead
>>> code.  I say remove it.
>> You know, not using the policy seems like a step backwards, and maybe
>> it suggests a problem with the attr packing.
>>
>> We had:
>>
>> ifla_br_policy
>>     IFLA_BRIDGE_FLAGS
>>     IFLA_BRIDGE_MODE
>>     IFLA_BRIDGE_VLAN_INFO
>>
>> This patch set makes it:
>>
>> ifla_br_policy
>>     IFLA_BRIDGE_FLAGS
>>     IFLA_BRIDGE_MODE
>>     IFLA_BRIDGE_VLAN_INFO
>>     IFLA_BRIDGE_VLAN_RANGE_INFO
>>
>> Which is fine, but now VLAN_INFO and VLAN_RANGE_INFO can be repeated.
>> I think you want some nesting to clarify:
>>
>> ifla_br_policy
>>     IFLA_BRIDGE_FLAGS
>>     IFLA_BRIDGE_MODE
>>     IFLA_BRIDGE_VLAN_INFO
>>     IFLA_BRIDGE_VLAN_LIST_INFO    // nested array of
>>         IFLA_BRIDGE_VLAN_INFO
>>         IFLA_BRIDGE_VLAN_RANGE_INFO
>>
>> Now you can keep the policy for the top-level parsing, and loop only
>> on the nested array VLAN_LIST_INFO.  Actually, now you can use just
>> RANGE_INFO in array and have:
>>
>> ifla_br_policy
>>     IFLA_BRIDGE_FLAGS
>>     IFLA_BRIDGE_MODE
>>     IFLA_BRIDGE_VLAN_INFO
>>     IFLA_BRIDGE_VLAN_LIST_INFO    // nested array of
>>         IFLA_BRIDGE_VLAN_RANGE_INFO
>>
>> And use VLAN_RANGE_INFO for both ranges of vids as well as single
>> vids.  That'll simplify your filling algo in patch 5.
> Hmmmm...do you even need VLAN_RANGE_INFO?  How about just using
> existing VLAN_INFO and add some more flags:
>
> #define BRIDGE_VLAN_INFO_RANGE_START    (1<<3)
> #define BRIDGE_VLAN_INFO_RANGE_END        (1<<4)
>
> Now you can have:
>
>     IFLA_BRIDGE_FLAGS
>     IFLA_BRIDGE_MODE
>     IFLA_BRIDGE_VLAN_INFO
>     IFLA_BRIDGE_VLAN_INFO_LIST    // nested array of
>         IFLA_BRIDGE_VLAN_INFO
>
> Don't set START or END for single vids in list.

ok. I was debating yesterday about introducing another nest. This looks 
good.
My only reason to not use existing IFLA_BRIDGE_VLAN_INFO was to make 
sure it works for existing users.
I see that in this case since IFLA_BRIDGE_VLAN_INFO_LIST is new, it will 
not affect existing users.

But, i cant use IFLA_BRIDGE_VLAN_INFO (ie an attribute in 
ifla_br_policy) under IFLA_BRIDGE_VLAN_INFO_LIST ?.

IFLA_BRIDGE_VLAN_INFO_LIST will have its own policy and its own attributes.

Which will make it look something like below ?

IFLA_BRIDGE_FLAGS
IFLA_BRIDGE_MODE
IFLA_BRIDGE_VLAN_INFO
IFLA_BRIDGE_VLAN_INFO_LIST    // nested array of
	IFLA_BRIDGE_VLAN_INFO_LIST_ENTRY


Thanks,
Roopa
