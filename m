From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 1/1][NETNS] resend:  fix net released by rcu callback
Date: Tue, 30 Oct 2007 22:43:26 +0100
Message-ID: <4727A57E.501@fr.ibm.com>
References: <20071030162139.954791193@mai.toulouse-stg.fr.ibm.com> <20071030162305.458123510@mai.toulouse-stg.fr.ibm.com> <m1odegl47t.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:10433 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbXJ3Vq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 17:46:29 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9ULkSL9417440
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 21:46:28 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ULkRKs3022982
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 21:46:27 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ULkEYY004657
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 21:46:14 GMT
In-Reply-To: <m1odegl47t.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <dlezcano@fr.ibm.com> writes:
> 
>> When a network namespace reference is held by a network subsystem,
>> and when this reference is decremented in a rcu update callback, we
>> must ensure that there is no more outstanding rcu update before 
>> trying to free the network namespace.
>>
>> In the normal case, the rcu_barrier is called when the network namespace
>> is exiting in the cleanup_net function.
>>
>> But when a network namespace creation fails, and the subsystems are
>> undone (like the cleanup), the rcu_barrier is missing.
>>
>> This patch adds the missing rcu_barrier.
> 
> Looks sane.  Did you have any specific failures related to this or was
> this something that was just caught in review?

Yes, I had this problem when doing ipv6 isolation for netns49. The ipv6 
subsystem creation failed and the different subsystem where rollbacked 
in the setup_net function.
When the network namespace was about to be freed in free_net function, I 
had the error with an usage refcount different from zero.
It appears that was coming from core/neighbour.c

neigh_parms_release
  -> neigh_rcu_free_parms
    -> neigh_parms_put
      -> neigh_parms_destroy
        -> release_net

The free_net function was called before rcu callback neigh_rcu_free_parms.
