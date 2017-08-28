From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: fdb add and delete tracepoints
Date: Mon, 28 Aug 2017 07:30:20 -0700
Message-ID: <CAJieiUjYSosJ2UoKoLPMeCgubZ7rZq3sAA3svTNX6rnxdrm4XQ@mail.gmail.com>
References: <1503869593-30165-1-git-send-email-roopa@cumulusnetworks.com>
	<592631a3-6a80-407a-f087-37f7f04417d2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"davem@davemloft.net" <davem@davemloft.net>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <592631a3-6a80-407a-f087-37f7f04417d2@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 27, 2017 at 7:11 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 08/27/2017 02:33 PM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Tracepoints to trace bridge forwarding database updates.
>
> Thanks for adding this!
>
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>  include/trace/events/bridge.h | 98 +++++++++++++++++++++++++++++++++++++++++++
>>  net/bridge/br_fdb.c           |  7 ++++
>>  net/core/net-traces.c         |  6 +++
>>  3 files changed, 111 insertions(+)
>>  create mode 100644 include/trace/events/bridge.h
>>
>> diff --git a/include/trace/events/bridge.h b/include/trace/events/bridge.h
>> new file mode 100644
>> index 0000000..e2d52cf
>> --- /dev/null
>> +++ b/include/trace/events/bridge.h
>> @@ -0,0 +1,98 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM bridge
>> +
>> +#if !defined(_TRACE_BRIDGE_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_BRIDGE_H
>> +
>> +#include <linux/netdevice.h>
>> +#include <linux/tracepoint.h>
>> +
>> +#include "../../../net/bridge/br_private.h"
>> +
>> +TRACE_EVENT(br_fdb_add,
>> +
>> +     TP_PROTO(struct ndmsg *ndm, struct net_device *dev,
>> +              const unsigned char *addr, u16 vid, u16 nlh_flags),
>> +
>> +     TP_ARGS(ndm, dev, addr, vid, nlh_flags),
>> +
>> +     TP_STRUCT__entry(
>> +             __field(u8, ndm_flags)
>> +             __string(dev, dev->name)
>> +             __array(unsigned char, addr, 6)
>
> Can you use ETH_ALEN instead of 6 here?
>
>> +             __field(u16, vid)
>> +             __field(u16, nlh_flags)
>> +     ),
>> +
>> +     TP_fast_assign(
>> +             __assign_str(dev, dev->name);
>> +             memcpy(__entry->addr, addr, 6);
>
> Likewise


will do.

>
>> +             __entry->vid = vid;
>> +             __entry->nlh_flags = nlh_flags;
>> +             __entry->ndm_flags = ndm->ndm_flags;
>> +     ),
>> +
>> +     TP_printk("dev %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u nlh_flags %x ndm_flags = %x",
>
> I wonder if we could make %pM work for TP_printk() as this would
> simplify the argument list a bitt.

yeah i struggled with getting %pM to work here.

> Can you use %04x for vid, nlh_flags
> and %02x for ndm_flags?

will do,

>
>> +               __get_str(dev), __entry->addr[0], __entry->addr[1],
>> +               __entry->addr[2], __entry->addr[3], __entry->addr[4],
>> +               __entry->addr[5], __entry->vid,
>> +               __entry->nlh_flags, __entry->ndm_flags)
>> +);
>> +
>> +TRACE_EVENT(br_fdb_external_learn_add,
>> +
>> +     TP_PROTO(struct net_bridge *br, struct net_bridge_port *p,
>> +              const unsigned char *addr, u16 vid),
>> +
>> +     TP_ARGS(br, p, addr, vid),
>> +
>> +     TP_STRUCT__entry(
>> +             __string(br_dev, br->dev->name)
>> +             __string(dev, p->dev->name)
>> +             __array(unsigned char, addr, 6)
>> +             __field(u16, vid)
>> +     ),
>> +
>> +     TP_fast_assign(
>> +             __assign_str(br_dev, br ? br->dev->name : "null");
>> +             __assign_str(dev, p ? p->dev->name : "null");
>> +             memcpy(__entry->addr, addr, 6);
>> +             __entry->vid = vid;
>> +     ),
>> +
>> +     TP_printk("br_dev %s port %s addr %02x:%02x:%02x:%02x:%02x:%02x vid %u",
>> +               __get_str(br_dev), __get_str(dev), __entry->addr[0],
>> +               __entry->addr[1], __entry->addr[2], __entry->addr[3],
>> +               __entry->addr[4], __entry->addr[5], __entry->vid)
>> +);
>> +
>> +TRACE_EVENT(fdb_delete,
>> +
>> +     TP_PROTO(struct net_bridge *br, struct net_bridge_fdb_entry *f),
>> +
>> +     TP_ARGS(br, f),
>> +
>> +     TP_STRUCT__entry(
>> +             __string(br_dev, br->dev->name)
>> +             __string(dev, f->dst ? f->dst->dev->name : "null")
>> +             __array(unsigned char, addr, 6)
>
> Same here, using ETH_ALEN would be clearer.
>

ack, thanks for the review.
