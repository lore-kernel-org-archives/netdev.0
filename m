From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH] ieee80211softmac: Fix errors related to the work_struct
 changes
Date: Mon, 11 Dec 2006 11:34:15 -0600
Message-ID: <457D9697.4090206@lwfinger.net>
References: <20061210173908.GB29871@p15091797.pureserver.info>	<200612101849.47179.mb@bu3sch.de>	<20061210183536.GC29871@p15091797.pureserver.info> <20061210104056.572db071.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Kunitz <kune@deine-taler.de>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:49112 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762992AbWLKRec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 12:34:32 -0500
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061210104056.572db071.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sun, 10 Dec 2006 19:35:36 +0100
> Ulrich Kunitz <kune@deine-taler.de> wrote:
> 
>> The problem is that you there are now different work structures:
>> struct work_struct and struct delayed_work. The quick fix seems to
>> have been to change all old work_structs as associnfo's work to
>> delayed_work. The way the structures are designed calling
>> schedule_work or schedule_delayed_work doesn't matter, but you
>> will get a gcc warning, because the pointer types are not
>> identical. This change works around the warning in the same way as
>> the other schedule_work calls for associnfo's work.
> 
> David proposed the below.  Does it fix things for you?
> 
> --- a/net/ieee80211/softmac/ieee80211softmac_assoc.c~workstruct-fix-ieee80211-softmac-compile-problem
> +++ a/net/ieee80211/softmac/ieee80211softmac_assoc.c
> @@ -438,7 +438,7 @@ ieee80211softmac_try_reassoc(struct ieee
>  
>  	spin_lock_irqsave(&mac->lock, flags);
>  	mac->associnfo.associating = 1;
> -	schedule_work(&mac->associnfo.work);
> +	schedule_delayed_work(&mac->associnfo.work, 0);
>  	spin_unlock_irqrestore(&mac->lock, flags);
>  }
>  
> _
> 
>> I'm not sure, whether the breaking of the workqueue API is really
>> worth it. What I see is that the change introduced choices and
>> choices make things more complex.
> 
> It is kinda sucky.  But it saves a bit of space in kernel data structures.

The above patch fixes a compile problem; however, the code still hangs when the network is started.
You need two additional hunks as shown below.

Larry
=========================================================================

From: Ulrich Kunitz <kune@deine-taler.de>

The signature of work functions changed recently from a context
pointer to the work structure pointer. This caused a problem in
the ieee80211softmac code, because the ieee80211softmac_assoc_work
function has  been called directly with a parameter explicitly
casted to (void*). This compiled correctly but resulted in a
softlock, because mutex_lock was called with the wrong memory
address. The patch fixes the problem. Another issue was a wrong
call of the schedule_work function. Softmac works again and this
fixes the problem I mentioned earlier in the zd1211rw rx tasklet
patch. The patch is against Linus' tree (commit af1713e0).

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Acked-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c 
b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index eec1a1d..a824852 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -167,7 +167,7 @@ static void
  ieee80211softmac_assoc_notify_scan(struct net_device *dev, int event_type, void *context)
  {
  	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
-	ieee80211softmac_assoc_work((void*)mac);
+	ieee80211softmac_assoc_work(&mac->associnfo.work.work);
  }

  static void
@@ -177,7 +177,7 @@ ieee80211softmac_assoc_notify_auth(struc

  	switch (event_type) {
  	case IEEE80211SOFTMAC_EVENT_AUTHENTICATED:
-		ieee80211softmac_assoc_work((void*)mac);
+		ieee80211softmac_assoc_work(&mac->associnfo.work.work);
  		break;
  	case IEEE80211SOFTMAC_EVENT_AUTH_FAILED:
  	case IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT:
