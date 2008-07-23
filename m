From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Wed, 23 Jul 2008 06:20:36 +0000
Message-ID: <20080723062036.GA4561@ff.dom.local>
References: <20080722.160409.216536011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:38650 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbYGWGPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 02:15:30 -0400
Received: by nf-out-0910.google.com with SMTP id d3so800443nfc.21
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 23:15:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080722.160409.216536011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23-07-2008 01:04, David Miller wrote:
> From: Larry Finger <Larry.Finger@lwfinger.net>
> Date: Tue, 22 Jul 2008 13:39:08 -0500
> 
>> =============================================
>> [ INFO: possible recursive locking detected ]
>> 2.6.26-Linus-05752-g93ded9b-dirty #53
>> ---------------------------------------------
>> b43/1997 is trying to acquire lock:
>>   (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
>> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
>>
>> but task is already holding lock:
>>   (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
>> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
...
> Lockdep doesn't like that we have an array of objects (the TX queues)
> and we're iterating over them grabbing all of their locks.
> 
> Does anyone know how to teach lockdep that this is OK?

I guess, David Miller knows...:

http://permalink.gmane.org/gmane.linux.network/99784

Jarek P.

PS: if there is nothing new in lockdep the classical method would
be to change this static array:

static struct lock_class_key
netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];

to

static struct lock_class_key
netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)][MAX_NUM_TX_QUEUES];

and set lockdep classes per queue as well. (If we are sure we don't
need lockdep subclasses anywhere this could be optimized by using
one lock_class_key per 8 queues and spin_lock_nested()).
