From: raz ben yehuda <raziebe@gmail.com>
Subject: RFC: OFFLINE NAPI FIREWALL and Linux current implementation
Date: Fri, 21 Aug 2009 03:00:00 +0300
Message-ID: <1250812800.4836.19.camel@raz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: wiseman@macs.biu.ac.il
To: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	SELinux@tycho.nsa.gov
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755410AbZHTVAF@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello
OFFSCHED stands for the OFFLINE SCHEDULER. OFFLINE SCHEDULER is a technique to remove a processor from the operating 
system and assign it a dedicated assignment(s). In this case I assigned my dropped SMT processor to do NAPI and remove 
packets by an OFFSCHED firewall rule.
The firewall is offloaded and it is ***not part*** of the operating system. The firewall runs in an offlet
context (see Documentation). The motivation of the offlet firewall is to protect the operating system kernel from 
outsider attack, something your system may lack.


Configuration:

#1   Reference test. just generate traffic 
			                 ---------------------
			                |                     |
  ----------------------                | 	Linux 	      |
 | Traffic Generator    |  pkts------>  |        NAPI         |
  ------ ---------------                |---------------------|


#2  OFFSCHED test. 
			                 -----------------------
			                |    Linux Kernel       |
  ----------------------                |-----------------------|
 | Traffic Generator    |  pkts------>  |  Offlet NAPI firewall |
  ------ ---------------                |-----------------------|

Machine:  Receing host: Supermicro PDMSi, hyper-threading enabled.
	  Receiving interface: Intel 1Gbps 82546EB. e1000. 
	  Kernel: 2.6.30	 

I have used pktgen as the traffic generator. pktgen uses port 9 ( discard port ).
I assume that the packet processing consumes processor resources like any other packet that needs to be dropped by the Linux native firewall.
OFFSCHED firewall was set with a firewall rule that drops UDP packets of port 9.


#1 Reference test. Linux napi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tasks:  66 total,   1 running,  65 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 65.3%id,  0.0%wa,  5.0%hi, 29.7%si,  0.0%st
Mem:   1025452k total,   153536k used,   871916k free,     5084k buffers
Swap:        0k total,        0k used,        0k free,    75568k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
    1 root      20   0 10312  668  556 S    0  0.1   0:00.36 init
    2 root      15  -5     0    0    0 S    0  0.0   0:00.00 kthreadd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2 OFFLET FIREWALL. SMT CPU1 is dropped and running OFFSCHED.

Tasks:  58 total,   1 running,  57 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.4%us,  0.4%sy,  0.0%ni, 92.9%id,  0.0%wa,  6.3%hi,  0.0%si,  0.0%st
Mem:   1025452k total,   194256k used,   831196k free,    22528k buffers
Swap:        0k total,        0k used,        0k free,    92808k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
    1 root      20   0 10312  668  556 S  0.0  0.1   0:00.36 init
    2 root      15  -5     0    0    0 S  0.0  0.0   0:00.00 kthreadd

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Results
In #2 Hardware interrupts happen because I haven't disabled receiving interrupts entirely (though it is possible).
In the reference test CPU1 is consumed by 35%, while cpu0 is mostly idle. In OFFSCHED kernel CPU0 is 7% busy due 
to hardware interrupts. The Intel network Interface was loaded with 1Gbps of incoming traffic.

Analysis
In terms of pure processor consumption, 107/200 is the CPU usage in and "offlet kernel" while 35/200 is the processor 
consumption in a non OFFSCHED kernel. So, one may wonder, Aren't we wasting a processor ? 

Yes, we do. But what we do earn is an operating system running undisturbed. If i were to load
this machine with more traffic then the operating system at some point, will be too loaded to be even 
accessed. In OFFSCHED kernel this will not happen. This is because, a denied packet processing in confined to the 
offloaded processor. 
Also, I have implemented a minimal server in OFFSCHED. The reason for that is that you can access
an **attacked machine** through the offlet server and apply a firewall rule, something you may not be able to do in Linux
as it is now.

The OFFSCHED project can be found at:
http://sos-linux.svn.sourceforge.net/viewvc/sos-linux/offsched/

Thank you
Raz
