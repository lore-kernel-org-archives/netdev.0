From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: btusb: Fix issue with suspend
Date: Sat, 6 Sep 2014 10:02:14 -0700
Message-ID: <6DF81E54-681F-4B18-95C7-F4684FF19786@holtmann.org>
References: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Champion Chen <champion_chen@realsil.com.cn>,
	Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Larry,

> Suspend could fail for some platforms because
> btusb_suspend==> btusb_stop_traffic ==> usb_kill_anchored_urbs,
> 
> When btusb_bulk_complete returns before system suspend and resubmits an urb,
> the system cannot enter suspend state.
> 
> Signed-off-by: Champion Chen <champion_chen@realsil.com.cn>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> ---
> Johan,
> 
> To help Champion with the process, I have formatted the patch in
> the correct manner. I hope I understand the issue correctly and
> stated it in a coherent manner in the commit message.
> 
> Larry
> ---
> drivers/bluetooth/btusb.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
> index 292c38e..45a7211 100644
> --- a/drivers/bluetooth/btusb.c
> +++ b/drivers/bluetooth/btusb.c
> @@ -330,6 +330,9 @@ static void btusb_intr_complete(struct urb *urb)
> 			BT_ERR("%s corrupted event packet", hdev->name);
> 			hdev->stat.err_rx++;
> 		}
> +	} else if (urb->status == -ENOENT) {
> +		/* Avoid suspend failed when usb_kill_urb */
> +		return;
> 	}
> 
> 	if (!test_bit(BTUSB_INTR_RUNNING, &data->flags))
> @@ -417,6 +420,9 @@ static void btusb_bulk_complete(struct urb *urb)
> 						urb->actual_length) < 0) {
> 			BT_ERR("%s corrupted ACL packet", hdev->name);
> 			hdev->stat.err_rx++;
> +		} else if (urb->status == -ENOENT) {
> +			/* Avoid suspend failed when usb_kill_urb */
> +			return;
> 		}

this one is utterly bogus. Either urb->status is 0 or it is -ENOENT, but it will not be both. I think you put it to the wrong if clause.

> 	}
> 
> @@ -512,6 +518,9 @@ static void btusb_isoc_complete(struct urb *urb)
> 				hdev->stat.err_rx++;
> 			}
> 		}
> +	} else if (urb->status == -ENOENT) {
> +		/* Avoid suspend failed when usb_kill_urb */
> +		return;
> 	}
> 
> 	if (!test_bit(BTUSB_ISOC_RUNNING, &data->flags))

Regards

Marcel
