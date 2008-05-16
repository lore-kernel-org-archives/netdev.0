From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener for DCB runtime changes.
Date: Fri, 16 May 2008 15:45:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32905168831@orsmsx414.amr.corp.intel.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain> <20080502004300.14392.87943.stgit@localhost.localdomain> <481AF501.3030507@pobox.com> <D5C1322C3E673F459512FB59E0DDC3290509D540@orsmsx414.amr.corp.intel.com> <48221B79.2010808@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9946 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756510AbYEPWpR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 18:45:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48221B79.2010808@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But like everything else in life, one must weight various 
> costs.  Maybe it is complex enough to warrant a new tool.  We 
> don't know until there's a design doc or review of the 
> generic interface that will be used for DCB.

100% agree.  I have a design document added to the bottom of this email
in plain text for the in-kernel design.  I can send a PDF or OpenOffice
doc if desired.  Please review it, see if that's something worth
supporting and developing, and send feedback.  If things look ok, I'll
write the in-kernel layer and send those patches asap, along with a
modified ixgbe to use the new interface.

Thanks Jeff,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>

------------------------------------------------------

Linux Kernel Interface Design for Data Center Bridging
Peter P. Waskiewicz Jr, Intel Corp.
5/16/2008

Overview:
	Data Center Bridging is a new layer 2 networking technology
targeted for data centers looking to converge certain network flows.
The technology uses 802.1p priority tagging from 802.1q, and then adds
the new 802.1Qaz Priority Grouping and 802.1Qbb Priority Flow Control
technologies.  The purpose is to provide per-priority flow control to
individual network flows without impacting other flows.  It also
provides the mechanism to enforce bandwidth allocation per flow.
	A Wikipedia article describing the network-wide model this fits
into can be found here:
http://en.wikipedia.org/wiki/Data_Center_Ethernet.

Netdev changes:

	The generic netlink interface will be added with the below
commands and attributes.  It will include a structure of function
pointers.  This structure will be part of the netdevice structure, and
will be populated by the underlying base driver, if applicable.

Structure of function pointers:

struct dcb_genl_ops *dcb_ops;

struct {
	int	(*getstate)(struct genl_info *info);
	int	(*setstate)(struct genl_info *info);
	int	(*setpgcfgtx)(struct genl_info *info);
	int	(*setpgcfgrx)(struct genl_info *info);
	int	(*getpgcfgtx)(struct genl_info *info);
	int	(*getpgcfgrx)(struct genl_info *info);
	int	(*setpfccfg)(struct genl_info *info);
	int	(*getpfccfg)(struct genl_info *info);
	int	(*setall)(struct genl_info *info);
} dcb_genl_ops;

	The entire module for all DCB netlink operations can be called
dcb_nl, and be built as a module.  The Kconfig option CONFIG_DCB can be
added, and can be used to include or omit the struct dcb_genl_ops
*dcb_ops member from the netdevice structure.

	NOTE: the (*setall) command applies all changes sent to the
driver.  This way all changes to Rx and Tx can be made to the device at
one time, and not leave the device in an unknown state.  This implies
the underlying implementation should store the new values from the
netlink interface in a temporary structure, and then apply it all when
(*setall) is invoked.

Purpose of the netlink interface:

- Provide a common interface for Data Center Bridging devices to
register into.  This includes 802.1Qaz priority grouping and 802.1Qbb
priority flow control mechanisms.
- The common interface will accept and process input from userspace and
send through to registered drivers.
- The common interface will accept and process input from registered
drivers and send to userspace.  This piece is required for the Data
Center Bridging Exchange protocol between link partners.

Commands:

	@DCB_CMD_UNDEFINED: unspecified command to catch errors
	@DCB_CMD_GSTATE: request the state of DCB in the device
	@DCB_CMD_SSTATE: set the state of DCB in the device
	@DCB_CMD_PGTX_GCFG: request the priority group configuration for
Tx
	@DCB_CMD_PGTX_SCFG: set the priority group configuration for Tx
	@DCB_CMD_PGRX_GCFG: request the priority group configuration for
Rx
	@DCB_CMD_PGRX_SCFG: set the priority group configuration for Rx
	@DCB_CMD_PFC_GCFG: request the priority flow control
configuration
	@DCB_CMD_PFC_SCFG: set the priority flow control configuration
	@DCB_CMD_SET_ALL: apply all changes to the underlying device
	@DCB_CMD_GPERM_HWADDR: get the permanent MAC address of the
underlying device.  Only useful when using bonding.

DCB configuration Attributes:

	@DCB_ATTR_UNDEFINED: unspecified attribute to catch errors
	@DCB_ATTR_IFNAME: interface name of the underlying device
(NLA_STRING)
	@DCB_ATTR_STATE: state of the DCB state machine in the device
