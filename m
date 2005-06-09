From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Wed, 8 Jun 2005 21:55:13 -0700
Message-ID: <200506090455.j594tDVG006745@guinness.s2io.com>
References: <20050608221047.GA12920@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jheffner@psc.edu>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Herbert Xu'" <herbert@gondor.apana.org.au>,
        "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050608221047.GA12920@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Some of the original data that we got couple weeks ago are attached.
On questions from Herbert and others:

- The performance drop from the "super-TSO" with TSO OFF is marginal, with
TSO ON
is quite noticeable. 

- The numbers are similar in back-to-back and switch based (sender vs two
receivers) tests.

- The numbers are relative; we tested in pci-x 1.0 slots where ~7.5Gbps is a
practical bus limit
For TCP traffic. In pci-x 2.0 slots, the numbers are ~10Gbps with either
Jumbo frames 
Or with 1500 mtu + TSO, (against two 1500 mtu receivers), at a fraction of a
single Opteron %cpu 

- David is correct, with 1500 mtu the single receiver %cpu becomes a
bottleneck; the best throughput
 with 1500 mtu I've seen was ~5Gbps. So, in B2B setup with 1500 mtu the
advantages of TSO are mostly wasted since there is no TSO counterpart on the
receive side.

Receive side stateless offloads fix this, but we did not get around to
deploy these ASIC capabilities in Linux yet.

Anyway, here it goes:
----------------------------------------------------------
Configuration:
Dual Opteron system .243 as Rx, dual Opteron system .117 as 
Rx, four way Opteron system .247 as Tx, connected via CISCO switch.
.243 and .117 kernel source are patched with tcp_ack26.diff,
.247 kernel source are patched with tcp_super_tso.diff.
Run 8 nttcp connections from Tx system to each Rx system,
Use package size 65535 for mtu 1500,
Use package size 300000 for mtu 9000.  
 
Tx throughput on four way Opteron system .247:
2.6.12-rc4
            Tx-1500 CPU usage           Tx-9000  CPU usage   
            ----------------            ------------------
TSO off      2.5Gb/s  55%(note 1)          5.3   40%(3)
TSO on       4.0      47%(2)               6.1   35%(4)

 
========================================================== 

 
2.6.12-rc4 with tcp_super_tso.diff patch
            Tx-1500 CPU usage           Tx-9000  CPU usage
            ----------------            ------------------
TSO off      2.4Gb/s  60%(5)               5.0   41%(7)
TSO on       3.5      45%(6)               5.7   35%(8)

 


Note(1):
1500 tso off
top - 08:45:41 up 13 min,  2 users,  load average: 2.03, 1.01, 0.54
Tasks:  90 total,   3 running,  87 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.0% us,  0.0% sy,  0.0% ni,  0.0% id,  0.0% wa, 50.7% hi, 49.3% s
 Cpu1 :  0.3% us, 29.2% sy,  0.0% ni, 53.2% id,  0.0% wa,  0.0% hi, 17.3% s
 Cpu2 :  0.3% us, 27.9% sy,  0.0% ni, 53.2% id,  0.0% wa,  0.0% hi, 18.6% s
 Cpu3 :  0.3% us, 23.6% sy,  0.0% ni, 59.5% id,  0.0% wa,  0.0% hi, 16.6% s
Mem:   2055724k total,   203172k used,  1852552k free,    24112k buffers
Swap:  2040244k total,        0k used,  2040244k free,    79384k cached

Note(2):
1500 tso on
top - 08:48:19 up 16 min,  2 users,  load average: 0.74, 0.71, 0.49
Tasks:  90 total,   4 running,  86 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.3% us,  1.1% sy,  0.0% ni, 71.9% id,  0.6% wa, 12.2% hi, 13.8% s
 Cpu1 :  0.5% us,  7.8% sy,  0.0% ni, 88.2% id,  0.5% wa,  0.0% hi,  3.0% s
 Cpu2 :  0.4% us,  8.1% sy,  0.0% ni, 88.2% id,  0.5% wa,  0.0% hi,  2.9% s
 Cpu3 :  0.3% us,  6.6% sy,  0.0% ni, 90.3% id,  0.1% wa,  0.0% hi,  2.7% s
Mem:   2055724k total,   203652k used,  1852072k free,    25308k buffers
Swap:  2040244k total,        0k used,  2040244k free,    79412k cached

Note(3):
9000 off
top - 08:58:19 up 6 min,  2 users,  load average: 0.88, 0.47, 0.21
Tasks:  90 total,   2 running,  88 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.8% us,  8.8% sy,  0.0% ni, 79.1% id,  1.4% wa,  3.5% hi,  6.4% si
 Cpu1 :  0.7% us,  7.3% sy,  0.0% ni, 90.8% id,  0.4% wa,  0.0% hi,  0.8% si
 Cpu2 :  0.7% us,  6.9% sy,  0.0% ni, 90.8% id,  1.0% wa,  0.1% hi,  0.5% si
 Cpu3 :  0.5% us,  5.1% sy,  0.0% ni, 93.9% id,  0.3% wa,  0.0% hi,  0.2% si
Mem:   2055724k total,   378620k used,  1677104k free,    18400k buffers
Swap:  2040244k total,        0k used,  2040244k free,    72788k cached


