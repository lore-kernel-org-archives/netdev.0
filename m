From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 12:03:03 -0600
Message-ID: <5602E957.2060409@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
 <5602C901.2050404@gmail.com> <5602CD17.3030008@cumulusnetworks.com>
 <5602D3CA.7010502@gmail.com> <5602DDC1.2080403@cumulusnetworks.com>
 <5602E39D.6060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34699 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbbIWSDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:03:06 -0400
Received: by padhy16 with SMTP id hy16so46914387pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 11:03:06 -0700 (PDT)
In-Reply-To: <5602E39D.6060509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/23/15 11:38 AM, Alexander Duyck wrote:
> On 09/23/2015 10:13 AM, David Ahern wrote:
>> On 9/23/15 10:31 AM, Alexander Duyck wrote:
>>>
>>> Just as you said, that code would be an intermediate step. Going though
>>> and adding more points where you are updating err and just exchanging
>>> one jump label for another doesn't help anything.  You are better off
>>> pulling apart the spaghetti right from the start and then rearranging
>>> the code.  If nothing else it helps to make things more readable.
>>>
>>> In a couple of patches from here you are going to have to pull out the
>>> local_input helper.  Rather than adding a new jump label inside of it
>>> for out you could save yourself a few steps and just return the error
>>> values.  If you do this correctly what you should end up with is a
>>> series of functions that all converge on one end point anyway.
>>>
>>> Also as far as the multiple returns issue it isn't much of a problem
>>> since ip_output_input_slow ends up being compiled into
>>> ip_route_input_noref anyway.  As such the return statements end up just
>>> being jumps to the bits for the rcu_read_unlock and returning the error
>>> value.
>>
>> I chose this series of steps because it is easy to follow each change
>> to ensure I do not introduce bugs with the patches. Small, focused
>> changes to evolve the code.
>
> Some of the steps just seem like they are busy work and doing them don't
> really add much of anything.

They add a lot of value. They make each change very easy to follow. No 
one is going to pickup a single patch in this series and backport to 
some kernel. Each is dependent on the one before it. Given that I would 
rather waste a few steps and ensure I arrive at the destination without 
error.

>
>> The first 3 patches appear to have *zero* impact on what the compiler
>> generates.
>
> That is kind of my point.  Why mess with something if it has zero
> impact.  At least by just adding the returns we actually gain
> something.  From what I can tell it looks like just going through
> ip_route_input_mc, __mkroute_input, and ip_route_input_slow and simply
> replacing all the spots where we are assigning err, and jumping to
> something that returns it with just a return err I save roughly 80 bytes
> worth of size.

If you have a better suggestion for how to improve this code then please 
submit it. I don't have a religion here. I don't like making mistakes 
and the silly mistake that led to bde6f9ded1 motivated this patch series.

>
>> Do you object to the end result of this patch series? ie. do you have
>> concerns about what the end code looks like?
>
> The biggest thing that caught my eye is the fact that the end result is
> larger than the original.  That tells me something went wrong in your
> process as there shouldn't be any reason for the code footprint to
> actually grow.  If for example moving things into functions has caused
> this then maybe we need to rethink the approach.

It's the last 2 patches that introduce the size change. Top line is 
without IP_VERBOSE; bottom line is with it:

1e03ff19c413 net: Remove no_route label
     19847          2321      32   22200    56b8 kbuild/net/ipv4/route.o
     20711          2321      32   23064    5a18 kbuild/net/ipv4/route.o

3772b7bbac8b net: Remove local_input label
     19781          2321      32   22134    5676 kbuild/net/ipv4/route.o
     20666          2321      32   23019    59eb kbuild/net/ipv4/route.o

cac02ff199fa net: Remove martian_destination label
     19756          2321      32   22109    565d kbuild/net/ipv4/route.o
     20626          2321      32   22979    59c3 kbuild/net/ipv4/route.o

071993ac0735 net: Remove martian_source goto
     19758          2321      32   22111    565f kbuild/net/ipv4/route.o
     20618          2321      32   22971    59bb kbuild/net/ipv4/route.o

6af3805a299e net: Move martian_destination to helper
     19778          2321      32   22131    5673 kbuild/net/ipv4/route.o
     20616          2321      32   22969    59b9 kbuild/net/ipv4/route.o

d56e8f30af4d net: Move rth handling from ip_route_input_slow to helper
     19778          2321      32   22131    5673 kbuild/net/ipv4/route.o
     20605          2321      32   22958    59ae kbuild/net/ipv4/route.o

139df871ec82 net: Remove e_nobufs label from ip_route_input_slow
     19778          2321      32   22131    5673 kbuild/net/ipv4/route.o
     20615          2321      32   22968    59b8 kbuild/net/ipv4/route.o

6daa3b43063b net: Remove e_inval label from ip_route_input_slow
     19778          2321      32   22131    5673 kbuild/net/ipv4/route.o
     20615          2321      32   22968    59b8 kbuild/net/ipv4/route.o

928edcca02e5 net: Remove martian_source_keep_err goto label
     19778          2321      32   22131    5673 kbuild/net/ipv4/route.o
     20615          2321      32   22968    59b8 kbuild/net/ipv4/route.o

227b9e8708b1 usbnet: remove invalid check
     19778          2321      32   22131    5673 kbuild/net/ipv4/route.o
     20615          2321      32   22968    59b8 kbuild/net/ipv4/route.o

This last one is the baseline.

>
> Also it doesn't really feel like you reduce the use of goto statements
> at all.  All you did is reduce the number of labels, but everything is
> still jumping to "out" all over the place.  It just seems kind of silly
> since the compiler will likely take care of that for us anyway since it
> will inline ip_route_input slow into ip_route_input_noref which means
> all of the returns will just end up dumping us out just before the
> rcu_read_unlock in that function.

I am not trying to reduce goto's. I am trying to avoid hops all over the 
place which lead to confusing logic.

David
