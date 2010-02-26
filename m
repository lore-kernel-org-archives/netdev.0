From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Fri, 26 Feb 2010 16:05:19 -0500
Message-ID: <4B88378F.9040104@garzik.org>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>	 <4B85F173.40703@garzik.org>	 <Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>	 <4B87315E.4080905@garzik.org> <1267214397.2098.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f182.google.com ([209.85.210.182]:43479 "EHLO
	mail-yx0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab0BZVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 16:05:31 -0500
Received: by yxe12 with SMTP id 12so251211yxe.33
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 13:05:30 -0800 (PST)
In-Reply-To: <1267214397.2098.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2010 02:59 PM, Ben Hutchings wrote:
> On Thu, 2010-02-25 at 21:26 -0500, Jeff Garzik wrote:
>> On 02/25/2010 08:49 PM, Waskiewicz Jr, Peter P wrote:
> [...]
>>> This will require a small kernel change.  Will something like this be
>>> pulled in at this point, given that 2.6.33 just released?
>>
>> The n-tuple stuff is not in 2.6.33's ethtool interface, so it hasn't
>> actually made it into a released kernel at this point.
>>
>> It seems reasonable for 2.6.34 to either add ETHTOOL_GSTRINGS_COUNT or
>> update drvinfo.  Even if net-next has already been pulled into
>> post-2.6.33 merge window, that would IMO qualify as a reasonable
>> interface bugfix to get upstream.  The ethtool n-tuple ABI is not locked
>> into stone until 2.6.34 is released by Linus.
>
> Given that, I would really like to see the tuple strings replaced with
> binary structures.  Setting them in binary format and retrieving them in
> text format is inelegant.  Also we should not assume that ethtool is the
> only user of the ethtool API.  If someone wanted to write a GUI to
> manage the filter tuples, or a tool that would programmatically
> reconfigure filters, they would have to parse the strings.
>
> Even the lookup of number of strings seems to be completely
> misconceived.  It's delegated to the driver thus:
>
>          ret = ops->get_sset_count(dev, gstrings.string_set);
>          if (ret<  0)
>                  return ret;
>
> What if gstrings.string_set != ETH_SS_NTUPLE_FILTERS?  Why is that even
> a parameter to the operation?
>
> Further, each filter can be formatted as multiple strings.  So is the
> driver supposed to know how many strings the ethtool core might
> generate?

Speaking _generally_, not specifically about n-tuple filters, text 
strings are much more flexible across varied types of hardware.  For 
example, the "private flags" ethtool interface is intended to be used as 
a generic means for a driver to export a set of hardware-specific 
boolean knobs.

For example, e1000e's SmartPowerDownEnable need not be a module-wide 
parameter applying to all e1000e devices in the system.  ethtool's 
private-flags interface could enable per-net_device runtime setting of 
this Intel-specific feature, simply by exporting a string 
"SmartPowerDownEnable" as a private flag.

Thus, text strings isolate the problem of hardware-specific settings, 
features and structures entirely in the kernel driver itself.

Getting back to n-tuple filters, the question becomes:  how 
hardware-specific are the filter formats?

Using binary structures is generally more efficient...   but efficiency 
is not really a primary goal.  Working across a broad spectrum of 
hardware, future-proof-edness, is more important.  Binary structures may 
lock ethtool users into a very specific filter specification -- one that 
might not be as easily applicable to other vendors' hardware, or even 
future hardware from the same vendor.

procfs and sysfs exist in their current, ASCII-friendly form in part 
because Linus has often observed that text strings are often easier and 
more resilient kernel<->userspace interfaces than binary interfaces.

All that said, I cannot argue that there are elements of the current 
Intel implementation that are quite inelegant, and binary structures may 
simply be easier.

Like everything else in life, it's a balance...   ;-)

	Jeff



