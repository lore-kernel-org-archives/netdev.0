From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 03 Feb 2005 12:47:14 -0800
Message-ID: <42028DD2.2010809@hp.com>
References: <4201A382.1020208@rapidforum.com>	<20050202205437.571a702b@localhost.localdomain>	<4201B4EA.2030101@rapidforum.com>	<20050203113335.46396c11@dxpl.pdx.osdl.net>	<42028278.7040008@rapidforum.com>	<20050203121503.4f122779@dxpl.pdx.osdl.net> <42028747.6060602@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <42028747.6060602@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid wrote:
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> 
> What exactly is tcp segmentation offload? 

TCP Segmentation Offload, aka TSO or in other contexts "large send" can be 
thought of as a "poor man's" Jumbo Frame.  The NIC advertises to the host that 
it can resegment larger TCP segments into sizes apropriate for the network.

This allows the host CPU stack to make fewer trips down the protocol stack to 
transfer a given quantity of data, thus reducing the service demand (quantity of 
CPU consumed per quantity of work).  The reduction in service demand can result 
in an increase in throughput if the transfer was previously CPU-bound.

It has the advantage over JumboFrame in that it does not require support in the 
rest of the infrastructure (switches, routers, receivers etc). I call it "poor 
man's" JumboFrame because it does not reduce the overheads on the receiver - the 
receiver still sees just as many "normally" sized segments as before, and sends 
just as many ACKs per KB transferred as before.

If a NIC is implemented with a microprocessor (bletch - personal opinion) the 
additional demands of TSO resegmenation may actually reduce throughput even as 
it greatly reduces server CPU utilization.  That was particularly evident in old 
Tigon2 NICs.  I am not sure if that is noticable in current generation BMC570X's 
or not - most of the systems I have at my disposal have BCM5701's in them and 
I'm not sure the drivers allow TSO to be enabled on that rev?  I've not seen a 
drop in maximum throughput on the "e1000" NICs I've played with, which have been 
some dual-port cards HP sells. YMMV.

 > Where can I read more about it?

In addition to whatever there may be in Linux documentation...
TSO or large send is also a long-standing feature of TCP  in AIX and (dare I say 
it here?-) Windows.  As such IBM and Microsoft may have writeups - I'm pretty 
sure that Microsoft had a write-up about it on their website - talking about the 
NDIS interface at least.  It is also a fairly recent addition to HP-UX, but I am 
not sure if there are any writeups about it on HP's websites yet.

>Should I disable it or is this not a good idea?

That depends.  If you are concerned about proper slow-start behaviour at the 
beginning of a connection you should disable it until you are on a later rev.

I've always wondered if it wouldn't be an interesting experiment with a "real" 
server to see if dishonouring slow-start at connection establishment (and there 
only, keep it after RTO) made all that much a difference in the host's 
retransmission rates...

rick jones
