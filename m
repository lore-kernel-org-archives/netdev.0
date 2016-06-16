From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH 4/5] netdev: implement infrastructure for threadable napi irq
Date: Thu, 16 Jun 2016 09:55:27 -0700
Message-ID: <CANn89i+Fh8n=Vre=5h=UzJtoixF=ayxJU+RKW80GibFAG1f0yQ@mail.gmail.com>
References: <cover.1465996447.git.pabeni@redhat.com> <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
 <CANn89i+EJMHeMN8=e12hoT1Jv8cCBDXeexTBdsd9hU2G=HpGZA@mail.gmail.com>
 <1466008955.24431.35.camel@redhat.com> <CANn89iJKxctv5Yzn2ecBLAjh2RtGpjNC6M3dqKXieqaORZaGsw@mail.gmail.com>
 <1466073593.4691.47.camel@redhat.com> <CANn89iL2WpZAOLDWEoJmJ3Hiv3x59c45nCQpLm66j29D0HXfcw@mail.gmail.com>
 <1466078635.4691.56.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34074 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbcFPQz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 12:55:28 -0400
Received: by mail-yw0-f169.google.com with SMTP id c72so48265908ywb.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 09:55:28 -0700 (PDT)
In-Reply-To: <1466078635.4691.56.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I guess you means 'consumer' here. The scheduler doesn't fail to migrate
> it: the consumer is actually migrated a lot of times, but on each cpu a
> competing and running ksoftirqd thread is found.
>
> The general problem is that under significant network load (not
> necessary udp flood, similar behavior is observed even with TCP_RR
> tests), with enough rx queue available and enough flows running, no
> single thread/process can use 100% of any cpu, even if the overall
> capacity would allow it.
>

Looks like a general process scheduler issue ?

Really, allowing the RX processing to be migrated among cpus is
problematic for TCP,
as it will increase reorders.

RFS for example has a very specific logic to avoid these problems as
much as possible.

                /*
                 * If the desired CPU (where last recvmsg was done) is
                 * different from current CPU (one in the rx-queue flow
                 * table entry), switch if one of the following holds:
                 *   - Current CPU is unset (>= nr_cpu_ids).
                 *   - Current CPU is offline.
                 *   - The current CPU's queue tail has advanced beyond the
                 *     last packet that was enqueued using this table entry.
                 *     This guarantees that all previous packets for the flow
                 *     have been dequeued, thus preserving in order delivery.
                 */
                if (unlikely(tcpu != next_cpu) &&
                    (tcpu >= nr_cpu_ids || !cpu_online(tcpu) ||
                     ((int)(per_cpu(softnet_data, tcpu).input_queue_head -
                      rflow->last_qtail)) >= 0)) {
                        tcpu = next_cpu;
                        rflow = set_rps_cpu(dev, skb, rflow, next_cpu);
                }
