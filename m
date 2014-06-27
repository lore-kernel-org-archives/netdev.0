From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH - RESEND] Bluetooth: Keep master role when SCO or eSCO is active
Date: Fri, 27 Jun 2014 11:41:15 +0200
Message-ID: <1C876A95-8077-4BA9-9A16-8AEB9C6AF117@holtmann.org>
References: <1403860813-360-1-git-send-email-kiran.kumar@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	"hyungseoung.yoo" <hyungseoung.yoo@samsung.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Android Kernel Team <kernel-team@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Jaikumar Ganesh <jaikumarg@android.com>
To: Kiran Kumar Raparthy <kiran.kumar@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403860813-360-1-git-send-email-kiran.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kiran,

> Preserve the master role when SCO or eSCO is active
> as this improves compatability with lots of
> headset and chipset combinations.

this comment is pretty much non-sense. If you have an incoming BR/EDR connection, then by default you will be slave. The acceptor is the slave, there is no way of preserving the master role. You never had it in the first place.

So lets assume you have an existing connection with a different device, then yes it could be beneficial to not enter a scatternet situation. Assume you are already master in the existing connection, then sure, staying master here is beneficial since you don't want to maintain a second connection and you want to drive the piconet. However what happens when you are slave in the existing connection. Are you forcing now master role on the new connection or better stay slave. Or check if you might be able to become master for both devices and thus move them into a single piconet.

> This is one of the number of patches from the Android AOSP
> common.git tree, which is used on almost all Android devices.
> It looks like it would improve support for compatibility with
> lot of headset,so I wanted to submit it for review to see
> if it should go upstream.
> 
> v3: Fixed formatting issues pointed by Sergei
> 
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Gustavo Padovan <gustavo@padovan.org>
> Cc: Johan Hedberg <johan.hedberg@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-bluetooth@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: John Stultz <john.stultz@linaro.org>
> Signed-off-by: hyungseoung.yoo <hyungseoung.yoo@samsung.com>
> Signed-off-by: Jaikumar Ganesh <jaikumarg@android.com>
> [kiran: Added context to commit message]
> Signed-off-by: Kiran Raparthy <kiran.kumar@linaro.org>

I am pretty sick of just blasting patches to everybody on the planet. Patches concerning Bluetooth subsystem should be send to linux-bluetooth@vger.kernel.org only. There is no point in spamming everybody else.

> ---
> net/bluetooth/hci_event.c | 12 +++++++++++-
> 1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
> index 15010a2..cfb1355 100644
> --- a/net/bluetooth/hci_event.c
> +++ b/net/bluetooth/hci_event.c
> @@ -1915,6 +1915,14 @@ unlock:
> 	hci_conn_check_pending(hdev);
> }
> 
> +static inline bool is_sco_active(struct hci_dev *hdev)
> +{
> +	if (hci_conn_hash_lookup_state(hdev, SCO_LINK, BT_CONNECTED) ||
> +	    hci_conn_hash_lookup_state(hdev, ESCO_LINK, BT_CONNECTED))
> +		return true;
> +	return false;
> +}
> +
> static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
> {
> 	struct hci_ev_conn_request *ev = (void *) skb->data;
> @@ -1961,7 +1969,9 @@ static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
> 
> 			bacpy(&cp.bdaddr, &ev->bdaddr);
> 
> -			if (lmp_rswitch_capable(hdev) && (mask & HCI_LM_MASTER))
> +			if (lmp_rswitch_capable(hdev) &&
> +			    ((mask & HCI_LM_MASTER) ||
> +			    is_sco_active(hdev)))
> 				cp.role = 0x00; /* Become master */
> 			else
> 				cp.role = 0x01; /* Remain slave */

So this is a policy that takes global affect and might not be the what all devices want to do. The problem now is that acceptors force slave role on the initiator. It might be the case that the initiator can not facilitate the slave role here. And that results in connection failures with certain devices. Not a good idea.

Where I am standing this should be a policy that the SCO sockets that are active can enforce. So on a SCO socket you might set that you want to stay master. And that policy, if set, then gets enforced here. That allows other profiles to pick whatever policy they want.

Regards

Marcel
