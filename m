From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/9] Introduce devlink infrastructure
Date: Tue, 23 Feb 2016 08:47:01 +0100
Message-ID: <20160223074701.GB2140@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-2-git-send-email-jiri@resnulli.us>
 <56CB8BB2.3070202@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33348 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbcBWHrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 02:47:05 -0500
Received: by mail-wm0-f45.google.com with SMTP id g62so188757224wme.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 23:47:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CB8BB2.3070202@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 22, 2016 at 11:29:06PM CET, roopa@cumulusnetworks.com wrote:
>On 2/22/16, 10:31 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Introduce devlink infrastructure for drivers to register and expose to
>> userspace via generic Netlink interface.
>>
>> There are two basic objects defined:
>> devlink - one instance for every "parent device", for example switch ASIC
>> devlink port - one instance for every physical port of the device.
>
>Like i have expressed earlier, the only thing that bothers me here is that we are creating a new devlink object for switch port when there
>is an existing netdev object.

Sometimes it is, sometimes it is not (IB). I bevelieve that there is a
need for a "handle" for a physical port, regardless what type it is.
The same instance exists all the time, even if you change the type or if
the netdev is not created yet (init phase)


>
>Is there a chance that the drivers you are targeting can still create netdevs for physical ports ?
>It would make things so much more consistent and simpler to manage without a cost of adding yet another interface.

So you see a problem in having devlink_port handle here? It is just an
index, very simple. But you would rather see something like:
myhost:~$ dl dev show
0: devlink0: bus pci dev 0000:01:00.0
myhost:~$ dl port show
ens4: type eth parent devlink0
ens5: type eth parent devlink0
?

There are 2 problems with that approach:
1) It's hard to use this for IB devices, they don't necessary have
   netdev associated.
2) You have to have the netdevs created (know ifindex) in order to work
   with that from userspace. But there are usecases, for example during
   initialization that netdevs are not yet present and user needs to
   specify port for configuration (that is usecase #4 I listed in the cover
   letter)

But it is very easy to change dl userspace tool to be able to use netdev
names to specify ports when possible. Then you could do something like
for example:
myswitch:~$ sudo dl port split eth0 2


>
>The port splitter support is needed at the netdev api too (ie rtnetlink). Most switchdev drivers that expose netdevs
>would benefit from a native 'ip link' way to configure port splitting. This will be useful for nic drivers too.

Why would it be needed in rtnetlink too if it would be exported using
devlink? I don't get it. Sounds similar like if you would expose
wireless-specific stuff via rtnetlink in parallel to nl80211.
