From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/4] switchdev: push bridge attributes down
Date: Thu, 24 Sep 2015 21:26:53 -0700
Message-ID: <CAE4R7bCwBWQXbwTxgLk7es_=_8UezhqzeY2eeQcDuCTTqwEZ2Q@mail.gmail.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com> <5604A208.3030902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36206 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbIYE1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 00:27:13 -0400
Received: by obbmp4 with SMTP id mp4so74212679obb.3
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 21:27:13 -0700 (PDT)
In-Reply-To: <5604A208.3030902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 6:23 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 24/09/15 13:59, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Push bridge-level attributes down to switchdev drivers.  This patchset
>> adds the infrastructure and then pushes, as an example, ageing_time attribute
>> down from bridge to switchdev (rocker) driver.  Add some range-checking
>> for ageing_time.
>>
>> # ip link set dev br0 type bridge ageing_time 1000
>>
>> # ip link set dev br0 type bridge ageing_time 999
>> RTNETLINK answers: Numerical result out of range
>>
>> Up until now, switchdev attrs where port-level attrs, so the netdev used in
>> switchdev_attr_set() would be a switch port or bond of switch ports.  With
>> bridge-level attrs, the netdev passed to switchdev_attr_set() is the bridge
>> netdev.  The same recusive algo is used to visit the leaves of the stacked
>> drivers to set the attr, it's just in this case we start one layer higher in
>> the stack.  One note is not all ports in the bridge may support setting a
>> bridge-level attribute, so rather than failing the entire set, we'll skip over
>> those ports returning -EOPNOTSUPP.
>
> So, without a better device to hold that kind of information (in the
> future it could be a global, switch-specific device holding that
> information), I agree with your decision to take the bridge device to
> hold that attribute, it still feels a bit uncomfortable to have
> switchdev_attr_port() take a bridge device parameter, but whatever, here
> is a scenario I am wondering how we would want to proceed with:
>
> - suppose we have a switch which is only able to control ageing
> globally, not per port or any other kind of logical domain
>
> - we have enabled two software bridges on the same physical switch, with
> different ageing timeouts
>
> It does not seem to me like it hurts ageing the other bridge faster than
> expected (even though that could be expensive for MDIO devices), but we
> would need to have consistent reporting here for the other bridge.

It could hurt a little bit by ageing out entries prematurely, forcing
relearning.  ;)

I think if the switch can't support multiple ageing timeouts (which is
probably typical), then the switch driver should not implement this
switchdev attr at the port level (this patchset).  So how does ageing
timeout get set for a switch with a global timer?  I believe we need
the switch-specific device to handle those switch-global attr sets.
I'll send out a refresh of my RFC patches for switch device class, and
add this ageing_time attr.
