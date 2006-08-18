From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: skge crashes
Date: Fri, 18 Aug 2006 10:56:01 +0200
Message-ID: <664E3671B2B6DC439E0C9FFCF8E40CA205F50B@exchange.I-BNEX>
References: <20060816203903.3a7b1d32@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Krzysztof Oledzki" <olel@ans.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:35043 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1751292AbWHRI40 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 04:56:26 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060816203903.3a7b1d32@localhost.localdomain>
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> possible PCI posting bug?
> 
> --- linux-2.6.orig/drivers/net/skge.c
> +++ linux-2.6/drivers/net/skge.c
> @@ -2745,7 +2745,7 @@ static int skge_poll(struct net_device *
>  	spin_lock_irq(&hw->hw_lock);
>  	hw->intr_mask |= rxirqmask[skge->port];
>    	skge_write32(hw, B0_IMSK, hw->intr_mask);
> -	mmiowb();
> +	skge_read32(hw, B0_IMSK);
>  	spin_unlock_irq(&hw->hw_lock);
>  
>  	return 0;
> @@ -2879,6 +2879,7 @@ static void skge_extirq(void *arg)
>  	spin_lock_irq(&hw->hw_lock);
>  	hw->intr_mask |= IS_EXT_REG;
>  	skge_write32(hw, B0_IMSK, hw->intr_mask);
> +	skge_read32(hw, B0_IMSK);
>  	spin_unlock_irq(&hw->hw_lock);
>  }
>  
> @@ -2953,6 +2954,7 @@ static irqreturn_t skge_intr(int irq, vo
>  		skge_error_irq(hw);
>  
>  	skge_write32(hw, B0_IMSK, hw->intr_mask);
> +	skge_read32(hw, B0_IMSK);
>  	spin_unlock(&hw->hw_lock);
>  
>  	return IRQ_HANDLED;


Unfortunately the patch doesn't fix the problem.
After some RX the transfer stalls, TCP gets corrupted and the log shows:

Aug 17 17:54:51 kernen kernel: ACPI: PCI Interrupt 0000:00:0b.0[A] ->
GSI 16 (level, low) -> IRQ 19
Aug 17 17:54:51 kernen kernel: skge 1.6 addr 0xfa000000 irq 19 chip
Yukon rev 1
Aug 17 17:54:51 kernen kernel: skge eth0: addr 00:13:46:7b:b6:52
Aug 17 17:54:51 kernen kernel: skge eth0: enabling interface
Aug 17 17:54:51 kernen kernel: skge eth0: Link is up at 1000 Mbps, full
duplex, flow control tx and rx
Aug 17 17:56:02 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:04 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:04 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:06 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:07 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:08 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:08 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:10 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:11 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:13 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:15 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:16 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:16 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:17 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:17 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: (fet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: <6(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg(flags & (M(flags & (MSG_PEEK |
MSet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC)))et(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:17 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:17 kernen kernel: KER(flags & et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: rec(fla(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:17 kernen kernel: KERNEL: assert(flags & (MSG_PEEK |
MSG_TRUNC)))(flags(flagset/ipv4/tcp.c (1236(flags & (MSG_PEEK |
MSG_TRUNC))) f(flags & (MSG_PEEK | MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC)))
failed (fla(flags & (MSG_PEEK |et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg(flags & (MSG(flags & (MSG_PEEK
|e(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg bug: copied 26EF7(flags &
(MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/(flags &
(MSG_PEEK | MSG_Tet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg (fe(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (flags & (MSG_PEet/ipv4/tcp.c
(1(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags
& (MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvmsg(flags (flags &
(MSG_PEEet/ipv4/(flags & (MSG_PEEK | MSG_TRUNC)))et(flags & (MSG_PEEK |
MSG_TRUNet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvms(flet(flet/ipv4/tcp.c (1(flags &
((flaget/ipv4/t(flags & (MSG_PEEK et/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recvm(flags & (MSG(flags & (MSG_PEEK |
(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recv(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:17 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c(flaet(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(fla(flags & (MSG_PEEK |
MSG_TRUNCet/ipv(flags & (MSG_PEEK | MSet/(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: <(flet/ipv4(flagset/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: re(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | Met/ipv4/t(flags & (MSGet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flae(flags & (Met/ipv4/tcp.c
(1(flags & (MSG_PEEK | MSG_TRUNC))) failed aet/ipv4/tcp.c (1236)(flags &
(MSG(fla(flags & (MSG_PEEK | Met/(flags & (MSG_PEEK | MSG_T(flags
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: <6(flags & (MSG_PEEK | MSG_TRUNC))(flags
& (MSG_Pet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF7(fla(flags &
(MSG_PEEK | MSG(fla(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copie(fl((flags & (MSG_PEEK
| MSGet/i(flags &(fla(flags & (MSG_PEEK | Met/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC)))(flet/ipv4/tcp.c ((flagset/ipv4(flags &
(MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))e(flags & (MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC(flags & (MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: assert(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: assert(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) fail(flags & (MSG_PEEK | MSG_TRUet(flags &
(MSG_PEEK | MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(et(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1(fla(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c ((flags & (MSG_PEEK |
MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at (flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: co(flags & (MSG_PEEK |
MSG_TRUNC))) (flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: re(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(fla(flaet/ipv4/tcp.c ((flags &
et(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(flags & (MSG_PEEK | MSG_TRUNC)))
faiet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26(flags
& (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(fla(flags & (MSG_PEEK | MSG_TRU(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK |
MSG_TRUNC))(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1(flags &(flagset/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: assert(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(f(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c ((flags & (MSG_PEEK | MSG_TRUNC)))
fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flags & (MSG_PEEK | MSG_TRUNC)))(flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(123(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC)))e(flags & (MSG_PEEK | MSG_TRUNC)(flet/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(et(flags & (MSG_PEEK | MSG_TRUN(flags & (MSG_PEEK | MS(flags &
(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(fle(flags & (MSG_PEEK |
MSG_TRUNC(flags & (MSG_PEEK | MSG_TRUNC)et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &(flags
& (MSG_PEEK | MSG_et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC)(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | Met/ipv4/tc(flags & (MSG_PEE(flags & (MSG_PEE(flags &
(MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: asse(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(flags et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF(flags &
(MSG_PEEK | MSG_TRUNC))) f(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: asse(flags & (MSG_PEEK |
MSG_TRUNC))(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(flags & (MSG_PEEK |
MSG_TRUNC))(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
(fl(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26(flags
& (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (flags & (MSG_PEEK |
MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC)))(flags & (MSG_PEEK |
MSG_TRUNC)et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
failed (flags & (MSG_PEEK | MSG_TR(fla(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: as(flags & (MSG_PEEK |
MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: re(fla(flags & (MSG_PEEK |
MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNet/(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv(flags &
(MSG_PEEK | MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (123(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC))) failed at et/ipv4/tcp.c
(1236)(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flaet/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (123(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (12(flags & (MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(fla(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: as(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (12(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
(flags & (MSG_PEEK | MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (fla(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26E(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flags & (MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MS(flags & (M(flags & et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC))(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (123(flags & (MSG_PE(flags & (MSG_PEEK |
MSG_TRUNC)et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC)))(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied
26EF75(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC)))e(fla(flags & (MSG_PEEK |
MSG_T(flags & (MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
faet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26E(fl(flags & (MSG_PEEK | MSG_TRUNC)et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) (flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (12(flags & (MSG_PEEK
| MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied
26EF75C(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)(flags & (MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC)))(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.(flags & (MSG_PEEK (flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75(flags &
(MSG_PEEK | MSG_TRUNC(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: <6(fla(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied
26EF75C(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KE(f(flags & (MSG_PEEK | MSG_TRUNC)))
failed a(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSGet/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC))(fl(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: <6(fla(flags & (MSG_PEEK |
MSG_et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC)))et(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(flags & (MSG_PEEK | MSG_TRUNC))(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (12(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_Tet/ipv(flags & (MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK |
MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_T(flags(flags & (MSG_PEEK | MSG_TRet/ip(flags &
(MSG_PEEK | MSG_(flags (flags (flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied (flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c(flags & (MSG_Pet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug(flags & (MSG_PEet/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF(flags &
(MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_T(flags
& (MSG_PEEK | MSG_TRUNC))) fail(flags et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(flags & ((flags & (MSG_PEEK |
MSet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: <(flags & (MSG_PEEK | MSG_TRUNC))) failed
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: r(flags &et(flags & (MSG_PE(flags &
(MSG_(flags & (MSG_PEEK | MSG_TRUNC)(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (12(flags & (MSG_PEEet/ipv4/tcp.c (1236)(flags
& (MSG_PEEK | MSG_TRUNC))) failed aet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flagset/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: re(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: asse(flags & (MSG_PEEK |
MSG_TRUNC))) (flags & (MSG_PEEK | MSG_TRUNC(flags & (MSG_PEEK |
MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(fla(flags & (MSG_PEEK |
MSG_TRUet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF761(flags & (MSG_PEEK | MSet/ipv4/t(flags & (MSG_PEEK |
MSGet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: cop(flags & (MSG_PEEK |
MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (flags eet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: assert(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK |
MSG_TRUNC))(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | et/ipv4/tcp.c
(1(flags & (MSG_PEEK | MSG_TRet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
faile(fl(flags & (MSG_PEEK | M(flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bu(fla(flags & (MSG_PEEK |
MSG_Tet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) (flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF(flags &
(MSG_PEet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (12(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) fa(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg b(fl(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fla(flaet/ipv4/tcp(flags &
(MSG_PEEet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: re(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC)et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms((flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) failet/ipv4/tcp.c (12(flags &
(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
fai(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tc(flags &
(MSG_PEEKet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
(flags & ((flags & (MSG_PEEK | MSG_et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: et/ipv(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flag(flags & (MSG_PEEK | MSG_TRU(flags &
(MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
fai(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (flags &
(MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: (flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (12(flags & (MSG_PEEK | MSG_TRUNC))) failed at
ne(f(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg b(flags & (MSG_PEEK(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26E(flags & (MSG_PEEK
| MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) et(flags & (MSG_PEEK | MSG_TRUNe(flags &
(MSG_PEEK | MSG_TRUNC((flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec((flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (123(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg b(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1(flags & (MSG_PEEK |
MSG_TRUNC))) f(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF(flags &
(MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK | MSG_TR(flags
&et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(fla(flags & (MSG_PEEK | MSG_TRU(flags
& (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvms(fla(flaget/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: <6(fla(flags & (MSG_PEEK |
MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (fl(fl((flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied (flaet/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flag(flags & (MSG_PEEK |
MSG_TRUet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg((flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK |et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tc((fl(flags & (MSG_PEEK | MSG_Tet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK |
MSG_TRUNC)((flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:18 kernen kernel: KERNEL: asse(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copie(flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags &
(MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK | MSG_TRUNC))) failed
at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(fla(flags &
(MSG_PEEK | MSG_TRUNCet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK | MSG_TRUNC))et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg (flags & (MSG_PEEK |
MSG_TRUNC))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK | MSG_TRUNC)))
f(f(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26(flags & (MSG_PEEK
| MSG_TRUNC))) failed at net/ipv4/tcp.c (1236(flags & (MSG_PEEK |
MSG_TRUNC))) et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK | MSG_TRUNC)))
et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF7(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C(flags &
(MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))) et/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC)))et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied 26EF75C1 seq
26EF76(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MSG_PEEK | MSG_TRUNC))) failed at net/ipv4/tcp.c
(1236)
Aug 17 17:56:18 kernen kernel: recvmsg bug: copied
26EF75(flaet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(flags & (MSG_PEEK |
MSG_TRUNC)))(flags & (MS(et/ipv4/tcp.c (123(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(f(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv(f(flags & (MSG_PEEK |
MSG_TRUNC(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))((flags & (MSG_PEEK |
MSG_TRUNC)(f(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recv((f(flags & (MSG_PEEK |
MSG_TRUN(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))((flags & (MSG_PEEK | MSG_TRUNC)((f(flags & (MSG_PEEK |
MSG_TRUN(flags & (MSG_PEEK | MSG_TRUNC))(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))((fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(f(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))((flags & (MSG_PEEK | MSG_TRUNC)(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))((flags & (MSG_PEEK |
MSG_TRUNC)(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))((flags & (MSG_PEEK | MSG_TRUNC)(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_P(((flags & (MSG_P((flags & (MSG_PEEK |
MSG_TRUNC)(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flags & (MSG_PEEK |
MSG_TRUNC))((flags &(flags & (fet/ipv4/tcp.(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))(flag(flags & (MSG_PEEK |
MSG_TR(flags & (MSG_PEE(flags & (MSG_P(flags & (MSG_PEEK |
MSG_TRUNC))(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: rec(((e(((et/ipv4/tc(et/ipv4/tcp.c
(123(((et/ipv4/tcp.c (123((et/ipv4/t((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(((flags & (MS(et/ipv4/tcp.c
(12((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))((f(et/ipv4/tcp(et/ipv4/tcp.c
(1(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp(flags & (MSG_PEEK
|(fet/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))(flags & (MSG_PEEK | MSG_TRUNC))((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(flags & (MSG_PEEK |
MSG_TRUNC))((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((flags & (MSG_PEEK |
MSG_TRUNC(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(flags & (MSG_PEEK |
MSG_TRUNC))((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvms(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg((((flags & (MSG_PEEK |
MSG_TRUNC))) failed at net/ipv4/tcp.c (1(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvmsg(((et/ipv4/tcp.c (1236)
Aug 17 17:56:18 kernen kernel: recvm(et/ipv4/tcp.c (1236)
Aug 17 17:56:19 kernen kernel: recvmsg((flags & (MSG_PEEK |
MSG_TRUNC)((et/i(flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:19 kernen kernel: recvmsg bug: copied 26EF75C1 seq 26EF7619
Aug 17 17:56:19 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:36 kernen kernel: Attempt to release TCP socket in state 1
da683a40
Aug 17 17:56:45 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:45 kernen kernel: KERNEL: assertion (tp->copied_seq ==
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at
net/ipv4/tcp.c (1236)
Aug 17 17:56:50 kernen kernel: Attempt to release TCP socket in state 4
da683a40
