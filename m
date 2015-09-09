From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Wed, 9 Sep 2015 18:06:31 -0300
Message-ID: <55F09F57.6080602@gmail.com>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <55F096EB.7000204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35677 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbIIVGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:06:41 -0400
In-Reply-To: <55F096EB.7000204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 09-09-2015 17:30, Vlad Yasevich escreveu:
> On 09/09/2015 04:03 PM, Marcelo Ricardo Leitner wrote:
>> Consider sctp module is unloaded and is being requested because an user
>> is creating a sctp socket.
>>
>> During initialization, sctp will add the new protocol type and then
>> initialize pernet subsys:
>>
>>          status = sctp_v4_protosw_init();
>>          if (status)
>>                  goto err_protosw_init;
>>
>>          status = sctp_v6_protosw_init();
>>          if (status)
>>                  goto err_v6_protosw_init;
>>
>>          status = register_pernet_subsys(&sctp_net_ops);
>>
>> The problem is that after those calls to sctp_v{4,6}_protosw_init(), it
>> is possible for userspace to create SCTP sockets like if the module is
>> already fully loaded. If that happens, one of the possible effects is
>> that we will have readers for net->sctp.local_addr_list list earlier
>> than expected and sctp_net_init() does not take precautions while
>> dealing with that list, leading to a potential panic but not limited to
>> that, as sctp_sock_init() will copy a bunch of blank/partially
>> initialized values from net->sctp.
>>
>> The race happens like this:
>>
>>       CPU 0                           |  CPU 1
>>    socket()                           |
>>     __sock_create                     | socket()
>>      inet_create                      |  __sock_create
>>       list_for_each_entry_rcu(        |
>>          answer, &inetsw[sock->type], |
>>          list) {                      |   inet_create
>>        /* no hits */                  |
>>       if (unlikely(err)) {            |
>>        ...                            |
>>        request_module()               |
>>        /* socket creation is blocked  |
>>         * the module is fully loaded  |
>>         */                            |
>>         sctp_init                     |
>>          sctp_v4_protosw_init         |
>>           inet_register_protosw       |
>>            list_add_rcu(&p->list,     |
>>                         last_perm);   |
>>                                       |  list_for_each_entry_rcu(
>>                                       |     answer, &inetsw[sock->type],
>>          sctp_v6_protosw_init         |     list) {
>>                                       |     /* hit, so assumes protocol
>>                                       |      * is already loaded
>>                                       |      */
>>                                       |  /* socket creation continues
>>                                       |   * before netns is initialized
>>                                       |   */
>>          register_pernet_subsys       |
>>
>> Inverting the initialization order between register_pernet_subsys() and
>> sctp_v4_protosw_init() is not possible because register_pernet_subsys()
>> will create a control sctp socket, so the protocol must be already
>> visible by then. Deferring the socket creation to a work-queue is not
>> good specially because we loose the ability to handle its errors.
>>
>> So the fix then is to invert the initialization order inside
>> register_pernet_subsys() so that the control socket is created by last
>> and also block socket creation if netns initialization wasn't yet
>> performed.
>>
>
> not sure how much I like that...  Wouldn't it be better
> to pull the control socket initialization stuff out into its
> own function that does something like
>
> for_each_net_rcu()
> 	init_control_socket(net, ...)
>
>
> Or may be even pull the control socket creation
> stuff completely into its own per-net ops operations structure
> and initialize it after the the protosw stuff has been done.
>
> -vlad

I'm afraid error handling won't be easy then.

But still, the control socket is not really the problem, because we 
don't care (much?) if it contains zeroed values and the panic happens 
only if you call connect() on it. I moved it solely because of the 
protection on sctp_init_sock().

The real problem is new sockets created by an user application while 
module is still loading, because even if them don't trigger the panic, 
they may not be fully functional due to improper values loaded. Can't 
see other good ways to protect sctp_init_sock() from that early call (as 
in, prior to netns initialization).

I used the list pointer because that's null as that memory is entirely 
zeroed when alloced and, after initialization, it's never null again. 
Works like a lock/condition without using an extra field.

   Marcelo

>> Fixes: 4db67e808640 ("sctp: Make the address lists per network namespace")
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> ---
>>   net/sctp/protocol.c | 18 +++++++++++-------
>>   net/sctp/socket.c   |  4 ++++
>>   2 files changed, 15 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
>> index 4345790ad3266c353eeac5398593c2a9ce4effda..d8f78165768a75f93f4ce4120dd5475b6a623aaf 100644
>> --- a/net/sctp/protocol.c
>> +++ b/net/sctp/protocol.c
>> @@ -1271,12 +1271,6 @@ static int __net_init sctp_net_init(struct net *net)
>>
>>   	sctp_dbg_objcnt_init(net);
>>
>> -	/* Initialize the control inode/socket for handling OOTB packets.  */
>> -	if ((status = sctp_ctl_sock_init(net))) {
>> -		pr_err("Failed to initialize the SCTP control sock\n");
>> -		goto err_ctl_sock_init;
>> -	}
>> -
>>   	/* Initialize the local address list. */
>>   	INIT_LIST_HEAD(&net->sctp.local_addr_list);
>>   	spin_lock_init(&net->sctp.local_addr_lock);
>> @@ -1284,11 +1278,21 @@ static int __net_init sctp_net_init(struct net *net)
>>
>>   	/* Initialize the address event list */
>>   	INIT_LIST_HEAD(&net->sctp.addr_waitq);
>> -	INIT_LIST_HEAD(&net->sctp.auto_asconf_splist);
>>   	spin_lock_init(&net->sctp.addr_wq_lock);
>>   	net->sctp.addr_wq_timer.expires = 0;
>>   	setup_timer(&net->sctp.addr_wq_timer, sctp_addr_wq_timeout_handler,
>>   		    (unsigned long)net);
>> +	/* sctp_init_sock() will use this to know that netns is
>> +	 * nearly all initialized but already good to go.
>> +	 */
>> +	INIT_LIST_HEAD(&net->sctp.auto_asconf_splist);
>> +
>> +	/* Initialize the control inode/socket for handling OOTB packets.  */
>> +	status = sctp_ctl_sock_init(net);
>> +	if (status) {
>> +		pr_err("Failed to initialize the SCTP control sock\n");
>> +		goto err_ctl_sock_init;
>> +	}
>>
>>   	return 0;
>>
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 17bef01b9aa3e7f75328d39fc976f9e80d641e92..45b94deec93d0c7c1612a16922348cf2a7e65ec5 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -3993,6 +3993,10 @@ static int sctp_init_sock(struct sock *sk)
>>
>>   	pr_debug("%s: sk:%p\n", __func__, sk);
>>
>> +	/* Validate if netns is already initialized. */
>> +	if (!net->sctp.auto_asconf_splist.prev)
>> +		return -ENOPROTOOPT;
>> +
>>   	sp = sctp_sk(sk);
>>
>>   	/* Initialize the SCTP per socket area.  */
>>
>
