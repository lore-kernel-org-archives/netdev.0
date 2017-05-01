From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next iproute2] ip: increase number of MPLS labels
Date: Mon, 01 May 2017 16:03:17 -0500
Message-ID: <8737convca.fsf@xmission.com>
References: <1493524130-10220-1-git-send-email-dsa@cumulusnetworks.com>
        <20170429230430.702c6b72@xeon-e3>
        <ddb54ca8-d7df-3446-3929-5f0116286c80@cumulusnetworks.com>
        <20170501091540.13f57676@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        roopa <roopa@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34889 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdEAVJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 17:09:39 -0400
In-Reply-To: <20170501091540.13f57676@xeon-e3> (Stephen Hemminger's message of
        "Mon, 1 May 2017 09:15:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Sun, 30 Apr 2017 17:42:15 -0600
> David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> On 4/30/17 12:04 AM, Stephen Hemminger wrote:
>> > On Sat, 29 Apr 2017 20:48:50 -0700
>> > David Ahern <dsa@cumulusnetworks.com> wrote:
>> >   
>> >> Kernel now supports more than 2 labels. Increase ip to
>> >> handle up to 16 labels.
>> >>
>> >> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> >> ---
>> >>  include/utils.h | 8 ++++----
>> >>  lib/utils.c     | 2 +-
>> >>  2 files changed, 5 insertions(+), 5 deletions(-)
>> >>
>> >> diff --git a/include/utils.h b/include/utils.h
>> >> index 8c12e1e2a60c..a69e176c260d 100644
>> >> --- a/include/utils.h
>> >> +++ b/include/utils.h
>> >> @@ -54,6 +54,9 @@ void incomplete_command(void) __attribute__((noreturn));
>> >>  #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
>> >>  #define PREV_ARG() do { argv--; argc++; } while(0)
>> >>  
>> >> +/* Maximum number of labels the mpls helpers support */
>> >> +#define MPLS_MAX_LABELS 16
>> >> +  
>> > 
>> > Why is the kernel limit not in include/uapi/ header file?
>> >   
>> 
>> I believe Eric had reasons, but not sure why.
>
> I just don't want iproute2 utilities chasing kernel values.
> Would prefer either make utilities take any size, or inherit maximum
> from kernel headers.

Basically the kernel maximum is how large we can make struct mpls_route
without while being < 4096 aka PAGE_SIZE.  Which also happens to be
larger than the largest known consumer.

Which basically makes the limit meaningless for userspace.  MPLS does
not actually have a maximum (other than packet size) in the protocol.

So we need a number large enough that people don't care or something
completely arbitrary in iproute.

At 8 labels we are the same size as an ipv6 address which is where
the limitation of 8 came from in the code.  It was easy and it allowed
for future growth.

Taking a quick look at the code iproure uses inet_prefix for an address
in any protocol family and it is used fairly widely in the code.
Further addresses are placed in what appear to be fixed sized
preallocated netlink packets.  Hmmmmm....

So a completely arbitrary number of labels seems like over-enginnerring.
It looks like what is more interesting is using as a limit the remaining
space in the rtnetlink buffer.  Perhaps a function that combines
the efforts of get_addr and addattr_l/rta_addattr_l is the way to go.

That would appear to make it easier to add new address families in the future.

Dave is there a practical reason that is motivating increasing the size
in iproute?  Or is the desire to ensure that iproute can take full
advantage of the kernel?

Eric
