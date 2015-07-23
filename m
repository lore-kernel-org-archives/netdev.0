From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2.1 21/22] fjes: handle receive cancellation request
 interrupt
Date: Thu, 23 Jul 2015 16:06:01 +0300
Message-ID: <55B0E6B9.3070301@cogentembedded.com>
References: <1437610142-12439-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1437610236-12490-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1437610236-12490-21-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	stephen@networkplumber.org, yasu.isimatu@gmail.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1437610236-12490-21-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 7/23/2015 3:10 AM, Taku Izumi wrote:

> This patch adds implementation of handling IRQ
> of other receiver's receive cancellation request.

> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>   drivers/net/fjes/fjes_main.c | 79 ++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 79 insertions(+)
>
> diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
> index faaf2ed..b21ad68 100644
> --- a/drivers/net/fjes/fjes_main.c
> +++ b/drivers/net/fjes/fjes_main.c
> @@ -822,6 +822,75 @@ static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
>   	return 0;
>   }
>
> +static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
> +				   int src_epid)
> +{
> +	struct fjes_hw *hw = &adapter->hw;
> +	enum ep_partner_status status;
> +
> +	status = fjes_hw_get_partner_ep_status(hw, src_epid);
> +	switch (status) {
> +	case EP_PARTNER_UNSHARE:
> +	default:
> +		break;
> +	case EP_PARTNER_COMPLETE:
> +		break;

    Why this *case* isn't merged with the above ones?

> +	case EP_PARTNER_WAITING:
> +		if (src_epid < hw->my_epid) {
> +			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
> +				FJES_RX_STOP_REQ_DONE;
> +
> +			clear_bit(src_epid, &hw->txrx_stop_req_bit);
> +			set_bit(src_epid, &adapter->unshare_watch_bitmask);
> +
> +			if (!work_pending(&adapter->unshare_watch_task))
> +				queue_work(adapter->control_wq,
> +					   &adapter->unshare_watch_task);
> +		}
> +		break;
> +	case EP_PARTNER_SHARED:
> +		if (hw->ep_shm_info[src_epid].rx.info->v1i.rx_status
> +				& FJES_RX_STOP_REQ_REQUEST) {

    Please leave the & operator on the first line and start the second line 
right under 'hw' on the first.

[...]

MBR, Sergei
