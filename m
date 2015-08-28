From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Fri, 28 Aug 2015 02:13:02 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC350F577112@ORSMSX101.amr.corp.intel.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26063 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbbH1CNE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 22:13:04 -0400
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of sfeldma@gmail.com
>Sent: Thursday, August 27, 2015 12:17 AM
>To: netdev@vger.kernel.org
>Cc: jiri@resnulli.us; davem@davemloft.net; f.fainelli@gmail.com;
>roopa@cumulusnetworks.com
>Subject: [RFC PATCH net-next 0/2] Add new switchdev device class
>
>From: Scott Feldman <sfeldma@gmail.com>
>
>
>So what next?  I'd rather not build APIs around sysfs, so we need a netlink
>API
>we can build on top of this.  It's not really rtnl.  Maybe genl would work?
>What ever it is, we'd need to teach iproute2 about a new 'switch' command.
>
[@Ronen] I developed PoC code based on genl which allows access for what I
call device options. It generalizes libteam/team driver option handling.
It allows for fields of all Netlink scalar or string types as well as arrays.
It differentiates between port-specific and device options.
(It was not limited to read-only but this could be changed to address the
 concerns raised on this thread)
Extending to Tables from just a list of named options is welcomed.

The diagram below shows possible architecture.

+-----------------------------------------+
|      tool (e.g. swdevnl, iproute2)      |
+-----------------------------------------+
               |
            +-----------------+
            |     libswdev    |
            +-----------------+
               |
      +-----------------------------+
      |          libnl3             |
      +-----------------------------+
               |
User           |
-------------------------------------------------
Kernel         |
               |
+-------------------+ +-------------------+
|     genetlink     | |     rtnetlink     |
+-------------------+ +-------------------+
               |
        +-----------+
        |   swdev   |
        +-----------+
               |
+-----------------------------------------+
|                                         |
|              SOMEswitch                 |
|                                         |
+-----------------------------------------+

Libswdev in the diagram is a user space library which should abstract the
netlink interaction and encoding details from user-space tools.

Swdev is a kernel module which provides similar abstraction to drivers. It 
saves drivers from most of the low level code.

Drivers register their supported options (or Table/Fields) with this module
and provide getters functions. The Swdev kernel module provides the genl API
for exporting device specific information.

This architecture allows for a generic tool to discover the information
available from each driver/port. The tool could extract sufficient
information which allows it to present user-friendly interface to users for
drilling down and retrieving specific details.  

>Netlink API would allow us to represent switch-wide objects such as registers,
>tables, stats, firmware, and maybe even control.  I think with with netlink
>TLVs, we can create a framework for these objects but still allow the switch
>driver provide switch-specific info.  For example, a table object:
>
>[TABLES]
>	[TABLE]
>		[FIELDS]
>			[FIELD]
>				[ID, TYPE]
>		[DATA]
>			[ID, VALUE]
>
[@Ronen] Some additional information could be useful. TABLE name, FIELD name,
(possible also short names for CLI commands or pretty printing of table
header), FIELD value range (help with pp), TABLE/FIELD description.

>Maybe iproute2 has pretty-printers for specific switches like ethtool has for
>reg dumps.
>
