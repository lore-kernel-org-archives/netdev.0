From: vaughan <vaughan.cao@oracle.com>
Subject: Re: [PATCH NET-NEXT V2] netxen: fix ethtool rx_dropped information
 in ethtool get_ethtool_stats()
Date: Wed, 09 Jul 2014 19:45:06 +0800
Message-ID: <53BD2B42.9000008@oracle.com>
References: <1404827830-22990-1-git-send-email-ethan.zhao@oracle.com> <53BCABD3.3050207@oracle.com> <31AFFC7280259C4184970ABA9AFE8B93E074D13E@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "balbi@ti.com" <balbi@ti.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"sriharsha.devdas@oracle.com" <sriharsha.devdas@oracle.com>,
	"ethan.kernel@gmail.com" <ethan.kernel@gmail.com>
To: Manish Chopra <manish.chopra@qlogic.com>,
	ethan zhao <ethan.zhao@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B93E074D13E@avmb3.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/09/2014 07:32 PM, Manish Chopra wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org]
>> On Behalf Of ethan zhao
>> Sent: Wednesday, July 09, 2014 8:11 AM
>> To: David Miller
>> Cc: balbi@ti.com; netdev; linux-kernel; sriharsha.devdas@oracle.com;
>> ethan.kernel@gmail.com; vaughan
>> Subject: Re: [PATCH NET-NEXT V2] netxen: fix ethtool rx_dropped info=
rmation in
>> ethtool get_ethtool_stats()
>>
>> David,
>>
>>    Please help to review and confirm this patch.
>>
>> Thanks,
>> Ethan
>>
>> On 2014/7/8 21:57, Ethan Zhao wrote:
>>> netxen driver has implemented netxen_nic_get_ethtool_stats()
>>> interface, but it doesn't collect stats.rxdropped in driver, so we
>>> will get different rx_dropped statistic information while using ifc=
onfig and
>> ethtool.
>>> this patch fills stats.rxdropped field with data from net core with
>>> dev_get_stats() just as ixgbe driver did for some of its stats.
>>>
>>> V2: only fix the stats.rxdropped field.
>>>
>>> Tested with last netxen 4.0.82
>>> Compiled with net-next branch 3.16-rc2
>>>
>>> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
>>> Tested-by: Sriharsha Yadagudde <sriharsha.devdas@oracle.com>
>>> ---
>>>   .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   34 +++++++=
++++++++++-
>> --
>>>   1 files changed, 29 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.=
c
>>> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> index 4ca2c19..49e6a1b 100644
>>> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> @@ -33,22 +33,30 @@
>>>   #include "netxen_nic.h"
>>>   #include "netxen_nic_hw.h"
>>>
>>> +enum {NETDEV_STATS, NETXEN_STATS};
>>> +
>>>   struct netxen_nic_stats {
>>>   	char stat_string[ETH_GSTRING_LEN];
>>> +	int type;
>>>   	int sizeof_stat;
>>>   	int stat_offset;
>>>   };
>>>
>>> -#define NETXEN_NIC_STAT(m) sizeof(((struct netxen_adapter *)0)->m)=
, \
>>> +#define NETXEN_NIC_STAT(m)	NETXEN_STATS, \
>>> +			sizeof(((struct netxen_adapter *)0)->m), \
>>>   			offsetof(struct netxen_adapter, m)
>>>
>>> +#define NETXEN_NETDEV_STAT(m)	NETDEV_STATS, \
>>> +			sizeof(((struct rtnl_link_stats64 *)0)->m), \
>>> +			offsetof(struct rtnl_link_stats64, m)
>>> +
>>>   #define NETXEN_NIC_PORT_WINDOW 0x10000
>>>   #define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
>>>
>>>   static const struct netxen_nic_stats netxen_nic_gstrings_stats[] =
=3D {
>>>   	{"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
>>>   	{"xmit_finished", NETXEN_NIC_STAT(stats.xmitfinished)},
>>> -	{"rx_dropped", NETXEN_NIC_STAT(stats.rxdropped)},
>>> +	{"rx_dropped", NETXEN_NETDEV_STAT(rx_dropped)},
>>>   	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
>>>   	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
>>>   	{"rx_pkts", NETXEN_NIC_STAT(stats.rx_pkts)}, @@ -679,11 +687,27 =
@@
>>> netxen_nic_get_ethtool_stats(struct net_device *dev,
>>>   {
>>>   	struct netxen_adapter *adapter =3D netdev_priv(dev);
>>>   	int index;
>>> +	struct rtnl_link_stats64 temp;
>>> +	const struct rtnl_link_stats64 *net_stats;
>>> +	char *p =3D NULL;
>>>
>>> +	net_stats =3D dev_get_stats(dev, &temp);
>>>   	for (index =3D 0; index < NETXEN_NIC_STATS_LEN; index++) {
>>> -		char *p =3D
>>> -		    (char *)adapter +
>>> -		    netxen_nic_gstrings_stats[index].stat_offset;
>>> +
>>> +		switch (netxen_nic_gstrings_stats[index].type) {
>>> +		case NETDEV_STATS:
>>> +			p =3D (char *)net_stats +
>>> +				netxen_nic_gstrings_stats[index].stat_offset;
>>> +			break;
>>> +		case NETXEN_STATS:
>>> +			p =3D (char *)adapter +
>>> +				netxen_nic_gstrings_stats[index].stat_offset;
>>> +			break;
>>> +		default:
>>> +			data[index] =3D 0;
>>> +			continue;
>>> +		}
>>> +
>>>   		data[index] =3D
>>>   		    (netxen_nic_gstrings_stats[index].sizeof_stat =3D=3D
>>>   		     sizeof(u64)) ? *(u64 *) p : *(u32 *) p;
> Ethan, I can't download this patch as I don=E2=80=99t see it in netde=
v patchwork. Just looking at the diff I think there is style issue with=
 macro definition of NETXEN_NIC_STAT and NETXEN_NETDEV_STAT.
> Enclose macro definition in parentheses as they are containing comple=
x values.
It's not an error as checkpatch.pl indicates.  As the definition of
netxen_nic_stats shows,

  struct netxen_nic_stats {
  	char stat_string[ETH_GSTRING_LEN];
+	int type;
  	int sizeof_stat;
  	int stat_offset;
  };

This macros consists of multiple elements, which shouldn't be enclosed
in parentheses.

>
> Send this patch targeted for net instead of net-next being a bug fix.=
 Please also run checkpatch.pl to correct any style warning/errors in t=
he patch.
>
> Thanks!! =20
>
