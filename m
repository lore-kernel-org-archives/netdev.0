From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 30 Nov 2004 08:46:04 -0500
Message-ID: <1101822364.1044.60.camel@jzny.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <1101498963.1076.39.camel@jzny.localdomain>
	 <1101738118.14930.142.camel@verza.polito.it>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
In-Reply-To: <1101738118.14930.142.camel@verza.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-11-29 at 09:21, Marco Mellia wrote:
> On Fri, 2004-11-26 at 20:56, jamal wrote:
> > On Fri, 2004-11-26 at 10:31, Marco Mellia wrote:
> > > If you don't trust us, please, ignore this email.
> > > Sorry.
> > 
> > Dont take it the wrong way please - nobody has been able to produce the
> > results you have. So thats why you may be getting that comment.
> > The fact you have been able to do this is a good thing.
> 
> No problem from this side. I also forgot a couple of 8-! I guess...
> 
> [...]
> 
> > prefetching as in the use of prefetch()?
> > What were you prefetching if you end up dropping packet?
> > 
> 

I read your paper on the weekend - theres one thing which i dont think
has been written on before on NAPI that you covered unfortunetly with no
melodrama ;-> This is the min-max fairness issue. If you actually mix
and match different speeds then it becomes a really interesting problem.
Example try congesting a 100Mbps with 2x1Gbps. What quotas to use etc.
Could this be done cleverly at runtime with dynamic adjustments etc.
Next time you want you want to slave students to do some work talk to us
- I got plenty of things you could try out and keep them busy forever;->

> Sorry I used the wrong terms there.
> What we discovered, is that the CPU caching mechanisms as a HUGE impact.
> And that you have very little control on it. Prefetching may help, but
> it is difficult to tredict its impacts...

Prefetching is hard. The only evidence i have seen of actually what
"appears" to be working prefetching is some code from David Morsberger
at HP. Other architectures are known to be more friendly - my eperiences
with MIPs are far more pleasant. BTW, thats another topic to get those
students to investigate ;->

> Indeed, if you access to the packet struct, the CPU has to fetch data
> from the main memory, which stored the packet transfered using DMA from
> the NIC. The penalty in the memory access is huge, and you have little
> control on it.
> 
> In our experiments, we modified the kernel to drop packets just after
> receiving them. skb are just deallocated (using standerd kernel
> routines, i.e., no recycling is used). Logically, that happen when the
> netif_rx() is called.
> 
> Now, we have three cases
> 1) just mofify the netif_rx() to drop packets.
> 2) as in one, plus remove the protocol check in the driver
> (i.e., comment the line
>       skb->protocol = eth_type_trans(skb, netdev);
> ) to avoid to access the real packet data.
> 3) as in 2, but dealloc is performed at the driver level, instead of
> calling the netif_rx()
> 
> In the first case, we can receive about 1.1Mpps (~80% of packets)

Possible. I was able to receive 900Kpps or so in my experiments with
gact drop which is slightly above this with a 2.4 Ghz machine with IRQ
affinity.

> In the second case, we can receive 100% of packets, as we removed the
> penalty of looking at the packet headers to discover its protocol type.
> 

This is the one people found hard to believe. I will go and retest this.
It is possible. 

> In the third case, we can NOT receive 100% of packets!
> The only difference is that we actually _REMOVED_ a funcion call. This
> reduces the overhead, and the compiler/cpu/whatever can not optimize the
> data path to access to the skb which must be freed.

It doesnt seem like you were runing NAPI if you depended on calling
netif_rx
In that case, #3 would be freeing in hard IRQ context while #2 is
softIRQ.

> Our guess is that by freeing up the skb in the netif_rx() function
> actually allows the compiler/cpu to prefetch the skb itself, and
> therefore keep the pipeline working...
> 
> My guess is that if you change compiler, cpu, memory subsystem, you may
> get very counterintuitive results...

Refer to my comment above.
Repeat tests with NAPI and see if you get same results.

cheers,
jamal
