From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V2 5/6] rtlwifi: btcoexist: Add routines for RTL8812AE kernel socket communications
Date: Fri, 30 Jan 2015 11:19:50 +0200
Message-ID: <87h9v8zkuh.fsf@kamboji.qca.qualcomm.com>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net>
	<1422304934-9239-6-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422304934-9239-6-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
	(Larry Finger's message of "Mon, 26 Jan 2015 14:42:13 -0600")
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I'm adding bluetooth list to the discussion. Full patch is available
here:

https://patchwork.kernel.org/patch/5712591/

Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:

> From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>
> This patch adds the routines used to communicate between the RTL8812AE (wifi)
> device and the RTL8761AU (bluetooth) device that are part of the same chip.
> Unlike other similar dual-function devices, this chip does not contain special
> hardware that lets the firmware pass coexistence info from one part to the
> other. As a result, this driver implements such communication as a kernel
> socket.
>
> Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> ---
> V2 - Add comments explaining the routine that sends a message via the
> socket.

The commit log is not still explaining that much about the actual
functionality, so I investigated on my own:

> +static u8 rtl_btcoex_create_kernel_socket(struct rtl_priv *rtlpriv,
> +					  u8 is_invite)
> +{
> +	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
> +	s8 kernel_socket_err;
> +
> +	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +		  "%s CONNECT_PORT %d\n", __func__, CONNECT_PORT);
> +
> +	if (!pcoex_info) {
> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL, "coex_info: NULL\n");
> +		return _FAIL;
> +	}
> +
> +	kernel_socket_err = sock_create(PF_INET, SOCK_DGRAM, 0,
> +					&pcoex_info->udpsock);
> +	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +		  "binding socket, err = %d\n", kernel_socket_err);
> +
> +	if (kernel_socket_err < 0) {
> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +			  "Error during creation of socket error:%d\n",
> +			  kernel_socket_err);
> +		return _FAIL;
> +	}
> +	memset(&pcoex_info->sin, 0, sizeof(pcoex_info->sin));
> +	pcoex_info->sin.sin_family = AF_INET;
> +	pcoex_info->sin.sin_port = htons(CONNECT_PORT);
> +	pcoex_info->sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
> +
> +	memset(&pcoex_info->bt_addr, 0, sizeof(pcoex_info->bt_addr));
> +	pcoex_info->bt_addr.sin_family = AF_INET;
> +	pcoex_info->bt_addr.sin_port = htons(CONNECT_PORT_BT);
> +	pcoex_info->bt_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
> +
> +	pcoex_info->sk_store = NULL;
> +
> +	kernel_socket_err =
> +	   pcoex_info->udpsock->ops->bind(pcoex_info->udpsock,
> +					  (struct sockaddr *)&pcoex_info->sin,
> +					  sizeof(pcoex_info->sin));
> +	if (kernel_socket_err == 0) {
> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +			  "binding socket success\n");
> +		pcoex_info->udpsock->sk->sk_data_ready =
> +			rtl_btcoex_recvmsg_int;
> +		pcoex_info->sock_open |=  KERNEL_SOCKET_OK;
> +		pcoex_info->bt_attend = false;
> +		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
> +			  "WIFI sending attend_req\n");
> +		rtl_btcoex_sendmsgbysocket(rtlpriv, attend_req,
> +					   sizeof(attend_req), true);
> +		return _SUCCESS;

So the wireless driver communicates with the bluetooth driver (which is
not in upstream) via a localhost UDP connection?

> +#define CONNECT_PORT 30000
> +#define CONNECT_PORT_BT 30001

And these are the UDP ports used.

> +struct hci_link_info {
> +	u16		connect_handle;
> +	u8		incoming_traffic_mode;
> +	u8		outgoing_traffic_mode;
> +	u8		bt_profile;
> +	u8		bt_corespec;
> +	s8		bt_RSSI;
> +	u8		traffic_profile;
> +	u8		link_role;
> +};
> +
> +#define	MAX_BT_ACL_LINK_NUM		8
> +
> +struct hci_ext_config {
> +	struct hci_link_info	acl_link[MAX_BT_ACL_LINK_NUM];
> +	u8	bt_operation_code;
> +	u16	current_connect_handle;
> +	u8	current_incoming_traffic_mode;
> +	u8	current_outgoing_traffic_mode;
> +
> +	u8	number_of_acl;
> +	u8	number_of_sco;
> +	u8	current_bt_status;
> +	u16	hci_ext_ver;
> +	bool	enable_wifi_scan_notify;
> +};

[...]

> +enum HCI_STATUS {
> +	/* Success */
> +	HCI_STATUS_SUCCESS				= 0x00,
> +	/* Unknown HCI Command */
> +	HCI_STATUS_UNKNOW_HCI_CMD			= 0x01,
> +	/* Unknown Connection Identifier */
> +	HCI_STATUS_UNKNOW_CONNECT_ID			= 0X02,
> +	/* Hardware Failure */
> +	HCI_STATUS_HW_FAIL				= 0X03,
> +	/* Page Timeout */
> +	HCI_STATUS_PAGE_TIMEOUT				= 0X04,
> +	/* Authentication Failure */
> +	HCI_STATUS_AUTH_FAIL				= 0X05,
> +	/* PIN or Key Missing */
> +	HCI_STATUS_PIN_OR_KEY_MISSING			= 0X06,
> +	/* Memory Capacity Exceeded */
> +	HCI_STATUS_MEM_CAP_EXCEED			= 0X07,
> +	/* Connection Timeout */
> +	HCI_STATUS_CONNECT_TIMEOUT			= 0X08,
> +	/* Connection Limit Exceeded */

And here's part of the information exchanged between the drivers.

This is something which needs to be properly reviewed both in wireless
and bluetooth lists, a wireless driver cannot just invent these on their
own. And using UDP sockets for this is in my opinion just horrible.

I know there's a general need for something similar like this, but it
needs to properly discussed and designed.

Comments?

-- 
Kalle Valo
