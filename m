From: Michael Cronenworth <mike@cchtml.com>
Subject: Re: e1000e max frame calculation
Date: Mon, 06 Apr 2015 16:45:40 -0500
Message-ID: <5522FE84.6030104@cchtml.com>
References: <5522B685.2030104@cchtml.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta11.charter.net ([216.33.127.80]:43415 "EHLO
	mta11.charter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbbDFVpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:45:44 -0400
Received: from imp11 ([10.20.200.11]) by mta11.charter.net
          (InterMail vM.8.01.05.09 201-2260-151-124-20120717) with ESMTP
          id <20150406214543.KWAM5815.mta11.charter.net@imp11>
          for <netdev@vger.kernel.org>; Mon, 6 Apr 2015 17:45:43 -0400
Received: from impout006 ([68.114.189.21])
          by mtaout005.msg.strl.va.charter.net
          (InterMail vM.9.00.015.01 201-2473-143-101) with ESMTP
          id <20150406214543.SINS1172.mtaout005.msg.strl.va.charter.net@impout006>
          for <netdev@vger.kernel.org>; Mon, 6 Apr 2015 16:45:43 -0500
Received: from mcronenworth.nhsrx.com (unknown [63.237.119.62])
	by cchtml.com (Postfix) with ESMTPSA id 45AAC1540144
	for <netdev@vger.kernel.org>; Mon,  6 Apr 2015 16:45:42 -0500 (CDT)
In-Reply-To: <5522B685.2030104@cchtml.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preface: I am not here to start a discussion about header sizes or hardware limits. 
This is solely about the calculation used to limit a user when they pass a MTU to a 
driver.

On 04/06/2015 11:38 AM, Michael Cronenworth wrote:
> Other drivers appear to be using the "old" maximum frame calculation and can
> continue to use 9000.
>
> Can a standard be decided upon that all drivers use or is it acceptable that one
> driver "does its own thing?"

To be specific here are some examples of maximum MTU calculation and their tests:

sky2: user_mtu > ETH_JUMBO_MTU

r8169: user_mtu < ETH_ZLEN || user_mtu > (ETH_DATA_LEN||x*1024 - ETH_HLEN - 2)

igb:   user_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN > MAX_JUMBO_FRAME_SIZE

e1000e <3.15:  user_mtu + ETH_HLEN + ETH_FCS_LEN > adapter->max_hw_frame_size;

e1000e >=3.15: user_mtu + VLAN_HLEN + ETH_HLEN + ETH_FCS_LEN >
                   adapter->max_hw_frame_size;

Let's say the hardware has a limit of 4096 bytes. The user wishes to set an MTU of 
4078 bytes.

sky2: false, mtu is set

r8169: false, mtu is set

igb: true, mtu is not set

e1000e <3.15: false, mtu is set

e1000e <3.15: true, mtu is not set

So some drivers work with the 4078 MTU and some do not. They all had the same 
hardware limit, but their driver's software calculated limit was different. Am I crazy?

Thanks,
Michael
