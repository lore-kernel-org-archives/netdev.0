From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC PATCH v3  2/8] CAIF Protocol Stack
Date: Thu, 10 Dec 2009 12:20:26 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E0790311F06B@eseldmw101.eemea.ericsson.se>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <4B1EECEC.5080903@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <randy.dunlap@oracle.com>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>,
	"Christian Bejram" <christian.bejram@stericsson.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:62622 "EHLO
	mailgw3.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760672AbZLJLUX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 06:20:23 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B1EECEC.5080903@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefano.

stefano babic wrote:
>> +enum caif_ctrlcmd {
>> +	/** Flow Control is OFF, transmit function should stop sending
>> data */ +	CAIF_CTRLCMD_FLOW_OFF_IND = 0,
>> +	/** Flow Control is ON, transmit function can start sending data */
>> +	CAIF_CTRLCMD_FLOW_ON_IND = 1,
>> +	/** Remote end modem has decided to close down channel */
>> +	CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND = 5,
> 
> Not really important, but is there some reason to not put them in
> order ? 
Good question, I don't remember why it ended up like this. I'll fix this up by
removing the assignment in the enum.
> 
> 
>> diff --git a/include/net/caif/generic/cfcnfg.h
>> b/include/net/caif/generic/cfcnfg.h
>> +/** Physical preference - HW Abstraction */ enum
>> +cfcnfg_phy_preference {
>> +	/** Default physical interface */
>> +	CFPHYPREF_UNSPECIFIED = 0xa0,
>> +	/** Default physical interface for low-latency traffic */
>> +	CFPHYPREF_LOW_LAT = 0xd0, +	/** Default physical interface for
>> high-bandwidth traffic */ +	CFPHYPREF_HIGH_BW = 0xe0, +	/** \b TEST
>> \b ONLY Loopback interface simulating modem responses */
>> +	CFPHYPREF_LOOP = 0x70, +	/** \b TEST \b ONLY Raw loopback
>> interface */ +	CFPHYPREF_RAW_LOOP = 0x80 +};
> 
> Different context, but preferences have always the same values. Could
> we remove the duplicates ? 
At some point I was thinking on or-ing preferences together.
This is no longer done and I think I'd rather skip the assignment
of values.

However on the subject of duplications, I have found some issues.
When I e.g. grep for UNSPECIFIED I get:
include/linux/caif/caif_socket.h:	CAIF_LINK_UNSPECIFIED	= 0x00,
include/linux/caif/caif_config.h:	CAIF_PHYPREF_UNSPECIFIED = 0x00,
include/net/caif/caif_actions.h:	CAIF_PHY_UNSPECIFIED = 0x00,
include/net/caif/generic/cfcnfg.h:	CFPHYPREF_UNSPECIFIED = 0xa0,

There are some types that are duplicated in different places for CAIF, 
but this is done for a reason.
* caif_socket.h header file is self-contained and defines types needed for
  setting up CAIF Connections.
* caif_kernel.h provides a interface for CAIF connections from kernel modules.
* The modules inside net/caif/generic include/net/caif/generic are designed to 
  be a generic CAIF Stack. 

As you might have noticed the CAIF stack residing in "generic" is designed to
be a generic CAIF implementation. This implies that if must be self-contained 
and not depend on caif_socket.h and caif_kernel.h. This allows CAIF protocol
implementation to be tested in user space test-applications and CAIF to be 
portable. The file cfglue.h contains wrappers for the Kernel Specific functions. 

Due to this you'll find duplicated information in structs like caif_channel_config, 
sockaddr_caif, cfctrl_link_param. One example of the effect of this is the following:

[snip from caif_dev.c]
int caifdev_adapt_register(struct caif_channel_config *config,
			   struct layer *adap_layer)
{
	struct cfctrl_link_param param;
	if (channel_config_2_link_param(get_caif_conf(), config, &param) == 0) <--
									-- Convert from caif_channel_config
									-- to cfctrl_link_param  
		if (cfcnfg_add_adaptation_layer(get_caif_conf(), <-- Wrap the generic function
						&param, adap_layer))
			return 0;
	return -EINVAL;
}

> 
>> +/** Configuration parameters for a physical layer (e.g. serial) */
>> +struct cfcnfg_phy_param { +	int foo;
>> +};
> 
> This structure is obsolete and can be safely dropped.
Yes you're right. Thanks for pointing this out, I have forgotten to remove some
obsolete functions and types here. I need to clean this up.

> 
>> +/**
>> + * These variable is used as a global flag, in order to configure
>> padding on SPI communication. + * NOTE: This is not a fully
>> future-proof solution. + */
> 
> I understand that the padding is due to the fact that a lot of spi
> controller can send only words and not bytes. However, this is very
> processor specific. Probably when you will add the SPI layer you will
> need to add a way to set up this issue. 
Yes, these parameters are module parameters to the SPI physical driver,
and they change on different platforms due to DMA specifics etc.
As mentioned before we're moving all SPI handling down to the SPI driver, 
so all SPI related code will be gone in the next patch-set.

BR/Sjur
