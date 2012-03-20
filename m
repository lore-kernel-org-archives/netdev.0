From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 07:19:29 -0700
Message-ID: <4F6891F1.9010105@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org> <4F61F551.5010608@gmail.com> <4F639851.5080500@gmail.com> <4F674616.8080103@gmail.com> <CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com> <4F674FF5.2060406@gmail.com> <4F6751B2.1030809@openwrt.org> <4F681B78.9000207@gmail.com> <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com> <4F68235C.5090701@gmail.com> <CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com> <4F682555.3020502@gmail.com> <20328.16366.166909.255035@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20328.16366.166909.255035@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2012 01:29 AM, Sujith Manoharan wrote:
> Justin P. Mattock wrote:
>> yeah this works:
>>
>> eading symbols from
>> /home/kernel/linux-next/drivers/net/wireless/ath/ath9k/ath9k.o...done.
>> (gdb) l *(ath_tx_start+0x284)
>> 0xcad4 is in ath_tx_start (drivers/net/wireless/ath/ath9k/xmit.c:1878).
>> 1873			ieee80211_is_data_qos(hdr->frame_control)) {
>> 1874			tidno = ieee80211_get_qos_ctl(hdr)[0]&
>> 1875				IEEE80211_QOS_CTL_TID_MASK;
>> 1876			tid = ATH_AN_2_TID(txctl->an, tidno);
>> 1877	
>> 1878			WARN_ON(tid->ac->txq != txctl->txq);
>> 1879		}
>> 1880	
>> 1881		if ((tx_info->flags&  IEEE80211_TX_CTL_AMPDU)&&  tid) {
>> 1882			/*
>> (gdb)
>
> Can you try this patch ?
>
> From: Sujith Manoharan<c_manoha@qca.qualcomm.com>
> Date: Tue, 20 Mar 2012 13:51:26 +0530
> Subject: [PATCH] ath9k: Use HW HT capabilites properly
>
> The commit "ath9k: Remove aggregation flags" changed how
> nodes were being initialized. Use the HW HT cap bits
> to initialize/de-initialize nodes, else we would be
> accessing an uninitialized entry during a suspend/resume cycle,
> resulting in a panic.
>
> Reported-by: Justin P. Mattock<justinmattock@gmail.com>
> Signed-off-by: Sujith Manoharan<c_manoha@qca.qualcomm.com>
> ---
>   drivers/net/wireless/ath/ath9k/main.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
> index 3879485..215eb25 100644
> --- a/drivers/net/wireless/ath/ath9k/main.c
> +++ b/drivers/net/wireless/ath/ath9k/main.c
> @@ -640,7 +640,7 @@ static void ath_node_attach(struct ath_softc *sc, struct ieee80211_sta *sta,
>   	an->sta = sta;
>   	an->vif = vif;
>
> -	if (sta->ht_cap.ht_supported) {
> +	if (sc->sc_ah->caps.hw_caps&  ATH9K_HW_CAP_HT) {
>   		ath_tx_node_init(sc, an);
>   		an->maxampdu = 1<<  (IEEE80211_HT_MAX_AMPDU_FACTOR +
>   				     sta->ht_cap.ampdu_factor);
> @@ -659,7 +659,7 @@ static void ath_node_detach(struct ath_softc *sc, struct ieee80211_sta *sta)
>   	an->sta = NULL;
>   #endif
>
> -	if (sta->ht_cap.ht_supported)
> +	if (sc->sc_ah->caps.hw_caps&  ATH9K_HW_CAP_HT)
>   		ath_tx_node_cleanup(sc, an);
>   }
>


alright!

both mohammed and sujith Thank you for the patches for this issue!
I really appreciate this..

I went and applied the debug printk and added ath_node_attach as well to 
my linux-next clone, will run for a few days to see if I get anything..
full dmesg is here..: http://fpaste.org/jHSX/

Justin P. Mattock
