From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl
 lock
Date: Thu, 26 Mar 2015 16:47:37 -0700
Message-ID: <55149A99.6040704@redhat.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>	<55147E5D.2070600@redhat.com>	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>	<55148576.1010303@redhat.com>	<CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com> <CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, tgraf@suug.ch
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416AbbCZXri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 19:47:38 -0400
In-Reply-To: <CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2015 04:05 PM, Cong Wang wrote:
> On Thu, Mar 26, 2015 at 3:32 PM, Cong Wang <cwang@twopensource.com> wrote:
>> On the other hand, the name rules_mod_lock already tells it is
>> just a protection for ops (module) register.
> I even doubt we really need rules_mod_lock, it is per netns,
> which is newly allocated when registering pernet and upper
> layer should guarantee no concurrent unregistering, so we
> probably only need to take rtnl lock.

I'm adding Thomas as he was the original author for the code and might 
have a better idea of what needs to be rtnl locked and what doesn't.  
You should probably CC him as well on the v2 patch.

As far as why I am so focused on moving fib4_rules_exit it is because we 
don't want to call that delete function until after the table has been 
cleared.  Otherwise you end up triggering the external_flush and unmerge 
code on a full table instead of an empty one.  The result is you end up 
allocating a bunch of memory before you then turn around and free it.  
So even if you retain the rtnl_lock changes it would still be best to 
move fib4_rules_exit call to the region after you have freed the FIB 
tables, but before you free fib_table_hash.

- Alex
