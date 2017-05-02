From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net v3] driver: veth: Fix one possbile memleak when fail
 to register_netdevice
Date: Wed, 3 May 2017 00:59:19 +0800
Message-ID: <CADvbK_cVS=M3tuz0QQT18D32UzLkdL0RMHuFxqcBgtfq_w7+9Q@mail.gmail.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com>
 <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com> <000601d2c333$abb526d0$031f7470$@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem <davem@davemloft.net>, jarod@redhat.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        dsa@cumulusnetworks.com, network dev <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36039 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdEBQ7U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:59:20 -0400
Received: by mail-qt0-f196.google.com with SMTP id t52so21145767qtb.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 09:59:20 -0700 (PDT)
In-Reply-To: <000601d2c333$abb526d0$031f7470$@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 7:03 PM, Gao Feng <gfree.wind@vip.163.com> wrote:
>> From: Xin Long [mailto:lucien.xin@gmail.com]
>> Sent: Tuesday, May 2, 2017 3:56 PM
>> On Sat, Apr 29, 2017 at 11:51 AM,  <gfree.wind@foxmail.com> wrote:
>> > From: Gao Feng <gfree.wind@foxmail.com>
> [...]
>> > -static void veth_dev_free(struct net_device *dev)
>> > +static void veth_destructor_free(struct net_device *dev)
>> >  {
>> >         free_percpu(dev->vstats);
>> > +}
>> not sure why you needed to add this function.
>> to use free_percpu() directly may be clearer.
>
> Because both of ndo_uninit and destructor need to perform same free statements.
> It is good at maintain the codes with the common function.
>>
>> > +
>> > +static void veth_dev_uninit(struct net_device *dev) {
>> call free_percpu() here, no need to check dev->reg_state.
>> free_percpu will just return if dev->vstats is NULL.
>
> It would break the original design if don't check the reg_state.
> The original logic is that free the resources in the destructor, not in ndo_init.
I got what you're doing now, can you pls try to fix this with:

--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -219,10 +219,9 @@ static int veth_dev_init(struct net_device *dev)
        return 0;
 }

-static void veth_dev_free(struct net_device *dev)
+static void veth_dev_uninit(struct net_device *dev)
 {
        free_percpu(dev->vstats);
-       free_netdev(dev);
 }

 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -279,6 +278,7 @@ static void veth_set_rx_headroom(struct net_device
*dev, int new_hr)

 static const struct net_device_ops veth_netdev_ops = {
        .ndo_init            = veth_dev_init,
+       .ndo_uninit          = veth_dev_uninit,
        .ndo_open            = veth_open,
        .ndo_stop            = veth_close,
        .ndo_start_xmit      = veth_xmit,
@@ -317,7 +317,7 @@ static void veth_setup(struct net_device *dev)
                               NETIF_F_HW_VLAN_STAG_TX |
                               NETIF_F_HW_VLAN_CTAG_RX |
                               NETIF_F_HW_VLAN_STAG_RX);
-       dev->destructor = veth_dev_free;
+       dev->destructor = free_netdev;
        dev->max_mtu = ETH_MAX_MTU;

        dev->hw_features = VETH_FEATURES;


just as what other virtual nic drivers do (vxlan, geneve, macsec, bridge ....)

>
> BTW, because I send multiple patches too fast today, the email server blocks my account.
> So I have to reply you with a different email account. Sorry.
>
> Best Regards
> Feng
>
>>
> [...]
>
>
