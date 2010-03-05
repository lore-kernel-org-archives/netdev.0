From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: KS8695: possible NAPI issue
Date: Fri, 5 Mar 2010 08:22:18 -0800
Message-ID: <20100305082218.4f734857@nehalam>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	<4B8D1C02.1010204@softplc.com>
	<c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	<f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	<c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	<f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	<1267798077.2576.17.camel@myhost>
	<f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Figo.zhang" <figo1802@gmail.com>,
	Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51826 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995Ab0CEQW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 11:22:29 -0500
In-Reply-To: <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Mar 2010 16:00:11 +0100
Yegor Yefremov <yegorslists@googlemail.com> wrote:

> >> My tests look like following:
> >>
> >> 1. system start
> >> 2. ping one host: O.K.
> >> 3. nc -l -p 5000 > /var/test (about 1Mb): O.K.
> >> 4. ping the same host: failed
> > 1. type "arp" command, see the arp is exit or expire?
> 
> debian:~# nc -l -p 5000 > /var/zImage
> 
> debian:~# ping -c 1 192.168.1.38
> 
> PING 192.168.1.38 (192.168.1.38) 56(84) bytes of data.
> 
> From 192.168.1.66 icmp_seq=1 Destination Host Unreachable
> 
> 
> 
> --- 192.168.1.38 ping statistics ---
> 
> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
> 
> 
> 
> debian:~# arp
> 
> Address                  HWtype  HWaddress           Flags Mask            Iface
> 192.168.1.38          (incomplete)                              eth0
> 
> 192.168.1.36             ether   00:10:18:39:19:aa   C                     eth0
> 
> 
> > 2. at this point, see is it still have RX interrpt and receive packet in
> > ks8695_rx()? (in some watchpoint add printk).
> 
> I've inserted some printks and I can see that interrupts are coming
> and the received count will be increased. I can also see my system
> sending arp requests. Even this ping request is visible in wireshark
> and its reply, but the ping utility sees nothing of it.


One of the requirements for NAPI to work is that the IRQ is level triggered.
Otherwise there can be a race between packet arrival and the end of
NAPI processing:

static int ks8695_poll(struct napi_struct *napi, int budget)
{
	struct ks8695_priv *ksp = container_of(napi, struct ks8695_priv, napi);
	unsigned long  work_done;

	unsigned long isr = readl(KS8695_IRQ_VA + KS8695_INTEN);
	unsigned long mask_bit = 1 << ks8695_get_rx_enable_bit(ksp);

	work_done = ks8695_rx(ksp, budget);

	if (work_done < budget) {
		unsigned long flags;
		spin_lock_irqsave(&ksp->rx_lock, flags);
>>> packet arrives >>
		/*enable rx interrupt*/
		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
>>> or here >>
		__napi_complete(napi);
		spin_unlock_irqrestore(&ksp->rx_lock, flags);

If the hardware can't be reprogrammed to level mode;
the solution used in some drivers is to poll for lost packet after re-enabling
NAPI.



-- 
