From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 22:39:42 +0000
Message-ID: <41FEB3AE.3090400@dsl.pipex.com>
References: <1107123123.8021.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1107123123.8021.80.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> This is in relation to providing functionality that IMQ was intending
> to using the dummy device and tc actions. Ive copied as many people as i
> could dig who i know may have interest in this.
> Please forward this to any other list which may have interest
> in the subject. It still needs some cleaning up; however, i dont wanna
> sit on it for another year - and now that mirred is out there, this is a
> good time.
> 
> Advantage over current IMQ; cleaner in particular in in SMP;
> with a _lot_ less code.
> Old Dummy device functionality is preserved while new one only
> kicks in if you use actions. Didnt have to write a new device and finaly
> made a real dumb device to be a little smarter ;->
> 
> IMQ USES
> --------
> As far as i know the reasons listed below is why people use IMQ. 
> It would be nice to know of anything else that i missed because this
> is the requirements list i used.
> 
> 1) qdiscs/policies that are per device as opposed to system wide.
> IMQ allows for sharing across multiple devices.
> 
> 2) Allows for queueing incoming traffic for shaping instead of
> dropping. I am not aware of any study that shows policing is 
> worse than shaping in achieving the end goal of rate control.

I would say the end goal is shaping not just rate control. Shaping 
meaning different things to different people and ingress shaping being 
different from egress.

For me it's from the wrong end of a relativly narrow (512kbit) 
bottleneck link that has a 600ms fifo at the other end. My aim to 
sacrifice as little bandwidth as possible while not adding latency 
bursts for gaming and per user bandwidth allocation (with sharing of 
unused) and sfq within that for bulk tcp traffic.

If I was shaping LAN traffic, then policers/drops would be OK for me - 
but for a slow link I think queueing and dropping are better/give more 
control eg. I get to use sfq which should not drop the one packet a 56k 
user has managed to send me in the face of lots of incoming from low 
latency high bandwidth servers.

Even if it's possible I bet few can easily get policers to setup the 
complex sharing/prioritisations that you can with HTB or HFSC.


> I would be interested if anyone is experimenting. Nevertheless,
> this is still an alternative as opposed to making a system wide
> ingress change.
> 
> 3) Very interesting use: if you are serving p2p you may wanna give 
> preference to your own localy originated traffic (when responses come
> back) vs someone using your system to do bittorent. So QoSing based on
> state comes in as the solution. What people did to achive this was stick
> the IMQ somewhere prelocal hook.
> I think this is a pretty neat feature to have in Linux in general.
> (i.e not just for IMQ).

I think flexibility is always good - tunnels, ipsec etc. may need it - I 
don't know from personal use, though.

> But i wont go back to putting netfilter hooks in the device to satisfy
> this.  I also dont think its worth it hacking dummy some more to be 
> aware of say L3 info and play ip rule tricks to achieve this.
> --> Instead the plan is to have a contrack related action. This action
> will selectively either query/create contrack state on incoming packets.

I don't understand exactly what you mean here - for my setup to work I 
need to see denatted addresses and mark (connbytes - it helps me be 
extra nasty to multiple simoultaneous connections in slowstart and 
prioritise browsing over bulk) in prerouting mangle. Of course if I can 
use netfilter to classify and save into contrack then I could do 
evrything in netfilter and then use something like connmark to save it 
per connection.


> Packets could then be redirected to dummy based on what happens -> eg 
> on incoming packets; if we find they are of known state we could send to
> a different queue than one which didnt have existing state. This
> all however is dependent on whatever rules the admin enters.


How does the admin enter the rules - netfilter or other?


Andy.
