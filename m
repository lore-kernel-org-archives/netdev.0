From: Mark Zealey <netdev@markandruth.co.uk>
Subject: Re: UDP multi-core performance on a single socket and SO_REUSEPORT
Date: Fri, 04 Jan 2013 18:50:59 +0000
Message-ID: <50E72493.4050406@markandruth.co.uk>
References: <50DD6DF1.7080304@markandruth.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailex.mailcore.me ([94.136.40.62]:37011 "EHLO
	mailex.mailcore.me" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906Ab3ADSvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 13:51:06 -0500
Received: from [78.179.121.82] (helo=[192.168.1.5])
	by mail5.atlas.pipex.net with esmtpa (Exim 4.71)
	(envelope-from <netdev@markandruth.co.uk>)
	id 1TrCM8-0002vu-Fu
	for netdev@vger.kernel.org; Fri, 04 Jan 2013 18:51:00 +0000
In-Reply-To: <50DD6DF1.7080304@markandruth.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have written two small test scripts now which can be found at 
http://mark.zealey.org/uploads/ - one launches 16 listening threads for 
a single UDP socket, the other needs to be run as

for i in `seq 16`; do ./udp_test_client & done

On my test server (32-core), stock kernel 3.7.1, 90% of the time is 
spent in the kernel waiting on spinlocks. Perf output:

     44.95%  udp_test_server  [kernel.kallsyms]   [k] _raw_spin_lock_bh
             |
             --- _raw_spin_lock_bh
                |
                |--100.00%-- lock_sock_fast
                |          skb_free_datagram_locked
                |          udp_recvmsg
                |          inet_recvmsg
                |          sock_recvmsg
                |          __sys_recvmsg
                |          sys_recvmsg
                |          system_call_fastpath
                |          0x7fd8c4702a2d
                |          start_thread
                 --0.00%-- [...]

     43.48%  udp_test_client  [kernel.kallsyms]   [k] _raw_spin_lock
             |
             --- _raw_spin_lock
                |
                |--99.80%-- udp_queue_rcv_skb
                |          __udp4_lib_rcv
                |          udp_rcv
                |          ip_local_deliver_finish
                |          ip_local_deliver
                |          ip_rcv_finish
                |          ip_rcv

Thanks,

Mark

On 28/12/12 10:01, Mark Zealey wrote:
> I appreciate that this question has come up a number of times over the 
> years, most recently as far as I can see in this thread: 
> http://markmail.org/message/hcc7zn5ln5wktypv . I'm going to explain my 
> problem and present some performance numbers to back this up.
>
> The problem: I'm doing some research on scaling a dns server 
> (powerdns) to work well on multi-core boxes (in this case testing with 
> 2*E5-2650 processors ie linux sees 32 cores).
>
> My powerdns configuration uses a shared socket with one thread for 
> each core in the box listening on that socket using poll()/recvmsg(). 
> I've modified powerdns so in my tests it is doing the absolute minimum 
> of work to answer packets (all queries are for the same record, it 
> keeps the response in memory and just changes a few fields before 
> calling sendmsg()). I'm binding to a single 10.xxx address and using 
> this for all local and remote tests.
>
> The numbers below are generated using 16 parallel queryperf's on 
> localhost (it doesn't really matter if it is from remote hosts or the 
> localhost; the numbers don't change much).
>
> Using stock centos 6.3 kernel I see powerdns performing at around 
> 120kqps (uses at most about 12 cpus)
> Using 3.7.1 kernel (from elrepo) I see this increase to 200-240kqps 
> maxing out all cpu's in the box (soft interrupt cpu time is about 8* 
> higher than on centos 6.3 kernel at 40% and system cpu time is at 50% 
> - powerdns only uses 10% of the cpu time)
> Using stock centos 6.3 kernel with the google SO_REUSEPORT patch from 
> 2010 (modified slightly so it applies) I see 500-600kqps from remote; 
> or 1mqps when doing localhost queries. powerdns doesn't go past using 
> 8 cpus - it appears that the limit it is hitting then is to do with 
> some lock in sendmsg().
>
> I've not been able to get the 2010 SO_REUSEPORT patch working on the 
> 3.7.1 kernel I suspect it would make for even better performance as 
> sendmsg() should have been significantly improved.
>
> Now, I don't believe that SO_REUSEPORT is needed in the kernel in this 
> case, however the numbers above clearly show that the current UDP 
> implementation for recvmsg() on a single socket across multiple cores 
> on kernel 3.7.1 is still locking badly. A perf report on 3.7.1 (using 
> 16 local queryperf's) shows:
>
>     68.34%  pdns_server  [kernel.kallsyms]    [k] _raw_spin_lock_bh
>             |
>             --- 0x7fa472023a2d
>                 system_call_fastpath
>                 sys_recvmsg
>                 __sys_recvmsg
>                 sock_recvmsg
>                 inet_recvmsg
>                 udp_recvmsg
>                 skb_free_datagram_locked
>                |
>                |--100.00%-- lock_sock_fast
>                |          _raw_spin_lock_bh
>                 --0.00%-- [...]
>
>      3.10%  pdns_server  [kernel.kallsyms]    [k] _raw_spin_lock_irqsave
>             |
>             --- 0x7fa472023a2d
>                 system_call_fastpath
>                 sys_recvmsg
>                 __sys_recvmsg
>                 sock_recvmsg
>                 inet_recvmsg
>                 udp_recvmsg
>                |
>                |--99.69%-- __skb_recv_datagram
>                |          |
>                |          |--77.68%-- _raw_spin_lock_irqsave
>                |          |
>                |          |--14.56%-- prepare_to_wait_exclusive
>                |          |          _raw_spin_lock_irqsave
>                |          |
>                |           --7.76%-- finish_wait
>                |                     _raw_spin_lock_irqsave
>                 --0.31%-- [...]
>                ...
>
> Any advice or patches welcome... :-)
>
> Mark
>
