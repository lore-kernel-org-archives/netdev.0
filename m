From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [UBSAN] iwlmvm's iwl_mvm_enable_txq accesses
 IEEE80211_INVAL_HW_QUEUE
Date: Fri, 23 Jun 2017 09:58:55 +0200
Message-ID: <1498204735.2595.1.camel@sipsolutions.net>
References: <3f089134-9739-a61f-80e4-6f9ee7dd83b4@suse.cz>
         (sfid-20170623_094852_912665_18314A6E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Jiri Slaby <jslaby@suse.cz>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        luciano.coelho@intel.com, linuxwifi@intel.com,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43354 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752878AbdFWH7C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:59:02 -0400
In-Reply-To: <3f089134-9739-a61f-80e4-6f9ee7dd83b4@suse.cz> (sfid-20170623_094852_912665_18314A6E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-23 at 09:48 +0200, Jiri Slaby wrote:
> 
> mac80211_queue is 255 which is IEEE80211_INVAL_HW_QUEUE, so it should
> not be worked with at all.

Funny you should find this today :-)

> The invalid queue is hopefully handled in ieee80211_check_queues
> after
> drv_add_interface in ieee80211_do_open:
> 
> res = drv_add_interface(local, sdata);
> if (res)
>         goto err_stop;
> res = ieee80211_check_queues(sdata,
>         ieee80211_vif_type_p2p(&sdata->vif));
> 
> 
> But the mvm driver still should not blindly shift 1 by 255 in
> iwl_mvm_enable_txq. Should the check for the invalid queue be before
> adding the interface in mac80211? Or should drivers check it in their
> add_interface?

Everything is actually handled well afaict, because the bug won't
matter - this is a queue we'll never really stop, so we won't be
looking at the (invalid) result of the calculation. I had actually been
under the impression that it wasn't undefined but would just result in
0; that's clearly not true but also doesn't matter. AFAICT it even
results in 0x80000000 (which makes some sense, since 255 % 32 == 31),
and that's a queue number (31) that's too big for mac80211 anyway, so
it would warn if we were to ever try to stop it.

In later versions of the code, however, there *was* indeed a bug - we
were using a u8 instead of a u32 in the code we have internally. While
fixing *that* bug, I also made this catch the case of
IEEE80211_INVAL_HW_QUEUE so we'll not modify the bitmap at all, which
is the correct thing to do.

IOW - yes, it's not nice, but it also shouldn't matter, and even if for
some strange reason we tried to stop the queue we'd just get a warning
from mac80211.

johannes
