From: Raimonds Cicans <ray@apollo.lv>
Subject: Re: r8169: fix driver drop incoming packets >= 1515 if MTU is set
 between 1515 and 1536
Date: Wed, 11 Nov 2009 22:05:35 +0200
Message-ID: <4AFB190F.2020009@apollo.lv>
References: <4AFB0061.7020908@apollo.lv> <1257964419.2839.58.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.apollo.lv ([80.232.168.211]:41831 "EHLO smtp1.apollo.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388AbZKKUFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 15:05:32 -0500
In-Reply-To: <1257964419.2839.58.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings:
> On Wed, 2009-11-11 at 20:20 +0200, Raimonds Cicans wrote:
>> Driver drop incoming packets >= 1515(1) if MTU is set between 1515(1) and 1536.
>>
>> 1) exact number depends on some factors:
>> - VLAN tagged or not
>> - patch "r8169: Fix card drop incoming VLAN tagged MTU byte large jumbo frames"
>>   applied or not
> [...]
> 
> MTU is a limit on transmission; it is not required to limit received
> frames.

???

In r8169 driver MTU is used to calculate receive buffer size.
Receive buffer size is used to configure hardware incoming packet filter.

For jumbo frames:
Receive buffer size = Max frame size = MTU + 14 (ethernet header) + 4
(vlan header) + 4 (ethernet checksum) = MTU + 22

Bug:
driver for all MTU up to 1536 use receive buffer size 1536

As you can see from formula, this mean all IP packets > 1536 - 22
(for vlan tagged, 1536 - 18 for not tagged) are dropped by hardware
filter.

Example:

host_good>  ifconfig eth0 mtu 1536
host_r8169> ifconfig eth0 mtu 1536
host_good>  ping host_r8169
Ok
host_good>  ping -s 1500 host_r8169
Fail
host_good>  ifconfig eth0 mtu 7000
host_r8169> ifconfig eth0 mtu 7000
host_good>  ping -s 1500 host_r8169
Ok

Raimonds Cicans

