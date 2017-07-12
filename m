From: Igor Mitsyanko <igor.mitsyanko.os-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org>
Subject: Re: WARN_ON_ONCE(work > weight) in napi_poll()
Date: Tue, 11 Jul 2017 18:19:51 -0700
Message-ID: <3ce246b3-b110-dd50-bf29-45ee78985872@quantenna.com>
References: <26670dce-4dd2-f8e4-0e14-90d74257e739@virtuozzo.com>
 <87wp7oia6j.fsf@kamboji.qca.qualcomm.com>
 <952aefe1-6f6a-3978-e7e7-5e74076f26a3@virtuozzo.com>
 <b418d63d-d348-90b5-ea58-6478a1a037f5@qca.qualcomm.com>
 <8cb28d9b-41c9-043c-16ca-f0bea41944e9@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
        Ryan Hsu <ryanhsu-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
        Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8cb28d9b-41c9-043c-16ca-f0bea41944e9-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/11/2017 10:28 AM, Andrey Ryabinin wrote:
> 
> It gave me this:
> 
> [118648.825347] #1 quota too big 72 64 16
> [118648.825351] #2 quota too big 72 64 16
> [118648.825471] ------------[ cut here ]------------
> [118648.825484] WARNING: CPU: 0 PID: 0 at ../net/core/dev.c:5274 net_rx_action+0x258/0x360
> 
> So this means that we didn't met the condition bellow, i.e. skb_queue_empty() returned true.
> 
>          ath10k_htt_txrx_compl_task():
> 
>                  if ((quota > ATH10K_NAPI_QUOTA_LIMIT) &&
>                      !skb_queue_empty(&htt->rx_in_ord_compl_q)) {
>                          resched_napi = true;
>                          goto exit;
>                  }
> 
>> Also WLAN.RM.2.0-00180-QCARMSWPZ-1 firmware is a bit old, could you also update firmware to give it a try?
>> https://github.com/kvalo/ath10k-firmware/tree/master/QCA6174/hw3.0/4.4
>>
> 
> Will try.
> 

Maybe ath10k_htt_rx_in_ord_ind() has to accept "budget_left" parameter 
and use it to limit number of processed MSDUs in queued AMSDU and saving 
rest for later (NAPI has to be rescheduled in this case).
It seems natural that this problem happens with current logic, in case 
AMSDU in Rx queue has more elements then left in budget.
