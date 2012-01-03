From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: APIC seems not working under high network load
Date: Tue, 03 Jan 2012 21:30:28 +0100
Message-ID: <1325622628.2611.8.camel@edumazet-laptop>
References: <CAA8E7hFwvhATa+LAsW4csnUh1gL-tFZVQMO7LN0iQBa6NFj3KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jia Rao <rickenrao@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA8E7hFwvhATa+LAsW4csnUh1gL-tFZVQMO7LN0iQBa6NFj3KQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 03 janvier 2012 =C3=A0 14:28 -0500, Jia Rao a =C3=A9crit :
> Hi all,
>=20
> I had scalability issues when running memcached-like workloads in a
> Intel 8-core system. It turned out that under high network load only
> one core handled the interrupts from NIC. In the output of mpstat, on=
e
> of the core was overloaded with 100% %soft time. I tried to echo
> different core ids to /proc/irq/irq#/smp_affinity, it did not take
> effect until I stopped the incoming network traffic. It seems that
> APIC is not distributing interrupts to different cores.
>=20
> The below are the details of the testing system:
> OS: Linux 3.1.4 X86_64
> CPU: Intel L5450, quad-core
> NIC: Intel e1000e

If network load is high enough, cpu handling network IRQ stay in softir=
q
mode (NAPI) and never re-arms interrupt, so no other cpu can handle the
load.

This is why its better to change /proc/irq/irq#/smp_affinity _before_
load starts.

With your kernel, one way to help this cpu exit from softirq is using
RPS (Receive Packet Steering), since packets will be spreaded on severa=
l
cpus. Then, later hardware IRQ might be spreaded on other cpus as well.

for n in `seq 0 7`
do
 echo ff >/sys/class/net/eth0/queues/rx-$n/rps_cpus
done

[ If your eth0 has 8 queues ]
