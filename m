From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] ax25: unsigned cannot be less than 0 in ax25_ctl_ioctl()
Date: Wed, 14 Oct 2009 17:26:30 +0200
Message-ID: <4AD5EDA6.4040709@gmail.com>
References: <4AD0FB0B.8050609@gmail.com> <4AD34D3C.1060206@bfs.de> <4AD37D44.9050207@gmail.com> <4AD3A67B.6070703@cerebellum.kd>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wharms@bfs.de, linux-hams@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Joerg Reuter <jreuter@yaina.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Kevin Dawson <kevind@esi.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:61859 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761864AbZJNPRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 11:17:43 -0400
In-Reply-To: <4AD3A67B.6070703@cerebellum.kd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct ax25_ctl_struct member `arg' is unsigned and cannot be less
than 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Op 12-10-09 23:58, Kevin Dawson schreef:

>>>  tmp_arg=ax25_ctl.arg * HZ;
>>>
>>>   if (arg == 0 || arg >  ULONG_MAX )
>>>         goto einval_put;
>>
>> I'm not sure, I think this would only work if we made `arg' an
>> unsigned long long.
> 
> That depends on the possible values of ax25_ctl.arg.
> 
>> +    if (ax25_ctl.arg * HZ > ULONG_MAX && ax25_ctl.cmd != AX25_KILL)
>> +        return -EINVAL;
> 
> Why the need to change arg before comparing it with a constant?  Let the
> compiler do the work:
> 
>     if (ax25_ctl.arg > ULONG_MAX / HZ && ...

Ok, How about this then?

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index f454607..d923ac4 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -369,6 +369,9 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 	if (ax25_ctl.digi_count > AX25_MAX_DIGIS)
 		return -EINVAL;
 
+	if (ax25_ctl.arg > ULONG_MAX / HZ && ax25_ctl.cmd != AX25_KILL)
+		return -EINVAL;
+
 	digi.ndigi = ax25_ctl.digi_count;
 	for (k = 0; k < digi.ndigi; k++)
 		digi.calls[k] = ax25_ctl.digi_addr[k];
@@ -418,14 +421,10 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 		break;
 
 	case AX25_T3:
-		if (ax25_ctl.arg < 0)
-			goto einval_put;
 		ax25->t3 = ax25_ctl.arg * HZ;
 		break;
 
 	case AX25_IDLE:
-		if (ax25_ctl.arg < 0)
-			goto einval_put;
 		ax25->idle = ax25_ctl.arg * 60 * HZ;
 		break;
 
