From: Ivan Safonov <insafonov@gmail.com>
Subject: Re: [PATCH] /drivers/net/wireless/ath/ath9k remove unnecessary ?:
 operator
Date: Tue, 29 Dec 2015 11:11:02 +0700
Message-ID: <568207D6.3070608@gmail.com>
References: <20151228134852.GA10572@alpha.sfu-kras.ru>
 <1451325412.3219.12.camel@perches.com> <5681818A.9060406@gmail.com>
 <1451349084.3219.19.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451349084.3219.19.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/29/2015 07:31 AM, Joe Perches wrote:
> On Tue, 2015-12-29 at 01:38 +0700, Ivan Safonov wrote:
>> On 12/29/2015 12:56 AM, Joe Perches wrote:
>>> On Mon, 2015-12-28 at 20:48 +0700, Ivan Safonov wrote:
>>>> ((thermometer < 0) ? 0 : (thermometer == X)) and (thermometer ==
>>>> X) are equal for X >= 0.
>>> X is not guaranteed to be >= 0 here
>> X is fixed constant. In this case X is {0, 1, 2}.
> Looks like it can be -1 to me (range: -1, 0, 1, 2)
>
> static int ar9003_hw_get_thermometer(struct ath_hw *ah)
> {
> 	struct ar9300_eeprom *eep = &ah->eeprom.ar9300_eep;
> 	struct ar9300_base_eep_hdr *pBase = &eep->baseEepHeader;
> 	int thermometer =  (pBase->miscConfiguration >> 1) & 0x3;
>
> 	return --thermometer;
> }

X is not thermometer. The thermometer is {-1, 0, 1, 2}. X is {0, 1, 2}.
All possible X valueswritten in the comments:

ar9003_hw_get_thermometer used only in ar9003_hw_thermometer_apply:

     static void ar9003_hw_thermometer_apply(struct ath_hw *ah)
     {
         struct ath9k_hw_capabilities *pCap = &ah->caps;
         int thermometer = ar9003_hw_get_thermometer(ah);
         u8 therm_on = (thermometer < 0) ? 0 : 1;

         REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_RXTX4,
                   AR_PHY_65NM_CH0_RXTX4_THERM_ON_OVR, therm_on);
         if (pCap->chip_chainmask & BIT(1))
             REG_RMW_FIELD(ah, AR_PHY_65NM_CH1_RXTX4,
                       AR_PHY_65NM_CH0_RXTX4_THERM_ON_OVR, therm_on);
         if (pCap->chip_chainmask & BIT(2))
             REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
                       AR_PHY_65NM_CH0_RXTX4_THERM_ON_OVR, therm_on);

         therm_on = (thermometer < 0) ? 0 : (thermometer == 0); /* X = 0 */
         REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_RXTX4,
                   AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
         if (pCap->chip_chainmask & BIT(1)) {
             therm_on = (thermometer < 0) ? 0 : (thermometer == 1);    
/* X = 1 */
             REG_RMW_FIELD(ah, AR_PHY_65NM_CH1_RXTX4,
                       AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
         }
         if (pCap->chip_chainmask & BIT(2)) {
             therm_on = (thermometer < 0) ? 0 : (thermometer == 2);    
/* X = 2 */
             REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX4,
                       AR_PHY_65NM_CH0_RXTX4_THERM_ON, therm_on);
         }
     }

There is no X = -1.
