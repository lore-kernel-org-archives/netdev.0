From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: iproute2 mpls max labels
Date: Thu, 21 Jul 2016 15:00:13 -0500
Message-ID: <8737n23goi.fsf@x220.int.ebiederm.org>
References: <578A7BF0.2020107@nordu.net>
	<57911A26.3080203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Magnus Bergroth <bergroth@nordu.net>, netdev@vger.kernel.org,
	Robert Shearman <rshearma@brocade.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35939 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbcGUUNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 16:13:18 -0400
In-Reply-To: <57911A26.3080203@cumulusnetworks.com> (Roopa Prabhu's message of
	"Thu, 21 Jul 2016 11:53:26 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> On 7/16/16, 11:24 AM, Magnus Bergroth wrote:
>> Wanted to use more than the default maximum of 8 mpls labels. Max labels
>> seems to be hardcode to 8 in two places.
>>
>> --- iproute2-4.6.0/lib/utils.c    2016-05-18 20:56:02.000000000 +0200
>> +++ iproute2-4.6.0-bergroth/lib/utils.c    2016-07-16 20:12:10.714958071
>> +0200
>> @@ -476,7 +476,7 @@
>>          addr->bytelen = 4;
>>          addr->bitlen = 20;
>>          /* How many bytes do I need? */
>> -        for (i = 0; i < 8; i++) {
>> +        for (i = 0; i < MPLS_MAX_LABELS; i++) {
>>              if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
>>                  addr->bytelen = (i + 1)*4;
>>                  break;
>>
>>
>> --- iproute2-4.6.0/include/utils.h    2016-05-18 20:56:02.000000000 +0200
>> +++ iproute2-4.6.0-bergroth/include/utils.h    2016-07-15
>> 11:55:57.297681742 +0200
>> @@ -54,6 +54,9 @@
>>  #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
>>  #define PREV_ARG() do { argv--; argc++; } while(0)
>>
>> +/* Maximum number of labels the mpls helpers support */
>> +#define MPLS_MAX_LABELS 8
>> +
>>  typedef struct
>>  {
>>      __u16 flags;
>> @@ -61,7 +64,7 @@
>>      __s16 bitlen;
>>      /* These next two fields match rtvia */
>>      __u16 family;
>> -    __u32 data[8];
>> +    __u32 data[MPLS_MAX_LABELS];
>>  } inet_prefix;
>>

This structure is not MPLS specific so that is not appropriate to use
MPLS_MAX_LABELS when definiting the structure.  Likewise changing this
structure and limiting the changes to mpls parts of the code is not
appropriate.

>>  #define PREFIXLEN_SPECIFIED 1
>> @@ -88,9 +91,6 @@
>>  # define AF_MPLS 28
>>  #endif
>>
>> -/* Maximum number of labels the mpls helpers support */
>> -#define MPLS_MAX_LABELS 8
>> -
>>  __u32 get_addr32(const char *name);
>>  int get_addr_1(inet_prefix *dst, const char *arg, int family);
>>  int get_prefix_1(inet_prefix *dst, char *arg, int family);
>>
>>
> I did not realize it is hardcoded to 8 in iproute2. Because kernel has a hard coded limit of
> 2.
> I think we need to fix it in a few places:
> a) we should move the kernel #define to a uapi header file which iproute2 can use
> b) there has been a general ask to bump the kernel MAX_LABELS from 2 and I don't see
> a problem with it yet. so, we could bump it to 8.
>
> Were you planning to post patches for one or both of the above ?.
>
> I can post them too. Let me know.

a) I just looked and the kernel netlink protocol does not have a limit.
   The kernel does have a limit but the netlink protocol does not  so
   there is no point in exporting a limit in a uapi header,  it will
   just be out of date and wrong.

b) I can see in principle bumping up the kernels MAX_LABELS past two
   although I haven't heard those requests, or understand the use cases.
   I don't recall seeing any ducumentation on cases where it is
   desirable to push a lot of labels at once.  (Do hardware
   implementations support pushing a lot of labels at once?)

   Bumping past 8 seems quite a lot.  That starts feeling like people
   trying to break other peoples mpls stacks.  That is asking for more
   packet space for labels than ipv6 uses for addresses and ipv6 is way
   oversized.  The commonly agreed wisdom is the world only needs 40 to
   48 bits to route on to reach the entire world.  

   I can completely understand a few specialty labels going beyond what
   is needed for general purpose routing but pushing more that 8 at
   once seems huge.  Especially since you can recirculate packets if
   you really need to and push more labels that way.

   Add to that for a software implementation we have these pesky things
   called cache lines.  I can see in the kernel pushing struct
   mpls_route towards the size of a full cacheline.  Today we are at 52
   bytes not counting the via adress.  With the via address we are at 56
   (ipv4), 58 (ethernet), and 60 (ipv6) bytes.  Which means in we have
   to make the kernel data structures smarter or we risk messing up the
   performance of the common case.

   Also we do need some kind of limit in the kernel to protect against
   insane inputs.
   
   So while I can imagine there are reasonable cases for bumping up the
   maximum number of labels in the kernel I think we need to be smart if
   we ware going to do that.  Which probably means we will want a
   __mpls_nh_label helper function.

Eric
