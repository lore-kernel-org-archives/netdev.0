From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] nfnetlink_queue: enable PID info retrieval
Date: Fri, 10 Jun 2016 01:22:16 +0200
Message-ID: <5759FA28.3060900@iogearbox.net>
References: <1465505409-1232-1-git-send-email-saeedm@mellanox.com> <20160609213517.GA25288@breakpoint.cc> <5759EBF5.4010902@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Andre Melkoumian <andre@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	john.fastabend@gmail.com, daniel.wagner@bmw-carit.de,
	hannes@stressinduktion.org, tj@kernel.org, viro@zeniv.linux.org.uk
To: Florian Westphal <fw@strlen.de>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60800 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbcFIXWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 19:22:24 -0400
In-Reply-To: <5759EBF5.4010902@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2016 12:21 AM, Daniel Borkmann wrote:
> On 06/09/2016 11:35 PM, Florian Westphal wrote:
>> Saeed Mahameed <saeedm@mellanox.com> wrote:
>>> index a1bd161..67de200 100644
>>> --- a/net/socket.c
>>> +++ b/net/socket.c
>>> @@ -382,6 +382,7 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
>>>       }
>>>
>>>       sock->file = file;
>>> +    file->f_owner.sock_pid  = find_get_pid(task_pid_nr(current));
>>>       file->f_flags = O_RDWR | (flags & O_NONBLOCK);
>>>       file->private_data = sock;
>>>       return file;
>>
>> This looks like this leaks sock_pid reference...?
>>
>> (find_get_pid -> get_pid -> atomic_inc() , I don't see a put_pid in the
>>   patch)
>>
>> Can't comment further than this since I'm not familiar with vfs; e.g.
>> I can't say if fown_struct is right place or not, or if this approach
>> even works when creating process has exited after fork, etc.
>
> Or ... if you xmit the fd via unix domain socket to a different process
> and initial owner terminates, which should give you invalid information
> then; afaik, this would just increase struct file's refcnt and hand out
> an unused fdnum ( get_unused_fd_flags() + fd_install(), etc).
> For extending 'struct fown_struct', you probably also need to Cc fs folks.

[ Cc'ing John, Daniel, et al ]

Btw, while I just looked at scm_detach_fds(), I think commits ...

  * 48a87cc26c13 ("net: netprio: fd passed in SCM_RIGHTS datagram not set correctly")
  * d84295067fc7 ("net: net_cls: fd passed in SCM_RIGHTS datagram not set correctly")

... might not be correct, maybe I'm missing something ...? Lets say process A
has a socket fd that it sends via SCM_RIGHTS to process B. Process A was the
one that called sk_alloc() originally. Now in scm_detach_fds() we install a new
fd for process B pointing to the same sock (file's private_data) and above commits
update the cached socket cgroup data for net_cls/net_prio to the new process B.
So, if process A for example still sends data over that socket, skbs will then
wrongly match on B's cgroup membership instead of A's, no?

Thanks,
Daniel
