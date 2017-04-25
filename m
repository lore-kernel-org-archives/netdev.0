From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2] brcmfmac: Make skb header writable before use
Date: Tue, 25 Apr 2017 09:46:16 +0200
Message-ID: <ddb49ce2-9968-534e-dd17-b1bf21513c5d@broadcom.com>
References: <20170424130322.476-1-james.hughes@raspberrypi.org>
 <ef75a194-2e0b-6586-7b31-2eb83128d2bc@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ef75a194-2e0b-6586-7b31-2eb83128d2bc-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 25-4-2017 9:38, Arend Van Spriel wrote:
> On 24-4-2017 15:03, James Hughes wrote:
>> The driver was making changes to the skb_header without
>> ensuring it was writable (i.e. uncloned).
>> This patch also removes some boiler plate header size
>> checking/adjustment code as that is also handled by the
>> skb_cow_header function used to make header writable.
>>
>> This patch depends on
>> brcmfmac: Ensure pointer correctly set if skb data location changes
>>
>> Signed-off-by: James Hughes <james.hughes-FnsA7b+Nu9XbIbC87yuRow@public.gmane.org>
>> ---
>> Changes in v2
>>   Makes the _cow_ call at the entry point of the skb in to the
>>   stack, means only needs to be done once, and error handling
>>   is easier.
>>   Split a separate minor bug fix off to a separate patch (which
>>   this patch depends on)
> 
> Hi James,
> 
> Can you please indicate in this section that you want it applied for
> 4.12 as it is an important fix. Probably will have to wait until after
> the merge window before it can get in the wireless-drivers repo.

Hi Kalle,

I should have checked kernel mailing list first as Linus added another
rc cycle. So can this patch still go in wireless-drivers-next for 4.12
kernel. I want it for stable as well, but I will look at that when it
lands upstream.

Regards,
Arend

> Regards,
> Arend
> 
>>  .../net/wireless/broadcom/brcm80211/brcmfmac/core.c   | 19 ++++---------------
>>  1 file changed, 4 insertions(+), 15 deletions(-)
>>
>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>> index 9b7c19a508ac..88f8675a94c2 100644
>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
>> @@ -211,22 +211,11 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
>>  		goto done;
>>  	}
>>  
>> -	/* Make sure there's enough room for any header */
>> -	if (skb_headroom(skb) < drvr->hdrlen) {
>> -		struct sk_buff *skb2;
>> -
>> -		brcmf_dbg(INFO, "%s: insufficient headroom\n",
>> -			  brcmf_ifname(ifp));
>> -		drvr->bus_if->tx_realloc++;
>> -		skb2 = skb_realloc_headroom(skb, drvr->hdrlen);
>> +	/* Make sure there's enough room for any header, and make it writable */
>> +	if (skb_cow_head(skb, drvr->hdrlen)) {
>>  		dev_kfree_skb(skb);
>> -		skb = skb2;
>> -		if (skb == NULL) {
>> -			brcmf_err("%s: skb_realloc_headroom failed\n",
>> -				  brcmf_ifname(ifp));
>> -			ret = -ENOMEM;
>> -			goto done;
>> -		}
>> +		ret = -ENOMEM;
>> +		goto done;
>>  	}
>>  
>>  	/* validate length for ether packet */
>>
