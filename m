From: "David S. Miller" <davem@redhat.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 17:34:16 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc5in$hjg$2@main.gmane.org>
References: <3CE9960D.15D41380@mvista.com>
	<200205210041.EAA04407@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: george@mvista.com, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200205210041.EAA04407@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Tue, 21 May 2002 04:41:39 +0400 (MSD)

   +Two similar problems arise. An example code snippet:
   +
   +       struct this_needs_locking tux[NR_CPUS];
   +       tux[smp_processor_id()] = some_value;
   +       /* task is preempted here... */
   +       something = tux[smp_processor_id()];
   
   If you are not going to break all the kernel just make sure that
   tasks preempted in the kernel do not migrate. That's all, simple & stupid.
   
Such rule does not even make this piece of code legal.  Consider:

task1:cpu0:	x = counters[smp_processor_id()];
      cpu0:	PREEMPT
task2:cpu0:	x = counters[smp_processor_id()];
task2:cpu0:	counters[smp_processor_id()] = x + 1;
      cpu0:	PREEMPT
task1:cpu0:	counters[smp_processor_id()] = x + 1;
		full garbage

But it does bring up important point, preemption people need to
fully audit entire networking.

It is totally broken by preemption the more I think about it.

At the very beginning, all the SNMP counter bumping tricks will
totally fail with preemption enabled.
