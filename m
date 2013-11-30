From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sun, 01 Dec 2013 07:48:37 +0800
Message-ID: <529A7955.9010507@gmail.com>
References: <528AEFB7.4060301@gmail.com>  <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>  <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>  <52957ADA.2080704@gmail.com>  (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>  <5299D306.7070701@gmail.com>  (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>  <5299ED38.4090509@gmail.com> <5299EFDD.6060405@gmail.com>  (sfid-20131130_150205_984535_068F14A9) <1385842134.6108.4.camel@jlt4.sipsolutions.net> <1385843940.2664.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	rkuo <rkuo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385843940.2664.4.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/01/2013 04:39 AM, Joe Perches wrote:
> On Sat, 2013-11-30 at 21:08 +0100, Johannes Berg wrote:
>> On Sat, 2013-11-30 at 22:02 +0800, Chen Gang wrote:
>>>  - fall-through is obvious (although I did not notice it, originally).
>>>
>>>  - Check 'A' again just near by "case A" seems a little strange.
>>>
>>>  - Some compilers aren't quit smart enough to know 'chanctx_conf' is OK.
>>
>> I know. If you have any good ideas of how to make it more obvious to the
>> compiler, I'm all ears, I just don't like any of the solutions offered
>> so far (and you aren't the first to do so either) :-)
>>

OK, thanks.

>> FWIW, I find the label to be odd because if you're familiar with the
>> code then AP/AP_VLAN *should* be identical except for two special things
>> that are now linearly & neatly handled in the code (the first being the
>> 4-addr station, the second the chanctx assignment which always has to be
>> done regardless of 4-addr). IMHO the == check after case should be
>> enough to make a human reader take a closer look. I understand that you
>> didn't and that's OK since you were just trying to squelch compile
>> warnings, but I don't see that this one warrants much attention.
> 
> The label/test could be moved to save a couple of lines
> of duplicated code.
> 

Hmm... for me, it must be an implementation which can satisfy all of us.

If ieee80211_subif_start_xmit() is not performance sensitive (I guess
so), we can use some short static functions instead of some code blocks
within ieee80211_subif_start_xmit().

 - ieee80211_subif_start_xmit() is a long function (600+ lines).

 - use short static function can share some code.

 - if code can be shared, the work flow can be more clearer too (don't
   need fall-through or goto).


And I guess, the implementation below can cause panic when
"sdata->vif.type == NL80211_IFTYPE_AP_VLAN".  :-(

> Maybe:
> 
>  net/mac80211/tx.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
> index 70b5a05..b2160f4 100644
> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> @@ -1777,18 +1777,16 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>  		}
>  		ap_sdata = container_of(sdata->bss, struct ieee80211_sub_if_data,
>  					u.ap);
> -		chanctx_conf = rcu_dereference(ap_sdata->vif.chanctx_conf);
> -		if (!chanctx_conf)
> -			goto fail_rcu;
> -		band = chanctx_conf->def.chan->band;
> -		if (sta)
> -			break;
>  		/* fall through */
>  	case NL80211_IFTYPE_AP:
> -		if (sdata->vif.type == NL80211_IFTYPE_AP)
> -			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
> +		chanctx_conf = rcu_dereference(ap_sdata->vif.chanctx_conf);
>  		if (!chanctx_conf)
>  			goto fail_rcu;
> +		if (sdata->vif.type == NL80211_IFTYPE_AP_VLAN) {
> +			band = chanctx_conf->def.chan->band;
> +			if (sta)
> +				break;
> +		}
>  		fc |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
>  		/* DA BSSID SA */
>  		memcpy(hdr.addr1, skb->data, ETH_ALEN);
> 
> 


-- 
Chen Gang
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
