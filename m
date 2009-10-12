From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] ax25: unsigned cannot be less than 0 in ax25_ctl_ioctl()
Date: Mon, 12 Oct 2009 21:02:28 +0200
Message-ID: <4AD37D44.9050207@gmail.com>
References: <4AD0FB0B.8050609@gmail.com> <4AD34D3C.1060206@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Joerg Reuter <jreuter@yaina.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: wharms@bfs.de
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4AD34D3C.1060206@bfs.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct ax25_ctl_struct member `arg' is unsigned and cannot be less
than 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
>> If the ax25_ctl.arg limit is known to be lower, please suggest
>> other values.

> what is about something like:
> 
>  tmp_arg=ax25_ctl.arg * HZ;
> 
>   if (arg == 0 || arg >  ULONG_MAX )
> 		goto einval_put;
> 
> re,
>  wh

I'm not sure, I think this would only work if we made `arg' an
unsigned long long.

How about this?

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index f454607..20ff0f3 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -369,6 +369,9 @@ static int ax25_ctl_ioctl(const unsigned int cmd, void __user *arg)
 	if (ax25_ctl.digi_count > AX25_MAX_DIGIS)
 		return -EINVAL;
 
+	if (ax25_ctl.arg * HZ > ULONG_MAX && ax25_ctl.cmd != AX25_KILL)
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
 
