From: Arthur Kepner <akepner@sgi.com>
Subject: NAPI and CPU utilization [was: NAPI, e100, and system performance
 problem]
Date: Tue, 19 Apr 2005 13:38:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504191210040.15052@linux.site>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
 <Pine.LNX.4.61.0504180943290.15052@linux.site> <1113855967.7436.39.camel@localhost.localdomain>
 <20050419055535.GA12211@sgi.com> <20050419113657.7290d26e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg Banks <gnb@sgi.com>, hadi@cyberus.ca, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050419113657.7290d26e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[Modified the subject line in order to not distract from 
Jesse's original thread.]

On Tue, 19 Apr 2005, David S. Miller wrote:

> On Tue, 19 Apr 2005 15:55:35 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > > How do you recognize when system resources are being poorly utilized?
> > 
> > An inordinate amount of CPU is being spent running around polling the
> > device instead of dealing with the packets in IP, TCP and NFS land.
> > By inordinate, we mean twice as much or more cpu% than a MIPS/Irix
> > box with slower CPUs.
> 
> You haven't answered the "how" yet.
> 
> What tools did you run, what did those tools attempt to measure, and
> what results did those tools output for you so that you could determine
> your conclusions with such certainty?
> 

I'm answering for myself, not Greg. 

Much of the data is essentially from "/proc/". (We use a nice tool 
called PCP to gather the data, but that's where PCP gets it, for the 
most part.) But I've used several other tools to gather corroborating 
data, including: the "kernprof" patch, "q-tools", an ad-hoc patch 
which used "get_cycles()" to time things which were happening while 
interrupts were disabled. 

The data acquired with all these show that NAPI causes relatively 
few packets to be processed per interrupt, so that expensive PIOs 
are relatively poorly amortized over a given amount of input from 
the network. (When I use "relative(ly)" above, I mean relative 
what we see when using Greg's interrupt coalescence patch from 
http://marc.theaimsgroup.com/?l=linux-netdev&m=107183822710263&w=2)

For example, following is a comparison of the number of packets 
processed per interrupt and CPU utilization using NAPI and Greg's 
interrupt coalescence patch. 

This data is pretty old by now, it was gathered using 2.6.5 on an 
Altix with 1GHz CPUs using the tg3 driver doing bulk data transfer 
using nttcp. (I'm eyeballing the data from a set of graphs, so 
it's rough...)


   Link util [%]  Packets/Interrupt     CPU utilization [%]

                  NAPI    Intr Coal.    NAPI      Intr Coal.
   ---------------------------------------------------------
    25             2          3.5       45           17
    40             4          6         52           30
    50             4          6         60           36
    60             4          7         75           41
    70             6          10        80           36
    80             6          16        90           40
    85             7          16        100          45
    100            -          17        -            50

I know more recent kernels have somewhat better performance, 
(http://marc.theaimsgroup.com/?l=linux-netdev&m=109848080827969&w=2
helped, for one thing.) 

The reason that CPU utilization is so high with NAPI is that 
we're spinning, waiting for PIOs to flush (this can take an 
impressively long time when the PCI bus/bridge is busy.) 

I guess that some of us (at SGI) have seen this so often as 
a bottleneck that we're surprised that it's not more generally 
recognized as a problem, er, uh, "opportunity for improvement".

--
Arthur
