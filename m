From: Luca Deri <deri@ntop.org>
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond	Device
 Polling
Date: Wed, 07 Apr 2004 08:59:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4073A6B8.8070803@ntop.org>
References: <20040330142354.GA17671@outblaze.com>	 <1081033332.2037.61.camel@jzny.localdomain> <c4rvvv$dbf$1@sea.gmane.org>	 <407286BB.8080107@draigBrady.com>  <4072A1CD.8070905@ntop.org> <1081262228.1046.25.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: P@draigBrady.com, Jason Lunz <lunz@falooley.org>, netdev@oss.sgi.com,
        cpw@lanl.gov, ntop-misc@fuji.unipi.it, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1081262228.1046.25.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,
from what I read below it seems that you read my first version of the 
paper/code. The current paper is available here 
http://luca.ntop.org/Ring.pdf and the code here 
http://sourceforge.net/project/showfiles.php?group_id=17233&package_id=110128 
(as I have said before I plan to have a new release soon).

Briefly:
- with the new release I don't have to patch the NIC driver anymore
- the principle is simple. At the beginning of netif_rx/netif_receive_sk 
I have added some code that does this: if there's an incoming packet for 
a device where a PF_RING socket was bound, the packet is processed by 
the socket and the functions return NET_RX_SUCCESS with no further 
processing.

This means that:
- Linux does not have to do anything else with the packet and it's ready 
to do something else
- the PF_RING is mapped to userland via mmap (like libpcap-mmap) but 
down the stack (for instance I'm below netfilter) so for each incoming 
packet there's no extra overhead like queuing into data structures, 
netfilter processing etc.

This work has been done to improve passive packet capture in order to 
speedup apps based on pcap like ntop, snort, ethereal...

jamal wrote:

>On Tue, 2004-04-06 at 08:25, Luca Deri wrote:
>  
>
>>Hi all,
>>the problem with libpcap-mmap is that:
>>- it does not reduce the journey of the packet from NIC to userland 
>>beside the last part of it (syscall replaced with mmap). This has a 
>>negative impact on the overall performance.
>>    
>>
>
>By how much does it add to the overall cost? I would say not by much if
>your other approach is also to cross user space.
>Can you post the userland program you used?
>Can you also capture profiles and post them?
>  
>
The code is available at the URL I have specified before.

>  
>
>>- it does not feature things like kernel packet sampling that pushes 
>>people to fetch all the packets out of a NIC then discard most of them 
>>(i.e. CPU cycles not very well spent). Somehow this is a limitation of 
>>pcap that does not feature a pcap_sample call.
>>    
>>
>
>Sampling can be done easily with tc extensions if you are willing to
>accept patches - 2.4.x only at the moment.
>Infact if all you want is to account and drop at the kernel,
>this would be the easiest way to do it (the kernel will gather stats for
>you which you can collect in user space).
>  
>

What I did is not for simply accounting. In fact as you pointed out 
accounting can be done with the kernel. What i did is for apps that need 
to access the raw packet and do something with it. Moreover, do not 
forget that at high speeds (or even at 100 Mbit under attack) the 
standard Linux kernel is not always able to receive all the traffic. 
This means that even using kernel apps like tc you will not account 
traffic properly

> 
>  
>
>>In addition if you do care about performance, I believe you're willing 
>>to turn off packet transmission and only do packet receive.
>>    
>>
>
>You are talking very speacilized machine here. If all you want is to 
>recieve and make sure the transmission never happens - consider looking
>at the patches i suggested.
>  
>
I probably missed your patches. Chan you please send them again?

>I still think you want to manage this device, so some packets should be
>transmitted.
>I have a small issue with your approach btw:
>Any solution which hacks things so that they run at the driver level
>would always get a good performance at the expense of flexibility.
>You might as well stop using Linux - what is the point? Write a bare
>bone OS constituting of said driver.
>  
>
I agree, that's why in release 2. I have decide not to hack the driver 
as this is not too smart.

>What we should do instead is improve Linux so it can be at the same
>level performance wise as your bare bone driver. I have never seen you
>post on this subject and then you show up with a a paper showing an
>ancient OS like BSD beating us at performance (or worse Win2k).
>
>  
>
>> 
>>Unfortunately I have no access to a "real" traffic generator (I use a PC 
>>as traffic generator). However if you read my paper you can see that 
>>with a Pentium IV 1.7 you can capture over 500'000 pkt/sec, so in your 
>>setup (Xeon + Spirent) you can have better figures.
>>    
>>
>
>Do you have a new version of the paper? In the version i have you
>only talk about 100Mbps rates.
>  
>

See above.

>  
>
>>IRQ: Linux has far too much latency, in particular at high speeds. I'm 
>>not the right person who can say "this is the way to go", however I 
>>believe that we need some sort of interrupt prioritization like RTIRQ does.
>>    
>>
>
>Is this still relevant with NAPI?
>  
>
Not really. I have written a simple kernel module with a dummy poll() 
implementation what returns immediately. Well under high system load the 
time it takes to process this poll call is much much greater (and 
totally unpredictable). You should read this:
http://home.t-online.de/home/Bernhard_Kuhn/rtirq/20040304/rtirq.html

>  
>
>>FYI, I've just polished the code and added kernel packet filtering to 
>>PF_RING. As soon as I have completed my tests I will release a new version.
>>
>>Finally It would be nice to have in the standard Linux core some packet 
>>capture improvements. It could either be based on my work or on somebody 
>>else's work. It doesn't really matter as long as Linux gets faster.
>>    
>>
>
>You should be involved since you have the energy. You also have to be
>willing to provide data when things dont work well - I am willing to
>help as i am sure many netdev people are if you are going to be positive
>in your approach. Provide results when needed and be willing to invest
>time and experiment.
>  
>

So tell me what to do in order to integrate my work into Linux and I'll 
do my best to serve the community.

>cheers,
>jamal
>
>  
>
Cheers, Luca

-- 
Luca Deri <deri@ntop.org>	http://luca.ntop.org/
Hacker: someone who loves to program and enjoys being
clever about it - Richard Stallman
