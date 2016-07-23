From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: iproute2 mpls max labels
Date: Sat, 23 Jul 2016 16:03:21 -0700
Message-ID: <5793F7B9.5060603@cumulusnetworks.com>
References: <578A7BF0.2020107@nordu.net> <57911A26.3080203@cumulusnetworks.com> <8737n23goi.fsf@x220.int.ebiederm.org> <5791BA22.7050309@cumulusnetworks.com> <87r3alv5s0.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Magnus Bergroth <bergroth@nordu.net>, netdev@vger.kernel.org,
	Robert Shearman <rshearma@brocade.com>,
	olivier.dugeon@orange.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36628 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbcGWXDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 19:03:25 -0400
Received: by mail-pf0-f177.google.com with SMTP id h186so51986040pfg.3
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 16:03:24 -0700 (PDT)
In-Reply-To: <87r3alv5s0.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/16, 12:20 PM, Eric W. Biederman wrote:
> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>
>> On 7/21/16, 1:00 PM, Eric W. Biederman wrote:
>>> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>>>
>>>

[snip]
>>> I did not realize it is hardcoded to 8 in iproute2. Because kernel has a hard coded limit of
>>> 2.
>>> I think we need to fix it in a few places:
>>> a) we should move the kernel #define to a uapi header file which iproute2 can use
>>> b) there has been a general ask to bump the kernel MAX_LABELS from 2 and I don't see
>>> a problem with it yet. so, we could bump it to 8.
>>>
>>> Were you planning to post patches for one or both of the above ?.
>>>
>>> I can post them too. Let me know.
>>> a) I just looked and the kernel netlink protocol does not have a limit.
>>>    The kernel does have a limit but the netlink protocol does not  so
>>>    there is no point in exporting a limit in a uapi header,  it will
>>>    just be out of date and wrong.
>> sure, if you have concerns about making it part of uapi, we can
>> separately maintain the same limit in iproute2 and kernel.
> The different tools already have different limits and it is not
> a problem.  The important thing is for the userspace tool to have
> the larger limit.
>>> b) I can see in principle bumping up the kernels MAX_LABELS past two
>>>    although I haven't heard those requests, or understand the use cases.
>>>    I don't recall seeing any ducumentation on cases where it is
>>>    desirable to push a lot of labels at once.  (Do hardware
>>>    implementations support pushing a lot of labels at once?)
>> I don't know of any use cases either. But i have received multiple requests
>> on bumping the current limit of two
>>>    Bumping past 8 seems quite a lot.  That starts feeling like people
>>>    trying to break other peoples mpls stacks.  That is asking for more
>>>    packet space for labels than ipv6 uses for addresses and ipv6 is way
>>>    oversized.  The commonly agreed wisdom is the world only needs 40 to
>>>    48 bits to route on to reach the entire world.  
>>>
>>>    I can completely understand a few specialty labels going beyond what
>>>    is needed for general purpose routing but pushing more that 8 at
>>>    once seems huge.  Especially since you can recirculate packets if
>>>    you really need to and push more labels that way.
>> I don't think there is an ask for going more than 8. anything greater than
>> current 2 is good.
> Except the patch that got all of this started.

ok, missed that. yesterday I also received some info on a segment routing use-case
where there is an ongoing study which is currently leaning towards a max label stack
depth of 17.

>
>>>    Add to that for a software implementation we have these pesky things
>>>    called cache lines.  I can see in the kernel pushing struct
>>>    mpls_route towards the size of a full cacheline.  Today we are at 52
>>>    bytes not counting the via adress.  With the via address we are at 56
>>>    (ipv4), 58 (ethernet), and 60 (ipv6) bytes.  Which means in we have
>>>    to make the kernel data structures smarter or we risk messing up the
>>>    performance of the common case.
>>>
>>>    Also we do need some kind of limit in the kernel to protect against
>>>    insane inputs.
>>>    
>>>    So while I can imagine there are reasonable cases for bumping up the
>>>    maximum number of labels in the kernel I think we need to be smart if
>>>    we ware going to do that.  Which probably means we will want a
>>>    __mpls_nh_label helper function.
>>>
>> sure, yes, the current static label array works well for the common case
>> of 2 labels. does it make sense for it to be configurable
>> with the default being 2 and max something like 8 ?
> We have two structures both with one byte holes:
> struct mpls_route { /* next hop label forwarding entry */
> 	struct rcu_head		rt_rcu;
> 	u8			rt_protocol;
> 	u8			rt_payload_type;
> 	u8			rt_max_alen;
> 	unsigned int		rt_nhn;
> 	unsigned int		rt_nhn_alive;
> 	struct mpls_nh		rt_nh[0];
> };
>
> struct mpls_nh { /* next hop label forwarding entry */
> 	struct net_device __rcu *nh_dev;
> 	unsigned int		nh_flags;
> 	u32			nh_label[MAX_NEW_LABELS];
> 	u8			nh_labels;
> 	u8			nh_via_alen;
> 	u8			nh_via_table;
> };
>
> If we were to define them as:
> struct mpls_route { /* next hop label forwarding entry */
> 	struct rcu_head		rt_rcu;
> 	u8			rt_protocol;
> 	u8			rt_payload_type;
> 	u8			rt_max_alen;
>         u8			rt_max_labels;
> 	unsigned int		rt_nhn;
> 	unsigned int		rt_nhn_alive;
> 	struct mpls_nh		rt_nh[0];
> };
>
> struct mpls_nh { /* next hop label forwarding entry */
> 	struct net_device __rcu *nh_dev;
> 	unsigned int		nh_flags;
> 	u8			nh_labels;
> 	u8			nh_via_alen;
> 	u8			nh_via_table;
> };
>
> static 32 *__mpls_nh_labels(struct mpls_route *rt, struct mpls_nh *nh)
> {
> 	u32 *nh0_labels = PTR_ALIGN((u32 *)&rt->rt_nh[rt->rt_nhn], sizeof(u32));
> 	int nh_index = nh - rt->rt_nh;
>
> 	return nh0_labels + rt->rt_max_labels * nh_index;
> }
>
> static u8 *__mpls_nh_via(struct mpls_route *rt, struct mpls_nh *nh)
> {
> 	u8 *nh0_via = PTR_ALIGN((u8 *)(&rt->rt_nh[rt->rt_nhn] + (sizeof(u32) *rt->max_labels * rt->nhn)), VIA_ALEN_ALIGN);
> 	int nh_index = nh - rt->rt_nh;
>
> 	return nh0_via + rt->rt_max_alen * nh_index;
> }
>
> Ugh.  I just noticed we have a nasty 4 byte gap in the mpls_route by
> having both rt_nhn and rt_nhn_alive in there.  As rt_nh[0] has pointer
> alignment.
>
> Anyway something like the above should allow us to remove the limit
> of the number of labels from the implementation and still fit everything
> in a cache line in the common case, as the change above doesn't take up
> any extra space in struct mpls_route.
>
> Then we just pick a reasonable maximum and set MAX_NEW_LABELS to that.
> That will change struct mpls_route_config.  So we need a small enough
> value that putting struct mpls_route_config continues to make sense.
> I propose 8 for MAX_NEW_LABELS after such a change.
>
> It looks pretty straighforward on the kernel side.
I like it. It follows how via is handled today and I agree seems like the best way to
represent varying number of labels without affecting the common case.

thanks for the suggestion.
