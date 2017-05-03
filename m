From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net v3] driver: veth: Fix one possbile memleak when fail
 to register_netdevice
Date: Wed, 3 May 2017 13:37:59 +0800
Message-ID: <CADvbK_c32g2t-Azgf10da8qke5B+wgG4dw3jLTE2L+R2qR3xPA@mail.gmail.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com>
 <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com>
 <000601d2c333$abb526d0$031f7470$@vip.163.com> <CADvbK_cVS=M3tuz0QQT18D32UzLkdL0RMHuFxqcBgtfq_w7+9Q@mail.gmail.com>
 <000c01d2c3b2$0925e880$1b71b980$@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <gfree.wind@vip.163.com>, davem <davem@davemloft.net>,
        jarod@redhat.com, Stephen Hemminger <stephen@networkplumber.org>,
        dsa@cumulusnetworks.com, network dev <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35547 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdECFiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 01:38:00 -0400
Received: by mail-qk0-f193.google.com with SMTP id u68so1324731qkd.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 22:38:00 -0700 (PDT)
In-Reply-To: <000c01d2c3b2$0925e880$1b71b980$@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 10:07 AM, Gao Feng <gfree.wind@foxmail.com> wrote:
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Xin Long
>> Sent: Wednesday, May 3, 2017 12:59 AM
>> On Tue, May 2, 2017 at 7:03 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
>> >> From: Xin Long [mailto:lucien.xin@gmail.com]
>> >> Sent: Tuesday, May 2, 2017 3:56 PM
>> >> On Sat, Apr 29, 2017 at 11:51 AM,  <gfree.wind@foxmail.com> wrote:
>> >> > From: Gao Feng <gfree.wind@foxmail.com>
>> > [...]
>> >> > -static void veth_dev_free(struct net_device *dev)
>> >> > +static void veth_destructor_free(struct net_device *dev)
>> >> >  {
>> >> >         free_percpu(dev->vstats);
>> >> > +}
>> >> not sure why you needed to add this function.
>> >> to use free_percpu() directly may be clearer.
>> >
>> > Because both of ndo_uninit and destructor need to perform same free
>> statements.
>> > It is good at maintain the codes with the common function.
>> >>
>> >> > +
>> >> > +static void veth_dev_uninit(struct net_device *dev) {
>> >> call free_percpu() here, no need to check dev->reg_state.
>> >> free_percpu will just return if dev->vstats is NULL.
>> >
>> > It would break the original design if don't check the reg_state.
>> > The original logic is that free the resources in the destructor, not in ndo_init.
>> I got what you're doing now, can you pls try to fix this with:
>>
>> --- a/drivers/net/veth.c
>> +++ b/drivers/net/veth.c
>> @@ -219,10 +219,9 @@ static int veth_dev_init(struct net_device *dev)
>>         return 0;
>>  }
>>
>> -static void veth_dev_free(struct net_device *dev)
>> +static void veth_dev_uninit(struct net_device *dev)
>>  {
>>         free_percpu(dev->vstats);
>> -       free_netdev(dev);
>>  }
>>
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>> @@ -279,6 +278,7 @@ static void veth_set_rx_headroom(struct net_device
>> *dev, int new_hr)
>>
>>  static const struct net_device_ops veth_netdev_ops = {
>>         .ndo_init            = veth_dev_init,
>> +       .ndo_uninit          = veth_dev_uninit,
>>         .ndo_open            = veth_open,
>>         .ndo_stop            = veth_close,
>>         .ndo_start_xmit      = veth_xmit,
>> @@ -317,7 +317,7 @@ static void veth_setup(struct net_device *dev)
>>                                NETIF_F_HW_VLAN_STAG_TX |
>>                                NETIF_F_HW_VLAN_CTAG_RX |
>>                                NETIF_F_HW_VLAN_STAG_RX);
>> -       dev->destructor = veth_dev_free;
>> +       dev->destructor = free_netdev;
>>         dev->max_mtu = ETH_MAX_MTU;
>>
>>         dev->hw_features = VETH_FEATURES;
>>
>>
>> just as what other virtual nic drivers do (vxlan, geneve, macsec, bridge ....)
>>
>
> The fix you mentioned change the original logic.
> The dev->vstats is freed in advance in the ndo_uninit, not destructor.
> It may break the backward.
Sorry, I didn't get your "backward"
I can't see there will be any problem caused by it.

can you say this patch also break the 'backward' ?
https://patchwork.ozlabs.org/patch/748964/

It's really weird to do dev->reg_state check in ndo_unint
ndo_unint is supposed to free the memory alloced in ndo_init.

>
> Regards
> Feng
>
>
