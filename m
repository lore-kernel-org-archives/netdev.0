From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] ieee80211softmac: Fix errors related to the work_struct
 changes
Date: Sun, 10 Dec 2006 10:40:56 -0800
Message-ID: <20061210104056.572db071.akpm@osdl.org>
References: <20061210173908.GB29871@p15091797.pureserver.info>
	<200612101849.47179.mb@bu3sch.de>
	<20061210183536.GC29871@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47922 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762339AbWLJSmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Dec 2006 13:42:31 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061210183536.GC29871@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Dec 2006 19:35:36 +0100
Ulrich Kunitz <kune@deine-taler.de> wrote:

> The problem is that you there are now different work structures:
> struct work_struct and struct delayed_work. The quick fix seems to
> have been to change all old work_structs as associnfo's work to
> delayed_work. The way the structures are designed calling
> schedule_work or schedule_delayed_work doesn't matter, but you
> will get a gcc warning, because the pointer types are not
> identical. This change works around the warning in the same way as
> the other schedule_work calls for associnfo's work.

David proposed the below.  Does it fix things for you?

--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c~workstruct-fix-ieee80211-softmac-compile-problem
+++ a/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -438,7 +438,7 @@ ieee80211softmac_try_reassoc(struct ieee
 
 	spin_lock_irqsave(&mac->lock, flags);
 	mac->associnfo.associating = 1;
-	schedule_work(&mac->associnfo.work);
+	schedule_delayed_work(&mac->associnfo.work, 0);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
_

> I'm not sure, whether the breaking of the workqueue API is really
> worth it. What I see is that the change introduced choices and
> choices make things more complex.

It is kinda sucky.  But it saves a bit of space in kernel data structures.
