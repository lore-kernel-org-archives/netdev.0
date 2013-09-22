From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 12/19] wireless: Change variable type to bool
Date: Sun, 22 Sep 2013 01:22:08 -0700
Message-ID: <1379838128.2086.6.camel@joe-AO722>
References: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
	 <1379802471-30252-12-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379802471-30252-12-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-09-22 at 00:27 +0200, Peter Senna Tschudin wrote:
> The variable continual is only assigned the values true and false.
> Change its type to bool.
[]
> diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
[]
> @@ -1203,7 +1203,7 @@ static void efuse_power_switch(struct ieee80211_hw *hw, u8 write, u8 pwrstate)
>  
>  static u16 efuse_get_current_size(struct ieee80211_hw *hw)
>  {
> -	int continual = true;
> +	bool continual = true;
>  	u16 efuse_addr = 0;
>  	u8 hworden;
>  	u8 efuse_data, word_cnts;

Yes, this could use bool, but would probably be better
written without continual at all

as it is before this patch:

static u16 efuse_get_current_size(struct ieee80211_hw *hw)
{
	int continual = true;
	u16 efuse_addr = 0;
	u8 hworden;
	u8 efuse_data, word_cnts;

	while (continual && efuse_one_byte_read(hw, efuse_addr, &efuse_data)
	       && (efuse_addr < EFUSE_MAX_SIZE)) {
		if (efuse_data != 0xFF) {
			hworden = efuse_data & 0x0F;
			word_cnts = efuse_calculate_word_cnts(hworden);
			efuse_addr = efuse_addr + (word_cnts * 2) + 1;
		} else {
			continual = false;
		}
	}

	return efuse_addr;
}

I think writing it without continual, which is effectively
an ersatz "break", would be better

Something like:

static u16 efuse_get_current_size(struct ieee80211_hw *hw)
{
	u16 efuse_addr = 0;
	u8 hworden;
	u8 efuse_data, word_cnts;

	while (efuse_one_byte_read(hw, efuse_addr, &efuse_data) &&
	       (efuse_addr < EFUSE_MAX_SIZE) {
		if (efuse_data == 0xff)
			break;
		hworden = efuse_data & 0x0F;
		word_cnts = efuse_calculate_word_cnts(hworden);
		efuse_addr = efuse_addr + (word_cnts * 2) + 1;
	}

	return efuse_addr;
}
