From: Vicente Feito <vicente.feito@gmail.com>
Subject: Reducing the overhead on the network core
Date: Mon, 28 Mar 2005 21:44:08 +0000
Message-ID: <200503282144.08870.vicente.feito@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, I was looking at the csma/cd algorithm and something ocurred to me. 
Maybe this has been already discussed/dropped/implemented somewhere, but I 
would like to know.

The idea is to create a new method in the net_device structure, the point of 
this method would be to compare a given MAC address
with our MAC ADDR, the multicast list MAC's and BROADCAST addr, this way we 
can use this from the driver directly when you are picking the frames from 
the hardware buffer directly. Something like this allows us to drop a frame 
that is not directed to us, without having the overhead to call netif_rx, add 
to a queue and pass trhough the packet_handlers (again, this would be done 
exactly after reading the frame from the card's buffer, it's not even 
necessary to read the whole frame, reading only the first few bytes and the 
dst mac address would do, saving resources).

I think that the benefits are worth, and most important, I would loose less 
frames, suppose the situation where a computer in the lan starts to send 
frames one after another that are not directed to us, we would be adding 
those and filling the queue, after those it sends a frame that is for us, but 
since the queue is full we would drop the frame, this is bad, and it can be 
avoided (if it is on a different perspective please let me know).

Another important issue is the overhead of calling functions to verify frames 
that are not worth the time, wasting cycles, my thoughs are: if the frame is 
for me, it would have my ADDR and after that I'll checksum, if the mac 
doesn't match, then drop the frame, because I don't care what the checksum 
says, it's simply non of my bussiness (of course this would be on top of the 
length verifications for the frame).

This can be implemented on interrupt context because it would be fast and 
wouldn't have to block, is a simple check, inexpensive.
The method to add to net_device would be something like :

(int) (*validate_rx_macdst)(struct net_device *dev, unsigned char dst_addr);

 this can be called from anywhere, and can be implemented from any driver, 
avoiding the work for 'core'.

Well, maybe this is crazy, I just wanted to know if has been though or dropped 
or is nonsense, I would like to start writing some
 code for this, but I think asking first is better.

Thanks for reading the whole thing.

Vicente.
