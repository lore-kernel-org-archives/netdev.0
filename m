From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 16 Jul 2004 09:04:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089983064.1060.1328.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
	 <1089910760.6114.967.camel@uganda>
	 <1089912285.1028.93.camel@jzny.localdomain>
	 <20040715235313.69897131@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YqzZqbFM9C1jXaX6bkbO"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20040715235313.69897131@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-YqzZqbFM9C1jXaX6bkbO
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2004-07-15 at 15:53, Evgeniy Polyakov wrote:
> On 15 Jul 2004 13:24:45 -0400
> jamal <hadi@cyberus.ca> wrote:

> > What is it that CARP does that couldnt be achieved by VRRP? 
> 
> I will answer a question by question, sorry.

;->

> Has vrrp some authentification mechanism?

They (at least used to) claim to be able to do so.

> Can it be used over IPv6? (CARP also can't but it is _very_ easy to
> add, I just don't have IPv6 network setup to test).

Theres effort to have it do v6.
http://www.ietf.org/internet-drafts/draft-ietf-vrrp-ipv6-spec-06.txt
I agree its lame to have it as an after thought it seems

> May someone use vrrp in private commercial enviroment without fear of
> being convicted?

That i dont know.

> > 
> > Can you explain a little more what you mean by "attching" to
> > master/slave?
> 
> Consider using some abstraction layer which makes some decisions based
> on knowledge of current HA state.

sure; make it an API/callback/event to/from the carp daemon to other
applications.

> It looks like we do not understand each other :)
> Here is the explanation of the ct_sync:
> http://cvs.netfilter.org/netfilter-ha/README?rev=1.2&content-type=text/vnd.viewcvs-markup
> 
> Harald Welte will have a talk about ct_sync at OLS.


Ok, good. Maybe if you too come to OLS we can settle this ;->
Looking at what HArald has, the infrastructure seems to be the correct
flavor. Seems something gets sent to user space via netlink and gets
delivered via keepalived.
I think the CARP loadbalancing feature is an improvement over what is
being suggested by Harald.
I have to say as well i am shocked that state is just being transfered
blindly - but i will deal with Harald when he shows up in Ottawa ;->

> > What do you mean realtime traffic?
> > Is it something that can be achieved by qos prioritization?
> 
> Yes it can. But who will control prioritization mechanism?
> Maybe userspace.
> But with such approach we need to create each time we need kernel access
> a kernel agent with it's own kernel<->user protocol, it's own connect
> to master/slave arbiter...
> With CARP just create one function in kernelspace and register it in
> CARP using provided mechanism.

bah.
Ok, now you are forcing me to draw diagrams.

I attached to avouid it being mangled.

> > In the end CISCO is going to be the loser in this of because 
> > something like CARP will take off and it cant talk to them. At the
> > moment though they do have the market so interoping with them is
> > valuable.
> 
> It is just marketing...
> The better software the more market it can eat. Theoretically...

I am afraid even if that sounds logical it doesnt work like that.
Too many stupid people. If it worked like that MS would be dead and
buried a few years ago.


> In theory practice and theory are the same, but in practice they are
> different. (c) Larry McVoy.

Agreed.

> Why use not good software and has even theoretical possibility to be 
> convicted when we have free successor( :) I said it? Nah... ).

Ok, keep spreading fear ;-> You are getting me worried now ;->

> I have great confidence that Theo de Raadt will not include non
> patent-free code in OpenBSD.

I hope he is a lawyer or has some good lawyer advising him;->

cheers,
jamal

--=-YqzZqbFM9C1jXaX6bkbO
Content-Disposition: attachment; filename=e1
Content-Type: text/plain; name=e1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit



         User space

              +-------+
              | CARPd | <-----> Other apps
              +---+---+
                  |
                  | - netlink to control ARP LB action
                  | - netlink to talk to ct_sync
                  | - netlink to control QoS rules
                  | - PF_PACKET or raw socket to send/rcv CARP pkts
                  |
   -----------------------------------
           Kernel
        network I/O etc

Apps interface to Carpd to send CARP encapulated packets i was talking
about earlier. With that thought lest redraw the diagram:


         User space

+-------+         +-------+         +---------+
| App#X | <-----> | CARPd | <-----> | ctsyncd |
+---+---+         +---+---+         +---+-----+
                      |                 |
                      |                 |
   ------------------------------------------
           Kernel
        network I/O etc

So now ct_sync control is not owned by carpd. Rather. ctsync listens
to the netlink msgs from the kernel, builds an app msg, passes it
carpd which will send it if state is right. Note such a mesage which
can be used by apps doesnt exist today, it would need to be defined.

Apps could also register callbacks for events
such as mastership transitions.


--=-YqzZqbFM9C1jXaX6bkbO--
