From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v3 5/9] forcedeth: implement ndo_get_stats64() API
Date: Tue, 15 Nov 2011 11:30:33 -0800
Message-ID: <CAG88wWa2S3iQbk0t8rat39aPX0XXVfMG5ub2496gchoqgFBPhA@mail.gmail.com>
References: <cover.1321313729.git.david.decotigny@google.com>
 <e2dd16618bc1bd5108e6dea3c7531ee229e4c699.1321313729.git.david.decotigny@google.com>
 <20111114171039.34a04369@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111114171039.34a04369@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Mon, Nov 14, 2011 at 5:10 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Please existing u64_stats_sync rather than inventing your own
> method. The u64_stats_sync is faster and does require locking.

Thanks for your review.
This should be fixed in the v4 series I just sent:
http://patchwork.ozlabs.org/patch/125861/

Regards,

--
David Decotigny



On Mon, Nov 14, 2011 at 5:10 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 14 Nov 2011 16:11:15 -0800
> David Decotigny <david.decotigny@google.com> wrote:
>
>> This commit implements the ndo_get_stats64() API for forcedeth. Sinc=
e
>> these stats are being updated from different contexts (process and
>> timer), this commit adds protection (locking + atomic variables).
>>
>> Tested:
>> =A0 - 16-way SMP x86_64 ->
>> =A0 =A0 RX bytes:7244556582 (7.2 GB) =A0TX bytes:181904254 (181.9 MB=
)
>> =A0 - pktgen + loopback: identical rx_bytes/tx_bytes and rx_packets/=
tx_packets
>>
>>
>>
>> Signed-off-by: David Decotigny <david.decotigny@google.com>
>> ---
>> =A0drivers/net/ethernet/nvidia/forcedeth.c | =A0182 ++++++++++++++++=
++++++++-------
>> =A01 files changed, 141 insertions(+), 41 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/e=
thernet/nvidia/forcedeth.c
>> index ee8cce5..a67c1f4 100644
>> --- a/drivers/net/ethernet/nvidia/forcedeth.c
>> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
>> @@ -692,6 +692,21 @@ struct nv_ethtool_stats {
>> =A0#define NV_DEV_STATISTICS_V2_COUNT (NV_DEV_STATISTICS_V3_COUNT - =
3)
>> =A0#define NV_DEV_STATISTICS_V1_COUNT (NV_DEV_STATISTICS_V2_COUNT - =
6)
>>
>> +/* driver statistics */
>> +struct nv_driver_stat {
>> + =A0 =A0 atomic_t delta; =A0/* increase since last nv_update_stats(=
) */
>> + =A0 =A0 u64 total; =A0/* cumulative, requires netdev_priv(dev)->st=
ats_lock */
>> +};
>
> Please existing u64_stats_sync rather than inventing your own
> method. The u64_stats_sync is faster and does require locking.
>