(NLA_U8)
	@DCB_ATTR_PFC_CFG: priority flow control configuration
(NLA_NESTED)
	@DCB_ATTR_PG_CFG: priority group configuration (NLA_NESTED
	@DCB_ATTR_SET_ALL: bool to commit changes to hardware or not
(NLA_U8)
	@DCB_ATTR_PERM_HWADDR: MAC address of the physical device
(NLA_NESTED)

Permanent Hardware attributes:

	@DCB_PERM_HW_ATTR_UNDEFINED: unspecified attribute to catch
errors
	@DCB_PERM_HW_ATTR_0: MAC address from receive address 0 (NLA_U8)
	@DCB_PERM_HW_ATTR_1: MAC address from receive address 1 (NLA_U8)
	@DCB_PERM_HW_ATTR_2: MAC address from receive address 2 (NLA_U8)
	@DCB_PERM_HW_ATTR_3: MAC address from receive address 3 (NLA_U8)
	@DCB_PERM_HW_ATTR_4: MAC address from receive address 4 (NLA_U8)
	@DCB_PERM_HW_ATTR_5: MAC address from receive address 5 (NLA_U8)
	@DCB_PERM_HW_ATTR_ALL: apply to all MAC addresses (NLA_FLAG)

Priority Flow Control attributes:

	@DCB_PFC_ATTR_UP_UNDEFINED: unspecified attribute to catch
errors
	@DCB_PFC_ATTR_UP_0: Priority Flow Control setting for User
Priority 0 (NLA_U8)
	@DCB_PFC_ATTR_UP_1: Priority Flow Control setting for User
Priority 1 (NLA_U8)
	@DCB_PFC_ATTR_UP_2: Priority Flow Control setting for User
Priority 2 (NLA_U8)
	@DCB_PFC_ATTR_UP_3: Priority Flow Control setting for User
Priority 3 (NLA_U8)
	@DCB_PFC_ATTR_UP_4: Priority Flow Control setting for User
Priority 4 (NLA_U8)
	@DCB_PFC_ATTR_UP_5: Priority Flow Control setting for User
Priority 5 (NLA_U8)
	@DCB_PFC_ATTR_UP_6: Priority Flow Control setting for User
Priority 6 (NLA_U8)
	@DCB_PFC_ATTR_UP_7: Priority Flow Control setting for User
Priority 7 (NLA_U8)
	@DCB_PFC_ATTR_UP_MAX: highest attribute number currently defined
	@DCB_PFC_ATTR_UP_ALL: apply to all priority flow control
attributes (NLA_FLAG)

Priority Group Traffic Class and Bandwidth Group attributes:

	@DCB_PG_ATTR_UNDEFINED: unspecified attribute to catch errors
	@DCB_PG_ATTR_TC_0: Priority Group Traffic Class 0 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_1: Priority Group Traffic Class 1 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_2: Priority Group Traffic Class 2 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_3: Priority Group Traffic Class 3 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_4: Priority Group Traffic Class 4 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_5: Priority Group Traffic Class 5 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_6: Priority Group Traffic Class 6 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_7: Priority Group Traffic Class 7 configuration
(NLA_NESTED)
	@DCB_PG_ATTR_TC_MAX: highest attribute number currently defined
	@DCB_PG_ATTR_TC_ALL: apply to all traffic classes (NLA_NESTED)
	@DCB_PG_ATTR_BWG_0: Bandwidth group 0 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_1: Bandwidth group 1 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_2: Bandwidth group 2 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_3: Bandwidth group 3 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_4: Bandwidth group 4 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_5: Bandwidth group 5 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_6: Bandwidth group 6 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_7: Bandwidth group 7 configuration (NLA_U8)
	@DCB_PG_ATTR_BWG_MAX: highest attribute number currently defined
	@DCB_PG_ATTR_BWG_ALL: apply to all bandwidth groups (NLA_FLAG)

Traffic Class configuration attributes:

	@DCB_TC_ATTR_PARAM_UNDEFINED: unspecified attribute to catch
errors
	@DCB_TC_ATTR_PARAM_STRICT_PRIO: Type of strict bandwidth
aggregration (link strict or group strict) (NLA_U8)
	@DCB_TC_ATTR_PARAM_BW_GROUP_ID: Bandwidth group this traffic
class belongs to (NLA_U8)
	@DCB_TC_ATTR_PARAM_BW_PCT_IN_GROUP: Percentage of bandwidth in
the bandwidth group this traffic class has (NLA_U8)
	@DCB_TC_ATTR_PARAM_UP_MAPPING: Traffic class to user priority
map (NLA_U8)
	@DCB_TC_ATTR_PARAM_ALL: apply to all traffic class parameters
(NLA_FLAG
