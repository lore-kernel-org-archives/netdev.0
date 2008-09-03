From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 3 Sep 2008 17:00:47 +0200
Message-ID: <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
References: <20080902194603.GA2825@2ka.mipt.ru>
	 <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
	 <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
	 <20080903.040626.198546183.davem@davemloft.net>
	 <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
	 <20080903132734.GA17541@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:4747 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365AbYICPAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 11:00:48 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2802866rvb.1
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 08:00:47 -0700 (PDT)
In-Reply-To: <20080903132734.GA17541@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

The driver and the hardware support DMA scater/gather and checksum offloading.

with pktgen and this below config, i reached 85MBytes/s ~ link
saturation (I've reached the same bitrate with raw socket + TX RING
ZeroCopy patch):
#!/bin/sh
echo rem_device_all > /proc/net/pktgen/kpktgend_0
echo add_device eth0 > /proc/net/pktgen/kpktgend_0
echo max_before_softirq 10000 > /proc/net/pktgen/kpktgend_0
sleep 1
echo count 10000000 > /proc/net/pktgen/eth0
echo clone_skb 0 > /proc/net/pktgen/eth0
echo pkt_size 7200 > /proc/net/pktgen/eth0
echo delay 0 > /proc/net/pktgen/eth0
echo dst 192.168.0.1 > /proc/net/pktgen/eth0
echo dst_mac  ff:ff:ff:ff:ff:ff > /proc/net/pktgen/eth0
echo start > /proc/net/pktgen/pgctrl

I can't saturate the link from user space with either UDP, TCP or RAW
socket due to copies and multiple system calls.

If the system is just doing one copy of the packet, it falls under
25Mbytes/s. This a simple memory bus which is only running at 100Mhz
for data and instruction.
I think I've well understood why my bitrate is so bad from userspace
using normal TCP,UDP or RAW socket.
That's why I'm working on this zero copy solution (without copy
between user and kernel or between kernel buffer and socket buffer;
and with a minimum of system call).
A kind of full zero-copy sending capability, HW accesses same buffers
as the user.
In fact, I'm just suggesting the symmetric of packet mmap IO used for
capture process with zero copy capability and I need to know what do
you think about it.

Thanks in advance,
Johann


On Wed, Sep 3, 2008 at 3:27 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi Johann.
>
> On Wed, Sep 03, 2008 at 03:05:07PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
>> TCP socket, transferring 20Mbytes file (located in initramfs) in loop
>> with sendfile() : 5.7Mbytes/s
>
> And _THIS_ is a serious problem. Let's assume that sendfile is broken or
> driver/hardware does not support scatter/gather and checksumming (does it?).
> Can you saturate the link with pktgen (1) and usual tcp socket (2).
> Assuming second case will fail, does it also broken because of very
> small performance of the copy from the userspace?
>
> --
>        Evgeniy Polyakov
>



-- 
Johann Baudy
johaahn@gmail.com
