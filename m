From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: warnings in git-wireless
Date: Wed, 06 Jun 2007 13:51:41 -0700
Message-ID: <46671E5D.9070304@linux.intel.com>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:10933 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S936265AbXFFWwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 18:52:43 -0400
In-Reply-To: <20070605020614.3f06b2ab.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew Morton wrote:

> i386 allmodconfig isn't that hard, guys.
> 
...
> drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c:2050: warning: left shift count >= width of type

My mistake.  I ran that and even fixed the warning at one point...  anyway, I've committed a patch to our tree to fix the code and also added comments to the iwl_{get,set}_bits code.

>> /*
>>  * make C=2 CF=-Wall will complain if you use ARRAY_SIZE on global data
>>  */
>> #define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
> 
> This is identical to ARRAY_SIZE.
>
> And if there's some problem with ARRAY_SIZE then fix ARRAY_SIZE!  Don't go 
> off and create some private thing and leave everyone else twisting in the
> wind.

The code was resolving the sparse warnings.  GLOBAL_ARRAY_SIZE removes the part of the ARRAY_SIZE definition that causes sparse to complain ('+ __must_be_array(arr)').  I don't know enough about how sparse works to fix sparse, or to know if its a problem with __must_be_array.  The code itself was fine -- using an array with ARRAY_SIZE.

>> /* Debug and printf string expansion helpers for printing bitfields */
>> #define BIT_FMT8 "%c%c%c%c-%c%c%c%c"
>> #define BIT_FMT16 BIT_FMT8 ":" BIT_FMT8
>> #define BIT_FMT32 BIT_FMT16 " " BIT_FMT16
...
>> #define BIT_ARG32(x) \
>> BITC(x,31),BITC(x,30),BITC(x,29),BITC(x,28),\
>> BITC(x,27),BITC(x,26),BITC(x,25),BITC(x,24),\
>> BITC(x,23),BITC(x,22),BITC(x,21),BITC(x,20),\
>> BITC(x,19),BITC(x,18),BITC(x,17),BITC(x,16),\
>> BIT_ARG16(x)
> 
> None of the above is appropriate to a driver-private header.

Where would be the appropriate place?  We use it in with iwlwifi; I don't know if others need it or want to use it.  Do you know of other projects using something similar?

>> #define KELVIN_TO_CELSIUS(x) ((x)-273)
> 
> Nor is that.

Where would the appropriate place be?

>> static inline const struct ieee80211_hw_mode *iwl_get_hw_mode(struct iwl_priv
>> 							      *priv, int mode)
>> {
>> 	int i;
>>
>> 	for (i = 0; i < 3; i++)
>> 		if (priv->modes[i].mode == mode)
>> 			return &priv->modes[i];
>>
>> 	return NULL;
>> }
> 
> Far too large to inline, has five callsites.

Currently CodingStyle states to use inline where you might have otherwise used a macro, and then later if the function is not overly complex (citing "3 lines" as a guideline).  Is this too long because it has a for loop in it?  Or a loop and a branch?

Removing static inline from the functions declared in header files means they need to be moved to .c files, declared as extern, and pollute the namespace.  In prior drivers we had been beaten up about doing that...

>> #define WLAN_FC_GET_TYPE(fc)    (((fc) & IEEE80211_FCTL_FTYPE))
>> #define WLAN_FC_GET_STYPE(fc)   (((fc) & IEEE80211_FCTL_STYPE))
>> #define WLAN_GET_SEQ_FRAG(seq)  ((seq) & 0x000f)
>> #define WLAN_GET_SEQ_SEQ(seq)   ((seq) >> 4)
> 
> These don't need to be macros

What would you like these to be?

These currently exist as macros in ieee80211.h and there are other examples in the kernel of similar macros.  If a goal is to remove *all macros* then that should be stated in CodingStyle, preferably in a way that helps developers understand how they are supposed to write their code.

>> #define QOS_CONTROL_LEN 2
>>
>> static inline u16 *ieee80211_get_qos_ctrl(struct ieee80211_hdr *hdr)
>> {
>> 	int hdr_len = ieee80211_get_hdrlen(hdr->frame_control);
>> 	if (hdr->frame_control & IEEE80211_STYPE_QOS_DATA)
>> 		return (u16 *) ((u8 *) hdr + (hdr_len) - QOS_CONTROL_LEN);
>> 	return NULL;
>> }
> 
> Two callsites, too large to inline.

If something is used more than once then it is unsuitable for an inline?  Again maybe updating CodingStyle would be helpful?

Change:
	"Generally, inline functions are preferable to macros resembling functions."

To:
	"Macros resembling functions and inline functions should *NOT* be used."

IIRC, ieee80211_get_qos_ctrl used to be a macros, and was then changed to an inline per CodingStyle.  Now we don't want inlines, and instead want pure functions (and consequently polluted namespace--or do we want to add to CodingStyle that all functions should be implemented in a single file and marked static?)

	"A reasonable rule of thumb is to not put inline at functions that have more
	 than 3 lines of code in them. "

An assignment and a branch return isn't overly complex; it does call another function... is that the problem?

If callsites is a key indicator of when to and not to use inline, please add that to CodingStyle.  We look at other drivers and headers, we see what they do, and we replicate.  We read CodingStyle and use it as a guideline.

...
>> #define ieee80211_is_reassoc_response(fc) \
>>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_REASSOC_RESP))
> 
> None of the above should be macros.

So inline with these (they have lots of callsites...) or ?

>> static inline unsigned long elapsed_jiffies(unsigned long start,
>> 					    unsigned long end)
>> {
>> 	if (end > start)
>> 		return end - start;
>>
>> 	return end + (MAX_JIFFY_OFFSET - start);
>> }
> 
> Whatever this uncommented function is doing, it is not appropriate to a
> per-driver header file.

Where should it go?  jiffies.h?

Is there already a kernel function for doing this? (I couldn't find one.)

> Dump the whole thing, use lib/hexdump.c.

Agreed; iwlwifi should be using lib/hexcump.c

James
