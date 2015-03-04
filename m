From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Tue, 3 Mar 2015 23:28:06 -0800
Message-ID: <CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
	<20150304.003844.1400829201582760359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:60552 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933454AbbCDH2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 02:28:07 -0500
Received: by mail-qa0-f53.google.com with SMTP id v8so6088093qal.12
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 23:28:06 -0800 (PST)
In-Reply-To: <20150304.003844.1400829201582760359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
> From: sfeldma@gmail.com
> Date: Tue,  3 Mar 2015 15:31:53 -0800
>
>> v3:
>>
>> Changes based on v2 review comments:
>>
>>   - Move check for custom rules up earlier in patch set, to keep git bisect
>>     safe.
>>   - Simplify the route add/modify failure handling to simple try until
>>     failure, and then on failure, undo everything.  The switchdev driver
>>     will return err when route can normally be installed to device, but
>>     the install fails for one reason or another (no space left on device,
>>     etc).  If a failure happens, uninstall all routes from the device,
>>     punting forwarding for all routes back to the kernel.
>>   - Scan route's full nexthop list, ensuring all nexthop devs belong
>>     to the same switchdev device, otherwise don't try to install route
>>     to device.
>
> Getting really close.
>
> I think you have to make some minor adjustments to the
> fib_flush_external() cases.
>
> First of all, that code that unloads the entries from the hardware
> should clear the RTNH_F_EXTERNAL flag.

In v3, the setting and clearing of RTNH_F_EXTERNAL moved to the
driver, the implementer of the add/del ndo ops.  So RTNH_F_EXTERNAL
does get cleared by the driver on fib_flush_external().  We could add
an additional clear above the driver, just in case the driver screwed
up and forgot to clear it.  Driver bug in that case; not sure where to
draw the line.

> Secondly, if you call fib_flush_external() because an add returned an
> error, you have to set some boolean state which prevents the next new
> route insert from loading only that new route into the hardware
> because that's exactly what will happen with your current
> implementation.

I guess we could add a net.ipv4.fib_hw_screwed.  But that kills other
innocent switch devices on same netns.  Or is it a private driver
bool, which gets set on first install err, and is checked on
subsequent installs?
