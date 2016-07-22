From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: iproute2 mpls max labels
Date: Fri, 22 Jul 2016 14:20:31 -0500
Message-ID: <87r3alv5s0.fsf@x220.int.ebiederm.org>
References: <578A7BF0.2020107@nordu.net>
	<57911A26.3080203@cumulusnetworks.com>
	<8737n23goi.fsf@x220.int.ebiederm.org>
	<5791BA22.7050309@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Magnus Bergroth <bergroth@nordu.net>, netdev@vger.kernel.org,
	Robert Shearman <rshearma@brocade.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48701 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbcGVTdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 15:33:31 -0400
In-Reply-To: <5791BA22.7050309@cumulusnetworks.com> (Roopa Prabhu's message of
	"Thu, 21 Jul 2016 23:16:02 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> On 7/21/16, 1:00 PM, Eric W. Biederman wrote:
>> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>>
>>> On 7/16/16, 11:24 AM, Magnus Bergroth wrote:
>>>> Wanted to use more than the default maximum of 8 mpls labels. Max labels
>>>> seems to be hardcode to 8 in two places.
>>>>
>>>> --- iproute2-4.6.0/lib/utils.c    2016-05-18 20:56:02.000000000 +0200
>>>> +++ iproute2-4.6.0-bergroth/lib/utils.c    2016-07-16 20:12:10.714958071
>>>> +0200
>>>> @@ -476,7 +476,7 @@
>>>>          addr->bytelen = 4;
>>>>          addr->bitlen = 20;
>>>>          /* How many bytes do I need? */
>>>> -        for (i = 0; i < 8; i++) {
>>>> +        for (i = 0; i < MPLS_MAX_LABELS; i++) {
>>>>              if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
>>>>                  addr->bytelen = (i + 1)*4;
>>>>                  break;
>>>>
>>>>
>>>> --- iproute2-4.6.0/include/utils.h    2016-05-18 20:56:02.000000000 +0200
>>>> +++ iproute2-4.6.0-bergroth/include/utils.h    2016-07-15
>>>> 11:55:57.297681742 +0200
>>>> @@ -54,6 +54,9 @@
>>>>  #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
>>>>  #define PREV_ARG() do { argv--; argc++; } while(0)
>>>>
>>>> +/* Maximum number of labels the mpls helpers support */
>>>> +#define MPLS_MAX_LABELS 8
>>>> +
>>>>  typedef struct
>>>>  {
>>>>      __u16 flags;
>>>> @@ -61,7 +64,7 @@
>>>>      __s16 bitlen;
>>>>      /* These next two fields match rtvia */
>>>>      __u16 family;
>>>> -    __u32 data[8];
>>>> +    __u32 data[MPLS_MAX_LABELS];
>>>>  } inet_prefix;
>>>>
>> This structure is not MPLS specific so that is not appropriate to use
>> MPLS_MAX_LABELS when definiting the structure.  Likewise changing this
>> structure and limiting the changes to mpls parts of the code is not
>> appropriate.
>>
>>>>  #define PREFIXLEN_SPECIFIED 1
>>>> @@ -88,9 +91,6 @@
>>>>  # define AF_MPLS 28
>>>>  #endif
>>>>
>>>> -/* Maximum number of labels the mpls helpers support */
>>>> -#define MPLS_MAX_LABELS 8
>>>> -
>>>>  __u32 get_addr32(const char *name);
>>>>  int get_addr_1(inet_prefix *dst, const char *arg, int family);
>>>>  int get_prefix_1(inet_prefix *dst, char *arg, int family);
>>>>
>>>>
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
>> a) I just looked and the kernel netlink protocol does not have a limit.
>>    The kernel does have a limit but the netlink protocol does not  so
>>    there is no point in exporting a limit in a uapi header,  it will
>>    just be out of date and wrong.
> sure, if you have concerns about making it part of uapi, we can
> separately maintain the same limit in iproute2 and kernel.

The different tools already have different limits and it is not
a problem.  The important thing is for the userspace tool to have
the larger limit.

>> b) I can see in principle bumping up the kernels MAX_LABELS past two
>>    although I haven't heard those requests, or understand the use cases.
>>    I don't recall seeing any ducumentation on cases where it is
>>    desirable to push a lot of labels at once.  (Do hardware
>>    implementations support pushing a lot of labels at once?)
> I don't know of any use cases either. But i have received multiple requests
> on bumping the current limit of two
>>
>>    Bumping past 8 seems quite a lot.  That starts feeling like people
>>    trying to break other peoples mpls stacks.  That is asking for more
>>    packet space for labels than ipv6 uses for addresses and ipv6 is way
>>    oversized.  The commonly agreed wisdom is the world only needs 40 to
>>    48 bits to route on to reach the entire world.  
>>
>>    I can completely understand a few specialty labels going beyond what
>>    is needed for general purpose routing but pushing more that 8 at
>>    once seems huge.  Especially since you can recirculate packets if
>>    you really need to and push more labels that way.
>
> I don't think there is an ask for going more than 8. anything greater than
> current 2 is good.

Except the patch that got all of this started.

>>    Add to that for a software implementation we have these pesky things
>>    called cache lines.  I can see in the kernel pushing struct
>>    mpls_route towards the size of a full cacheline.  Today we are at 52
>>    bytes not counting the via adress.  With the via address we are at 56
>>    (ipv4), 58 (ethernet), and 60 (ipv6) bytes.  Which means in we have
>>    to make the kernel data structures smarter or we risk messing up the
>>    performance of the common case.
>>
>>    Also we do need some kind of limit in the kernel to protect against
>>    insane inputs.
>>    
>>    So while I can imagine there are reasonable cases for bumping up the
>>    maximum number of labels in the kernel I think we need to be smart if
>>    we ware going to do that.  Which probably means we will want a
>>    __mpls_nh_label helper function.
>>
> sure, yes, the current static label array works well for the common case
> of 2 labels. does it make sense for it to be configurable
> with the default being 2 and max something like 8 ?

We have two structures both with one byte holes:
struct mpls_route { /* next hop label forwarding entry */
	struct rcu_head		rt_rcu;
	u8			rt_protocol;
	u8			rt_payload_type;
	u8			rt_max_alen;
	unsigned int		rt_nhn;
	unsigned int		rt_nhn_alive;
	struct mpls_nh		rt_nh[0];
};

struct mpls_nh { /* next hop label forwarding entry */
	struct net_device __rcu *nh_dev;
	unsigned int		nh_flags;
	u32			nh_label[MAX_NEW_LABELS];
	u8			nh_labels;
	u8			nh_via_alen;
	u8			nh_via_table;
};

If we were to define them as:
struct mpls_route { /* next hop label forwarding entry */
	struct rcu_head		rt_rcu;
	u8			rt_protocol;
	u8			rt_payload_type;
	u8			rt_max_alen;
        u8			rt_max_labels;
	unsigned int		rt_nhn;
	unsigned int		rt_nhn_alive;
	struct mpls_nh		rt_nh[0];
};

struct mpls_nh { /* next hop label forwarding entry */
	struct net_device __rcu *nh_dev;
	unsigned int		nh_flags;
	u8			nh_labels;
	u8			nh_via_alen;
	u8			nh_via_table;
};

static 32 *__mpls_nh_labels(struct mpls_route *rt, struct mpls_nh *nh)
{
	u32 *nh0_labels = PTR_ALIGN((u32 *)&rt->rt_nh[rt->rt_nhn], sizeof(u32));
	int nh_index = nh - rt->rt_nh;

	return nh0_labels + rt->rt_max_labels * nh_index;
}

static u8 *__mpls_nh_via(struct mpls_route *rt, struct mpls_nh *nh)
{
	u8 *nh0_via = PTR_ALIGN((u8 *)(&rt->rt_nh[rt->rt_nhn] + (sizeof(u32) *rt->max_labels * rt->nhn)), VIA_ALEN_ALIGN);
	int nh_index = nh - rt->rt_nh;

	return nh0_via + rt->rt_max_alen * nh_index;
}

Ugh.  I just noticed we have a nasty 4 byte gap in the mpls_route by
having both rt_nhn and rt_nhn_alive in there.  As rt_nh[0] has pointer
alignment.

Anyway something like the above should allow us to remove the limit
of the number of labels from the implementation and still fit everything
in a cache line in the common case, as the change above doesn't take up
any extra space in struct mpls_route.

Then we just pick a reasonable maximum and set MAX_NEW_LABELS to that.
That will change struct mpls_route_config.  So we need a small enough
value that putting struct mpls_route_config continues to make sense.
I propose 8 for MAX_NEW_LABELS after such a change.

It looks pretty straighforward on the kernel side.

Eric
