From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Tue, 1 Feb 2005 13:51:47 +0100
Message-ID: <20050201125147.GK31837@postel.suug.ch>
References: <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch> <1107186044.1076.11.camel@jzny.localdomain> <20050131155929.GF31837@postel.suug.ch> <1107189625.1076.77.camel@jzny.localdomain> <20050131181553.GG31837@postel.suug.ch> <1107202715.1075.559.camel@jzny.localdomain> <20050131225328.GI31837@postel.suug.ch> <1107259361.1095.584.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107259361.1095.584.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Why bother putting extra classifier functionality into a qdisc? 
> you should be able to rip off the classifier from sfq so you dont depend
> on it; you can then select one of n queues (eaction meta set class 1:X
> based on result of sfq classifier - or you can have it set the classids
> based on resulting hash index) 

Excellent idea, this would allow for various hash functions to be used
in a single sfq. We can use skb->tc_index for it so we can easly combine
it with a underlying dsmark. The hardest part is to find a intuitive
form to define the hash, it should be possible to for example define
a hash based on daddr + hproto only completely ignoring saddr. The
perutrbation must be made optional, sometimes the hash will not produce
any unwanted collisions (hash based on dscp for example) so modifying it
wouldn't make sense. We can fork sfq and make a gsfq which takes the
hash from tc_index and disabled perturbation if it is set to 0.
Thoughts?

> Well, even if it is just being able to describe in english the u32
> parameters and displaying them in english (by using a ID stored)
> its already huge progress.

True. I've some notes on paper describing a match definition db which
basically defines a u32 like match and assigns a name and id to it, it
is stored in a external database file so everyone can define their
own pre defined matches without recompiling.

I've put together some code printing a tc tree as a whole and added
it to netconfig. It's just a start and still contains redundant
information which can be removed but I think it's already a step
forward because it all gets down to one command. Currently it's only
possible to filter on the device but I'll extend this later so one
can extract a part of the tree. One pretty ugly thing is that cbq
creates a qdisc and class with the same handle which gets quite
confusing if one wants list the filters attached to a certain handle
because they will show up for both, the qdisc and the root class.

Full output for a default ethernet device:
lsx# tc tree full where device eth0 
eth0 ether 00:02:44:63:ed:53 mtu 1500 <BROADCAST,MULTICAST,UP>
    txqlen 1000 weight 64 qdisc pfifo_fast irq 19 index 4 brd ff:ff:ff:ff:ff:ff
  pfifo_fast qdisc dev eth0 handle none parent none bands 3
      refcnt 1 priomap [1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1]
            besteffort => 1                0x8 => 1
                filler => 2                0x9 => 1
                  bulk => 2                0xa => 1
                   0x3 => 2                0xb => 1
      interactive_bulk => 1                0xc => 1
                   0x5 => 2                0xd => 1
           interactive => 0                0xe => 1
               control => 0                0xf => 1

Brief output for some cbq classes:
lsx# tc tree where device eth0 
eth0 ether 00:02:44:63:ed:53 mtu 1500 <BROADCAST,MULTICAST,UP>
  cbq qdisc dev eth0 handle 10: parent none rate 11.92MiB/s (95Mbit) prio 8
    cbq class dev eth0 handle 10: parent root rate 11.92MiB/s (95Mbit) prio 8
      u32 cls dev eth0 handle none parent 10: prio 10 protocol ip
      u32 cls dev eth0 handle 8000: parent 10: prio 10 protocol ip divisor 1
      u32 cls dev eth0 handle 8000:800 parent 10: prio 10 protocol ip target 10:12
      cbq class dev eth0 handle 10:12 parent 10: rate 11.92MiB/s (95Mbit) prio 3
        sfq qdisc dev eth0 handle 8003: parent 10:12 quantum 1514 perturb 0us

Full output with stats for some cbq classes:
lsx# tc tree stats where device eth0 
eth0 ether 00:02:44:63:ed:53 mtu 1500 <BROADCAST,MULTICAST,UP>
    txqlen 1000 weight 64 qdisc cbq irq 19 index 4 brd ff:ff:ff:ff:ff:ff
    Stats:    bytes    packets     errors    dropped   fifo-err compressed
    RX    46.65 MiB      42211          0          0          0          0
    TX     1.91 MiB      16234          0          0          0          0
    Errors:  length       over        crc      frame     missed  multicast
    RX            0          0          0          0          0          0
    Errors: aborted    carrier  heartbeat     window  collision
    TX            0          0          0          0          0
  cbq qdisc dev eth0 handle 10: parent none rate 11.92MiB/s (95Mbit) prio 8
      refcnt 1 avgpkt 1400 mpu 64 cell 16 allot 1514 weight 95Mbit
      minidle 65535999us maxidle 2us offtime 0us level 1 ewma_log 5
      penalty 0us strategy classic split none defmap 0x00000000 police ok
      Stats:    bytes    packets      drops overlimits       qlen    backlog
            44.02 KiB        380          0          0          0          0
               0.00 B/s        0 pps
              borrows    overact    avgidle  undertime
                    0          0        114          0
    cbq class dev eth0 handle 10: parent root rate 11.92MiB/s (95Mbit) prio 8
        avgpkt 1400 mpu 64 cell 16 allot 1514 weight 95Mbit
        minidle 65535999us maxidle 2us offtime 0us level 1 ewma_log 5
        penalty 0us strategy classic split none defmap 0x00000000 police ok
        Stats:    bytes    packets      drops overlimits       qlen    backlog
              44.02 KiB        380          0          0          0          0
                 0.00 B/s        0 pps
                borrows    overact    avgidle  undertime
                      0          0        114          0
      u32 cls dev eth0 handle none parent 10: prio 10 protocol ip
          Stats:    bytes    packets      drops overlimits       qlen    backlog
                   0.00 B          0          0          0          0          0
                   0.00 B/s        0 pps
      u32 cls dev eth0 handle 8000: parent 10: prio 10 protocol ip divisor 1
          Stats:    bytes    packets      drops overlimits       qlen    backlog
                   0.00 B          0          0          0          0          0
                   0.00 B/s        0 pps
      u32 cls dev eth0 handle 8000:800 parent 10: prio 10 protocol ip target 10:12
          nkeys 1 ht key 0x800 hash 0x0 <TERMINAL>
              match u32 at 8 & 0x00ff0000 == 0x00010000 successful 34
          Stats:    bytes    packets      drops overlimits       qlen    backlog
                   0.00 B          0          0          0          0          0
                   0.00 B/s        0 pps
               successful       hits
                       34        379

      cbq class dev eth0 handle 10:12 parent 10: rate 11.92MiB/s (95Mbit) prio 3
          child-qdisc 8003: avgpkt 500 mpu 0 cell 8 allot 1514 weight 95Mbit
          minidle 65535999us maxidle 0us offtime 0us level 0 ewma_log 5
          penalty 0us strategy classic split none defmap 0x00000000 police ok
          Stats:    bytes    packets      drops overlimits       qlen    backlog
                 3.25 KiB         34          0          0          0          0
                   0.00 B/s        0 pps
                  borrows    overact    avgidle  undertime
                        0          0         40          0
        sfq qdisc dev eth0 handle 8003: parent 10:12 quantum 1514 perturb 0us
            refcnt 1 limit 128 divisor 1024 flows 128
            Stats:    bytes    packets      drops overlimits       qlen    backlog
                   3.25 KiB         34          0          0          0          0
                     0.00 B/s        0 pps
