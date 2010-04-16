From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 22:10:28 +0800
Message-ID: <r2q412e6f7f1004160710j6d575f36t8e39a283328cf2d7@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi>
	<4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
	<n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	<1271395106.16881.3645.camel@edumazet-laptop> <1271424065.4606.31.camel@bigi>
	<k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
	<1271425753.4606.65.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:35520 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120Ab0DPOKs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 10:10:48 -0400
Received: by iwn35 with SMTP id 35so295747iwn.21
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 07:10:48 -0700 (PDT)
In-Reply-To: <1271425753.4606.65.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 9:49 PM, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2010-04-16 at 21:34 +0800, Changli Gao wrote:
>
>
> my observation is:
> s->total is the sum of all packets received by cpu (some directly fro=
m
> ethernet)

It is meaningless currently. If rps is enabled, it may be twice of the
number of the packets received, because one packet may be count twice:
one in enqueue_to_backlog(), and the other in __netif_receive_skb(). I
had posted a patch to solve this problem.

http://patchwork.ozlabs.org/patch/50217/

If you don't apply my patch, you'd better refer to /proc/net/dev for
the total number.

> s->received_rps was what the count receiver cpu saw incoming if they
> were sent by another cpu.

Maybe its name confused you.

/* Called from hardirq (IPI) context */
static void trigger_softirq(void *data)
{
        struct softnet_data *queue =3D data;
        __napi_schedule(&queue->backlog);
        __get_cpu_var(netdev_rx_stat).received_rps++;
}

the function above is called in IRQ of IPI. It counts the number of
IPIs received. It is actually ipi_rps you need.

> s-> ipi_rps is the times we tried to enq to remote cpu but found it t=
o
> be empty and had to send an IPI.
> ipi_rps can be < received_rps if we receive > 1 packet without
> generating an IPI. What did i miss?
>


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
