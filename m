From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/4] Make inotify instance/watches be accounted per userns
Date: Thu, 02 Jun 2016 11:19:23 -0500
Message-ID: <87y46n36no.fsf@x220.int.ebiederm.org>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
	<8737ow7vcp.fsf@x220.int.ebiederm.org> <574FD1E4.8090109@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john@johnmccutchan.com, eparis@redhat.com, jack@suse.cz,
	linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com,
	Linux Containers <containers@lists.linux-foundation.org>
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <574FD1E4.8090109@kyup.com> (Nikolay Borisov's message of "Thu, 2
	Jun 2016 09:27:48 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nikolay Borisov <kernel@kyup.com> writes:

> On 06/01/2016 07:00 PM, Eric W. Biederman wrote:
>> Cc'd the containers list.
>> 
>> 
>> Nikolay Borisov <kernel@kyup.com> writes:
>> 
>>> Currently the inotify instances/watches are being accounted in the 
>>> user_struct structure. This means that in setups where multiple 
>>> users in unprivileged containers map to the same underlying 
>>> real user (e.g. user_struct) the inotify limits are going to be 
>>> shared as well which can lead to unplesantries. This is a problem 
>>> since any user inside any of the containers can potentially exhaust 
>>> the instance/watches limit which in turn might prevent certain 
>>> services from other containers from starting.
>> 
>> On a high level this is a bit problematic as it appears to escapes the
>> current limits and allows anyone creating a user namespace to have their
>> own fresh set of limits.  Given that anyone should be able to create a
>> user namespace whenever they feel like escaping limits is a problem.
>> That however is solvable.
>
> This is indeed a problem and the presented solution is rather dumb in
> that regard. I'm happy to work with you on suggestions so that I arrive
> at a solution that is upstreamable.

The one in kernel solution to hierarchical resource limits that I am
aware of is the current include/linux/page_counter.h which evolved from
include/linux/res_counter.h

>> A practical question.  What kind of limits are we looking at here?
>> 
>> Are these loose limits for detecting buggy programs that have gone
>> off their rails?
>
> Loose limits.
>
>> 
>> Are these tight limits to ensure multitasking is possible?
>> 
>> 
>> 
>> For tight limits where something is actively controlling the limits you
>> probably want a cgroup base solution.
>> 
>> For loose limits that are the kind where you set a good default and
>> forget about I think a user namespace based solution is reasonable.
>
> That's exactly the use case I had in mind.
>
>> 
>>> The solution I propose is rather simple, instead of accounting the 
>>> watches/instances per user_struct, start accounting them in a hashtable, 
>>> where the index used is the hashed pointer of the userns. This way
>>> the administrator needn't set the inotify limits very high and also 
>>> the risk of one container breaching the limits and affecting every 
>>> other container is alleviated.
>> 
>> I don't think this is the right data structure for a user namespace
>> based solution, at least in part because it does not account for users
>> escaping.
>
> Admittedly this is a naive solution, what are you ideas on something
> which achieves my initial aim of having limits per users, yet not
> allowing them to just create another namespace and escape them. The
> current namespace code has a hard-coded limit of 32 for nesting user
> namespaces. So currently at the worst case one can escape the limits up
> to 32 * current_limits.

32 is the nesting depth not the width of the tree.  But see above.

Eric
