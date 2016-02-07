From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Sun, 07 Feb 2016 12:18:35 -0800
Message-ID: <56B7A69B.5040101@cumulusnetworks.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33026 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcBGUSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 15:18:40 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so109510142wme.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 12:18:39 -0800 (PST)
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/16, 2:47 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> There a is need for some userspace API that would allow to expose things
> that are not directly related to any device class like net_device of
> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
>
> Use cases:
> 1) get/set of port type (Ethernet/InfiniBand)
> 2) monitoring of hardware messages to and from chip
> 3) setting up port splitters - split port into multiple ones and squash again,
>    enables usage of splitter cable
> 4) setting up shared buffers - shared among multiple ports within one chip
>
> First patch of this set introduces a new generic Netlink based interface,
> called "devlink". It is similar to nl80211 model and it is heavily
> influenced by it, including the API definition. The devlink introduction patch
> implements use cases 1) and 2). Other 2 are in development atm and will
> be addressed by follow-ups.
>
> It is very convenient for drivers to use devlink, as you can see in other
> patches in this set.
>
> Counterpart for devlink is userspace tool called "dl". Command line interface
> and outputs are derived from "ip" tool so it should be easy for users to get
> used to it.
>
> It is available here:
> https://github.com/jpirko/devlink

Jiri, thanks for this series!. Something like this is definitely needed for chip specific data. But i thought we were going to limit it to chip specific global attributes that cannot be set on a port.
>
> Example usage:
> butter:~$ dl help
> Usage: dl [ OPTIONS ] OBJECT { COMMAND | help }
> where  OBJECT := { dev | port | monitor }
>        OPTIONS := { -v/--verbose }
>
> butter:~$ dl dev show
> 0: devlink0: bus pci dev 0000:01:00.0
>
> butter:~$ dl port help
> Usage: dl port show [DEV/PORT_INDEX]
> Usage: dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]

I don't think we should include port specific attributes in this api. ports are netdevs and they should still continue to use 'ip link set'.

So, why not just introduce a rtnetlink ops abstraction for switch ports ?. Example:

static struct rtnl_link_ops swport_link_ops __read_mostly = {
        .kind           = 'swport',
        .setup          = swport_setup,
        .validate       = swport_validate,
};

IFLA_INFO_KIND = swport
IFLA_INFO_DATA = {
            IFLA_SWPORT_KIND = 'mlx'
            IFLA_SWPORT_TYPE, /* u16 */
            IFLA_SWPORT_DESIRED_TYPE, /* u16 */

            ... more ...
}

IFLA_INFO_DATA can be redirected to the specific switch driver at the switchdev ops/api layer.

ip link set dev swp1 swport_type eth swport_desired_type <blah>

Taking this one step further, the port splitter management can be done in user-space:
And, users/switch port management infra can use 'ip link add type swport ...' to create required switch ports.

Thanks,
Roopa



             
