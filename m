From: Steve Hill <steve@services.navaho.net>
Subject: Re: More IPSEC trouble
Date: Fri, 11 Mar 2005 15:05:28 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0503111453320.18067@sorbus2.navaho>
References: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1D9Ymg-0001x0-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2005, Herbert Xu wrote:

> What does CTRL-SCROLLLOCK or SysRq tell us?

The kernel locks up solid - no SysRq, capslock/numlock lights don't toggle 
when hitting the keys - completely dead.

I've managed to work out what causes it though:

I have overlapping subnets on the IPSEC tunnel - on the local side there 
is 10.101.0.0/16 and on the remote side there is 10.0.0.0/8.  The IPSEC 
server is 10.101.0.254.  The problem is that the policies I had required:

 	10.101.0.0/16	->	10.0.0.0/8	Requires AH and ESP
 	10.0.0.0/8	->	10.101.0.0/16	Requires AH and ESP

This obviously also matches traffic sent from 10.101.0.254 (the IPSEC 
server) to any machine on the local 10.101.0.0/16 network.  And since 
there is no SA for that traffic it gets dropped.

This was a configuration mistake on my part and admittedly it shouldn't 
work properly - however, it triggered a kernel bug: sending a packet with 
the DF flag set which will grow to be > the MTU when encrypted causes the 
kernel to generate an ICMP Frag Needed packet, which got caught by the 
policy and this triggered the kernel to lock up hard.

So whilest the error in the configuration legitimately causes parts of the 
network to not work, it certainly shouldn't have caused the kernel to lock 
up.  It seems the problem is occurring when the kernel generates a packet 
which the policy drops.

I have fixed my configuration now so that I have policies like:
 	10.101.0.0/16	->	10.101.0.0/16	None
 	10.101.0.0/16	->	10.0.0.0/8	Requires AH and ESP
 	10.0.0.0/8	->	10.101.0.0/16	Requires AH and ESP
Since the policy nolonger catches the kernel-generated packets the problem 
nolonger occurs for me, but obviously there is a bug there that should 
really be fixed.

- Steve Hill (BSc)
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015
