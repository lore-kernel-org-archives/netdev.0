From: "Alex Aizman" <alex@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 17:07:44 -0800
Message-ID: <200503150108.j2F18FDD016965@guinness.s2io.com>
References: <m1br9l6c63.fsf@muc.de>
Reply-To: <alex@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>
To: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>
In-Reply-To: <m1br9l6c63.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen writes: 

> I guess the main objection to the HAL comes not from 
> performance issues 

But the second or the third objection comes from there, I guess... As far as
the data path, HAL as a "layer" completely disappears. There is just a few
inline instructions that post descriptors and process completed descriptors.
These same instructions are unavoidable; they'd be present HAL or no-HAL.
There's no HAL locks on the data path (the locks are compiled out), no HAL
(as a "layer") induced overhead. Note that the performance was one
persistent "paranoia" from the very start of this project.

The numbers also tell the tale. We have 7.6Gbps jumbo throughput, the
bottleneck is PCI, not the host. We have 13us 1byte netpipe latency. Here's
for example today's netpipe run:

[root@localhost root]# ./nptcp -a -t -l 256 -u 98304 -i 256 -p 5100 -P - h
17.1.1.227
Latency: 0.000013
Now starting main loop
  0:       256 bytes    7 times -->  131.37 Mbps in 0.000015 sec
  1:       512 bytes   65 times -->  239.75 Mbps in 0.000016 sec
  2:       768 bytes 7701 times -->  181.37 Mbps in 0.000032 sec
  3:      1024 bytes 5168 times -->  212.35 Mbps in 0.000037 sec
  4:      1280 bytes 5102 times -->  209.95 Mbps in 0.000047 sec
  5:      1536 bytes 4303 times -->  211.65 Mbps in 0.000055 sec
  6:      1792 bytes 3765 times -->  238.44 Mbps in 0.000057 sec
  7:      2048 bytes 3739 times -->  267.33 Mbps in 0.000058 sec
  8:      2304 bytes 3744 times -->  297.43 Mbps in 0.000059 sec
  9:      2560 bytes 3761 times -->  319.77 Mbps in 0.000061 sec
 10:      2816 bytes 3685 times -->  349.80 Mbps in 0.000061 sec
 11:      3072 bytes 3701 times -->  344.98 Mbps in 0.000068 sec
 12:      3328 bytes 3374 times -->  372.86 Mbps in 0.000068 sec
 13:      3584 bytes 3389 times -->  400.46 Mbps in 0.000068 sec
...

> (Usually the only thing that really counts 
> for performance is data cache misses and the HAL is unlikely 
> to affect this much), but the coding style etc.. Indeed it 
> does not look too Linux like. 
> 
> One thing that's frowned upon in Linux are lots of wrappers 
> for standard functions (like spin_lock etc.). I would 
> recommend to at least replace them with the standard Linux functions.

There's always a tradeoff, a balancing act. The wrappers is a price to pay
for the reusable and extremely well tested code. Note also that a small
company like Neterion does not have the luxury *not* to re-use the code.. 

Having said that, there's couple ideas that can be worked in relatively
easily.

> In principle this can be even done with some kind of 
> preprocessor Also less ifdefs would be nice.

Exactly. Simple script that'll remove extra #ifdefs and wrappers.

> 
> An possible compromise might be to get rid of all the HAL 
> parts that wraps Linux functionality, and then only use a 
> leaner low level library to access the more difficult parts 
> of the hardware.  This would involve moving more code into 
> the Linux specific layers. This should be more low level 
> code, nothing like the high level queue handling functions 
> you currently have etc., with the high level logic all in Linux code

Well, I guess we can do a lot in that direction. Looking forward to get
specific review comments, etc. However, the main question remains: will the
HAL-based driver (because even after the script-produced "surgery" it'll
continue to be HAL based) ever get accepted?

> 
> -Andi
> 
> P.S.: The patch would be much easier to read if it created 
> new files instead of changing the old ones. 

Can be done, very easy. Obviously, only one of the driver has to be
selected..

> This makes sense 
> since the new driver will probably live next to the old one 
> for some time.
> 
> 

Alex
