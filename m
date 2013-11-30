From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sat, 30 Nov 2013 12:39:00 -0800
Message-ID: <1385843940.2664.4.camel@joe-AO722>
References: <528AEFB7.4060301@gmail.com>
	 <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>
	 <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>
	 <52957ADA.2080704@gmail.com>
	 (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>
	 <5299D306.7070701@gmail.com>
	 (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>
	 <5299ED38.4090509@gmail.com> <5299EFDD.6060405@gmail.com>
	 (sfid-20131130_150205_984535_068F14A9) <1385842134.6108.4.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chen Gang <gang.chen.5i5j@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	rkuo <rkuo@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0137.hostedemail.com ([216.40.44.137]:49483 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751259Ab3K3UjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 15:39:05 -0500
In-Reply-To: <1385842134.6108.4.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-30 at 21:08 +0100, Johannes Berg wrote:
> On Sat, 2013-11-30 at 22:02 +0800, Chen Gang wrote:
> 
> > >>>  	case NL80211_IFTYPE_AP:
> > >>> -		if (sdata->vif.type == NL80211_IFTYPE_AP)
> > >>> -			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
> > >>> +		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
> > >>>  		if (!chanctx_conf)
> > >>>  			goto fail_rcu;
> > >>> +try_next:
> > >>
> > >> I don't think that's better than the (fairly obvious) fall-through, and
> > >> has a pretty odd goto. Also, depending on the compiler, it still knows
> > >> the previous case label and doesn't warn.
> > >>
> > > 
> > > Yeah, fall-through is obvious. But check 'A' again just near by "case A"
> > > seems a little strange, and some of compilers (or some of versions) are
> > > really not quit smart enough to know it is not a warning.
> > > 
> > 
> > Sorry, the paragraph above may lead misunderstanding, I repeated again:
> > 
> >  - fall-through is obvious (although I did not notice it, originally).
> > 
> >  - Check 'A' again just near by "case A" seems a little strange.
> > 
> >  - Some compilers aren't quit smart enough to know 'chanctx_conf' is OK.
> 
> I know. If you have any good ideas of how to make it more obvious to the
> compiler, I'm all ears, I just don't like any of the solutions offered
> so far (and you aren't the first to do so either) :-)
> 
> FWIW, I find the label to be odd because if you're familiar with the
> code then AP/AP_VLAN *should* be identical except for two special things
> that are now linearly & neatly handled in the code (the first being the
> 4-addr station, the second the chanctx assignment which always has to be
> done regardless of 4-addr). IMHO the == check after case should be
> enough to make a human reader take a closer look. I understand that you
> didn't and that's OK since you were just trying to squelch compile
> warnings, but I don't see that this one warrants much attention.

The label/test could be moved to save a couple of lines
of duplicated code.

Maybe:

 net/mac80211/tx.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 70b5a05..b2160f4 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1777,18 +1777,16 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		}
 		ap_sdata = container_of(sdata->bss, struct ieee80211_sub_if_data,
 					u.ap);
-		chanctx_conf = rcu_dereference(ap_sdata->vif.chanctx_conf);
-		if (!chanctx_conf)
-			goto fail_rcu;
-		band = chanctx_conf->def.chan->band;
-		if (sta)
-			break;
 		/* fall through */
 	case NL80211_IFTYPE_AP:
-		if (sdata->vif.type == NL80211_IFTYPE_AP)
-			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
+		chanctx_conf = rcu_dereference(ap_sdata->vif.chanctx_conf);
 		if (!chanctx_conf)
 			goto fail_rcu;
+		if (sdata->vif.type == NL80211_IFTYPE_AP_VLAN) {
+			band = chanctx_conf->def.chan->band;
+			if (sta)
+				break;
+		}
 		fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
 		/* DA BSSID SA */
 		memcpy(hdr.addr1, skb->data, ETH_ALEN);
