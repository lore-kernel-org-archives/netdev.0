From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 17 Jul 2004 08:47:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090068454.1064.1258.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
	 <1089910760.6114.967.camel@uganda>
	 <1089912285.1028.93.camel@jzny.localdomain>
	 <20040715235313.69897131@zanzibar.2ka.mipt.ru>
	 <1089983064.1060.1328.camel@jzny.localdomain>
	 <1089990401.6114.2843.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Jg80ClHEA8W8IX24Rgxz"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1089990401.6114.2843.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Jg80ClHEA8W8IX24Rgxz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2004-07-16 at 11:06, Evgeniy Polyakov wrote:
> On Fri, 2004-07-16 at 17:04, jamal wrote:
> 

[..]
> They do strong signed digest, but it does not have any kind of counter
> so i do not see replay attack prevention.

Ok, you are right. I do think that there are people who have run this
over IPSEC though. I could swear that the current linux based one does.
I wish we could get Alexander to comment on this discussion.

> 
> > > Can it be used over IPv6? (CARP also can't but it is _very_ easy to
> > > add, I just don't have IPv6 network setup to test).
> > 
> > Theres effort to have it do v6.
> > http://www.ietf.org/internet-drafts/draft-ietf-vrrp-ipv6-spec-06.txt
> > I agree its lame to have it as an after thought it seems
> 
> * VRRP for IPv6 does not currently include any type of authentication. *

Fine.

> I will draw one too.

ok, my resonse attached.

> For those who cares they are already done.

I was done 10 years ago. But theres a lot of fools around. 
MS targets the fools. 

> > > I have great confidence that Theo de Raadt will not include non
> > > patent-free code in OpenBSD.
> > 
> > I hope he is a lawyer or has some good lawyer advising him;->
> 
> He is an OpenBSD creator, so he is just a bit more paranoidal than
> others :)

I see ;-> 

cheers,
jamal

--=-Jg80ClHEA8W8IX24Rgxz
Content-Disposition: attachment; filename=carp.dig2
Content-Type: text/plain; name=carp.dig2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

No, your diagram should looks like this:

         User space
                    +----------------------------------------------------------+
		    |                                                          |
                    |  +-------------------------------------+                 |
		    |  |                                     |                 |
+-------+         +-------+         +---------+         +-------+          +-------+          
| App#A | <-----> | CARPd | <-----> | ctsyncd | <-----> | App#B | <----->  | App#C | <-----> 
+---+---+         +---+---+         +---+-----+         +---+---+          +---+---+         
                      |                 |                   |                  |              
                      |                 |                   |                  |              
   ------------------------------------------------------------------------------------------
           Kernel
        network I/O etc

Or only have one BUS(and it is actually implemented using netlink).

jamal> I relabeled the Apps. I suppose you see some apps using ctsyncd for something?

You need to connect each application daemon to carpd, even using broadcast netlink.
And for any in-kernel access you will need to create new App and new kernel part.

jamal> App2app doesnt have to go across kernel unless it turns out it is the
jamal> best way.
jamal> Alternatives include: unix or local host sockets, IPCs such as pipes or
jamal> just shared libraries.
jamal> 

If we will extrapolate it we can create following:
userspace carp determines that it is a master, it will suspend all kernel memory or dump /proc/kmem
and begins to advertise it. Remote node receives it and has pretty the same firewall settings, 
flow controls and any in-kernel state.

jamal> I havent studied what Harald proposes in details. I think that the slave would
jamal> continously be getting master updates.
jamal> The interesting thing about CARP is the ARP balancing feature in which X nodes
jamal> maybe masters of different IP flows all within the same subnet. 
jamal> VRRP load balances by subnet. I am not sure how challenge this will present to
jamal> to ctsyncd.

No matter that it takes a long time.


It make sence if App#X needs userspace access only.
But here is other diagram:

                                        userspace
                 |
-----------------+-------------------------------
                CARP                  kernelspace
                 |
                 |
+----------+-----+-----+---------+-------
|          |           |         |
ct_sync  iSCSI       e1000      CPU


My main idea for in-kernel CARP was to implement invisible HA mechanism suitable for in-kernel use.
You do not need to create netlink protocol parser, you do not need to create extra userspace overhead,
you do not need to create suitable for userspace control hooks in kernel infrastructure.
Just register callback.
But even with such simple approach you have opportunity to collaborate with userspace. If you need.

Why creating all userspace cruft if/when you need only kernel one?

jamal> 
jamal> so we now move appA, B, C to the kernel too?
jamal> There is absolutely no need to put this in kernel space.
jamal> If you do this, your next step should be to put zebra in the kernel
jamal> 

Resume: 
With your approach any data flow MUST go through userspace arbiters with all overhead and complexity.
With my approach any data flow _MAY_ go through userspace arbiters, but if you do_need/only_has 
in-kernel access than using in-kernel CARP is the only solution.

jamal> 
jamal> Yes, there is a cost. How much? Read the paper on user space drivers it actually does
jamal> some cost analysis.
jamal> If you prove that it is too expensive to put it in user space then prove it and lets
jamal> have a re-discussion
jamal>

--=-Jg80ClHEA8W8IX24Rgxz--
