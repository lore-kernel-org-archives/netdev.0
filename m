From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 29 Nov 2004 15:21:58 +0100
Message-ID: <1101738118.14930.142.camel@verza.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <1101498963.1076.39.camel@jzny.localdomain>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mellia@prezzemolo.polito.it, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1101498963.1076.39.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-11-26 at 20:56, jamal wrote:
> On Fri, 2004-11-26 at 10:31, Marco Mellia wrote:
> > If you don't trust us, please, ignore this email.
> > Sorry.
> 
> Dont take it the wrong way please - nobody has been able to produce the
> results you have. So thats why you may be getting that comment.
> The fact you have been able to do this is a good thing.

No problem from this side. I also forgot a couple of 8-! I guess...

[...]

> prefetching as in the use of prefetch()?
> What were you prefetching if you end up dropping packet?
> 

Sorry I used the wrong terms there.
What we discovered, is that the CPU caching mechanisms as a HUGE impact.
And that you have very little control on it. Prefetching may help, but
it is difficult to tredict its impacts...

Indeed, if you access to the packet struct, the CPU has to fetch data
from the main memory, which stored the packet transfered using DMA from
the NIC. The penalty in the memory access is huge, and you have little
control on it.

In our experiments, we modified the kernel to drop packets just after
receiving them. skb are just deallocated (using standerd kernel
routines, i.e., no recycling is used). Logically, that happen when the
netif_rx() is called.

Now, we have three cases
1) just mofify the netif_rx() to drop packets.
2) as in one, plus remove the protocol check in the driver
(i.e., comment the line
      skb->protocol = eth_type_trans(skb, netdev);
) to avoid to access the real packet data.
3) as in 2, but dealloc is performed at the driver level, instead of
calling the netif_rx()

In the first case, we can receive about 1.1Mpps (~80% of packets)
In the second case, we can receive 100% of packets, as we removed the
penalty of looking at the packet headers to discover its protocol type.

In the third case, we can NOT receive 100% of packets!
The only difference is that we actually _REMOVED_ a funcion call. This
reduces the overhead, and the compiler/cpu/whatever can not optimize the
data path to access to the skb which must be freed.
Our guess is that by freeing up the skb in the netif_rx() function
actually allows the compiler/cpu to prefetch the skb itself, and
therefore keep the pipeline working...

My guess is that if you change compiler, cpu, memory subsystem, you may
get very counterintuitive results...

-- 
Ciao,                    /\/\/\rco

+-----------------------------------+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+-----------------------------------+
The box said "Requires Windows 95 or Better." So I installed Linux.
