From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [RFC 04/12] ndisc: get rid off dev parameter in
 ndisc_opt_addr_space
Date: Fri, 27 May 2016 20:54:08 +0200
Message-ID: <3486f153-6e3f-4514-9d67-61a21aca458f@pengutronix.de>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
 <1464031328-17524-5-git-send-email-aar@pengutronix.de>
 <574534F8.20308@miraclelinux.com>
 <0f311957-d645-422a-bf58-9aa3412b0bb4@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, stefan@osg.samsung.com,
	mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:33177 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbcE0Sy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 14:54:27 -0400
In-Reply-To: <0f311957-d645-422a-bf58-9aa3412b0bb4@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Hannes,

On 05/27/2016 06:56 PM, Hannes Frederic Sowa wrote:
> On 25.05.2016 07:15, YOSHIFUJI Hideaki wrote:
>>
>>
>> Alexander Aring wrote:
>>> This patch removes the net_device parameter from ndisc_opt_addr_space
>>> function. This can be useful for calling such functionality which
>>> doesn't depends on dev parameter. For current existing functionality
>>> which depends on dev parameter, we introduce ndisc_dev_opt_addr_space to have
>>> an easy replacement for the ndisc_opt_addr_space function.
>>>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>>> Cc: James Morris <jmorris@namei.org>
>>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>>> Cc: Patrick McHardy <kaber@trash.net>
>>> Signed-off-by: Alexander Aring <aar@pengutronix.de>
>>> ---
>>>  include/net/ndisc.h | 13 +++++++++----
>>>  net/ipv6/ndisc.c    | 12 ++++++------
>>>  2 files changed, 15 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
>>> index 2d8edaa..dbc8d01 100644
>>> --- a/include/net/ndisc.h
>>> +++ b/include/net/ndisc.h
>>> @@ -127,10 +127,15 @@ static inline int ndisc_addr_option_pad(unsigned short type)
>>>  	}
>>>  }
>>>  
>>> -static inline int ndisc_opt_addr_space(struct net_device *dev)
>>> +static inline int ndisc_opt_addr_space(unsigned char addr_len, int pad)
>>>  {
>>> -	return NDISC_OPT_SPACE(dev->addr_len +
>>> -			       ndisc_addr_option_pad(dev->type));
>>> +	return NDISC_OPT_SPACE(addr_len + pad);
>>> +}
>>> +
>>> +static inline int ndisc_dev_opt_addr_space(const struct net_device *dev)
>>> +{
>>> +	return ndisc_opt_addr_space(dev->addr_len,
>>> +				    ndisc_addr_option_pad(dev->type));
>>>  }
>>>  
>>
>> I prefer not to change existing functions such as ndisc_opt_addr_space(),
>> and name new function __ndisc_opt_addr_space() etc.
>>
>> Plus, my original thought (when I implement these functions) was to
>> have per-net_device ndisc_opt_addr_spece(), ndisc_opt_adr_data() etc.
>>
>> What do you think of that?
> 
> As I understood it 6lowpan devices need to handle both, non-compressed
> and compressed options/addresses. Probably one can make them
> per-interface, but a change to the arguments has still to happen.
> 

Yes, we need to handle both addresses at the same time.

I think you mixed some keywords here: "non-compressed/compressed", it
should be extended(sometimes also named long) and short address.

But the short address is an optional address, the extended address is
always available (that's why we handle them as dev->addr).

I suppose Hideaki suggest here to don't rename the function, what I have
now is:

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 2d8edaa..4cee826 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -127,10 +127,15 @@ static inline int ndisc_addr_option_pad(unsigned short type)
 	}
 }
 
+static inline int __ndisc_opt_addr_space(unsigned char addr_len, int pad)
+{
+	return NDISC_OPT_SPACE(addr_len + pad);
+}
+
 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
-	return NDISC_OPT_SPACE(dev->addr_len +
-			       ndisc_addr_option_pad(dev->type));
+	return __ndisc_opt_addr_space(dev->addr_len,
+				      ndisc_addr_option_pad(dev->type));
 }
 
 static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
