From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch v2] net: reserve ports for applications using fixed
 port numbers
Date: Fri, 05 Feb 2010 12:41:18 +0800
Message-ID: <4B6BA16E.3010002@redhat.com>
References: <20100204101533.4619.34599.sendpatchset@localhost.localdomain> <201002041959.JEG43202.JQOFHFOVSFMtLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, davem@davemloft.net
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002041959.JEG43202.JQOFHFOVSFMtLO@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> Hello.
> 
> Amerigo Wang wrote:
>> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
>> index 2b79377..d3e160a 100644
>> --- a/net/ipv4/inet_hashtables.c
>> +++ b/net/ipv4/inet_hashtables.c
>> @@ -456,6 +456,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
>>  		local_bh_disable();
>>  		for (i = 1; i <= remaining; i++) {
>>  			port = low + (i + offset) % remaining;
>> +			if (inet_is_reserved_local_port(port))
>> +				continue;
>>  			head = &hinfo->bhash[inet_bhashfn(net, port,
>>  					hinfo->bhash_size)];
>>  			spin_lock(&head->lock);
> 
> I'm planning to add a LSM hook here.
> 
> If root user sets min port value less than 1024 to
> /proc/sys/net/ipv4/ip_local_port_range , a process without CAP_NET_BIND_SERVICE
> capability can bind to privileged port by "bind() with port == 0" or "connect()
> without bind()" because the condition is
> 
> 	err = -EACCES;
> 	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
> 		goto out;
> 
> I consider this is a security problem if MAC is enabled. MAC is used for
> dividing root user's privilege. With MAC, somebody doing some part of root
> user's jobs may set min port value to less than 1024.
> 
> Also, some applications needs fixed local port numbers (e.g. 3128 for Squid,
> 8080 for Tomcat). The port numbers I want to reserve are more complex than
> simple min-max range like /proc/sys/net/ipv4/ip_local_reserved_ports .
> 
> Therefore, TOMOYO wants to insert a LSM hook (
> http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/udp.c#L235
> http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/inet_connection_sock.c#L114
> http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/inet_hashtables.c#L459
> ) and allow reserving local ports like
> 
>   deny_autobind 0-1023
>   deny_autobind 3128
>   deny_autobind 8080
> 
> so that
> 
>   applications which need such ports won't be unexpectedly blocked by
>   other application's temporary port usage (i.e. "bind() with port == 0" or
>   "connect() without bind()")
> 
> and
> 
>   MAC guarantees that processes without CAP_NET_BIND_SERVICE can never bind
>   to privileged port
> 

Oh, IIUC, TOMOYO is something like SELinux? So, it is somewhat weird
to let users to use TOMOYO to reserve the ports with MAC. For normal
users /proc interface seems more friendly.

Thanks.
