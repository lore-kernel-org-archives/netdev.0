From: figo zhang <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Mon, 8 Mar 2010 17:04:09 +0800
Message-ID: <c6ed1ac51003080104l4d67d72aybd3909ac12b54e3b@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	 <1267798077.2576.17.camel@myhost>
	 <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f202.google.com ([209.85.223.202]:33798 "EHLO
	mail-iw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676Ab0CHJEK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 04:04:10 -0500
Received: by iwn40 with SMTP id 40so804944iwn.1
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 01:04:09 -0800 (PST)
In-Reply-To: <f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/3/5 Yegor Yefremov <yegorslists@googlemail.com>:
>>> My tests look like following:
>>>
>>> 1. system start
>>> 2. ping one host: O.K.
>>> 3. nc -l -p 5000 > /var/test (about 1Mb): O.K.
>>> 4. ping the same host: failed
>> 1. type "arp" command, see the arp is exit or expire?
>
> debian:~# nc -l -p 5000 > /var/zImage
>
> debian:~# ping -c 1 192.168.1.38
>
> PING 192.168.1.38 (192.168.1.38) 56(84) bytes of data.
>
> From 192.168.1.66 icmp_seq=3D1 Destination Host Unreachable
>
>
>
> --- 192.168.1.38 ping statistics ---
>
> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, time =
0ms
>
>
>
> debian:~# arp
>
> Address =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0HWtype =A0HWaddress =A0 =A0=
 =A0 =A0 =A0 Flags Mask =A0 =A0 =A0 =A0 =A0 =A0Iface
> 192.168.1.38 =A0 =A0 =A0 =A0 =A0(incomplete) =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0eth0
>
> 192.168.1.36 =A0 =A0 =A0 =A0 =A0 =A0 ether =A0 00:10:18:39:19:aa =A0 =
C =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 eth0
>
>
>> 2. at this point, see is it still have RX interrpt and receive packe=
t in
>> ks8695_rx()? (in some watchpoint add printk).
>
> I've inserted some printks and I can see that interrupts are coming
> and the received count will be increased. I can also see my system
> sending arp requests. Even this ping request is visible in wireshark
> and its reply, but the ping utility sees nothing of it.
>

when you netcat finished, it cannot ping, right? at this point, would
you like to add some printk at RX and TX?
i want to see the target board have send arp packet, or have receive
arp reply packet.

you can add such funtion to print the packet buffer:

void print_mem(unsigned char *p,u32 len, u8 * s)
{
	u32 i;
	printk("  %s   ram addr =3D %x , data len =3D %x",s, p, len);

	for (i=3D0;i<len;i++) {
		if (0=3D=3Di%16) {
			printk("\n  0x%02x : ",(p+i));
		}
		printk("%02x",*(u8 *)(p+i));
		printk(" ");
	}
	printk("\n\n");
}

for TX: ks8695_start_xmit(struct sk_buff *skb, struct net_device *ndev)

=3D>
    	ksp->tx_ring[buff_n].status =3D
		cpu_to_le32(TDES_IC | TDES_FS | TDES_LS |
			    (skb->len & TDES_TBS));

	print_mem(skb->data, skb->len, "tx");

	wmb();

for RX: static int ks8695_rx(struct ks8695_priv *ksp, int budget)
=3D>
  			/* Retrieve the sk_buff */
			skb =3D ksp->rx_buffers[buff_n].skb;

			print_mem(skb->data, skb->len, "rx");

			/* Clear it from the ring */
			ksp->rx_buffers[buff_n].skb =3D NULL;
