From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] netdev: add support for interface name retrieval from DT aliases
Date: Fri, 16 May 2014 12:49:50 -0700
Message-ID: <CAGVrzcaFHYtavBp52mkm0aTQtkxpPwty6M6P7J2-FAnuT7Wdwg@mail.gmail.com>
References: <1399390594-1409-1-git-send-email-boris.brezillon@free-electrons.com>
 <20140508.224252.1337086843732451389.davem@davemloft.net> <536C9146.2060007@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	netdev <netdev@vger.kernel.org>, nicolas.ferre@atmel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Boris BREZILLON <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <536C9146.2060007@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-05-09 1:26 GMT-07:00 Boris BREZILLON <boris.brezillon@free-electrons.com>:
> Hi David,
>
> On 09/05/2014 04:42, David Miller wrote:
>> From: Boris BREZILLON <boris.brezillon@free-electrons.com>
>> Date: Tue,  6 May 2014 17:36:34 +0200
>>
>>> There is currently no proper way to bind a net interface to a specific
>>> name. The interface name is chosen based on the interface type (eth,
>>> wlan, ...) and the interfaces already registered (the core codes takes
>>> the first unused interface id of the given type).
>>>
>>> Add support for DT retrieval of the interface id based on DT aliases.
>>> The alias name must match the interface type (e.g. ethX if you're defining
>>> an ethernet dev alias).
>>>
>>> Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>
>> This really isn't kosher at all.
>
> Just for my personal knowledge, what is wrong with this code ?
> Is it because I'm using "of_" functions in the core code, and you want
> to keep it DT agnostic ?
> Or is it something else ?

I think the major problem is that you are using DT to name interfaces
and enforcing a naming policy within the kernel, while this should be
left solely to user-space. I know that coming from an embedded
use-case this might sound appealing, but the interface naming policy
had better remain in user-space to avoid mixing policy with
mechanisms.

>
>>
>> And there absolutely is a proper way to bind a net interface to
>> a specific name, udev has provided this facility for years.
>
> Thanks for pointing this out.
>
> But, what if the system does not use udev (this is often the case on
> embedded systems where udev is replaced by mdev) ?

Traditional embedded systems are also using a lot of custom software,
why not write a small device mapper program that looks at aliases in
the device-tree and matches it with sysfs entries for these
corresponding network interfaces?

> Moreover, on embedded systems, most users rely on the default interface
> name provided by the kernel.
>
> IIRC (tell me if I'm wrong), before moving to DT we could control the
> probe order of net interfaces derived from platform devices by modifying
> the platform dev registration order (okay, this is only true if the
> platform devices are controlled by the same driver, which is often the
> case when a SoC provides several net interfaces).

I do not quite agree with this, before moving to DT, we were mostly
relying on the linking order imposed by the lines in the Makefile,
which is still the case for a few things. It is sometimes fragile, and
it is sometimes very convenient, and it also provides some perceived
probing order stability, but that's no longer true with e.g: deffered
probing which can happen regardless of DT.

> With DT we can't know for sure the exact probe order because it depends
> on the net interface node position in the DT, and this node position
> might change over the time (or at least it used to change, now that
> we're enforced to declare DT nodes in strict memory @ order it should
> not change that much).

Which is precisely where aliases are coming handy, and I understand
why it is tempting to use them, but aliases are nothing more than the
mechanism to help you, not the policy.

>
> Another issue: what if I want to rename eth0 into eth1 and eth1 into eth0 ?
> I guess I'll have to execute this sequence: eth1 -> eth2, eth0 -> eth1,
> eth2 -> eth0, otherwise the SIOCSIFNAME ioctl will return an error.

Just like you swap two variables, use a temporary name.
-- 
Florian
