From: Santwona.Behera@Sun.COM
Subject: Re: [PATCH 2/3] Add support for RX packet classification in a	network
 device
Date: Mon, 22 Dec 2008 15:04:15 -0800
Message-ID: <49501CEF.8010101@Sun.COM>
References: <494FE060.8020600@Sun.COM> <1229974033.3077.14.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:62665 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334AbYLVXE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 18:04:27 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id mBMN4MiN001265
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2008 15:04:22 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0KCA00K01VSR8X00@fe-sfbay-09.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Mon,
 22 Dec 2008 15:04:22 -0800 (PST)
In-reply-to: <1229974033.3077.14.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/22/08 11:27 AM, Ben Hutchings wrote:
> On Mon, 2008-12-22 at 10:45 -0800, Santwona.Behera@Sun.COM wrote:
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index b4b038b..d3289b0 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -55,12 +55,13 @@ struct ethtool_drvinfo {
>>         char    bus_info[ETHTOOL_BUSINFO_LEN];  /* Bus info for this IF. */
>>                                 /* For PCI devices, use pci_name(pci_dev). */
>>         char    reserved1[32];
>> -       char    reserved2[12];
>> +       char    reserved2[8];
>>         __u32   n_priv_flags;   /* number of flags valid in ETHTOOL_GPFLAGS */
>>         __u32   n_stats;        /* number of u64's from ETHTOOL_GSTATS */
>>         __u32   testinfo_len;
>>         __u32   eedump_len;     /* Size of data from ETHTOOL_GEEPROM (bytes) */
>>         __u32   regdump_len;    /* Size of data from ETHTOOL_GREGS (bytes) */
>> +       __u32   n_rx_rules;     /* number of rx classification rules */
>>  };
> 
> This shifts all the fields between n_priv_flags and regdump_len
> inclusive.  What is the point of reserving space in the structure if we
> then go and move fields around elsewhere?
> 
> Also, why do you think n_rx_rules is driver or hardware information?
> The maximum number of RX filters is not necessarily a static property.
> Consider hardware that has separate limited-size sets of layer-2 and
> layer-3 filters, or that has a single set but needs more storage for
> some types of filters.
> 
> The important value is the current number of rules which is dynamic and
> does not belong here.
> 
> [...]


OK, I will move this to the ethtool_rxnfc struct.

>> @@ -558,14 +626,16 @@ struct ethtool_ops {
>>  #define        TCP_V4_FLOW     0x01
>>  #define        UDP_V4_FLOW     0x02
>>  #define        SCTP_V4_FLOW    0x03
>> -#define        AH_ESP_V4_FLOW  0x04
>> -#define        TCP_V6_FLOW     0x05
>> -#define        UDP_V6_FLOW     0x06
>> -#define        SCTP_V6_FLOW    0x07
>> -#define        AH_ESP_V6_FLOW  0x08
>> +#define        AH_V4_FLOW      0x04
>> +#define        ESP_V4_FLOW     0x05
>> +#define        TCP_V6_FLOW     0x06
>> +#define        UDP_V6_FLOW     0x07
>> +#define        SCTP_V6_FLOW    0x08
>> +#define        AH_V6_FLOW      0x09
>> +#define        ESP_V6_FLOW     0x0a
>> +#define        IP_USER_FLOW    0x0b
>>  
>>  /* L3-L4 network traffic flow hash options */
>> -#define        RXH_DEV_PORT    (1 << 0)
>>  #define        RXH_L2DA        (1 << 1)
>>  #define        RXH_VLAN        (1 << 2)
>>  #define        RXH_L3_PROTO    (1 << 3)
> [...]
> 
> No, you can't do this.  Leave the existing definitions unchanged and
> only add new ones.

The original code/patch was not quite correct where the AH_ESP_V4_FLOW 
was being used to represent AH flows. So my goal here was to remove that 
and add 2 separate flow types for AH and ESP. I have two ways of 
achieving this without changing the existing definitions completely:

1. I change AH_ESP_Vx_FLOW defines to AH_Vx_FLOW defines and add 2 new 
defines for ESP_Vx_FLOW at the end, with values 0x9 and 0xa.

2. I keep the AH_ESP_Vx_FLOW defines as is (but this will be dead code 
as it will not be used) and add 2 new AH_Vx_FLOW defines and 2 new 
ESP_Vx_FLOW defines at the end with values 0x9, 0xa, 0xb, 0xc.

Please let me know which one is more desirable.

rgds,
--santwona
