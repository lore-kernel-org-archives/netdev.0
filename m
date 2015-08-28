From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Fri, 28 Aug 2015 09:55:55 -0700
Message-ID: <55E0929B.2060800@gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com> <E4CD12F19ABA0C4D8729E087A761DC350F577112@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33403 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbbH1Q61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 12:58:27 -0400
Received: by padfo6 with SMTP id fo6so29840633pad.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 09:58:27 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC350F577112@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/08/15 19:13, Arad, Ronen wrote:
> 
> 
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> Behalf Of sfeldma@gmail.com
>> Sent: Thursday, August 27, 2015 12:17 AM
>> To: netdev@vger.kernel.org
>> Cc: jiri@resnulli.us; davem@davemloft.net; f.fainelli@gmail.com;
>> roopa@cumulusnetworks.com
>> Subject: [RFC PATCH net-next 0/2] Add new switchdev device class
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>>
>> So what next?  I'd rather not build APIs around sysfs, so we need a netlink
>> API
>> we can build on top of this.  It's not really rtnl.  Maybe genl would work?
>> What ever it is, we'd need to teach iproute2 about a new 'switch' command.
>>
> [@Ronen] I developed PoC code based on genl which allows access for what I
> call device options. It generalizes libteam/team driver option handling.
> It allows for fields of all Netlink scalar or string types as well as arrays.
> It differentiates between port-specific and device options.

OpenWrt has had a similar scheme, called swconfig:

Kernel code:

https://dev.openwrt.org/browser/trunk/target/linux/generic/files/drivers/net/phy/swconfig.c

User-space tools:

https://dev.openwrt.org/browser/trunk/package/network/config/swconfig/src

This was initially proposed but was rejected in favor of what became
switchdev because it did not focus exclusively on the switch device (as
a whole piece of hardware), but rather allowed configuration of things
that were already available through bridge/vlan etc..

Having a netlink interface to interface with a global (as in, not
per-port) switch device sounds like a good idea, especially if there are
events that need to be sent back to user-space, my only major concern
with this approach is to make sure there is careful review of what goes
into this interface such that:

- it is strongly defined, not just allow sending custom
u8/u16/u32/u64/blobs attributes back and forth, but rather have a
properly defined set of commands and associated data-structures

- this always covers something that is not, by nature a switch
port/physical interface attribute, and for which there is not an
existing interface

Bottom line being that it is very easy for this interface to be a
catch-all, dumping ground of things that did not fit within existing
facilities...

> (It was not limited to read-only but this could be changed to address the
>  concerns raised on this thread)
> Extending to Tables from just a list of named options is welcomed.
> 
> The diagram below shows possible architecture.
> 
> +-----------------------------------------+
> |      tool (e.g. swdevnl, iproute2)      |
> +-----------------------------------------+
>                |
>             +-----------------+
>             |     libswdev    |
>             +-----------------+
>                |
>       +-----------------------------+
>       |          libnl3             |
>       +-----------------------------+
>                |
> User           |
> -------------------------------------------------
> Kernel         |
>                |
> +-------------------+ +-------------------+
> |     genetlink     | |     rtnetlink     |
> +-------------------+ +-------------------+
>                |
>         +-----------+
>         |   swdev   |
>         +-----------+
>                |
> +-----------------------------------------+
> |                                         |
> |              SOMEswitch                 |
> |                                         |
> +-----------------------------------------+
> 
> Libswdev in the diagram is a user space library which should abstract the
> netlink interaction and encoding details from user-space tools.
> 
> Swdev is a kernel module which provides similar abstraction to drivers. It 
> saves drivers from most of the low level code.
> 
> Drivers register their supported options (or Table/Fields) with this module
> and provide getters functions. The Swdev kernel module provides the genl API
> for exporting device specific information.
> 
> This architecture allows for a generic tool to discover the information
> available from each driver/port. The tool could extract sufficient
> information which allows it to present user-friendly interface to users for
> drilling down and retrieving specific details.  
> 
>> Netlink API would allow us to represent switch-wide objects such as registers,
>> tables, stats, firmware, and maybe even control.  I think with with netlink
>> TLVs, we can create a framework for these objects but still allow the switch
>> driver provide switch-specific info.  For example, a table object:
>>
>> [TABLES]
>> 	[TABLE]
>> 		[FIELDS]
>> 			[FIELD]
>> 				[ID, TYPE]
>> 		[DATA]
>> 			[ID, VALUE]
>>
> [@Ronen] Some additional information could be useful. TABLE name, FIELD name,
> (possible also short names for CLI commands or pretty printing of table
> header), FIELD value range (help with pp), TABLE/FIELD description.
> 
>> Maybe iproute2 has pretty-printers for specific switches like ethtool has for
>> reg dumps.
>>


-- 
Florian
