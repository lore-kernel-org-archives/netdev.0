From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Mon, 29 Sep 2014 14:52:39 -0400
Message-ID: <6C43129E-4365-4BEF-ADAD-963B8F386789@oracle.com>
References: <53F1EF18.7010909@acm.org> <53F47917.8080003@mellanox.com> <F580F466-28A5-4BDD-A338-D5C065A760C1@oracle.com> <541000F1.5000805@mellanox.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML Kernel <linux-kernel@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bart Van Assche <bvanassche@acm.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Roland Dreier <roland@kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <541000F1.5000805@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 10, 2014, at 3:42 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:

>=20
> On 9/9/2014 10:30 PM, Chuck Lever wrote:
>> This crash happens when booting v3.17-rcN on any of my IB-enabled
>> systems. I have both ConnectX-2 and mthca systems, all are affected.
>>=20
>> I bisected this to:
>>=20
>> commit e0f31d8498676fda36289603a054d0d490aa2679
>> Author:     Govindarajulu Varadarajan <_govind@gmx.com>
>> AuthorDate: Mon Jun 23 16:07:58 2014 +0530
>> Commit:     David S. Miller <davem@davemloft.net>
>> CommitDate: Mon Jun 23 14:32:19 2014 -0700
>>=20
>>     flow_keys: Record IP layer protocol in skb_flow_dissect()
>>=20
>>     skb_flow_dissect() dissects only transport header type in ip_pro=
to. It dose not
>>     give any information about IPv4 or IPv6.
>>     This patch adds new member, n_proto, to struct flow_keys. Which =
records the
>>     IP layer type. i.e IPv4 or IPv6.
>>     This can be used in netdev->ndo_rx_flow_steer driver function to=
 dissect flow.
>>     Adding new member to flow_keys increases the struct size by arou=
nd 4 bytes.
>>     This causes BUILD_BUG_ON(sizeof(qcb->data) < sz); to fail in
>>     qdisc_cb_private_validate()
>>     So increase data size by 4
>>=20
>>     Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>=20
>>=20
>> This commit includes a hunk that increases the size of struct qdisc_=
skb_cb
>> by at least 4 bytes:
>>=20
>>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>>> index 624f985..a3cfb8e 100644
>>> --- a/include/net/sch_generic.h
>>> +++ b/include/net/sch_generic.h
>>> @@ -231,7 +231,7 @@ struct qdisc_skb_cb {
>>>         unsigned int            pkt_len;
>>>         u16                     slave_dev_queue_mapping;
>>>         u16                     _pad;
>>> -       unsigned char           data[20];
>>> +       unsigned char           data[24];
>>>  };
>>>    static inline void qdisc_cb_private_validate(const struct sk_buf=
f *skb, int sz)
>>=20
>>=20
>> IPoIB defines the following structure in drivers/infiniband/ulp/ipoi=
b/ipoib.h:
>>=20
>>> struct ipoib_cb {
>>>         struct qdisc_skb_cb     qdisc_cb;
>>>         u8                      hwaddr[INFINIBAND_ALEN];
>>> };
>> IPoIB keeps this in the sk_buff:cb field, which is exactly 48 bytes.
>> After commit e0f31d84, the size of struct ipoib_cb on x86_64 becomes
>> 52 bytes.
>>=20
>> Thus IPoIB overruns sk_buff:cb, and trashes the sk_buff::_skb_refdst
>> field, which contains a pointer. By the time we get into
>> __dev_queue_xmit() and try to use the result of skb_dst(), that poin=
ter
>> is garbage, and we oops.
>>=20
>> Obviously, cb[] could be increased to 56 bytes to accommodate struct
>> ipoib_cb. I tried this, and it is effective in preventing the oops o=
n
>> one of my systems.
>>=20
>> But I suspect there is an historical reason I=92m not aware of that =
it
>> has remained 48 bytes for years.
>=20
> Hi Chuck, thanks for bisecting this out. Indeed, as of this kernel 3.=
2 commit 936d7de "IPoIB: Stop lying about hard_header_len and use skb->=
cb to stash LL addresses" we are using the skb->cb field to enable prop=
er work under GRO and avoid another historical quirk we had there... so=
 I think we can definetly consider commit e0f31d849 to introduce a seve=
