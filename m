From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/4] Make inotify instance/watches be accounted per userns
Date: Mon, 06 Jun 2016 15:00:33 -0500
Message-ID: <87lh2im6ji.fsf@x220.int.ebiederm.org>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
	<8737ow7vcp.fsf@x220.int.ebiederm.org>
	<20160602074920.GG19636@quack2.suse.cz>
	<87bn3jy1cd.fsf@x220.int.ebiederm.org> <5751667D.7010207@kyup.com>
	<87inxqovho.fsf@x220.int.ebiederm.org> <57551B10.6080505@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Kara <jack@suse.cz>, avagin@openvz.org, netdev@vger.kernel.org,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-kernel@vger.kernel.org, eparis@redhat.com,
	operations@siteground.com, gorcunov@openvz.org,
	john@johnmccutchan.com
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57551B10.6080505@kyup.com> (Nikolay Borisov's message of "Mon, 6
	Jun 2016 09:41:20 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nikolay Borisov <kernel@kyup.com> writes:

> On 06/03/2016 11:41 PM, Eric W. Biederman wrote:
>> Nikolay Borisov <kernel@kyup.com> writes:
>> 
>>> On 06/02/2016 07:58 PM, Eric W. Biederman wrote:
>>>>
>>>> Nikolay please see my question for you at the end.
>> [snip] 
>>>> All of that said there is definitely a practical question that needs to
>>>> be asked.  Nikolay how did you get into this situation?  A typical user
>>>> namespace configuration will set up uid and gid maps with the help of a
>>>> privileged program and not map the uid of the user who created the user
>>>> namespace.  Thus avoiding exhausting the limits of the user who created
>>>> the container.
>>>
>>> Right but imagine having multiple containers with identical uid/gid maps
>>> for LXC-based setups imagine this:
>>>
>>> lxc.id_map = u 0 1337 65536
>> 
>> So I am only moderately concerned when the containers have overlapping
>> ids.  Because at some level overlapping ids means they are the same
>> user.  This is certainly true for file permissions and for other
>> permissions.  To isolate one container from another it fundamentally
>> needs to have separate uids and gids on the host system.
>> 
>>> Now all processes which are running with the same user on different
>>> containers will actually share the underlying user_struct thus the
>>> inotify limits. In such cases even running multiple instances of 'tail'
>>> in one container will eventually use all allowed inotify/mark instances.
>>> For this to happen you needn't also have complete overlap of the uid
>>> map, it's enough to have at least one UID between 2 containers overlap.
>>>
>>>
>>> So the risk of exhaustion doesn't apply to the privileged user that
>>> created the container and the uid mapping, but rather the users under
>>> which the various processes in the container are running. Does that make
>>> it clear?
>> 
>> Yes.  That is clear.
>> 
>>>> Which makes me personally more worried about escaping the existing
>>>> limits than exhausting the limits of a particular user.
>>>
>>> So I thought bit about it and I guess a solution can be concocted which
>>> utilize the hierarchical nature of page counter, and the inotify limits
>>> are set per namespace if you have capable(CAP_SYS_ADMIN). That way the
>>> admin can set one fairly large on the init_user_ns and then in every
>>> namespace created one can set smaller limits. That way for a branch in
>>> the tree (in the nomenclature you used in your previous reply to me) you
>>> will really be upper-bound to the limit set in the namespace which have
>>> ->level = 1. For the width of the tree, you will be bound by the
>>> "global" init_user_ns limits. How does that sound?
>> 
>> As a addendum to that design.  I think there should be an additional
>> sysctl or two that specifies how much the limit decreases when creating
>> a new user namespace and when creating a new user in that user
>> namespace.  That way with a good selection of limits and a limit
>> decrease people can use the kernel defaults without needing to change
>> them.
>
> I agree that a sysctl which controls how the limits are set for new
> namespaces is a good idea. I think it's best if this is in % rather than
> some absolute value. Also I'm not sure about the sysctl when a user is
> added in a namespace since just adding a new user should fall under the
> limits of the current userns.

My hunch is that a reserve per namespace as an absolute number will be
easier to implement and analyze but I don't much care.

I meant that we have a tree where we track created inotify things
that looks like:

                    uns0:
      +-------------//\\----------+
     /       /------/  \----\      \
   user1  user2            user3  user4
                   +-------//\\--------+
                  /     /--/  \---\     \
                uns1  uns2       uns3  uns4
              +-------//\\---------+
             /    /---/  \---\      \
          user5 user6       user7  user8


Allowing a hierarchical tracking of things per user and per user
namespace.

The limits programed with the sysctl would look something like they do
today.
          
> Also should those sysctls be global or should they be per-namespace? At
> this point I'm more inclined to have global sysctl and maybe refine it
> in the future if the need arises?

I think at the end of the day per-namespace is interesting.  We
certainly need to track the values as if they were per namespace.

However given that this should be a setup and forget kind of operation
we don't need to worry about how to implement the sysctl settings as per
namespace in the until everything else is sorted.  

>> Having default settings that are good enough 99% of the time and that
>> people don't need to tune, would be my biggest requirement (aside from
>> being light-weight) for merging something like this.
>> 
>> If things are set and forget and even the continer case does not need to
>> be aware then I think we have a design sufficiently robust and different
>> from what cgroups is doing to make it worth while to have a userns based
>> solution.
>
> Provided that we agree on the overall design, so far it seems we just
> need to iron out the details with the sysctl I'll be happy to implement
> this.

Thanks.  There are some other limits that need to be implemented in this
style that are more important to me: maximum number of user namespaces,
max number of pid namespaces, max number of mount namespaces, etc.
Those limits I will gladly implement.  As I can finally see how to make
all of this just work.  Which is to say the per userns per user per data
structures that hold the counts will be worth creating generically.

No need to generalize the code prematurely I think it make sense to sort
out the logic on whichever we implement first and then the rest of the
interesting limits can just follow the pattern that gets laid down.

Eric
