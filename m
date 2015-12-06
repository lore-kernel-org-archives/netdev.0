From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: fix gigantic memleak in rtl_usb
Date: Sun, 6 Dec 2015 14:18:36 -0600
Message-ID: <5664981C.1040704@lwfinger.net>
References: <1449424677-3140-1-git-send-email-peter@lekensteyn.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Peter Wu <peter@lekensteyn.nl>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449424677-3140-1-git-send-email-peter@lekensteyn.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/2015 11:57 AM, Peter Wu wrote:
> Free skb for received frames with a wrong checksum.
>
> While using the rtl8192cu driver in monitor mode, somehow 5G of memory
> was permanently lost (observable via the Available column in `free -m`).
>
> Test scenario:
>
>      ip link set down wlan1
>      iw wlan1 set type monitor
>      ip link set up wlan1
>      iw wlan1 set channel 11
>
> Then stream a video on a smartphone on channel 11. Without this patch
> the memory usage grows linearly with the number of received packets:
>
>      grep MemAvailable /proc/meminfo
>      ip -s link show dev wlan1
>
> Signed-off-by: Peter Wu <peter@lekensteyn.nl>
> ---
> Hi,
>
> This issue has existed since the introduction of this driver in v2.6.x,
> using kmemleak I was about to figure out the source. There is also a
> _rtl_usb_rx_process_agg that has similarly looking code, but that one is
> unaffected. The pci code already frees the skb and is unaffected too.
>
> Tested with kernel v4.3, this patch is simply rebased on v4.4-rc3 (due
> to changed paths).
>
> Kind regards,
> Peter
> ---
>   drivers/net/wireless/realtek/rtlwifi/usb.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
> index 2721cf8..aac1ed3 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/usb.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
> @@ -531,6 +531,8 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
>   			ieee80211_rx(hw, skb);
>   		else
>   			dev_kfree_skb_any(skb);
> +	} else {
> +		dev_kfree_skb_any(skb);
>   	}
>   }
>
>

Thanks for finding and fixing this memory leak.

The patch is OK, but the commit message and subject are not. I do not like the 
use of the word "gigantic" in the subject. A better subject would be: "rtlwifi: 
Fix memory leak for USB device while in monitor mode".

The commit message should say that a memory leak was observed, and found with 
kmemleak. If you were simply reportimg the bug, then the steps needed to 
reproduce it would be important, but as you have a fix, those steps are 
extraneous. You should also include a "Cc: Stable <stable@vger.kernel.org" line. 
When the patch is picked up for stable kernels, it will be necessary to rebase 
the patch to compensate for the directory change.

NACK for the moment.

Larry
