From: Luca Coelho <luca@coelho.fi>
Subject: Re: More wireless problems..
Date: Mon, 18 Aug 2014 11:50:16 +0300
Message-ID: <1408351816.29649.8.camel@dubbel>
References: <CA+55aFwTGDFgRuPS5DaQ9-XMLgbZ0y6ZtvXLsZhFkM6P_kXQHw@mail.gmail.com>
	 <CA+55aFwUJLZUi4wDKwiX1XAht=H9exmvUD5P_aNHK9=XBSixjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Michal Kazior <michal.kazior@tieto.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dedo.coelho.fi ([88.198.205.34]:41558 "EHLO dedo.coelho.fi"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750775AbaHRJS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 05:18:27 -0400
In-Reply-To: <CA+55aFwUJLZUi4wDKwiX1XAht=H9exmvUD5P_aNHK9=XBSixjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Sun, 2014-08-17 at 23:37 -0500, Linus Torvalds wrote:
> On Sun, Aug 17, 2014 at 11:01 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> >   BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> >   IP: ieee80211_vif_use_reserved_switch+0x71c/0xb00 [mac80211]
> 
> Looking at the Code: line and the code generation for that function,
> this *looks* to be this code:
> 
>                         list_del(&sdata->reserved_chanctx_list);
>                         list_move(&sdata->assigned_chanctx_list,
>                                   &new_ctx->assigned_vifs);
>                         sdata->reserved_chanctx = NULL;
> 
> in ieee80211_vif_use_reserved_switch(), where "new_ctx" is NULL, so
> the "list_move()" ends up oopsing. But maybe I screwed up the
> analysis, I don't know the code.
> 
> Looks like that is all-new code introduced by commit 5bcae31d9cb1
> ("mac80211: implement multi-vif in-place reservations")
> 
> And doesn't look at all IWL-specific. Adding Michal Kazior to the list
> of people.

Unfortunately I don't think channel switch on the client side has been
tested very thoroughly yet, from the iwlwifi point of view, we're still
fine-tuning things in the firmware configuration.  So I'd rather disable
channel-switch entirely for iwlwifi.

Probably better to disable it in mac80211, since this oops will probably
happen with other drivers too, since doesn't seem to be iwlwifi related.

I'll sent a patch soon.  Meanwhile, you can apply this directly, to make
the problem go away:

diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index e0ab432..4b8eee8 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -758,6 +758,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
        netdev_features_t feature_whitelist;
        struct cfg80211_chan_def dflt_chandef = {};
 
+       /* The CSA client code is not very stable yet and seems to be
+        * causing trouble.  Disable it for all drivers until
+        * everything has been fixed and tested properly.
+        */
+       hw->flags &= ~IEEE80211_HW_CHANCTX_STA_CSA;
+
        if (hw->flags & IEEE80211_HW_QUEUE_CONTROL &&
            (local->hw.offchannel_tx_hw_queue ==
IEEE80211_INVAL_HW_QUEUE ||
             local->hw.offchannel_tx_hw_queue >= local->hw.queues))

--
Cheers,
Luca.
