From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 06 Dec 2006 18:36:56 -0600
Message-ID: <45776228.2050005@lwfinger.net>
References: <4576D778.mailLQC18T1PN@lwfinger.net> <200612062152.36475.mb@bu3sch.de> <20061206215101.GA24100@p15091797.pureserver.info> <200612062351.07016.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:42567 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937841AbWLGAh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:37:26 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612062351.07016.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Wednesday 06 December 2006 22:51, Ulrich Kunitz wrote:
>> On 06-12-06 21:52 Michael Buesch wrote:
>>
>>> On Wednesday 06 December 2006 21:17, Ulrich Kunitz wrote:
>>>> On 06-12-06 18:52 Michael Buesch wrote:
>>>>
>>>>> All data in mac->associnfo is protected by mac->associnfo->mutex
>>>>> and _not_ mac->lock.
>>>> Are you sure?
>>> Yes I am.
>>>
>>>> One can find for instance the following function in 
>>>> ieee80211softmac_assoc.c:
>>> This is not the first time we notice that locking
>>> is completely broken in softmac. ;)
>> So the right thing would be to add another work function
>> (*_start_reassoc_work) which sets the associating variable and
>> calls then *_assoc_work? 
> 
> Ah, well. I think the right thing doesn't exist.
> Even if you replace the lock by the mutex, it's still racy.
> The whole lock design of softmac is broken and racy and we
> can't simply fix that with a oneliner.
> 
> I'd say, John, apply the original patch as-is, as it does
> more good than harm.
> 
> Basically, I just wanted to point out that this is not race-free.
> But I think we can live with it.

In struct ieee80211softmac_device, there are the following entries:
...
	spinlock_t lock;

         u8 running; /* SoftMAC started? */
         u8 scanning;

         struct ieee80211softmac_scaninfo *scaninfo;
         struct ieee80211softmac_assoc_info associnfo;
         struct ieee80211softmac_bss_info bssinfo;
...

In struct ieee80211softmac_assoc_info, we have the following entries:

         struct mutex mutex;
         struct ieee80211softmac_essid associate_essid;
         char bssid[ETH_ALEN];
         u8 static_essid;
         u8 short_preamble_available;
         u8 associating;
         u8 associated;
         u8 assoc_wait;
         u8 bssvalid;
         u8 bssfixed;

Although it has been amply demonstrated in this forum that I know nothing about locking, it seems to 
me that the mutex protects only the association data; whereas the spinlock protects more data, but 
does include the association data. If this is correct, then the original posted code is not wrong, 
only protecting data unnecessarily.

Please point out the error in my logic. I'm trying to learn.

Larry


