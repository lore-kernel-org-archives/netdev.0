From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Use CAP_NET_ADMIN and alias netdev-nlmon instead
Date: Wed, 13 Aug 2014 11:39:45 +0200
Message-ID: <53EB3261.2090007@redhat.com>
References: <7B1A5F4E-7DCD-4054-9E8C-E5511AF64CE3@holtmann.org> <53E67742.9080405@redhat.com> <09B6E85F-9B01-435B-B18B-71730DBD450D@holtmann.org> <20140809170344.0352b16c@haswell.linuxnetplumber.net> <BF76FDB5-3355-45A8-894C-40072B5DAE54@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbaHMJjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 05:39:52 -0400
In-Reply-To: <BF76FDB5-3355-45A8-894C-40072B5DAE54@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2014 10:01 PM, Marcel Holtmann wrote:
...
>>>>> so I am running this command sequence:
>>>>>
>>>>> 	ip link add name nlmon type nlmon
>>>>> 	ip link set dev nlmon up
>>>>>
>>>>> With that I get this message in dmesg:
>>>>>
>>>>> Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).
>>>>> Use CAP_NET_ADMIN and alias netdev-nlmon instead.
>>>>>
>>>>> The kernel section producing this is dev_load() from net/core/dev_ioctl.c:
>>>>>
>>>>>         no_module = !dev;
>>>>>         if (no_module && capable(CAP_NET_ADMIN))
>>>>>                 no_module = request_module("netdev-%s", name);
>>>>>         if (no_module && capable(CAP_SYS_MODULE)) {
>>>>>                 if (!request_module("%s", name))
>>>>>                         pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
>>>>>                                 name);
>>>>>         }
>>>>>
>>>>> Since I am explicitly giving the name from userspace, I have no idea why the
>>>>> kernel bugs me in providing netdev-nlmon alias. It makes no sense to me. What
>>>>> is the reasoning behind this?
>>>>
>>>> Could it just be that your process doesn't have CAP_NET_ADMIN set
>>>> but CAP_SYS_MODULE instead thus triggering this pr_warn()?
>>>>
>>>> grep Cap /proc/$$/status ?
>>>>
>>>> Hm, I don't think this is nlmon related, above works fine on my side.
>>>
>>> so I have not nlmon.ko loaded or compiled into the kernel. This means the ip command will trigger the autoloading. Command is either run with sudo or as root. So this is not a capability issue.
>>>
>>> I think this is just a wrong check when handling loading of modules. I still do not understand how a netdev-%s alias makes any sense. Or even trying to load module nlmon.ko since I created interface nlmon.
>>>
>>> The real module loading should also be done in the type and not the name.
>>
>> The netdev module alias is a hold over from the past. For normal device people
>> used to create a alias eth0 to and point it to the type of network device used, that
>> was back in the bad old ISA days before real discovery.
>
> so can we just remove the second request_module for the network interface name here. I find the warning pretty much annoying since especially in cases where the autoloading happens based on RTNL and the type it is just in the wrong order.
>
> I mean, I told you to create this type of interface with this name. So please stop complaining to me ;)

It can btw also be triggered when nlmon is loaded, nlmon device exists
and calling `ip link del dev nlmon` more than once. Given that the
netdev-%s alias was only introduced 'recently' [1], I'd rather just say
to go for Stephen's suggestion to not break some deprecated user space
expectations.

   [1] http://thread.gmane.org/gmane.linux.kernel/1105168
