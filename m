From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Sat, 21 Nov 2009 10:31:31 +0100
Message-ID: <4B07B373.1090801@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <4B079FDF.9040809@gmail.com> <65634d660911210103k2a55e324o8c07ca87eae16faa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34035 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbZKUJbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:31:35 -0500
In-Reply-To: <65634d660911210103k2a55e324o8c07ca87eae16faa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>        percpu_add(netdev_rx_stat.total, 1);
>>        spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
>>
> Would it make sense to percpu_add into dev.c just for this when other
> parts in dev.c would still use __get_cpu_var(stat)++?  Also, I think
> this results in more instructions...

Dont worry, this is out of RPS scope anyway, but percpu_add() is
better on x86 at least.

	__get_cpu_var(netdev_rx_stat).total++;
->
	mov    $0xc17aa6b8,%eax  // per_cpu__netdev_rx_stat
	mov    %fs:0xc17a77c0,%edx // per_cpu__this_cpu_off
	incl   (%edx,%eax,1)

While

	percpu_add(netdev_rx_stat.total, 1);
->
	addl   $0x1,%fs:0xc17aa6b8 // per_cpu__netdev_rx_stat


Later can be done in any context, and use no register, so :

1) we reduce window with disabled interrupts.
2) allow compiler to not scratch two registers.

