From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 00:53:43 +0100
Message-ID: <874n780wzc.fsf@natisbad.org>
References: <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
	<87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
	<20131117141940.GA18569@1wt.eu>
	<1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<87li0kkhzx.fsf@natisbad.org>
	<1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119174323.GH913@1wt.eu>
	<1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119184121.GN913@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:53610 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199Ab3KSXyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 18:54:19 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 0D3F94C80A8
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 00:54:08 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Willy Tarreau <w@1wt.eu> writes:

> On Tue, Nov 19, 2013 at 10:31:50AM -0800, Eric Dumazet wrote:
>> On Tue, 2013-11-19 at 18:43 +0100, Willy Tarreau wrote:
>> 
>> > - #define MVNETA_TX_DONE_TIMER_PERIOD 10
>> > + #define MVNETA_TX_DONE_TIMER_PERIOD (1000/HZ)
>> > 
>> 
>> I suggested this in a prior mail :
>> 
>> #define MVNETA_TX_DONE_TIMER_PERIOD 1
>
> Ah sorry, I remember now.
>
>> But apparently it was triggering strange crashes...
>
> Ah, when a bug hides another one, it's the situation I prefer, because
> by working on one, you end up fixing two :-)

Follow me just for one sec: today, I got a USB 3.0 Gigabit Ethernet
adapter. More specifically an AX88179-based one (Logitec LAN-GTJU3H3),
about which there is currently a thread on netdev and linux-usb
lists. Anyway, I decided to give it a try on my RN102 just to check what
performance I could achieve. So I basically did the same experiment as
yesterday (wget on client against a 1GB file located on the filesystem
served by an apache on the NAS) except that time the AX88179-based
adapater was used instead of the mvneta-based interface. Well, the
download started at a high rate (90MB/s) but then drops and I get some
SATA error on the NAS (similar to the errors I already got during
12.0-rc series [1] to finally *erroneously* consider it was an artefact).

So I decided to remove the SATA controllers and disks from the equation:
I switched to my ReadyNAS 2120 whose GbE interfaces are also based on
mvneta driver and comes w/ 2GB of RAM. The main additional difference is
that the device is a dual core armada @1.2GHz, where the RN102 is a
single core armada @1.2GHz. I created a dummy 1GB file *in RAM*
(/run/shm) to have it served by the apache2 instead of the file
previously stored on the disks. 

I started w/ todays linus tree (dec8e46178b) with Eric's revert patch
for c9eeec26e32e (tcp: TSQ can use a dynamic limit) and also the change
to mvneta driver to have:

-#define MVNETA_TX_DONE_TIMER_PERIOD    10
+#define MVNETA_TX_DONE_TIMER_PERIOD    1

Here are the average speed given by wget for the following TCP send
window:

   4 MB:  19 MB/s
   2 MB:  21 MB/s
   1 MB:  21 MB/s
  512KB:  23 MB/s
  384KB: 105 MB/s
  256KB: 112 MB/s
  128KB: 111 MB/s
   64KB:  93 MB/s

Then, I decided to redo the exact same test w/o the change on
MVNETA_TX_DONE_TIMER_PERIOD (i.e. w/ the initial value of 10). I get the
exact same results as with the MVNETA_TX_DONE_TIMER_PERIOD set to 1, i.e:

   4 MB:  20 MB/s
   2 MB:  21 MB/s
   1 MB:  21 MB/s
  512KB:  22 MB/s
  384KB: 105 MB/s
  256KB: 112 MB/s
  128KB: 111 MB/s
   64KB:  93 MB/s

And, then, I also dropped Eric's revert patch for c9eeec26e32e (tcp: TSQ
can use a dynamic limit), just to verify we came back where the thread
started but i got a surprise:

   4 MB:  10 MB/s
   2 MB:  11 MB/s
   1 MB:  10 MB/s
  512KB:  12 MB/s
  384KB: 104 MB/s
  256KB: 112 MB/s
  128KB: 112 MB/s
   64KB:  93 MB/s

Instead of the 256KB/s I had observed the low value was now 10MB/s. I
thought it was due to the switch from RN102 to RN2120 so I came back
to the RN102 w/o any specific patch for mvneta nor your revert patch for 
c9eeec26e32e, i.e. only Linus tree as it is today (dec8e46178b). The
file is served from the disk:

   4 MB:   5 MB/s
   2 MB:   5 MB/s
   1 MB:   5 MB/s
  512KB:   5 MB/s
  384KB:  90 MB/s for 4s, then 3 MB/s
  256KB:  80 MB/s for 3s, then 2 MB/s
  128KB:  90 MB/s for 3s, then 3 MB/s
   64KB:  80 MB/s for 3s, then 3 MB/S

Then, I allocated a dummy 400MB file in RAM (/run/shm) and redid the
test on the RN102:

   4 MB:   8 MB/s
   2 MB:   8 MB/s
   1 MB:  92 MB/s
  512KB:  90 MB/s
  384KB:  90 MB/s
  256KB:  90 MB/s
  128KB:  90 MB/s
   64KB:  60 MB/s

In the end, here are the conclusions *I* draw from this test session,
do not hesitate to correct me:

 - Eric, it seems something changed in linus tree betwen the beginning
   of the thread and now, which somehow reduces the effect of the
   regression we were seen: I never got back the 256KB/s.
 - You revert patch still improves the perf a lot
 - It seems reducing MVNETA_TX_DONE_TIMER_PERIOD does not help
 - w/ your revert patch, I can confirm that mvneta driver is capable of
   doing line rate w/ proper tweak of TCP send window (256KB instead of
   4M)
 - It seems I will I have to spend some time on the SATA issues I
   previously thought were an artefact of not cleaning my tree during a
   debug session [1], i.e. there is IMHO an issue.

What I do not get is what can cause the perf to drop from 90MB/s to
3MB/s (w/ a 256KB send window) when streaming from the disk instead of
the RAM. I have no issue having dd read from the fs @ 150MB/s and
mvneta streaming from RAM @ 90MB/s but both together get me 3MB/s after
a few seconds.

Anyway, I think if the thread keeps going on improving mvneta, I'll do
all additional tests from RAM and will stop polluting netdev w/ possible
sata/disk/fs issues.

Cheers,

a+

[1]: http://thread.gmane.org/gmane.linux.ports.arm.kernel/271508
