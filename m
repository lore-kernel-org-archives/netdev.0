From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Sun, 27 Jan 2013 18:48:18 -0800
Message-ID: <5105E6F2.2010805@gmail.com>
References: <1358874800.3464.4002.camel@edumazet-glaptop> <50FED7CE.1030008@hp.com> <20130122184245.GJ4608@sociomantic.com> <50FF0C25.9000300@hp.com> <20130123104736.GK4608@sociomantic.com> <510039C8.7040401@hp.com> <20130124122223.GQ4608@sociomantic.com> <51018110.1070403@hp.com> <20130124192125.GD4608@sociomantic.com> <5102225E.2040506@gmail.com> <20130125100525.GE4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f176.google.com ([209.85.161.176]:44347 "EHLO
	mail-gg0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab3A1Csb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 21:48:31 -0500
In-Reply-To: <20130125100525.GE4608@sociomantic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2013 02:05 AM, Leandro Lucarella wrote:
> On Thu, Jan 24, 2013 at 10:12:46PM -0800, Nivedita SInghvi wrote:
>>>>> I was just kind of quoting the name given by netstat: "SYNs to LISTEN
>>>>> sockets dropped" (for kernel 3.0, I noticed newer kernels don't have
>>>>> this stat anymore, or the name was changed). I still don't know if we
>>>>> are talking about the same thing.
>>>>
>> [snip]
>>>> I will sometimes be tripped-up by netstat's not showing a statistic
>>>> with a zero value...
>>
>> Leandro, you should be able to do an nstat -z, it will print all
>> counters even if zero. You should see something like so:
>>
>> ipv4]> nstat -z
>> #kernel
>> IpInReceives                    2135               0.0
>> IpInHdrErrors                   0                  0.0
>> IpInAddrErrors                  202                0.0
>> ...
>>
>> You might want to take a look at those (your pkts may not even be
>> making it to tcp) and these in particular:
>>
>> TcpExtSyncookiesSent            0                  0.0
>> TcpExtSyncookiesRecv            0                  0.0
>> TcpExtSyncookiesFailed          0                  0.0
>> TcpExtListenOverflows           0                  0.0
>> TcpExtListenDrops               0                  0.0
>> TcpExtTCPBacklogDrop            0                  0.0
>> TcpExtTCPMinTTLDrop             0                  0.0
>> TcpExtTCPDeferAcceptDrop        0                  0.0
>>
>> If you don't have nstat on that version for some reason, download the
>> latest iproute pkg. Looking at the counter names is a lot more helpful
>> and precise than the netstat converstion to human consumption. 
> 
> Thanks, but what about this?
> 
> pc2 $ nstat -z | grep -i drop
> TcpExtLockDroppedIcmps          0                  0.0
> TcpExtListenDrops               0                  0.0
> TcpExtTCPPrequeueDropped        0                  0.0
> TcpExtTCPBacklogDrop            0                  0.0
> TcpExtTCPMinTTLDrop             0                  0.0
> TcpExtTCPDeferAcceptDrop        0                  0.0

That seems bogus. 


> pc2 $ netstat -s | grep -i drop
>     470 outgoing packets dropped
>     5659740 SYNs to LISTEN sockets dropped
> 
> Is this normal?

That's a lot ofconnect requests dropped, but it depends on how 
long you've been up and how much traffic you've seen. 

Hmm...you were on an older Ubuntu, right? The netstat source 
was patched to translate it as follows:

+    { "ListenDrops", N_("%u SYNs to LISTEN sockets dropped"), opt_number },

(see the file debian/patches/CVS-20081003-statistics.c_sync.patch 
 in the net-tools src)

i.e., the netstat pkg is printing the value of the TCPEXT MIB counter
that's counting TCPExtListenDrops. 

Theoretically, that number should be the same as that printed by nstat,
as they are getting it from the same kernel stats counter. I have not
looked at nstat code (I actually almost always dump the counters from
/proc/net/{netstat + snmp} via a simple prettyprint script (will send
you that offline).  

If the nstat and netstat counters don't match, something is fishy.
That nstat output is broken.  

>>> Yes, I already did captures and we are definitely loosing packets
>>> (including SYNs), but it looks like the amount of SYNs I'm loosing is
>>> lower than the amount of long connect() times I observe. This is not
>>> confirmed yet, I'm still investigating.
>>
>> Where did you narrow down the drop to? There are quite a few places in
>> the networking stack we silently drop packets (such as the one pointed
>> out earlier in this thread), although they should almost all be
>> extremely low probability/NEVER type events. Do you want a patch to
>> gap the most likely scenario? (I'll post that to netdev separately). 
> 
> Even when that would be awesome, unfortunately there is no way I could
> get permission to run a patched kernel (or even restart the servers for
> that matter).
> 
> And I don't know how could I narrow down the drops in any way. What I
> know is capturing traffic with tcpdump, I see some packets leaving one
> server but never arriving to the new one.

Hmm..do you have a switch between your two end points dropping pkts? 
Could be.. Basically, by looking at the statistics kept by each layer, you 
should be able to narrow it down a little bit at least. 

It does still sound like some drops are occurring in TCP due to accept 
backlog being full and you're overrunning TCP incoming processing (or 
at least this contributing), going by that ListenDrops count. 

> Also, the hardware is not great either, I'm not sure is not responsible
> for the loss. There are some errors reported by ethtool, but I don't
> know exactly what they mean:
> 
> # ethtool -S eth0
> NIC statistics:
>      tx_packets: 336978308273
>      rx_packets: 384108075585
>      tx_errors: 0
>      rx_errors: 194
>      rx_missed: 1119
>      align_errors: 31731
>      tx_single_collisions: 0
>      tx_multi_collisions: 0
>      unicast: 384108023754
>      broadcast: 51825
>      multicast: 6
>      tx_aborted: 0
>      tx_underrun: 0
> 
> Thanks!
> 

You aren't suffering a lot of packet loss at the NIC.  

Sorry, I'm on the road, travelling, and likely not online much this week. 


thanks,
Nivedita
