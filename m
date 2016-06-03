From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Make inotify instance/watches be accounted per
	userns
Date: Fri, 3 Jun 2016 14:14:05 +0300
Message-ID: <5751667D.7010207@kyup.com>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
	<8737ow7vcp.fsf@x220.int.ebiederm.org>
	<20160602074920.GG19636@quack2.suse.cz>
	<87bn3jy1cd.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bn3jy1cd.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 06/02/2016 07:58 PM, Eric W. Biederman wrote:
> 
> Nikolay please see my question for you at the end.
> 
> Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org> writes:
> 
>> On Wed 01-06-16 11:00:06, Eric W. Biederman wrote:
>>> Cc'd the containers list.
>>>
>>> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
>>>
>>>> Currently the inotify instances/watches are being accounted in the 
>>>> user_struct structure. This means that in setups where multiple 
>>>> users in unprivileged containers map to the same underlying 
>>>> real user (e.g. user_struct) the inotify limits are going to be 
>>>> shared as well which can lead to unplesantries. This is a problem 
>>>> since any user inside any of the containers can potentially exhaust 
>>>> the instance/watches limit which in turn might prevent certain 
>>>> services from other containers from starting.
>>>
>>> On a high level this is a bit problematic as it appears to escapes the
>>> current limits and allows anyone creating a user namespace to have their
>>> own fresh set of limits.  Given that anyone should be able to create a
>>> user namespace whenever they feel like escaping limits is a problem.
>>> That however is solvable.
>>>
>>> A practical question.  What kind of limits are we looking at here?
>>>
>>> Are these loose limits for detecting buggy programs that have gone
>>> off their rails?
>>>
>>> Are these tight limits to ensure multitasking is possible?
>>
>> The original motivation for these limits is to limit resource usage.  There
>> is in-kernel data structure that is associated with each notification mark
>> you create and we don't want users to be able to DoS the system by creating
>> too many of them. Thus we limit number of notification marks for each user.
>> There is also a limit on the number of notification instances - those are
>> naturally limited by the number of open file descriptors but admin may want
>> to limit them more...
>>
>> So cgroups would be probably the best fit for this but I'm not sure whether
>> it is not an overkill...
> 
> There is some level of kernel memory accounting in the memory cgroup.
> 
> That said my experience with cgroups is that while they are good for
> some things the semantics that derive from the userspace API are
> problematic.
> 
> In the cgroup model objects in the kernel don't belong to a cgroup they
> belong to a task/process.  Those processes belong to a cgroup.
> Processes under control of a sufficiently privileged parent are allowed
> to switch cgroups.  This causes implementation challenges and sematic
> mismatch in a world where things are typically considered to have an
> owner.
> 
> Right now fs_notify groups (upon which all of the rest of the inotify
> accounting is built upon) belong to a user.  So there is a semantic
> mismatch with cgroups right out of the gate.
> 
> Given that cgroups have not choosen to account for individual kernel
> objects or give that level of control, I think it reasonable to look to
> other possible solutions.  Assuming the overhead can be kept under
> control.
> 
> The implementation of a hierarchical counter in mm/page_counter.c
> strongly suggests to me that the overhead can be kept under control.
> 
> And yes.  I am thinking of the problem space where you have a limit
> based on the problem domain where if an application consumes more than
> the limit, the application is likely bonkers.  Which does prevent a DOS
> situation in kernel memory.  But is different from the problem I have
> seen cgroups solve.
> 
> The problem I have seen cgroups solve looks like.  Hmm.  I have 8GB of
> ram.  I have 3 containers.  Container A can have 4GB, Container B can
> have 1GB and container C can have 3GB.  Then I know one container won't
> push the other containers into swap.
> 
> Perhaps that would tend to be a top down/vs a bottom up approach to
> coming up with limits.  As DOS preventions limits like the inotify ones
> are generally written from the perspective of if you have more than X
> you are crazy.  While cgroup limits tend to be thought about top down
> from a total system management point of view.
> 
> So I think there is definitely something to look at.
> 
> 
> All of that said there is definitely a practical question that needs to
> be asked.  Nikolay how did you get into this situation?  A typical user
> namespace configuration will set up uid and gid maps with the help of a
> privileged program and not map the uid of the user who created the user
> namespace.  Thus avoiding exhausting the limits of the user who created
> the container.

Right but imagine having multiple containers with identical uid/gid maps
for LXC-based setups imagine this:

lxc.id_map = u 0 1337 65536

Now all processes which are running with the same user on different
containers will actually share the underlying user_struct thus the
inotify limits. In such cases even running multiple instances of 'tail'
in one container will eventually use all allowed inotify/mark instances.
For this to happen you needn't also have complete overlap of the uid
map, it's enough to have at least one UID between 2 containers overlap.


So the risk of exhaustion doesn't apply to the privileged user that
created the container and the uid mapping, but rather the users under
which the various processes in the container are running. Does that make
it clear?


> 
> Which makes me personally more worried about escaping the existing
> limits than exhausting the limits of a particular user.

So I thought bit about it and I guess a solution can be concocted which
utilize the hierarchical nature of page counter, and the inotify limits
are set per namespace if you have capable(CAP_SYS_ADMIN). That way the
admin can set one fairly large on the init_user_ns and then in every
namespace created one can set smaller limits. That way for a branch in
the tree (in the nomenclature you used in your previous reply to me) you
will really be upper-bound to the limit set in the namespace which have
->level = 1. For the width of the tree, you will be bound by the
"global" init_user_ns limits. How does that sound?


> 
> Eric
> 
