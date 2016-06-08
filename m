From: Alan Davey <Alan.Davey@metaswitch.com>
Subject: RE: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Wed, 8 Jun 2016 08:41:31 +0000
Message-ID: <BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
 <20160531.113913.1477085966766110028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0131.outbound.protection.outlook.com ([157.56.110.131]:51254
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422927AbcFHIlg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 04:41:36 -0400
In-Reply-To: <20160531.113913.1477085966766110028.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Thank you for your email.  I understand raw IP sockets have worked this way for a long time, but I think that there is real benefit in this patch for little risk.  Please take a look at the following and let me know what you think.

-  The current behaviour is counter-intuitive (fragmentation takes place in all other cases) and therefore different to what everyone expects.

-  Consequently, everyone has to fix the same bug and work around it by fragmenting in their application (we have seen this happen several dozen times just in our experience).

-  The end result is that the fragmentation code ends up being implemented in many places, instead of just once, using the existing kernel code.

-  The patch is a low risk fix; removing 5 lines of code and using existing code to perform the fragmentation.  It should be back-compatible because
    o  existing code written to work round the feature will continue to work
    o  it seems very unlikely that anyone relies on the current behaviour of oversized packets being rejected, and would not prefer the new behavior.  

Therefore, whether it is a bug or a feature, I think there is value in fixing the behaviour.

Regards
Alan

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: 31 May 2016 19:39
To: Alan Davey <Alan.Davey@metaswitch.com>
Cc: netdev@vger.kernel.org; kuznet@ms2.inr.ac.ru; jmorris@namei.org; yoshfuji@linux-ipv6.org; kaber@trash.net
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is set.

From: Alan Davey <alan.davey@metaswitch.com>
Date: Mon, 23 May 2016 15:23:45 +0100

> One of the bugs documented in the raw(7) man page is as follows: When 
> the IP_HDRINCL option is set, datagrams will not be fragmented and are 
> limited to the interface MTU.
> 
> This patch fixes the bug by removing the check for "length > rt->dst.dev->mtu"
> in raw_send_hdrinc() (net/ipv4/raw.c).  Datagrams are no longer 
> limited to the interface MTU size if the IP_HDRINCL option is set, but 
> are fragmented, if necessary, in the same way as all other datagrams.
> 
> Signed-off-by: Alan Davey <alan.davey@metaswitch.com>

This is not a bug, it's a feature and it's how RAW ipv4 sockets have behaved for two decades.

If the user wants to use hdr inclusion, he can send multiple frames and set the fragmentation bits appropriately.

I'm not applying this patch.
