From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: Mon, 17 Nov 2003 17:13:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB8F3BF.6050509@trash.net>
References: <3FB3996A.6080008@trash.net>	 <1069076786.1075.19.camel@jzny.localdomain>  <3FB8DDE0.1070105@trash.net> <1069081153.1022.20.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1069081153.1022.20.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

the patch was meant to fix the problem that when replacing (or deleting)
a leaf queue that still holds packets the packets are not subtracted
from the upper queue's q.qlen. dsmark_reset does set the length to 0 but
it is not called when grafting. I've now verified experimentally the
problem also exists in dsmark:

# tc qdisc add dev eth0 root handle 1: dsmark indices 64
# tc qdisc add dev eth0 parent 1: pfifo limit 100
# netperf -H 192.168.0.1
< queue is holding 38 packets at this moment >
# tc qdisc del dev eth0 parent 1: pfifo
# tc qdisc add dev eth0 parent 1: pfifo limit 100
# tc -s -d qdisc show dev eth0

qdisc pfifo 800d: limit 100p
 Sent 296729221 bytes 854680 pkts (dropped 0, overlimits 0)
 backlog 33p
                                                                                
qdisc dsmark 1: indices 0x0040
 Sent 510414473 bytes 1489414 pkts (dropped 40, overlimits 0)
 backlog 71p

While it may not be a common operation or not even make sense, it is a
valid one and IMHO should be handled correctly. It actually did happen
to me while playing with TBF. I missed dsmark only has a single queue
so sch->q.qlen = 0 would be ok in dsmark_graft. If you're ok with that,
I'm going to change the patch.

Best regards,
Patrick


jamal wrote:

>Patrick,
>
>It doesnt make sense to have more than one queue in Dsmark (used as a
>place holder/work queue while DSCP remarking). 
>If reset() is already setting the length to 0 then it is not useful
>to set it to anything else (it may actually become a -ve number).
>I would suggest you use some of the examples in
>iproute2/examples/diffserv to test things out (for all your changes -
>the dsmark change was staring at me in the face - i didnt pay attention
>to the rest).
>
>cheers,
>jamal
>  
>
