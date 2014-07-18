From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool
 get_ethtool_stats()
Date: Fri, 18 Jul 2014 11:38:34 +0530
Message-ID: <53C8B9E2.7050709@gmail.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>	<53C898E7.5080204@gmail.com> <CABawtvOpER3yEqmLigSDt8Wy5_9X0QA2e0zJ+KByhOy7du2gVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, manish.chopra@qlogic.com,
	sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ethan Zhao <ethan.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABawtvOpER3yEqmLigSDt8Wy5_9X0QA2e0zJ+KByhOy7du2gVQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/18/2014 11:35 AM, Ethan Zhao wrote:
> On Fri, Jul 18, 2014 at 11:47 AM, Varka Bhadram <varkabhadram@gmail.com> wrote:
>> On 07/18/2014 09:13 AM, Ethan Zhao wrote:
>>> netxen driver has implemented netxen_nic_get_ethtool_stats() interface,
>>> but it doesn't collect stats.rxdropped in driver, so we will get
>>> different rx_dropped statistic information while using ifconfig and
>>> ethtool.
>>> this patch fills stats.rxdropped field with data from net core
>>> with dev_get_stats() just as ixgbe driver did for some of its stats.
>>>
>>> Tested with last netxen 4.0.82
>>> Compiled with stable 3.15.6
>>>
>>> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
>>> Tested-by: Sriharsha Yadagudde <sriharsha.devdas@oracle.com>
>>> ---
>>> -v2 only fix rx_dropped field, not all.
>>> -v3 workaround checkpatch.pl bug according to suggestion from Joe Perches
>>> <joe@perches.com>
>>>    .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   59
>>> +++++++++++++++-----
>>>    1 files changed, 45 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> index 87e073c..2753f00 100644
>>> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
>>> @@ -31,28 +31,43 @@
>>>    #include "netxen_nic.h"
>>>    #include "netxen_nic_hw.h"
>>>    +enum {NETDEV_STATS, NETXEN_STATS};
>>> +
>>>    struct netxen_nic_stats {
>>>          char stat_string[ETH_GSTRING_LEN];
>>> +       int type;
>>>          int sizeof_stat;
>>>          int stat_offset;
>>>    };
>>>    -#define NETXEN_NIC_STAT(m) sizeof(((struct netxen_adapter *)0)->m), \
>>> -                       offsetof(struct netxen_adapter, m)
>>> +#define NETXEN_NIC_STAT(name, m)                                       \
>>> +{                                                                      \
>>> +       .stat_string = name,                                            \
>>> +       .type = NETXEN_STATS,                                           \
>>> +       .sizeof_stat = FIELD_SIZEOF(struct netxen_adapter, m),          \
>>> +       .stat_offset = offsetof(struct netxen_adapter, m)               \
>>> +}
>>> +
>>> +#define NETXEN_NETDEV_STAT(name, m)                                    \
>>> +{      .stat_string = name,                                            \
>>> +       .type = NETDEV_STATS,                                           \
>>> +       .sizeof_stat = FIELD_SIZEOF(struct rtnl_link_stats64, m),       \
>>> +       .stat_offset = offsetof(struct rtnl_link_stats64, m)            \
>>> +}
>>>      #define NETXEN_NIC_PORT_WINDOW 0x10000
>>>    #define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
>>>      static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
>>> -       {"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
>>> -       {"xmit_finished", NETXEN_NIC_STAT(stats.xmitfinished)},
>>> -       {"rx_dropped", NETXEN_NIC_STAT(stats.rxdropped)},
>>> -       {"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
>>> -       {"csummed", NETXEN_NIC_STAT(stats.csummed)},
>>> -       {"rx_pkts", NETXEN_NIC_STAT(stats.rx_pkts)},
>>> -       {"lro_pkts", NETXEN_NIC_STAT(stats.lro_pkts)},
>>> -       {"rx_bytes", NETXEN_NIC_STAT(stats.rxbytes)},
>>> -       {"tx_bytes", NETXEN_NIC_STAT(stats.txbytes)},
>>> +       NETXEN_NIC_STAT("xmit_called", stats.xmitcalled),
>>> +       NETXEN_NIC_STAT("xmit_finished", stats.xmitfinished),
>>> +       NETXEN_NETDEV_STAT("rx_dropped", rx_dropped),
>>> +       NETXEN_NIC_STAT("tx_dropped", stats.txdropped),
>>> +       NETXEN_NIC_STAT("csummed", stats.csummed),
>>> +       NETXEN_NIC_STAT("rx_pkts", stats.rx_pkts),
>>> +       NETXEN_NIC_STAT("lro_pkts", stats.lro_pkts),
>>> +       NETXEN_NIC_STAT("rx_bytes", stats.rxbytes),
>>> +       NETXEN_NIC_STAT("tx_bytes", stats.txbytes),
>>>    };
>>>      #define NETXEN_NIC_STATS_LEN
>>> ARRAY_SIZE(netxen_nic_gstrings_stats)
>>> @@ -677,11 +692,27 @@ netxen_nic_get_ethtool_stats(struct net_device *dev,
>>>    {
>>>          struct netxen_adapter *adapter = netdev_priv(dev);
>>>          int index;
>>> +       struct rtnl_link_stats64 temp;
>>> +       const struct rtnl_link_stats64 *net_stats;
>>> +       char *p = NULL;
>>>    +     net_stats = dev_get_stats(dev, &temp);
>>>          for (index = 0; index < NETXEN_NIC_STATS_LEN; index++) {
>>> -               char *p =
>>> -                   (char *)adapter +
>>> -                   netxen_nic_gstrings_stats[index].stat_offset;
>>> +
>>> +               switch (netxen_nic_gstrings_stats[index].type) {
>>> +               case NETDEV_STATS:
>>> +                       p = (char *)net_stats +
>>> +
>>> netxen_nic_gstrings_stats[index].stat_offset;
>>> +                       break;
>>> +               case NETXEN_STATS:
>>> +                       p = (char *)adapter +
>>> +
>>> netxen_nic_gstrings_stats[index].stat_offset;
>>> +                       break;
>>> +               default:
>>> +                       data[index] = 0;
>>> +                       continue;
>>
>> If there is a chance of default case, then it will be always in switch case
>> ...?
>    It is possible that hit the default case, but will not stay in swich case.
>    try this little case
>
>   #include <stdio.h>
> #include <stdlib.h>
>
> main()
> {
>          int i,j;
>          for (i=0; i<16; i++) {
>                  j=i%3;
>
>          switch(j) {
>          case 1:
>                  printf("i=%d\n",i);
>                  break;
>          case 2:
>                  printf("i=%d\n",i);
>                  break;
>          default:
>                  printf("i=%d,j=%d\n",i,j);
>                  continue;
>          }
>          }
> }
>
Ohhh.. You are right . Thanks for the clarity.  :-)


-- 
Regards,
Varka Bhadram.
