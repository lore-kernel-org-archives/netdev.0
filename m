From: Mathy Vanhoef <vanhoefm@gmail.com>
Subject: Re: [PATCH] brcmfmac: unlink URB when request timed out
Date: Tue, 11 Nov 2014 20:02:27 -0500
Message-ID: <5462B1A3.9020401@gmail.com>
References: <545FAE05.2030701@gmail.com> <1415610506.16488.20.camel@linux-0dmf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: brudley@broadcom.com, Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	John Linville <linville@tuxdriver.com>, pieterpg@broadcom.com,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415610506.16488.20.camel@linux-0dmf.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/2014 04:08 AM, Oliver Neukum wrote:
> On Sun, 2014-11-09 at 13:10 -0500, Mathy Vanhoef wrote:
>> From: Mathy Vanhoef <vanhoefm@gmail.com>
>>
>> Unlink the submitted URB in brcmf_usb_dl_cmd if the request timed out. This
>> assures the URB is never submitted twice, preventing a driver crash.
>
> Hi,
>
> I am afrad this patch is no good. The diagnosis is good,
> but the fix introduces serious problems.
>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>> index 5265aa7..1bc7858 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
>> @@ -738,10 +738,12 @@ static int brcmf_usb_dl_cmd(struct brcmf_usbdev_info *devinfo, u8 cmd,
>>   goto finalize;
>>   }
>>  
>> - if (!brcmf_usb_ioctl_resp_wait(devinfo))
>> + if (!brcmf_usb_ioctl_resp_wait(devinfo)) {
>> + usb_unlink_urb(devinfo->ctl_urb);
>
> This is the asynchronous unlink. You have no guarantee it is finished
> after this point.
>
>>   ret = -ETIMEDOUT;
>> - else
>> + } else {
>>   memcpy(buffer, tmpbuf, buflen);
>> + }
>>  
>>  finalize:
>>   kfree(tmpbuf);
>
> Which means that you are freeing memory that may still be used by DMA
> at this time.
> In addition you have no guarantee that the unlink is indeed finished
> by the time the URB is reused.
> If you wish to take this approach you better forget about this URB
> and allocate a new one and free the buffer from the callback.

Hi Oliver,

Good catch. I think the DMA issue is also present in the current driver: it
frees the buffer without unlinking/killing the URB at all. Can a malicious USB
device force a timeout to occur (i.e. delay the call to the completion
handler)? If so this might be a use-after-free vulnerability.

It seems using usb_kill_urb instead of usb_unlink_urb in the patch prevents any
possible use-after-free. Can someone double check?

Kind regards,
Mathy

>
> Regards
> Oliver
>
