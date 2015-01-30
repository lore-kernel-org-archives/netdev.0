From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH V2 5/6] rtlwifi: btcoexist: Add routines for RTL8812AE
 kernel socket communications
Date: Fri, 30 Jan 2015 09:18:38 -0600
Message-ID: <54CBA0CE.8030800@lwfinger.net>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net> <1422304934-9239-6-git-send-email-Larry.Finger@lwfinger.net> <87h9v8zkuh.fsf@kamboji.qca.qualcomm.com> <EC423C22-AEA0-4232-A452-7A131C41780A@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:45339 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762233AbbA3PSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 10:18:40 -0500
In-Reply-To: <EC423C22-AEA0-4232-A452-7A131C41780A@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2015 03:57 AM, Marcel Holtmann wrote:

Marcel,

> Hi Kalle,
>
>> I'm adding bluetooth list to the discussion. Full patch is available
>> here:
>>
>> https://patchwork.kernel.org/patch/5712591/
>>
>> Larry Finger <Larry.Finger@lwfinger.net> writes:
>>
>>> From: Troy Tan <troy_tan@realsil.com.cn>
>>>
>>> This patch adds the routines used to communicate between the RTL8812AE (wifi)
>>> device and the RTL8761AU (bluetooth) device that are part of the same chip.
>>> Unlike other similar dual-function devices, this chip does not contain special
>>> hardware that lets the firmware pass coexistence info from one part to the
>>> other. As a result, this driver implements such communication as a kernel
>>> socket.
>>>
>>> Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
>>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>>> ---
>>> V2 - Add comments explaining the routine that sends a message via the
>>> socket.
>>
>> The commit log is not still explaining that much about the actual
>> functionality, so I investigated on my own:
>>
>>> +static u8 rtl_btcoex_create_kernel_socket(struct rtl_priv *rtlpriv,
>>> +					  u8 is_invite)
>>> +{
>>> +	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
>>> +	s8 kernel_socket_err;
>>> +
>>> +	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
>>> +		  "%s CONNECT_PORT %d\n", __func__, CONNECT_PORT);
>>> +
>>> +	if (!pcoex_info) {
>>> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL, "coex_info: NULL\n");
>>> +		return _FAIL;
>>> +	}
>>> +
>>> +	kernel_socket_err = sock_create(PF_INET, SOCK_DGRAM, 0,
>>> +					&pcoex_info->udpsock);
>>> +	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
>>> +		  "binding socket, err = %d\n", kernel_socket_err);
>>> +
>>> +	if (kernel_socket_err < 0) {
>>> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
>>> +			  "Error during creation of socket error:%d\n",
>>> +			  kernel_socket_err);
>>> +		return _FAIL;
>>> +	}
>>> +	memset(&pcoex_info->sin, 0, sizeof(pcoex_info->sin));
>>> +	pcoex_info->sin.sin_family = AF_INET;
>>> +	pcoex_info->sin.sin_port = htons(CONNECT_PORT);
>>> +	pcoex_info->sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
>>> +
>>> +	memset(&pcoex_info->bt_addr, 0, sizeof(pcoex_info->bt_addr));
>>> +	pcoex_info->bt_addr.sin_family = AF_INET;
>>> +	pcoex_info->bt_addr.sin_port = htons(CONNECT_PORT_BT);
>>> +	pcoex_info->bt_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
>>> +
>>> +	pcoex_info->sk_store = NULL;
>>> +
>>> +	kernel_socket_err =
>>> +	   pcoex_info->udpsock->ops->bind(pcoex_info->udpsock,
>>> +					  (struct sockaddr *)&pcoex_info->sin,
>>> +					  sizeof(pcoex_info->sin));
>>> +	if (kernel_socket_err == 0) {
>>> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
>>> +			  "binding socket success\n");
>>> +		pcoex_info->udpsock->sk->sk_data_ready =
>>> +			rtl_btcoex_recvmsg_int;
>>> +		pcoex_info->sock_open |=  KERNEL_SOCKET_OK;
>>> +		pcoex_info->bt_attend = false;
>>> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
>>> +			  "WIFI sending attend_req\n");
>>> +		rtl_btcoex_sendmsgbysocket(rtlpriv, attend_req,
>>> +					   sizeof(attend_req), true);
>>> +		return _SUCCESS;
>>
>> So the wireless driver communicates with the bluetooth driver (which is
>> not in upstream) via a localhost UDP connection?
>
> I think the first order of business should be to get the Bluetooth driver upstream. Until that has happened this is all kinda pointless discussion.

I agree with this; however, the last time I tried to submit a BT driver for 
Realtek, I was told that this driver should use some (as yet included) feature. 
I have watched the driver development, and if that feature was ever included, it 
was in a form that I did not recognize. I'm sorry that this is vague, but this 
happened a long time ago.

--snip--

>> I know there's a general need for something similar like this, but it
>> needs to properly discussed and designed.
>
> This is just insane. Clear NAK.
>
> Two kernel modules will not use UDP ports over the loopback interface to communicate with each other.

I will work on combining the latest BT drivers from Realtek with btusb to see if 
I can achieve a patch that will both work with the Realtek hardware, and get 
approval from the reviewers.

What would be an approved method of communicating between two kernel modules? Is 
there some example in the kernel that I could study?

Larry
