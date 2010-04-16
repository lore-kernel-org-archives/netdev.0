From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 21:34:56 +0800
Message-ID: <k2h412e6f7f1004160634v88440075p6e4cb2404abdb006@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi>
	<20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi>
	<4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
	<n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	<1271395106.16881.3645.camel@edumazet-laptop> <1271424065.4606.31.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:50072 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757329Ab0DPNfQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:35:16 -0400
Received: by pwj9 with SMTP id 9so1925149pwj.19
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:35:16 -0700 (PDT)
In-Reply-To: <1271424065.4606.31.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 9:21 PM, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2010-04-16 at 07:18 +0200, Eric Dumazet wrote:
>
>>
>> A kernel module might do this, this could be integrated in perf benc=
h so
>> that we can regression tests upcoming kernels.
>
> Perf would be good - but even softnet_stat cleaner than the the nasty
> hack i use (attached) would be a good start; the ping with and withou=
t
> rps gives me a ballpark number.
>
> IPI is important to me because having tried it before it and failed
> miserably. I was thinking the improvement may be due to hardware used
> but i am having a hard time to get people to tell me what hardware th=
ey
> used! I am old school - I need data;-> The RFS patch commit seems to
> have more info but still vague, example:
> "The benefits of RFS are dependent on cache hierarchy, application
> load, and other factors"
> Also, what does a "simple" or "complex" benchmark mean?;->
> I think it is only fair to get this info, no?
>
> Please dont consider what i say above as being anti-RPS.
> 5 microsec extra latency is not bad if it can be amortized.
> Unfortunately, the best traffic i could generate was < 20Kpps of
> ping which still manages to get 1 IPI/packet on Nehalem. I am going
> to write up some app (lots of cycles available tommorow). I still thi=
nk
> it is valueable.
>

+	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %0=
8x\n",
 		   s->total, s->dropped, s->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   s->cpu_collision, s->received_rps);
+		   s->cpu_collision, s->received_rps, s->ipi_rps);

Do you mean that received_rps is equal to ipi_rps? received_rps is the
number of IPI used by RPS. And ipi_rps is the number of IPIs sent by
function generic_exec_single(). If there isn't other user of
generic_exec_single(), received_rps should be equal to ipi_rps.

@@ -158,7 +159,10 @@ void generic_exec_single(int cpu, struct
call_single_data *data, int wait)
 	 * equipped to do the right thing...
 	 */
 	if (ipi)
+{
 		arch_send_call_function_single_ipi(cpu);
+		__get_cpu_var(netdev_rx_stat).ipi_rps++;
+}


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
