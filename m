From: Paul Gortmaker <paul.gortmaker@gmail.com>
Subject: Re: [PATCH net] macvlan: fix leak in macvlan_handle_frame
Date: Mon, 7 Dec 2015 18:25:37 -0500
Message-ID: <CAP=VYLpP9xzV5i-TY5xZfhGSqQFq+L-sN3opid294kESCuPoLA@mail.gmail.com>
References: <d4141a7c4841ae5f631858a8537968419f0e396b.1447705984.git.sd@queasysnail.net>
 <20151117.144014.402280202991903863.davem@davemloft.net> <CAP=VYLrNh2KUFTMZnNfvyoSiO1dG3xvV8-XRszD51o+kEKA=ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sd@queasysnail.net, netdev <netdev@vger.kernel.org>,
	jiri@resnulli.us, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35443 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932555AbbLGX0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 18:26:08 -0500
Received: by wmuu63 with SMTP id u63so160674528wmu.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 15:26:07 -0800 (PST)
In-Reply-To: <CAP=VYLrNh2KUFTMZnNfvyoSiO1dG3xvV8-XRszD51o+kEKA=ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 6, 2015 at 6:35 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
> On Tue, Nov 17, 2015 at 2:40 PM, David Miller <davem@davemloft.net> wrote:
>> From: Sabrina Dubroca <sd@queasysnail.net>
>> Date: Mon, 16 Nov 2015 22:54:20 +0100
>>
>>> Reset pskb in macvlan_handle_frame in case skb_share_check returned a
>>> clone.
>>>
>>> Fixes: 8a4eb5734e8d ("net: introduce rx_handler results and logic around that")
>>> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>>
>> Applied.
>
> Just as a report, using my sbc8641d (powerpc dual core 7448) and as of this
> commit it fails to NFS boot (according to git bisect).  Unclear to me why this
> would trigger it.  The fail looks like:

Apologies; turns out I pooched the bisect while trying to race a dying laptop
battery.  It is a couple commits after this, v4.3-11564-g321beec5047a that
changes PHY handling based on whether it has an IRQ or not (which makes
a lot more sense).  Reverting that on v4.4-rc4 makes it work and confirms
I've got the bisect right this time.

I'll follow up that patch once I investigate a bit further as to whether it just
uncovers a board issue (broken PHY irq line or similar) that previously just
went unseen.

Sorry again for the noise.
Paul.
--

>
> IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> fsl-gianfar f8024000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
> IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> IP-Config: Unable to set interface netmask (-22)
>
> Board uses 1st gen FSL gianfar hardware.
>
> Bisect log follows. Will look into it more as time permits.
>
> Paul.
> --
>
> paul@yow-lpgnfs-02:~/git/linux-head$ git bisect log
> git bisect start 'net' 'drivers/net'
> # good: [6a13feb9c82803e2b815eca72fa7a9f5561d7861] Linux 4.3
> git bisect good 6a13feb9c82803e2b815eca72fa7a9f5561d7861
> # bad: [31ade3b83e1821da5fbb2f11b5b3d4ab2ec39db8] Linux 4.4-rc3
> git bisect bad 31ade3b83e1821da5fbb2f11b5b3d4ab2ec39db8
> # good: [991659674288dba28c2f5a3d1a0133ef4d20824a] Merge tag
> 'wireless-drivers-next-for-davem-2015-10-09' of
> git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
> git bisect good 991659674288dba28c2f5a3d1a0133ef4d20824a
> # good: [d59542ddcb547871b1913c34c31a6d207627db02] Merge tag
> 'wireless-drivers-next-for-davem-2015-10-27' of
> git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
> git bisect good d59542ddcb547871b1913c34c31a6d207627db02
> # good: [41ecf1404b34d9975eb97f5005d9e4274eaeb76a] Merge tag
> 'for-linus-4.4-rc0-tag' of
> git://git.kernel.org/pub/scm/linux/kernel/git/xen/tip
> git bisect good 41ecf1404b34d9975eb97f5005d9e4274eaeb76a
> # good: [2df4ee78d042ee3d17cbebd51e31b300286549dc] Merge
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> git bisect good 2df4ee78d042ee3d17cbebd51e31b300286549dc
> # good: [00ee5927177792a6e139d50b6b7564d35705556a] net: fix
> __netdev_update_features return on ndo_set_features failure
> git bisect good 00ee5927177792a6e139d50b6b7564d35705556a
> # bad: [a3a116e04cc6a94d595ead4e956ab1bc1d2f4746] af_unix: take
> receive queue lock while appending new skb
> git bisect bad a3a116e04cc6a94d595ead4e956ab1bc1d2f4746
> # good: [f1a454a37618b819f2528ccd234f77a02b3a6016] ipg: Remove ipg driver
> git bisect good f1a454a37618b819f2528ccd234f77a02b3a6016
> # bad: [e639b8d8a7a728f0b05ef2df6cb6b45dc3d4e556] macvlan: fix leak in
> macvlan_handle_frame
> git bisect bad e639b8d8a7a728f0b05ef2df6cb6b45dc3d4e556
> # good: [28f9ee22bcdd84726dbf6267d0b58f254166b900] vlan: Do not put
> vlan headers back on bridge and macvlan ports
> git bisect good 28f9ee22bcdd84726dbf6267d0b58f254166b900
> # good: [cf554ada0be7077906aa9a17faf151ff66e3cb8e] ipvlan: fix leak in
> ipvlan_rcv_frame
> git bisect good cf554ada0be7077906aa9a17faf151ff66e3cb8e
> # good: [a534dc529853c69e94994aa47c1d80a03ce2c11d] ipvlan: fix use
> after free of skb
> git bisect good a534dc529853c69e94994aa47c1d80a03ce2c11d
> # first bad commit: [e639b8d8a7a728f0b05ef2df6cb6b45dc3d4e556]
> macvlan: fix leak in macvlan_handle_frame
> paul@yow-lpgnfs-02:~/git/linux-head$
>
>
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
