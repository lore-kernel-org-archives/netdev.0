From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 29 Nov 2004 13:44:27 +0100
Message-ID: <1101732267.14930.75.camel@verza.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <20041127200030.GD27762@xi.wantstofly.org>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041127200030.GD27762@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > >What is weird, is that if we artificially "preload" the NIC tx-fifo with
> > >packets, and then instruct it to start sending them, those are actually
> > >transmitted AT WIRE SPEED!!
> 
> I've very interested in exactly what it is you're doing here.  What
> do you mean by 'preload'?

Here is a brief description of the trick we used.
The modified driver code can be grabbed from 
http://www.tlc-networks.polito.it/~mellia/e1000_modified.tar.gz

So: with "preloaded" we mean that we put the packets to be transmitted 
previously in the TX fifo of the nic without actually updating the
register which counts the number of packets in the fifo queue.
To do this a student modified the network 
driver adding an entry in /proc/net/e1000/eth#.
If you read from there you will get the values of the internal registers
of the NIC regarding the internal fifo.

Writing a number to it, you can set the TDFPC register which contains
the number of pkts in the TX queue of the internal FIFO.

To get the above result you have to:
Compile this version of the driver (don't remember on which version it
was based on)
Load it.
After that you can take a look at the internal registers with:

cat /proc/net/e1000/eth# (# replace it with the correct number)

Then we start placing something inthe TX fifo.
To do this i simply used:

ping -c 10 x.x.x.x

This has placed and also transmitted 10 ping pkts. But they aren't
deleted 
from the internal FIFO; only the pointers have been updated. Take a look
at the registers again with:

cat /proc/net/e1000/eth#

Now use:

echo 10 > /proc/net/e1000/eth#

Naturally 10 is the number we used above.
This "resets" the registers and writes in the TDFPC that there are 10
pkts in the TX queue.
Now when we do:

ping -c 1 x.x.x.x

You will see that the NIC will transmit 11 pkts (10 we "preloaded" + the
new one).
If you try to measure the TX speed you will see that it is ~ the wire
speed.

Note:
- note that if you haven't static arp tables there will be also some arp
pkts (should be two more pkts)
- probably if you write too many pkts it won't work because the FIFO is 
organized like a circular buffer and you will begin to overwrite the
first pkts.
- the normal ping pkts aren't minimum size but reduce them with the -s
option
- the code modoifications have been writen with having "quick and dirty"
in mind, certainly it is possible to write them better
-- 
Ciao,                    /\/\/\rco

+-----------------------------------+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+-----------------------------------+
The box said "Requires Windows 95 or Better." So I installed Linux.
