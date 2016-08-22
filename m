From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 1/1] brcmfmac: fix pmksa->bssid usage
Date: Mon, 22 Aug 2016 21:38:23 +0200
Message-ID: <45617c4f-60b9-2587-5e29-6330ba2f40a6@broadcom.com>
References: <20160805203418.32162-1-nicolas.iooss_linux@m4x.org>
 <96ea6e57-79d7-d4ff-1228-6f22addd4996@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org, brcm80211-dev-list.pdl@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <96ea6e57-79d7-d4ff-1228-6f22addd4996@m4x.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-8-2016 15:03, Nicolas Iooss wrote:
> Hello,
> 
> After I sent the following patch a few weeks ago, I have not received
> any feedback. Could you please review it and tell me what I may have
> done wrong?

Nothing. People went on vacation :-)
> Thanks,
> Nicolas
> 
> On 05/08/16 22:34, Nicolas Iooss wrote:
>> The struct cfg80211_pmksa defines its bssid field as:
>>
>>     const u8 *bssid;
>>
>> contrary to struct brcmf_pmksa, which uses:
>>
>>     u8 bssid[ETH_ALEN];
>>
>> Therefore in brcmf_cfg80211_del_pmksa(), &pmksa->bssid takes the address
>> of this field (of type u8**), not the one of its content (which would be
>> u8*).  Remove the & operator to make brcmf_dbg("%pM") and memcmp()
>> behave as expected.
>>
>> This bug have been found using a custom static checker (which checks the
>> usage of %p... attributes at build time).  It has been introduced in
>> commit 6c404f34f2bd ("brcmfmac: Cleanup pmksa cache handling code"),
>> which replaced pmksa->bssid by &pmksa->bssid while refactoring the code,
>> without modifying struct cfg80211_pmksa definition.
>>
>> Fixes: 6c404f34f2bd ("brcmfmac: Cleanup pmksa cache handling code")
>> Cc: stable@ger.kernel.org

Ah, so you did something wrong after all :-p. The email address should
be 'stable@vger.kernel.org'.

>> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
>> ---
>>
>> scripts/checkpatch.pl reports a warning: "Prefer ether_addr_equal() or
>> ether_addr_equal_unaligned() over memcmp()".  Because some files in
>> drivers/net/wireless/broadcom/brcm80211/brcmfmac/ still use memcmp()
>> to compare addresses and because I do not know whether pmksa->bssid is
>> always aligned, I did not follow this warning.

As most of this is done in slow path, I prefer memcmp() as I do not want
to check alignment for minimal performance gain.

>>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>> index 2628d5e12c64..aceab77cd95a 100644
>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>> @@ -3884,11 +3884,11 @@ brcmf_cfg80211_del_pmksa(struct wiphy *wiphy, struct net_device *ndev,
>>  	if (!check_vif_up(ifp->vif))
>>  		return -EIO;
>>  
>> -	brcmf_dbg(CONN, "del_pmksa - PMK bssid = %pM\n", &pmksa->bssid);
>> +	brcmf_dbg(CONN, "del_pmksa - PMK bssid = %pM\n", pmksa->bssid);
>>  
>>  	npmk = le32_to_cpu(cfg->pmk_list.npmk);
>>  	for (i = 0; i < npmk; i++)
>> -		if (!memcmp(&pmksa->bssid, &pmk[i].bssid, ETH_ALEN))
>> +		if (!memcmp(pmksa->bssid, &pmk[i].bssid, ETH_ALEN))

I find '&pmk[i].bssid' confusing so maybe you could change it to
'&pmk[i].bssid[0]' or 'pmk[i].bssid' as I think these two are
essentially the same.

Regards,
Arend

>>  			break;
>>  
>>  	if ((npmk > 0) && (i < npmk)) {
>>
> 
