From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bluetooth: btusb: Fix issue with suspend
Date: Sat, 06 Sep 2014 12:16:09 -0500
Message-ID: <540B4159.9000003@lwfinger.net>
References: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net> <6DF81E54-681F-4B18-95C7-F4684FF19786@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Champion Chen <champion_chen@realsil.com.cn>,
	Stable <stable@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:51985 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaIFRQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 13:16:12 -0400
In-Reply-To: <6DF81E54-681F-4B18-95C7-F4684FF19786@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2014 12:02 PM, Marcel Holtmann wrote:
> Hi Larry,
>
>> Suspend could fail for some platforms because
>> btusb_suspend==> btusb_stop_traffic ==> usb_kill_anchored_urbs,
>>
>> When btusb_bulk_complete returns before system suspend and resubmits an urb,
>> the system cannot enter suspend state.
>>
>> Signed-off-by: Champion Chen <champion_chen@realsil.com.cn>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: Stable <stable@vger.kernel.org>
>> ---
>> Johan,
>>
>> To help Champion with the process, I have formatted the patch in
>> the correct manner. I hope I understand the issue correctly and
>> stated it in a coherent manner in the commit message.
>>
>> Larry
>> ---
>> drivers/bluetooth/btusb.c | 9 +++++++++
>> 1 file changed, 9 insertions(+)
>>
>> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
>> index 292c38e..45a7211 100644
>> --- a/drivers/bluetooth/btusb.c
>> +++ b/drivers/bluetooth/btusb.c
>> @@ -330,6 +330,9 @@ static void btusb_intr_complete(struct urb *urb)
>> 			BT_ERR("%s corrupted event packet", hdev->name);
>> 			hdev->stat.err_rx++;
>> 		}
>> +	} else if (urb->status == -ENOENT) {
>> +		/* Avoid suspend failed when usb_kill_urb */
>> +		return;
>> 	}
>>
>> 	if (!test_bit(BTUSB_INTR_RUNNING, &data->flags))
>> @@ -417,6 +420,9 @@ static void btusb_bulk_complete(struct urb *urb)
>> 						urb->actual_length) < 0) {
>> 			BT_ERR("%s corrupted ACL packet", hdev->name);
>> 			hdev->stat.err_rx++;
>> +		} else if (urb->status == -ENOENT) {
>> +			/* Avoid suspend failed when usb_kill_urb */
>> +			return;
>> 		}
>
> this one is utterly bogus. Either urb->status is 0 or it is -ENOENT, but it will not be both. I think you put it to the wrong if clause.

Thanks for the review. Obviously, you are correct. A revised patch will be sent 
soon.

The code sent by Champion is now posted at 
http://github.com/lwfinger/rtl8723au_bt/new. It works for everyone that has 
tested it.

Larry
