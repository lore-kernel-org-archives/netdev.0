From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCHv2 next 3/3] ipvlan: Introduce l3s mode
Date: Wed, 14 Sep 2016 12:04:12 -0600
Message-ID: <14bd5ab7-9206-1399-01c3-4b4ed06ce6f9@cumulusnetworks.com>
References: <1473703312-26757-1-git-send-email-mahesh@bandewar.net>
 <1177f2c5-6c2d-32e1-1628-f272d6b0b5c6@cumulusnetworks.com>
 <CAF2d9jgEOsSEQXOVJWJsw=RMdr27YiTdcMPrZ6P2EopqU8wtkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34132 "EHLO
        mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755452AbcINSEf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 14:04:35 -0400
Received: by mail-pa0-f52.google.com with SMTP id wk8so7565578pab.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 11:04:14 -0700 (PDT)
In-Reply-To: <CAF2d9jgEOsSEQXOVJWJsw=RMdr27YiTdcMPrZ6P2EopqU8wtkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/14/16 10:30 AM, Mahesh Bandewar (महेश बंडेवार) wrote:
> Hi David, thanks for the comments.
> 
> On Tue, Sep 13, 2016 at 8:24 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 9/12/16 12:01 PM, Mahesh Bandewar wrote:
>>
>>> +struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
>>> +                           u16 proto)
>>> +{
>>> +     struct ipvl_addr *addr;
>>> +     struct net_device *sdev;
>>> +
>>> +     addr = ipvlan_skb_to_addr(skb, dev);
>>> +     if (!addr)
>>> +             goto out;
>>> +
>>> +     sdev = addr->master->dev;
>>> +     switch (proto) {
>>> +     case AF_INET:
>>> +     {
>>> +             int err;
>>> +             struct iphdr *ip4h = ip_hdr(skb);
>>> +
>>> +             err = ip_route_input_noref(skb, ip4h->daddr, ip4h->saddr,
>>> +                                        ip4h->tos, sdev);
>>> +             if (unlikely(err))
>>> +                     goto out;
>>> +             break;
>>> +     }
>>> +     case AF_INET6:
>>> +     {
>>> +             struct dst_entry *dst;
>>> +             struct ipv6hdr *ip6h = ipv6_hdr(skb);
>>> +             int flags = RT6_LOOKUP_F_HAS_SADDR;
>>> +             struct flowi6 fl6 = {
>>> +                     .flowi6_iif   = sdev->ifindex,
>>> +                     .daddr        = ip6h->daddr,
>>> +                     .saddr        = ip6h->saddr,
>>> +                     .flowlabel    = ip6_flowinfo(ip6h),
>>> +                     .flowi6_mark  = skb->mark,
>>> +                     .flowi6_proto = ip6h->nexthdr,
>>> +             };
>>> +
>>> +             skb_dst_drop(skb);
>>> +             dst = ip6_route_input_lookup(dev_net(sdev), sdev, &fl6, flags);
>>> +             skb_dst_set(skb, dst);
>>> +             break;
>>> +     }
>>> +     default:
>>> +             break;
>>> +     }
>>
>> Nit: why not put the above in separate per-version functions (ipvlan_ip_rcv and ipvlan_ip6_rcv) similar to what is done for ipvlan_process_outbound?
>>
> I can but it's small enough to have it together. Also 'proto' is a
> parameter to the handler and makes it easier However do you see any
> issue having just one function?

no, just readability comment about putting the case statements in helper functions.

> 
>>
>>> +
>>> +out:
>>> +     return skb;
>>> +}
>>> +
>>> +unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
>>> +                          const struct nf_hook_state *state)
>>> +{
>>> +     struct ipvl_addr *addr;
>>> +     unsigned int len;
>>> +
>>> +     addr = ipvlan_skb_to_addr(skb, skb->dev);
>>> +     if (!addr)
>>> +             goto out;
>>> +
>>> +     skb->dev = addr->master->dev;
>>> +     len = skb->len + ETH_HLEN;
>>> +     ipvlan_count_rx(addr->master, len, true, false);
>>> +out:
>>> +     return NF_ACCEPT;
>>> +}
>>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>>> index 18b4e8c7f68a..d02be277e1db 100644
>>> --- a/drivers/net/ipvlan/ipvlan_main.c
>>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>>> @@ -9,24 +9,65 @@
>>>
>>>  #include "ipvlan.h"
>>>
>>> +static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
>>> +     {
>>> +             .hook     = ipvlan_nf_input,
>>> +             .pf       = NFPROTO_IPV4,
>>> +             .hooknum  = NF_INET_LOCAL_IN,
>>> +             .priority = INT_MAX,
>>> +     },
>>> +     {
>>> +             .hook     = ipvlan_nf_input,
>>> +             .pf       = NFPROTO_IPV6,
>>> +             .hooknum  = NF_INET_LOCAL_IN,
>>> +             .priority = INT_MAX,
>>> +     },
>>> +};
>>> +
>>> +static struct l3mdev_ops ipvl_l3mdev_ops __read_mostly = {
>>> +     .l3mdev_l3_rcv = ipvlan_l3_rcv,
>>> +};
>>> +
>>>  static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
>>>  {
>>>       ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
>>>  }
>>>
>>> -static void ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
>>> +static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
>>>  {
>>>       struct ipvl_dev *ipvlan;
>>> +     int err = 0;
>>>
>>> +     ASSERT_RTNL();
>>>       if (port->mode != nval) {
>>> +             if (nval == IPVLAN_MODE_L3S) {
>>> +                     port->dev->l3mdev_ops = &ipvl_l3mdev_ops;
>>> +                     port->dev->priv_flags |= IFF_L3MDEV_MASTER;
>>> +                     if (!port->ipt_hook_added) {
>>> +                             err = _nf_register_hooks(ipvl_nfops,
>>> +                                                     ARRAY_SIZE(ipvl_nfops));
>>
>> That's clever. The hooks are not device based so why do the register for each device? Alternatively, you could use a static dst like VRF does for Tx. In the ipvlan rcv function set the dst input handler to send the packet back to the ipvlan driver via dst->input. From there send the packet through the netfilter hooks and then do the real lookup, update the dst and call its input function. I have working code for VRF driver somewhere that shows how to do this.
>>
> Do you mean per slave device?  It's registering it for a port (so only
> once) depending on the mode. If the mode != l3s it wont bother
> registering to keep current modes as they are.

My reading of the patch the register is called for each ipvlan newlink that uses l3s mode. Adding this debug patch 

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index d02be277e1db..3f733f1e18ae 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -46,6 +46,7 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
                        if (!port->ipt_hook_added) {
                                err = _nf_register_hooks(ipvl_nfops,
                                                        ARRAY_SIZE(ipvl_nfops));
+pr_warn("called _nf_register_hooks for dev %s: err %d\n", port->dev->name, err);
                                if (!err)
                                        port->ipt_hook_added = true;
                                else
@@ -54,9 +55,11 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
                } else {
                        port->dev->priv_flags &= ~IFF_L3MDEV_MASTER;
                        port->dev->l3mdev_ops = NULL;
-                       if (port->ipt_hook_added)
+                       if (port->ipt_hook_added) {
+pr_warn("calling _nf_unregister_hooks for dev %s\n", port->dev->name);
                                _nf_unregister_hooks(ipvl_nfops,
                                                     ARRAY_SIZE(ipvl_nfops));
+                       }
                        port->ipt_hook_added = false;
                }
                list_for_each_entry(ipvlan, &port->ipvlans, pnode) {



and building, installing and testing I see this:

$ ip link add ipvl1 link eth1 type ipvlan mode l3s
-->  called _nf_register_hooks for dev eth1: err 0

$ ip link add ipvl2 link eth1 type ipvlan mode l3s
--> no message generated

$ ip link add ipvl3 link eth2 type ipvlan mode l3s
--> called _nf_register_hooks for dev eth2: err 0


But there is more. If I delete all 3 ipvlan devices the nf_unregister is not called. Unload the ipvlan module and panic:

[  181.135061] BUG: unable to handle kernel paging request at ffffffffa002cfca
[  181.137710] IP: [<ffffffffa002cfca>] 0xffffffffa002cfca
[  181.139574] PGD 1a07067 PUD 1a08063 PMD 1387e4067 PTE 0
[  181.140964] Oops: 0010 [#1] SMP
[  181.141684] Modules linked in: 8021q garp mrp stp llc vrf [last unloaded: ipvlan]
[  181.143678] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.8.0-rc6+ #96
[  181.145092] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  181.147340] task: ffff88013f196180 task.stack: ffff88013f19c000
[  181.148510] RIP: 0010:[<ffffffffa002cfca>]  [<ffffffffa002cfca>] 0xffffffffa002cfca
[  181.150044] RSP: 0018:ffff88013fc83bd0  EFLAGS: 00010a12
[  181.151102] RAX: ffff88013a781c88 RBX: ffff88013fc83c08 RCX: 0000000000000000
[  181.152460] RDX: ffff88013fc83c38 RSI: ffff88013ab15600 RDI: 0000000000000000
[  181.153781] RBP: ffff88013fc83bf8 R08: 0000000000004b61 R09: 0000000000000004
[  181.155107] R10: 0000000000000000 R11: ffffea00044d9c80 R12: ffffffff81a89510
[  181.156426] R13: ffff88013ab15600 R14: ffff88013fc83c38 R15: ffff88013ab15600
[  181.157742] FS:  0000000000000000(0000) GS:ffff88013fc80000(0000) knlGS:0000000000000000
[  181.159232] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  181.160303] CR2: ffffffffa002cfca CR3: 000000013a5de000 CR4: 00000000000406e0
[  181.161588] Stack:
[  181.161954]  ffffffff813f8b47 ffff88013ab15600 ffff88013ab15600 ffff88013fc83c38
[  181.163353]  ffff88013874ac4e ffff88013fc83c28 ffffffff813f8b8c ffff88013a781c88
[  181.164722]  ffff88013ab15600 ffffffff81a88b00 ffff88013874ac4e ffff88013fc83c88
[  181.166094] Call Trace:
[  181.166532]  <IRQ>
[  181.166885]  [<ffffffff813f8b47>] ? nf_iterate+0x41/0x5b
[  181.167880]  [<ffffffff813f8b8c>] nf_hook_slow+0x2b/0x94
[  181.168803]  [<ffffffff81400c6e>] ip_local_deliver+0xa4/0xbf
[  181.169748]  [<ffffffff81400644>] ? xfrm4_policy_check.constprop.8+0x52/0x52
[  181.170910]  [<ffffffff81400a71>] ip_rcv_finish+0x2ed/0x34a
[  181.171841]  [<ffffffff81400f02>] ip_rcv+0x279/0x2fb
...


Also, another sequence:
$ ip link add ipvl1 link eth1 type ipvlan mode l3s
-->  called _nf_register_hooks for dev eth1: err 0

$ ip link add ipvl2 link eth1 type ipvlan mode l3s
--> no message generated

$ ip link set ipvl2 type ipvlan mode l3
--> calling _nf_unregister_hooks for dev eth1

that means the hooks are not there for ipvl1. I can remove the module with no panic.