Note(4):
9000 on
top - 08:55:55 up 4 min,  2 users,  load average: 0.53, 0.26, 0.12
Tasks:  90 total,   2 running,  88 sleeping,   0 stopped,   0 zombie
 Cpu0 :  1.1% us,  4.4% sy,  0.0% ni, 89.2% id,  2.2% wa,  1.2% hi,  1.9% si
 Cpu1 :  1.0% us,  3.5% sy,  0.0% ni, 94.3% id,  0.6% wa,  0.0% hi,  0.5% si
 Cpu2 :  1.1% us,  6.4% sy,  0.0% ni, 90.7% id,  1.6% wa,  0.1% hi,  0.2% si
 Cpu3 :  0.8% us,  5.3% sy,  0.0% ni, 93.5% id,  0.4% wa,  0.0% hi,  0.1% si
Mem:   2055724k total,   375892k used,  1679832k free,    17424k buffers
Swap:  2040244k total,        0k used,  2040244k free,    72676k cached


Note (5):
1500 tso off
top - 05:54:20 up 10 min,  2 users,  load average: 1.48, 0.62, 0.29
Tasks:  91 total,   3 running,  88 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.5% us,  0.5% sy,  0.0% ni, 81.3% id,  0.9% wa,  7.6% hi,  9.1%
 Cpu1 :  0.7% us,  5.4% sy,  0.0% ni, 91.5% id,  0.7% wa,  0.0% hi,  1.8%
 Cpu2 :  0.6% us,  6.5% sy,  0.0% ni, 90.2% id,  0.7% wa,  0.0% hi,  2.0%
 Cpu3 :  0.4% us,  5.5% sy,  0.0% ni, 92.1% id,  0.2% wa,  0.0% hi,  1.8%
Mem:   2055724k total,   204100k used,  1851624k free,    24056k buffers
Swap:  2040244k total,        0k used,  2040244k free,    79440k cached

Note (6):
1500 tso on
top - 05:49:36 up 6 min,  2 users,  load average: 1.28, 0.45, 0.18
Tasks:  91 total,   6 running,  85 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.0% us,  0.0% sy,  0.0% ni,  0.0% id,  0.0% wa, 41.5% hi, 58.5%
 Cpu1 :  0.0% us, 26.4% sy,  0.0% ni, 69.9% id,  0.0% wa,  0.0% hi,  3.7%
 Cpu2 :  0.3% us, 24.3% sy,  0.0% ni, 71.3% id,  0.0% wa,  0.0% hi,  4.0%
 Cpu3 :  0.0% us, 19.1% sy,  0.0% ni, 77.6% id,  0.0% wa,  0.0% hi,  3.3%
Mem:   2055724k total,   200496k used,  1855228k free,    22644k buffers
Swap:  2040244k total,        0k used,  2040244k free,    79288k cached

Note (7):
9000 off
top - 06:03:13 up 19 min,  2 users,  load average: 0.52, 0.27, 0.23
Tasks:  91 total,   3 running,  88 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.3% us,  1.0% sy,  0.0% ni, 86.0% id,  0.5% wa,  5.3% hi,  6.8%
 Cpu1 :  0.4% us,  4.3% sy,  0.0% ni, 93.7% id,  0.4% wa,  0.0% hi,  1.3%
 Cpu2 :  0.3% us,  4.5% sy,  0.0% ni, 93.2% id,  0.4% wa,  0.0% hi,  1.5%
 Cpu3 :  0.2% us,  3.8% sy,  0.0% ni, 94.7% id,  0.1% wa,  0.0% hi,  1.2%
Mem:   2055724k total,   399540k used,  1656184k free,    25816k buffers
Swap:  2040244k total,        0k used,  2040244k free,    79516k cached

Note (8):
9000 on
top - 06:05:16 up 21 min,  2 users,  load average: 0.79, 0.42, 0.29
Tasks:  91 total,   1 running,  90 sleeping,   0 stopped,   0 zombie
 Cpu0 :  0.3% us,  2.5% sy,  0.0% ni, 83.5% id,  0.5% wa,  5.6% hi,  7.7%
 Cpu1 :  0.4% us,  5.1% sy,  0.0% ni, 92.9% id,  0.3% wa,  0.0% hi,  1.3%
 Cpu2 :  0.3% us,  4.9% sy,  0.0% ni, 92.9% id,  0.4% wa,  0.0% hi,  1.4%
 Cpu3 :  0.2% us,  3.9% sy,  0.0% ni, 94.7% id,  0.1% wa,  0.0% hi,  1.2%
Mem:   2055724k total,   397784k used,  1657940k free,    26892k buffers
Swap:  2040244k total,        0k used,  2040244k free,    79528k cached 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Herbert Xu
> Sent: Wednesday, June 08, 2005 3:11 PM
> To: David S. Miller
> Cc: jheffner@psc.edu; netdev@oss.sgi.com
> Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
> 
> On Wed, Jun 08, 2005 at 02:49:06PM -0700, David S. Miller wrote:
> > 
> > Performance went down, with both TSO enabled and disabled, 
> compared to 
> > not having the patches applied.
> 
> What was the receiver running? Was the performance 
> degradation more pronounced with TSO enabled?
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au> 
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
> 
