From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 02 Dec 2004 18:24:34 +0100
Message-ID: <1102008274.19646.14.camel@mellia.lipar.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <1101498963.1076.39.camel@jzny.localdomain>
	 <1101738118.14930.142.camel@verza.polito.it>
	 <1101822364.1044.60.camel@jzny.localdomain>
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
In-Reply-To: <1101822364.1044.60.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > In our experiments, we modified the kernel to drop packets just after
> > receiving them. skb are just deallocated (using standerd kernel
> > routines, i.e., no recycling is used). Logically, that happen when the
> > netif_rx() is called.
> > 
> > Now, we have three cases
> > 1) just mofify the netif_rx() to drop packets.
> > 2) as in one, plus remove the protocol check in the driver
> > (i.e., comment the line
> >       skb->protocol = eth_type_trans(skb, netdev);
> > ) to avoid to access the real packet data.
> > 3) as in 2, but dealloc is performed at the driver level, instead of
> > calling the netif_rx()
> > 
> > In the first case, we can receive about 1.1Mpps (~80% of packets)
> 
> Possible. I was able to receive 900Kpps or so in my experiments with
> gact drop which is slightly above this with a 2.4 Ghz machine with IRQ
> affinity.

I double checked with the people that actually did the job. They indeed
tested both cases, i.e., dropping packets either using IRQ (therefore
using netif_rx()) or using NAPI (therefore using netif_receive_skb()).

In both cases, disabling the eth_type_trans() check, we receive 100% of
packets...

> > In the third case, we can NOT receive 100% of packets!
> > The only difference is that we actually _REMOVED_ a funcion call. This
> > reduces the overhead, and the compiler/cpu/whatever can not optimize the
> > data path to access to the skb which must be freed.
> 
> It doesnt seem like you were runing NAPI if you depended on calling
> netif_rx
> In that case, #3 would be freeing in hard IRQ context while #2 is
> softIRQ.

Again, it was my mistake. Case #3 was performed using the NAPI stack,
i.e., freeing up skb instead of calling the netif_receive_skb().
Doing that, we observed a performance drop, that we hint to some caching
isses. Indeed, investigating with a Oprofile, in case #3 it registers
about twice the number of cache miss than in case #2.
Again, we do not have any plain explanation, but our intuition is that
adding a function call with  pointer as argument might allow the
compiler/cpu to prefecth the skb and speed up the memory release...


> > Our guess is that by freeing up the skb in the netif_rx() function
> > actually allows the compiler/cpu to prefetch the skb itself, and
> > therefore keep the pipeline working...
> > 
> > My guess is that if you change compiler, cpu, memory subsystem, you may
> > get very counterintuitive results...
> 
> Refer to my comment above.
> Repeat tests with NAPI and see if you get same results.

We were using NAPI. Sorry for the misunderstanding.
Hope this helps.



-- 
Ciao,                    /\/\/\rco

+--+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+--+
The box said "Requires Windows 95 or Better." So I installed Linux.
