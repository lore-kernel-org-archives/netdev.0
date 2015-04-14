From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 03/24] switchdev: convert STP update to swdev
 attr set
Date: Tue, 14 Apr 2015 00:51:46 -0700
Message-ID: <CAE4R7bDxc-XOBoVibGtzReM1kXi7HFLf5e8Zr0j0nJCHz+qTPQ@mail.gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
	<1428905838-14920-4-git-send-email-sfeldma@gmail.com>
	<552C1773.3030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34052 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbbDNHvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 03:51:47 -0400
Received: by qkgx75 with SMTP id x75so3968924qkg.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 00:51:46 -0700 (PDT)
In-Reply-To: <552C1773.3030907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 12:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 12/04/15 23:16, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> STP update is just a writable port attribute, so convert swdev_port_stp_update
>> to an attr set.
>>
>> For rocker, support prepare-commit transaction model for setting STP state.
>> This requires rocker to preallocate memory needed for the commit up front in
>> the prepare phase.  Since rtnl_lock is held between prepare-commit, store the
>> allocated memory on a queue hanging off of the rocker_port.  Also, in prepare
>> phase, do everything right up to calling into HW.  The same code paths are
>> tranversed in the driver for both prepare and commit phases.  In some cases,
>> any state modified in the prepare phase must be reverted before returning
>> so the commit phase makes the same decisions.
>
> I now better understand the reason for introducing both the object and
> transactional model, but that is really a dramatic change in the API
> complexity now, and unfortunately this is reflected in the drivers using
> it...

Yes, the drivers must now individually handle each transaction phase
at the level that makes sense for the driver/device.  For DSA, the
prepare phase is skipped and only the commit phase is run, as would
have happened before all this transactional model work.  Rocker gets
more interesting because the driver allocates memory as it goes and
updates driver and device state in multiple steps, any which can fail,
so the prepare phase needs to do a lot of work before giving the all
clear for commit.  I'm not sure how to up-level the prepare phase
since it's very device/driver specific.

> Can we try to classify switches by their underlying control/transport
> bus, essentially sleeping vs. non-sleeping I/O operations and provide a
> good enough abstraction from there which avoids drivers like rocker to
> have to maintain a list of transactions?

I'm not sure I follow the sleeping vs. non-sleeping classification.
