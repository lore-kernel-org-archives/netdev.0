From: Andreas Greve <andreas.greve@a-greve.de>
Subject: Re: Bug: tc filter show .... raise segfault if more than one rule
 with action -j MARK exist
Date: Sat, 10 May 2014 11:11:08 +0200
Message-ID: <536DED2C.10301@a-greve.de>
References: <536B6F03.5040401@a-greve.de>
Reply-To: andreas.greve@a-greve.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:24709 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917AbaEJJLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 05:11:25 -0400
In-Reply-To: <536B6F03.5040401@a-greve.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Stephen Hemminger, Dear List Members,

this is a corrected/optimized version of the patch
Thanks to Stephen Hemminger, for giving me the hint to use structure 
assignment instead of
memcpy().

Best wishes

Andreas Greve

On 05/08/14 13:48, Andreas Greve wrote:
> Dear Stephen Hemminger, Dear List Members,
>
> the command
>
> tc filter show dev eth1 parent ffff:
>
> raise a segmentation fault if there are more than one filter rule with 
> action -j MARK exists.
>
> Reason:
> In print_ipt(...) xtables will be initialzed with a pointer to the 
> static struct tcipt_globals at xtables_init_all(). Later on the fields 
> .opts and .options_offset of tcipt_globals are modified. The call of 
> xtables_free_opts(1) at the end of print_ipt(...) does not restore the 
> original values of tcipt_globals for the modified fields. It only 
> frees some allocated memory and sets .opts to NULL. This leads to a 
> segmentation fault when print_ipt()
> is called for the next filter rule with action -j MARK.
>
> Fix: (patch attached)
> Cloneing tcipt_globals on the stack as tmp_tcipt_globals and use it 
> instead of tcipt_globals, so tcipt_globals will be not modified.
>
> Tests:
> I only have done limit tests for this fix ( action -j MARK ) on a 
> debian wheezy iproute2 package build from source based on 
> upstream/3.14.0. The system is a little bit special  kernel 
> 3.12.17-xen on xen-4.4.1-pre.
>
>
> Andreas Henriksson (debian iproute maintainer) give me an other idea 
> of how to fix this bug by modifying  xtables_free_opts() so that it 
> sets .opts = .orig_opts instead .opts = NULL. This should avoid having 
> to duplicate the entire struct each time.
>
> I prefer the cloning  because:
>
> 1)  In my understanding the variable tcipt_globals is a complex 
> "constant" that should never be modified. ( Is that right ?)
>
> 2) If we want to do the fix in xtables_free_opts we have to change the 
> struct xtables_globals because we need for all fields .orig fields I 
> think this will  make all things much more complicated.
>
>
> additional Brainstorms:
>
> a ) Perhaps we have to think about of a deep clone of tcipt_globals to 
> protect the underlaying option array
> b ) makes cloning of  tcipt_globals sense in  parse_ipt(...)
> But for this two decisions my understanding of the whole system is not 
> enough.
>
>
> I hope the Information helps
>
> Thanks
>
> Best wishes
>
>
> Andreas Greve
>
>
>
>
>
>
>
>
> Andreas Henriksson
>
>
> Stephen Hemminger
>
