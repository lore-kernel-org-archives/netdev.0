From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Wed, 10 Sep 2014 10:42:41 +0300
Message-ID: <541000F1.5000805@mellanox.com>
References: <53F1EF18.7010909@acm.org> <53F47917.8080003@mellanox.com> <F580F466-28A5-4BDD-A338-D5C065A760C1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <F580F466-28A5-4BDD-A338-D5C065A760C1-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 9/9/2014 10:30 PM, Chuck Lever wrote:
> This crash happens when booting v3.17-rcN on any of my IB-enabled
> systems. I have both ConnectX-2 and mthca systems, all are affected.
>
> I bisected this to:
>
> commit e0f31d8498676fda36289603a054d0d490aa2679
> Author:     Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>
> AuthorDate: Mon Jun 23 16:07:58 2014 +0530
> Commit:     David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> CommitDate: Mon Jun 23 14:32:19 2014 -0700
>
>      flow_keys: Record IP layer protocol in skb_flow_dissect()
>
>      skb_flow_dissect() dissects only transport header type in ip_pro=
to. It dose not
>      give any information about IPv4 or IPv6.
>      This patch adds new member, n_proto, to struct flow_keys. Which =
records the
>      IP layer type. i.e IPv4 or IPv6.
>      This can be used in netdev->ndo_rx_flow_steer driver function to=
 dissect flow.
>      Adding new member to flow_keys increases the struct size by arou=
nd 4 bytes.
>      This causes BUILD_BUG_ON(sizeof(qcb->data) < sz); to fail in
>      qdisc_cb_private_validate()
>      So increase data size by 4
>
>      Signed-off-by: Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>
>      Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>
>
> This commit includes a hunk that increases the size of struct qdisc_s=
kb_cb
> by at least 4 bytes:
>
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index 624f985..a3cfb8e 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -231,7 +231,7 @@ struct qdisc_skb_cb {
>>          unsigned int            pkt_len;
>>          u16                     slave_dev_queue_mapping;
>>          u16                     _pad;
>> -       unsigned char           data[20];
>> +       unsigned char           data[24];
>>   };
>>  =20
>>   static inline void qdisc_cb_private_validate(const struct sk_buff =
*skb, int sz)
>
>
> IPoIB defines the following structure in drivers/infiniband/ulp/ipoib=
/ipoib.h:
>
>> struct ipoib_cb {
>>          struct qdisc_skb_cb     qdisc_cb;
>>          u8                      hwaddr[INFINIBAND_ALEN];
>> };
> IPoIB keeps this in the sk_buff:cb field, which is exactly 48 bytes.
> After commit e0f31d84, the size of struct ipoib_cb on x86_64 becomes
> 52 bytes.
>
> Thus IPoIB overruns sk_buff:cb, and trashes the sk_buff::_skb_refdst
> field, which contains a pointer. By the time we get into
> __dev_queue_xmit() and try to use the result of skb_dst(), that point=
er
> is garbage, and we oops.
>
> Obviously, cb[] could be increased to 56 bytes to accommodate struct
> ipoib_cb. I tried this, and it is effective in preventing the oops on
> one of my systems.
>
> But I suspect there is an historical reason I=92m not aware of that i=
t
> has remained 48 bytes for years.

Hi Chuck, thanks for bisecting this out. Indeed, as of this kernel 3.2=20
commit 936d7de "IPoIB: Stop lying about hard_header_len and use skb->cb=
=20
to stash LL addresses" we are using the skb->cb field to enable proper=20
work under GRO and avoid another historical quirk we had there... so I=20
think we can definetly consider commit e0f31d849 to introduce a severe=20
regression... Govindarajulu, Dave - what's your thinking here? any quic=
k=20
idea on how to fix?

Also, I was thinking we have the mechanics in the kernel, e.g commit=20
a0417fa3a18a ("net: Make qdisc_skb_cb upper size bound explicit.") to=20
catch such over-flows?

Or.

>>> BUG: unable to handle kernel paging request at ffff88090000007e
>>> IP: __dev_queue_xmit+0x519
>>> Call Trace:
>>> ? __dev_queue_xmit+0x49
>>> dev_queue_xmit+0x10
>>> neigh_connected_output
>>> ? ip_finish_output
>>> ip_finish_output
>>> ? ip_finish_output
>>> ? netif_rx_ni
>>> ip_mc_output
>>> ip_local_out_sk
>>> ip_send_skb
>>> udp_send_skb
>>> udp_sendmsg
>>> ? ip_reply_glue_bits
>>> ? __lock_is_held
>>> inet_sendmsg
>>> ? inet_sendmsg
>>> sock_sendmsg
>>> ? might_fault
>>> ? might_fault
>>> ? move_addr_to_kernel.part.38
>>> SYSC_sendto
>>> ? sysret_check
>>> ? trace_hardirqs_on_caller
>>> ? trace_hardirqs_on_thunk
>>> SyS_sendto
>>> system_call_fastpath
>>>
>>> Kernel panic - not syncing: Fatal exception in interrupt
>>> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xfff=
fffff80000000-0xffffffff9fffffff)
>>> drm_kms_helper: panic occurred, switching back to text console
>>>
>>> A screenshot of this kernel oops can be found here:
>>> https://drive.google.com/file/d/0B1YQOreL3_FxVDB5UTNwekF6LVU/
>>>
>>> gdb translates the crash address into the following (not sure this =
makes sense
>>> since offset 0x519 is past the end of __dev_queue_xmit()):
>>>
>>> (gdb) list *(__dev_queue_xmit+0x519)
>>> 0xffffffff8136bc89 is in netdev_adjacent_rename_links (net/core/dev=
=2Ec:5167).
>>> 5162    void netdev_adjacent_rename_links(struct net_device *dev, c=
har *oldname)
>>> 5163    {
>>> 5164            struct netdev_adjacent *iter;
>>> 5165
>>> 5166            list_for_each_entry(iter, &dev->adj_list.upper, lis=
t) {
>>> 5167                    netdev_adjacent_sysfs_del(iter->dev, oldnam=
e,
>>> 5168                                              &iter->dev->adj_l=
ist.lower);
>>> 5169                    netdev_adjacent_sysfs_add(iter->dev, dev,
>>> 5170                                              &iter->dev->adj_l=
ist.lower);
>>> 5171            }
>>>
>>> And the address __dev_queue_xmit+0x49 is translated by gdb into:
>>>
>>> (gdb) list *(__dev_queue_xmit+0x49)
>>> 0xffffffff8136b7b9 is in __dev_queue_xmit (./arch/x86/include/asm/p=
reempt.h:75).
>>> 70       * The various preempt_count add/sub methods
>>> 71       */
>>> 72
>>> 73      static __always_inline void __preempt_count_add(int val)
>>> 74      {
>>> 75              raw_cpu_add_4(__preempt_count, val);
>>> 76      }
>>> 77
>>> 78      static __always_inline void __preempt_count_sub(int val)
>>> 79      {

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
