From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 11:36:14 +0100
Message-ID: <4219B99E.1000603@rapidforum.com>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20050221090121.GA7478@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> On Mon, Feb 21, 2005 at 01:35:33AM +0100, Christian Schmid wrote:
> 
> 
>>New connections get made without any problems. Just existing connections 
>>slow down painfully.
> 
> 
> Incoming our outgoing data mostly?

Outgoing data. I am using sendfile() to send the file on a non-blocking socket but the call blocks 
for 100 ms per socket if I get over 3000 sockets. Thats causing the massive slowdown in sum. I first 
thought its a disk-issue but I tried with pure-cache data as well and it still blocks.

>>3000 sockets = no slowdown at all (500 MBit in use)
>>3300 sockets = 10% slowdown
>>3600 sockets = 30% slowdown
>>4000 sockets = 60% slowdown (i aborted here, as it only uses 200 MBit for 
>>sending... catastrophy!)
>>
>>They are all receiving data. Its a download-service. receive-buffer is set 
>>to 24 KB and send-buffer set to 224 KB. I don't see a problem with 
>>port-space. I only have 3500 sockets when the problem appears but it 
>>appears suddenly.
> 
> 
> I'm a bit confused, it is a download service so you are probably *sending*
> data? 

Only sending. Receiving ACKs of course.

>>>But it would help if you looked at the stats and ifconfig
>>>to see who's dropping packets, how many retransmissions there
>>>are, memory failures, or the bottleneck is some other issue altogether...
>>
>>No way. Doing 30000 packets per second and your stats are 32 bit integers ;)
> So? You could be a bit more helpful. Sample over 5 seconds, you won't
> overflow that.

5 seconds, here you go:

eth0      Link encap:Ethernet  HWaddr 00:30:48:27:84:28
           inet addr:80.237.244.12  Bcast:80.237.244.63  Mask:255.255.255.192
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2861390424 errors:5991038 dropped:5991056 overruns:38681 frame:4294967287
           TX packets:2906616171 errors:4294967279 dropped:0 overruns:0 carrier:4294967278
           collisions:4294967289 txqueuelen:1000
           RX bytes:1613084024 (1538.3 Mb)  TX bytes:2528808392 (2411.6 Mb)
           Base address:0x4000 Memory:fc000000-fc020000

eth0      Link encap:Ethernet  HWaddr 00:30:48:27:84:28
           inet addr:80.237.244.12  Bcast:80.237.244.63  Mask:255.255.255.192
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2861511619 errors:5991038 dropped:5991056 overruns:38681 frame:4294967287
           TX packets:2906804392 errors:4294967279 dropped:0 overruns:0 carrier:4294967278
           collisions:4294967289 txqueuelen:1000
           RX bytes:1625289307 (1549.9 Mb)  TX bytes:2802520805 (2672.6 Mb)
           Base address:0x4000 Memory:fc000000-fc020000

> Also, can you tcpdump a bit? Are you using iptables? The conntrack table
> might be slowing you down. 

Hmmm tcpdump what exactly? I am using iptables and the conntrack-problem has been solved in the past 
already by disabling conn-tracking. The table overran and it dropped packets massively. I disabled 
conn-tracking and the problem was gone. This is a different problem though.

> I have a hunch this problem has to do with high-mem issues though.

Well, 6 GB of high-mem, 2 GB of low-mem... at least there is not too less memory.

MemTotal:      8314392 kB
MemFree:         13936 kB
Buffers:         28732 kB
Cached:        7926792 kB
SwapCached:          0 kB
Active:        3129028 kB
Inactive:      5031240 kB
HighTotal:     6421952 kB
HighFree:          640 kB
LowTotal:      1892440 kB
LowFree:         13296 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:           54160 kB
Writeback:           0 kB
Mapped:         210108 kB
Slab:           128176 kB
CommitLimit:   4157196 kB
Committed_AS:   674072 kB
PageTables:       1604 kB
VmallocTotal:   114680 kB
VmallocUsed:      1160 kB
VmallocChunk:   113416 kB

Best regards,
Chris