re regression... Govindarajulu, Dave - what's your thinking here? any q=
uick idea on how to fix?

Hi Or-

Is there a bugzilla report filed for this issue? Has there been any pro=
gress
towards a fix?


> Also, I was thinking we have the mechanics in the kernel, e.g commit =
a0417fa3a18a ("net: Make qdisc_skb_cb upper size bound explicit.") to c=
atch such over-flows?
>=20
> Or.
>=20
>>>> BUG: unable to handle kernel paging request at ffff88090000007e
>>>> IP: __dev_queue_xmit+0x519
>>>> Call Trace:
>>>> ? __dev_queue_xmit+0x49
>>>> dev_queue_xmit+0x10
>>>> neigh_connected_output
>>>> ? ip_finish_output
>>>> ip_finish_output
>>>> ? ip_finish_output
>>>> ? netif_rx_ni
>>>> ip_mc_output
>>>> ip_local_out_sk
>>>> ip_send_skb
>>>> udp_send_skb
>>>> udp_sendmsg
>>>> ? ip_reply_glue_bits
>>>> ? __lock_is_held
>>>> inet_sendmsg
>>>> ? inet_sendmsg
>>>> sock_sendmsg
>>>> ? might_fault
>>>> ? might_fault
>>>> ? move_addr_to_kernel.part.38
>>>> SYSC_sendto
>>>> ? sysret_check
>>>> ? trace_hardirqs_on_caller
>>>> ? trace_hardirqs_on_thunk
>>>> SyS_sendto
>>>> system_call_fastpath
>>>>=20
>>>> Kernel panic - not syncing: Fatal exception in interrupt
>>>> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xff=
ffffff80000000-0xffffffff9fffffff)
>>>> drm_kms_helper: panic occurred, switching back to text console
>>>>=20
>>>> A screenshot of this kernel oops can be found here:
>>>> https://drive.google.com/file/d/0B1YQOreL3_FxVDB5UTNwekF6LVU/
>>>>=20
>>>> gdb translates the crash address into the following (not sure this=
 makes sense
>>>> since offset 0x519 is past the end of __dev_queue_xmit()):
>>>>=20
>>>> (gdb) list *(__dev_queue_xmit+0x519)
>>>> 0xffffffff8136bc89 is in netdev_adjacent_rename_links (net/core/de=
v.c:5167).
>>>> 5162    void netdev_adjacent_rename_links(struct net_device *dev, =
char *oldname)
>>>> 5163    {
>>>> 5164            struct netdev_adjacent *iter;
>>>> 5165
>>>> 5166            list_for_each_entry(iter, &dev->adj_list.upper, li=
st) {
>>>> 5167                    netdev_adjacent_sysfs_del(iter->dev, oldna=
me,
>>>> 5168                                              &iter->dev->adj_=
list.lower);
>>>> 5169                    netdev_adjacent_sysfs_add(iter->dev, dev,
>>>> 5170                                              &iter->dev->adj_=
list.lower);
>>>> 5171            }
>>>>=20
>>>> And the address __dev_queue_xmit+0x49 is translated by gdb into:
>>>>=20
>>>> (gdb) list *(__dev_queue_xmit+0x49)
>>>> 0xffffffff8136b7b9 is in __dev_queue_xmit (./arch/x86/include/asm/=
preempt.h:75).
>>>> 70       * The various preempt_count add/sub methods
>>>> 71       */
>>>> 72
>>>> 73      static __always_inline void __preempt_count_add(int val)
>>>> 74      {
>>>> 75              raw_cpu_add_4(__preempt_count, val);
>>>> 76      }
>>>> 77
>>>> 78      static __always_inline void __preempt_count_sub(int val)
>>>> 79      {
>=20

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
