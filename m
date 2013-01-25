From: Nivedita SInghvi <niveditasinghvi@gmail.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Thu, 24 Jan 2013 22:12:46 -0800
Message-ID: <5102225E.2040506@gmail.com>
References: <1358873142.3464.3964.camel@edumazet-glaptop> <20130122165929.GH4608@sociomantic.com> <1358874800.3464.4002.camel@edumazet-glaptop> <50FED7CE.1030008@hp.com> <20130122184245.GJ4608@sociomantic.com> <50FF0C25.9000300@hp.com> <20130123104736.GK4608@sociomantic.com> <510039C8.7040401@hp.com> <20130124122223.GQ4608@sociomantic.com> <51018110.1070403@hp.com> <20130124192125.GD4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:37975 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab3AYGMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 01:12:55 -0500
In-Reply-To: <20130124192125.GD4608@sociomantic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2013 11:21 AM, Leandro Lucarella wrote:
> On Thu, Jan 24, 2013 at 10:44:32AM -0800, Rick Jones wrote:
>> On 01/24/2013 04:22 AM, Leandro Lucarella wrote:
>>> On Wed, Jan 23, 2013 at 11:28:08AM -0800, Rick Jones wrote:
>>>>> Then if syncookies are enabled, the time spent in connect() shouldn't be
>>>>> bigger than 3 seconds even if SYNs are being "dropped" by listen, right?
>>>>
>>>> Do you mean if "ESTABLISHED" connections are dropped because the
>>>> listen queue is full?  I don't think I would put that as "SYNs being
>>>> dropped by listen" - too easy to confuse that with an actual
>>>> dropping of a SYN segment.
>>>
>>> I was just kind of quoting the name given by netstat: "SYNs to LISTEN
>>> sockets dropped" (for kernel 3.0, I noticed newer kernels don't have
>>> this stat anymore, or the name was changed). I still don't know if we
>>> are talking about the same thing.
>>
[snip]
>> I will sometimes be tripped-up by netstat's not showing a statistic
>> with a zero value...

Leandro, you should be able to do an nstat -z, it will print all counters even if zero. You should see something like so:

ipv4]> nstat -z
#kernel
IpInReceives                    2135               0.0
IpInHdrErrors                   0                  0.0
IpInAddrErrors                  202                0.0
...

You might want to take a look at those (your pkts may not even be making it to tcp) and these in particular:

TcpExtSyncookiesSent            0                  0.0
TcpExtSyncookiesRecv            0                  0.0
TcpExtSyncookiesFailed          0                  0.0
TcpExtListenOverflows           0                  0.0
TcpExtListenDrops               0                  0.0
TcpExtTCPBacklogDrop            0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0

If you don't have nstat on that version for some reason, download the latest iproute pkg. Looking at the counter names is a lot more helpful and precise than the netstat converstion to human consumption. 


> Yes, I already did captures and we are definitely loosing packets
> (including SYNs), but it looks like the amount of SYNs I'm loosing is
> lower than the amount of long connect() times I observe. This is not
> confirmed yet, I'm still investigating.

Where did you narrow down the drop to? There are quite a few places in the networking stack we silently drop packets (such as the one pointed out earlier in this thread), although they should almost all be extremely low probability/NEVER type events. Do you want a patch to gap the most likely scenario? (I'll post that to netdev separately). 

thanks,
Nivedita
