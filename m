From: "Bonitch, Joseph" <Joseph.Bonitch@xerox.com>
Subject: RE: IPV6 stateless address autoconfiguration
Date: Wed, 14 May 2008 16:05:08 -0400
Message-ID: <BECE1C148A85274EB554378A3E0EDF490642ED58@USA0300MS02.na.xerox.net>
References: <OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com><20080513.021736.125105716.yoshfuji@linux-ipv6.org><BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net> <20080513.104215.82952085.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wbmler1.mail.xerox.com ([13.13.138.216]:37450 "EHLO
	wbmler1.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759786AbYENUFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 16:05:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080513.104215.82952085.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> In article
> <BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net>
> (at Mon, 12 May 2008 15:36:57 -0400), "Bonitch, Joseph"
> <Joseph.Bonitch@xerox.com> says:   
> 
>> I did some testing with the second patch.  My router is still
>> configured to send RA's with prefix information valid_lft =
>> preferred_lft = 0xffffffff. It works except for one thing: the
>> initial prefix route (after the 
>> first RA) shows an expire time when using
>>    ip -6 route list
>> If I keep checking I can see the expires time counting down.  After
>> some minutes the expires field disappeares from the ip -6 route list
>> output. 
>> I tracked it down and it looks like when a subsequent RA is received
>> with the same prefix is when the expires time stops showing up.
> 
> Thanks.  I had missed sevral other users of addrconf_prefix_route().
> Please try this.
> 

Yoshfuji,

I tested your latest patch to addrconf.c.  It worked but I still had the
problem that the prefix routes had an expiry time until the second
RA was received.

I tracked it down to ip6_route_add() inside route.c: lifetime passed
in was not checked for 0.  I made a minor change (see below) and
now it is working as expected.

Regards,

Joe

diff --git a/route.c.orig b/route.c
index 5f0043c..2c23d67 100644
--- a/route.c.orig
+++ b/route.c
@@ -1069,7 +1069,7 @@ int ip6_route_add(struct fib6_config *cfg)
        }

        rt->u.dst.obsolete = -1;
-       rt->rt6i_expires = jiffies + clock_t_to_jiffies(cfg->fc_expires);
+       rt->rt6i_expires = (cfg->fc_expires) ? jiffies + clock_t_to_jiffies(cfg->fc_expires) : 0;

        if (cfg->fc_protocol == RTPROT_UNSPEC)
                cfg->fc_protocol = RTPROT_BOOT;
