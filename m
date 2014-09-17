From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1] bluetooth: Check for SCO type before setting  retransmission effort
Date: Wed, 17 Sep 2014 06:55:26 -0700
Message-ID: <8B07B86E-19D4-49E2-B471-DAF31C8D4F34@holtmann.org>
References: <1410938010-6181-1-git-send-email-bernhard.thaler@r-it.at>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Bernhard Thaler <bernhard.thaler@r-it.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410938010-6181-1-git-send-email-bernhard.thaler@r-it.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bernhard,

> SCO connection cannot be setup to devices that do not support retransmission.
> Patch based on http://permalink.gmane.org/gmane.linux.bluez.kernel/7779 and
> adapted for this kernel version.
> Code changed to check SCO/eSCO type before setting retransmission effort 
> and max. latency. The purpose of the patch is to support older devices not
> capable of eSCO.
> 
> Tested on Blackberry 655+ headset which does not support retransmission.
> Credits go to Alexander Sommerhuber.
> 
> Signed-off-by: Bernhard Thaler <bernhard.thaler@r-it.at>
> ---
> net/bluetooth/hci_conn.c |   39 ++++++++++++++++++++++-----------------
> 1 file changed, 22 insertions(+), 17 deletions(-)
> 
> diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
> index faff624..093abcc 100644
> --- a/net/bluetooth/hci_conn.c
> +++ b/net/bluetooth/hci_conn.c
> @@ -186,26 +186,31 @@ bool hci_setup_sync(struct hci_conn *conn, __u16 handle)
> 	cp.rx_bandwidth   = cpu_to_le32(0x00001f40);
> 	cp.voice_setting  = cpu_to_le16(conn->setting);
> 
> -	switch (conn->setting & SCO_AIRMODE_MASK) {
> -	case SCO_AIRMODE_TRANSP:
> -		if (conn->attempt > ARRAY_SIZE(sco_param_wideband))
> -			return false;
> -		cp.retrans_effort = 0x02;
> -		param = &sco_param_wideband[conn->attempt - 1];
> -		break;
> -	case SCO_AIRMODE_CVSD:
> -		if (conn->attempt > ARRAY_SIZE(sco_param_cvsd))
> +	if (!(conn->link->features[0][3] & LMP_ESCO)) {

so we have something that is called lmp_esco_capable.

> +		cp.retrans_effort = 0xff;
> +		cp.pkt_type = __cpu_to_le16(conn->pkt_type);
> +		cp.max_latency = __cpu_to_le16(0xffff);

Anyway, I do not thing this is the right approach. I think what we should do is just reject a connection attempt for transparent eSCO connections (since we only use them for wideband speech anyway) when connecting to a device that has no eSCO support.

> +	} else {
> +		switch (conn->setting & SCO_AIRMODE_MASK) {
> +		case SCO_AIRMODE_TRANSP:
> +			if (conn->attempt > ARRAY_SIZE(sco_param_wideband))
> +				return false;
> +			cp.retrans_effort = 0x02;
> +			param = &sco_param_wideband[conn->attempt - 1];
> +			break;
> +		case SCO_AIRMODE_CVSD:
> +			if (conn->attempt > ARRAY_SIZE(sco_param_cvsd))
> +				return false;
> +			cp.retrans_effort = 0x01;
> +			param = &sco_param_cvsd[conn->attempt - 1];
> +			break;

For CVSD based attempts, we should start with non eSCO parameter settings if we know that the remote side can not support eSCO.

The reason is that you still need to follow through with defined parameter sets from the HFP profile.

Regards

Marcel
