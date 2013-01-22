From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Tue, 22 Jan 2013 14:01:09 -0800
Message-ID: <50FF0C25.9000300@hp.com>
References: <20130122161038.GG4608@sociomantic.com> <1358873142.3464.3964.camel@edumazet-glaptop> <20130122165929.GH4608@sociomantic.com> <1358874800.3464.4002.camel@edumazet-glaptop> <50FED7CE.1030008@hp.com> <20130122184245.GJ4608@sociomantic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122184245.GJ4608@sociomantic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/22/2013 10:42 AM, Leandro Lucarella wrote:
> On Tue, Jan 22, 2013 at 10:17:50AM -0800, Rick Jones wrote:
>>> What is important is the backlog, and I guess you didn't increase it
>>> properly. The somaxconn default is quite low (128)
>>
>> Leandro -
>>
>> If that is being overflowed, I believe you should be seeing something like:
>>
>>      14 SYNs to LISTEN sockets dropped
>>
>> in the output of netstat -s on the system on which the server
>> application is running.
>
> What is that value reporting exactly?

Netstat is reporting the ListenDrops and/or ListenOverflows  which map 
to LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS.  Those get 
incremented in tcp_v4_syn_recv_sock() (and its v6 version etc)

        if (sk_acceptq_is_full(sk))
                 goto exit_overflow;

Will increment both overflows and drops, and drops will increment on its 
own in some additional cases.

> Because we are using syncookies, and AFAIK with that enabled, all
> SYNs are being replied, and what the listen backlog is really
> limitting is the "completely established sockets waiting to be
> accepted", according to listen(2). What I don't really know to be
> honest, is what a "completely established socket" is, does it mean
> that the SYN,ACK was sent, or the ACK was received back?

I have always thought it meant that the ACK of the SYN|ACK has been 
received.

SyncookiesSent SyncookiesRecv SyncookiesFailed also appear in 
/proc/net/netstat and presumably in netstat -s output.

> Also, from the client side, when is the connect(2) call done? When the
> SYN,ACK is received?

That would be my assumption.


In a previous message:

> What I'm seeing are clients taking either useconds to connect, or 3
> seconds, which suggest SYNs are getting lost, but the network doesn't
> seem to be the problem. I'm still investigating this, so unfortunately
> I'm not really sure.

I recently ran into something like that, which turned-out to be an issue 
with nf_conntrack and its table filling.

rick
