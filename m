From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Fri, 19 Dec 2014 11:07:32 +0100
Message-ID: <20141219110732.53264ef8@griffin>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com>
	<1418920017.9773.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<17951.1418924367@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com, Stefan Assmann <sassmann@redhat.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696AbaLSKH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 05:07:58 -0500
In-Reply-To: <17951.1418924367@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 09:39:27 -0800, Jay Vosburgh wrote:
> 	I've actually been looking into this "hw csum failure" (as it
> appears with OVS and VXLAN) the last couple of days, and, at least on
> the sky2 hardware I have, the problem doesn't appear to be the
> hardware's CHECKSUM_COMPLETE checksumming.

With the enic driver, the problem _is_ the hardware checksumming.

While debugging the "hw csum failure" messages, I verified the checksum
returned by the hardware directly in the driver (in
enic_rq_indicate_buf). It appears that for some packets (most notably
ICMP ones), the hardware returns 0xffff. I did not see any other wrong
value, in other words, the returned checksum was either correct, or
0xffff.

I have no idea whether the hardware verified the checksum for the
0xffff case and is just not returning the checksum or whether such
packets come completely unverified.

As for Govindarajulu's patch, I believe we can do better. First, its
description does not match what I'm seeing (I see correct checksum
provided in most cases) and second, the driver should provide
CHECKSUM_COMPLETE whenever possible; and it seems to be possible.

> 	I've also not tested it on enic hardware.  Govindarajulu, would
> you be able to test this against the unmodified enic driver and see if
> it resolves the problem for you?

I'm quite sure it does not, the skb->csum field is incorrect even
before the skb enters the stack.

 Jiri

-- 
Jiri Benc
