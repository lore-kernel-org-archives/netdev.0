From: jamal <hadi@cyberus.ca>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture:
	Beyond	Device Polling
Date: 07 Apr 2004 08:20:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081340407.15893.114.camel@jzny.localdomain>
References: <20040330142354.GA17671@outblaze.com>
	 <1081033332.2037.61.camel@jzny.localdomain> <c4rvvv$dbf$1@sea.gmane.org>
	 <407286BB.8080107@draigBrady.com>  <4072A1CD.8070905@ntop.org>
	 <1081262228.1046.25.camel@jzny.localdomain>  <4073A6B8.8070803@ntop.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, Jason Lunz <lunz@falooley.org>, netdev@oss.sgi.com,
        cpw@lanl.gov, ntop-misc@fuji.unipi.it, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Luca Deri <deri@ntop.org>
In-Reply-To: <4073A6B8.8070803@ntop.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-04-07 at 02:59, Luca Deri wrote:
> Hi Jamal,
> from what I read below it seems that you read my first version of the 
> paper/code. The current paper is available here 
> http://luca.ntop.org/Ring.pdf and the code here 
> http://sourceforge.net/project/showfiles.php?group_id=17233&package_id=110128
> (as I have said before I plan to have a new release soon).

Thanks. I will take a look at the above. The paper i looked at was
posted on netdev by someone else.

> Briefly:
> - with the new release I don't have to patch the NIC driver anymore
> - the principle is simple. At the beginning of netif_rx/netif_receive_sk 
> I have added some code that does this: if there's an incoming packet for 
> a device where a PF_RING socket was bound, the packet is processed by 
> the socket and the functions return NET_RX_SUCCESS with no further 
> processing.

I think theres a good connection with what i am working on since the
patches i have are at the same level. On my TODO list was  "fast packet
diverting to userspace" - but this meant either stealing or sharing
unlike your case where it is always stealing the packet. My intention
was to just mmaped PF_PACKET at the level you are refering to. So maybe
i could use your work instead if its clean. 
I will send you the patches privately.

> This means that:
> - Linux does not have to do anything else with the packet and it's ready 
> to do something else

This should be policy driven. In some cases you may want that packet
to be shared/copied (i.e this is a more generic solution).
i.e you add a policy which says to divert all packets from
10.0.0.1 arriving on eth0 to user space with a tag x.
User space binds to tag x or * to receive all. Filtering out at that
low level provides early discard opportunities.
Of course what above means is you may need to have several rings
even within a device.
There is also nothing that should stop packet capture to happen at the
egress side (what you refered to as transmit).

> - the PF_RING is mapped to userland via mmap (like libpcap-mmap) but 
> down the stack (for instance I'm below netfilter) so for each incoming 
> packet there's no extra overhead like queuing into data structures, 
> netfilter processing etc.

Netfilter is definetely not something to be proud of perfomance wise but
i think you may be overstating the impact of the other pieces.

> This work has been done to improve passive packet capture in order to 
> speedup apps based on pcap like ntop, snort, ethereal...

Again note that we want to get as close as possible to performance you
get from speacilized work while still maintaining Linux as a general OS.
For example creating a new socket family like you have MUST have a good
reason; could you not have reused PF_PACKET?[1]


> jamal wrote:
> 
> >On Tue, 2004-04-06 at 08:25, Luca Deri wrote:
> >  
> >

> >By how much does it add to the overall cost? I would say not by much if
> >your other approach is also to cross user space.
> >Can you post the userland program you used?
> >Can you also capture profiles and post them?
> >  
> >
> The code is available at the URL I have specified before.

But i asked for your profiles since you did the work ;->
Dont expect me to get very enthusiastic and collect profiles for you.
For example, i didnt know why you couldnot get packet mmap to work.
I certainly could do about 200Kpps with it on what i remember to be an
average machine. 

> 
> What I did is not for simply accounting. In fact as you pointed out 
> accounting can be done with the kernel. What i did is for apps that need 
> to access the raw packet and do something with it. Moreover, do not 
> forget that at high speeds (or even at 100 Mbit under attack) the 
> standard Linux kernel is not always able to receive all the traffic. 
> This means that even using kernel apps like tc you will not account 
> traffic properly

I think s/ware not receiving all packets will always be an issue
regardless - actually i should say even well designed NICs will have
problems. So whatever sampling methodology you use should factor that in
to account for properly. 


> >  
> >
> >>IRQ: Linux has far too much latency, in particular at high speeds. I'm 
> >>not the right person who can say "this is the way to go", however I 
> >>believe that we need some sort of interrupt prioritization like RTIRQ does.
> >>    
> >>
> >
> >Is this still relevant with NAPI?
> >  
> >
> Not really. I have written a simple kernel module with a dummy poll() 
> implementation what returns immediately. Well under high system load the 
> time it takes to process this poll call is much much greater (and 
> totally unpredictable). You should read this:
> http://home.t-online.de/home/Bernhard_Kuhn/rtirq/20040304/rtirq.html
> 

This maybe related to what Robert and co. are chasing; How did 2.4.x
treat you?
 
I did a quick glance at the above work and i am curious how they address
shared interupts. Lets say you have a PC with a soundcard and videocard
sharing an IRQ and the video card is considered high prio - how do you
control priorities then?
  

> 
> So tell me what to do in order to integrate my work into Linux and I'll 
> do my best to serve the community.

For one, provide results when people ask. I asked you for profiles above
and you point me to the code ;-> You should do the work ;->

cheers,
jamal

[1]A good reason not to use PF_PACKET maybe because it would have
required too many changes and may break backward compatibility. But
these are the kind of things you need to show. I would also suggest you
look at other work like relayfs which i have not heard time to look at
myself.
