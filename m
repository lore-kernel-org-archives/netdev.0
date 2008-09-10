From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 15:56:55 -0700
Message-ID: <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	 <20080910220115.GH20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm@linux-foundation.org, kaber@trash.net,
	lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:1991 "EHLO
	smtp-out3.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752581AbYIJW5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 18:57:06 -0400
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out3.google.com with ESMTP id m8AMuuRh031905
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 23:56:56 +0100
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by spaceape9.eur.corp.google.com with ESMTP id m8AMufXd028785
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 15:56:55 -0700
Received: by rv-out-0708.google.com with SMTP id b17so65860rvf.38
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 15:56:55 -0700 (PDT)
In-Reply-To: <20080910220115.GH20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 3:01 PM, Thomas Graf <tgraf@suug.ch> wrote:
> * Ranjit Manomohan <ranjitm@google.com> 2008-09-10 10:42
>> +void cgroup_tc_set_sock_classid(struct sock *sk)
>> +{
>> +     if (sk)
>> +             sk->sk_cgroup_classid = cgroup_tc_classid(current);
>> +}
>> +
>> @@ -1170,6 +1171,8 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
>>       if (err < 0)
>>               goto out_module_put;
>>
>> +     cgroup_tc_set_sock_classid(sock->sk);
>> +
>>       /*
>>        * Now to bump the refcnt of the [loadable] module that owns this
>>        * socket at sock_release time we decrement its refcnt.
>> @@ -1444,6 +1447,8 @@ asmlinkage long sys_accept(int fd, struct sockaddr __user *upeer_sockaddr,
>>       if (err < 0)
>>               goto out_fd;
>>
>> +     cgroup_tc_set_sock_classid(newsock->sk);
>> +
>>       if (upeer_sockaddr) {
>>               if (newsock->ops->getname(newsock, (struct sockaddr *)address,
>>                                         &len, 2) < 0) {
>
> The big disadvantage of this method is that it does not allow to change
> the classid for sockets which already exist. It inherits the classid
> at socket creation time and then sticks to it. So if you want to follow
> this approach I'd suggest to at least store a reference to the cgroup
> state and reference count it properly.
>

I had considered adding support for moving tasks between cgroups by
going through all the open fds of the task and updating the sockets
(in the cgroup attach method). It is a very heavy weight operation and
not considered a common use case (and even undesirable at times) so I
dropped the idea. I can add it back in if it is considered essential.


> As for the locking that you mentioned in the other thread. IMHO it is
> not possible to lookup a socket without taking at least one lock, but
> I might be wrong there. Actually I think it will take even more locks
> as different locks are used to f.e. protect listening and established
> tcp sockets.

That is correct for ingress, for egress the sk is already available in
the skb so should be fine.

-Thanks,
Ranjit

>
