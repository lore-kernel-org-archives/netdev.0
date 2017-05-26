From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v3] ibmvnic: Enable TSO support
Date: Fri, 26 May 2017 15:35:52 -0400 (EDT)
Message-ID: <20170526.153552.136103281054991565.davem@redhat.com>
References: <1495815346-5638-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60630 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753852AbdEZTfy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 15:35:54 -0400
In-Reply-To: <1495815346-5638-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Fri, 26 May 2017 11:15:46 -0500

> Enable TSO in the ibmvnic driver. Scatter-gather is also enabled,
> though there currently is no support for scatter-gather in
> vNIC-compatible hardware, resulting in forced linearization
> of all fragmented SKB's. Though not ideal, given the throughput
> improvement gained by enabling TSO, it has been decided
> that this is an acceptable tradeoff.
> 
> The feature is also enabled by a module parameter.
> This parameter is necessary because TSO can not easily be
> enabled or disabled in firmware without reinitializing the driver.
> 
> CC: Nathan Fontenot <nfont@linux.vnet.ibm.com>
> CC: John Allen <jallen@linux.vnet.ibm.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
> v3: Remove module parameter, TSO will be set through ethtool
>     include ibmvnic_fix_features to manage scatter-gather
> v2: Fix kbuild robot warning from module parameter init

You're only dealing with half of my feedback.

I stated, explicitly, that you're only probably getting a performance
increase with TSO even though it is being software split up before
being sent by the device, because you don't implement xmit_more.

It makes zero sense, to have the networking stack do such an enormous
amount of wasted work putting the TSO segments together just to then
split them apart and linearize the whole packet before transmit.

That should have been a huge red flag for you, and caused you to
inspect further what the true reason is why performance still
increases with all of that happening.

Please look into this further, because I am quite convinced that
you have TX doorbell and VM exit overhead issues at hand, which
would be more properly and suitable dealt with by xmit_more which
is designed _specifically_ to target that apsect of virtual
networking driver performance.

Thanks.
