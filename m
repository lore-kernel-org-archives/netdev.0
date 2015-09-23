From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 10:38:37 -0700
Message-ID: <5602E39D.6060509@gmail.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
 <5602C901.2050404@gmail.com> <5602CD17.3030008@cumulusnetworks.com>
 <5602D3CA.7010502@gmail.com> <5602DDC1.2080403@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34127 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468AbbIWRii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:38:38 -0400
Received: by padhy16 with SMTP id hy16so46388180pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 10:38:38 -0700 (PDT)
In-Reply-To: <5602DDC1.2080403@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2015 10:13 AM, David Ahern wrote:
> On 9/23/15 10:31 AM, Alexander Duyck wrote:
>>
>> Just as you said, that code would be an intermediate step. Going though
>> and adding more points where you are updating err and just exchanging
>> one jump label for another doesn't help anything.  You are better off
>> pulling apart the spaghetti right from the start and then rearranging
>> the code.  If nothing else it helps to make things more readable.
>>
>> In a couple of patches from here you are going to have to pull out the
>> local_input helper.  Rather than adding a new jump label inside of it
>> for out you could save yourself a few steps and just return the error
>> values.  If you do this correctly what you should end up with is a
>> series of functions that all converge on one end point anyway.
>>
>> Also as far as the multiple returns issue it isn't much of a problem
>> since ip_output_input_slow ends up being compiled into
>> ip_route_input_noref anyway.  As such the return statements end up just
>> being jumps to the bits for the rcu_read_unlock and returning the error
>> value.
>
> I chose this series of steps because it is easy to follow each change 
> to ensure I do not introduce bugs with the patches. Small, focused 
> changes to evolve the code.

Some of the steps just seem like they are busy work and doing them don't 
really add much of anything.

> The first 3 patches appear to have *zero* impact on what the compiler 
> generates.

That is kind of my point.  Why mess with something if it has zero 
impact.  At least by just adding the returns we actually gain 
something.  From what I can tell it looks like just going through 
ip_route_input_mc, __mkroute_input, and ip_route_input_slow and simply 
replacing all the spots where we are assigning err, and jumping to 
something that returns it with just a return err I save roughly 80 bytes 
worth of size.

> Do you object to the end result of this patch series? ie. do you have 
> concerns about what the end code looks like?

The biggest thing that caught my eye is the fact that the end result is 
larger than the original.  That tells me something went wrong in your 
process as there shouldn't be any reason for the code footprint to 
actually grow.  If for example moving things into functions has caused 
this then maybe we need to rethink the approach.

Also it doesn't really feel like you reduce the use of goto statements 
at all.  All you did is reduce the number of labels, but everything is 
still jumping to "out" all over the place.  It just seems kind of silly 
since the compiler will likely take care of that for us anyway since it 
will inline ip_route_input slow into ip_route_input_noref which means 
all of the returns will just end up dumping us out just before the 
rcu_read_unlock in that function.

- Alex
