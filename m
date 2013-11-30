From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: mac80211: tx.c: be sure of 'sdata->vif.type' must
 be NL80211_IFTYPE_AP when be in NL80211_IFTYPE_AP case
Date: Sat, 30 Nov 2013 21:50:48 +0800
Message-ID: <5299ED38.4090509@gmail.com>
References: <528AEFB7.4060301@gmail.com>   <20131125011938.GB18921@codeaurora.org> <5292B845.3010404@gmail.com>   <5292B8A0.7020409@gmail.com> <5294255E.7040105@gmail.com>   <52957ADA.2080704@gmail.com>  (sfid-20131127_055211_558798_A7DF5684) <1385739487.8656.1.camel@jlt4.sipsolutions.net>  <5299D306.7070701@gmail.com> (sfid-20131130_125901_519610_EDA4068E) <1385816013.4327.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	rkuo <rkuo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385816013.4327.1.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/30/2013 08:53 PM, Johannes Berg wrote:
> On Sat, 2013-11-30 at 19:59 +0800, Chen Gang wrote:
>> On 11/29/2013 11:38 PM, Johannes Berg wrote:
>>>
>>>> +++ b/net/mac80211/tx.c
>>>> @@ -1814,8 +1814,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>>>>  			break;
>>>>  		/* fall through */
>>>>  	case NL80211_IFTYPE_AP:
>>>> -		if (sdata->vif.type == NL80211_IFTYPE_AP)
>>>> -			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
>>>> +		if (sdata->vif.type != NL80211_IFTYPE_AP)
>>>> +			goto fail_rcu;
>>>> +		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
>>>
>>> This change is completely wrong.
>>>
>>
>> Oh, it is.
>>
>> Hmm... for me, this work flow still can be implemented with a little
>> clearer way (at least it will avoid related warning):
>>
>> -------------------------diff begin------------------------------
>>
>> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
>> index c558b24..7076128 100644
>> --- a/net/mac80211/tx.c
>> +++ b/net/mac80211/tx.c
>> @@ -1810,14 +1810,14 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
>>  		if (!chanctx_conf)
>>  			goto fail_rcu;
>>  		band = chanctx_conf->def.chan->band;
>> -		if (sta)
>> -			break;
>> -		/* fall through */
>> +		if (!sta)
>> +			goto try_next;
>> +		break;
>>  	case NL80211_IFTYPE_AP:
>> -		if (sdata->vif.type == NL80211_IFTYPE_AP)
>> -			chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
>> +		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
>>  		if (!chanctx_conf)
>>  			goto fail_rcu;
>> +try_next:
> 
> I don't think that's better than the (fairly obvious) fall-through, and
> has a pretty odd goto. Also, depending on the compiler, it still knows
> the previous case label and doesn't warn.
> 

Yeah, fall-through is obvious. But check 'A' again just near by "case A"
seems a little strange, and some of compilers (or some of versions) are
really not quit smart enough to know it is not a warning.

Hmm... for me, if the code (implementation) can express real logical
work flow as much as directly and simply, the code (implementation) is
clear enough (don't mind whether use 'goto' or not).


And originally, at first, I am really not quite careful enough, and sent
an incorrect patch after noticed the related compiler's warning. :-)


Thanks.
-- 
Chen Gang
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
