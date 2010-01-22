From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Fri, 22 Jan 2010 09:18:42 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E07903231FED@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com> <1264146719.3469.5.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stefano.babic@babic.homelinux.org>, <randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:42522 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab0AVIUh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 03:20:37 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1264146719.3469.5.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel.

Marcel Holtmann wrote:
>> +/**
>> + * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
>> + * @u:			     Union of address data 'switched' by familty.
>> + * @at:			     Applies when family = CAIFPROTO_AT.
>> + * @at.type:		     Type of AT link to set up (enum caif_at_type).
>> + * @util:		     Applies when family = CAIFPROTO_UTIL
>> + * @util.service:	     Service name.
>> + * @dgm:		     Applies when family = CAIFPROTO_DATAGRAM
>> + * @dgm.connection_id:	     Datagram connection id.
>> + * @dgm.nsapi:		     NSAPI of the PDP-Context.
>> + * @rfm:		     Applies when family = CAIFPROTO_RFM
>> + * @rfm.connection_id:       Connection ID for RFM.
>> + * @rfm.volume:	     	     Volume to mount.
>> + */
>> +struct sockaddr_caif {
>> +	sa_family_t  family;
>> +	union {
>> +		struct {
>> +			u_int8_t  type;		/* type: enum caif_at_type */
>> +		} at;				/* CAIFPROTO_AT */
>> +		struct {
>> +			char	  service[16];
>> +		} util;				/* CAIFPROTO_UTIL */
>> +		union {
>> +			u_int32_t connection_id;
>> +			u_int8_t  nsapi;
>> +		} dgm;				/* CAIFPROTO_DATAGRAM(_LOOP)*/
>> +		struct {
>> +			u_int32_t connection_id;
>> +			char	  volume[16];
>> +		} rfm;				/* CAIFPROTO_RFM */
>> +	} u;
>> +};
> 
> as mentioned on the oFono mailing list, what is the right procedure
> to select a local CAIF device for usage with doing bing(). The use
> case I am thinking of is that you have multiple CAIF device attached
> to the same system. Think of desktops with USB or even Dual-SIM
> phones. Before we set the API in stone, we need to have a way o bind
> the socket to a specific device. Maybe it is possible, but I am
> missing it.      

The CAIF interface can be selected by using the following types:
[snip caif_config.h]
/**
 * enum caif_phy_preference  - Types of physical HW interfaces
 *				       towards modem defined in CAIF stack
 * @CAIF_PHYPREF_UNSPECIFIED:	Default physical interface
 * @CAIF_PHYPREF_LOW_LAT:	Default physical interface for low-latency
 *				      traffic
 * @CAIF_PHYPREF_HIGH_BW:	Default physical interface for high-bandwidth
 *				      traffic
 * @CAIF_PHYPREF_LOOP:		TEST Loopback interface, simulating modem
 *				      responses
 *
 * For client convenience, two special types are defined:
 * CAIF_PHYPREF_LOW_LAT is the preferred low-latency physical link.
 * Typically used for "control" purposes.
 * CAIF_PHYPREF_HIGH_BW is the preferred high-bandwidth physical link.
 * Typically used for "payload" purposes.
 */
...
enum caif_phy_preference {
	CAIF_PHYPREF_UNSPECIFIED,
	CAIF_PHYPREF_LOW_LAT,
	CAIF_PHYPREF_HIGH_BW,
	CAIF_PHYPREF_LOOP
};
[snip caif_socket.h]
...
/**
 * struct caif_channel_opt - CAIF channel connect options.
 * @priority:		Priority of the channel (between 0 and 0x1f)
 * @link_selector:	Selector for the physical link.
 *			      (see enum caif_phy_preference in caif_config.h)
 * @link_name:		Physical link to use. This is the instance name of the
 *			      CAIF Physical Driver.
 */
struct caif_channel_opt {
	u_int16_t  priority;
	u_int16_t  link_selector;
	char	   link_name[16];
};
...
/** enum caif_socket_opts - CAIF option values for getsockopt and setsockopt
 * @CAIFSO_CHANNEL:		Used to set the connect options on a CAIF
 *				socket. (struct caif_config_opt). This can only
 *				be set before connecting.
[end snip]

CAIFSO_CHANNEL is used for specifying the physical interface to use for the 
CAIF Channel. You can select the type of interface to use
by setting link_selector:
CAIF_PHYPREF_LOW_LAT will typically be used for AT (or other control traffic),
and CAIF_PHYPREF_HIGH_BW for IP traffic.
When the CAIF interfaces registers itself it will inform about their type,
(low-latency or high-bandwidth). This approach assumes that you have only one
modem, but multiple links to it (e.g. USB and UART). 

But you can also specify interface by name using link_name. In this case
you specify the name of the interface to use. I think this would support
your use case with multiple modems attached.

BR/Sjur
