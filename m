From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time stamping policy
Date: Mon, 13 May 2013 15:48:43 +0000
Message-ID: <CDB65511.1CE8D%matthew.vick@intel.com>
References: <20130513100742.GM8399@zhudong.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Howells <dhowells@redhat.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.ne
To: Dong Zhu <bluezhudong@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130513100742.GM8399@zhudong.nay.redhat.com>
Content-Language: en-US
Content-ID: <AD8DAF99FE7A5E438C558B8D0D72E49B@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/13/13 3:07 AM, "Dong Zhu" <bluezhudong@gmail.com> wrote:

>> You could use the flags field, as it has no definition yet.
>>=20
>> But you still need to explain why this new functionality is needed i=
n
>> the first place:
>>=20
>> - You can query an interface's time stamping capabilities with the
>>   GET_TS_INFO ethtool command.
>>=20
>
>Hi,
>
>I modified this patch and added the method to igb_get_ts_info function=
=2E
>For 82576 nic, through this method we can easily check which type of
>packets
>are time stamped now, such as (HWTSTAMP_FILTER_PTP_V1_L4_SYNC and
>HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ), then change or disable it up to
>your requests.
>I think it is convenient.The origial GET_TS_INFO method can only show =
the
>device=B9s
>time stamping capabilities which nics supported.
>
>I use the tx_reserved[0] and rx_reserved[0] to restore the
>hwtstamp_tx_types and
>hwtstamp_rx_filters enumeration values.
>
>Due to the limitation of 80 characters one line, I have to move the
>switch out of else judegment.
>
>I test it on I350 and 82576NS nics and it works as expect.
>
>Could help reviewing it again ? Any comments would be appreciated.
>
>
>From 8a12932fd2a3bb5ca904bc72b20140247a5d81be Mon Sep 17 00:00:00 2001
>From: Dong Zhu <bluezhudong@gmail.com>
>Date: Mon, 13 May 2013 17:27:59 +0800
>
>Currently kernel only support setting the hw time stamping policy
>through ioctl,now add a method to check which packets(Outgoing and
>Incoming) are time stamped by nic.
>
>Add this to igb_get_ts_info, we can query this by using the GET_TS_INF=
O
>ethtool command. Testing on I350 and 82576NS it seems work well.
>
>Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
>---
> drivers/net/ethernet/intel/igb/igb_ethtool.c | 78
>+++++++++++++++++++++++++++-
> include/uapi/linux/ethtool.h                 |  3 ++
> 2 files changed, 79 insertions(+), 2 deletions(-)

[...]

>diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool=
=2Eh
>index 0c9b448..06cdbc0 100644
>--- a/include/uapi/linux/ethtool.h
>+++ b/include/uapi/linux/ethtool.h
>@@ -772,7 +772,10 @@ struct ethtool_sfeatures {
>  * @so_timestamping: bit mask of the sum of the supported
>SO_TIMESTAMPING flags
>  * @phc_index: device index of the associated PHC, or -1 if there is =
none
>  * @tx_types: bit mask of the supported hwtstamp_tx_types enumeration
>values
>+ * @tx_reserved[0]: bit mask of the in use hwtstamp_tx_types enumerat=
ion
>values
>  * @rx_filters: bit mask of the supported hwtstamp_rx_filters
>enumeration values
>+ * @rx_reserved[0]: bit mask of the in use hwtstamp_rx_filters
>enumeration
>+ * values
>  *
>  * The bits in the 'tx_types' and 'rx_filters' fields correspond to
>  * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration valu=
es,
>--=20
>1.7.11.7
>
>
>--=20
>Best Regards,
>Dong Zhu

CCing Ben Hutchings, since now your patch is affecting ethtool.

Dong,

The drivers should already be updating the config.tx_type and
config.rx_filter with what the driver is configuring the device for, so
any userspace application that needs to know what the device is actuall=
y
configured for can check those values after the ioctl call. If the
userspace app needs to know for certain that something is going to be
handled, it should just call the ioctl (as Richard suggested).

I'm not sure what you mean by "checking more" with the 82599EB in ixgbe=
=2E
It is permissible to timestamp additional packets, as long as the user
gets the packets they requested timestamped. This in mind, it's much mo=
re
efficient for the I350 to timestamp all receive packets and prevents ot=
her
headaches (for example, failure to timestamp if the device receives two
packets that should be timestamped at once). Because of this, the 82599=
EB
may have more individual filters, but the driver will be upscaling any
user input request to HWTSTAMP_FILTER_ALL on I350.

Cheers,
Matthew
