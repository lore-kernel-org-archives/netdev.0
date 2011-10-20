From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 9/9] make net/core/scm.c uid comparisons user namespace aware
Date: Thu, 20 Oct 2011 06:35:45 -0700
Message-ID: <m1fwinvl8u.fsf@fess.ebiederm.org>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
	<1318974898-21431-10-git-send-email-serge@hallyn.com>
	<m1sjmpytpf.fsf@fess.ebiederm.org> <20111020125801.GA1315@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	oleg@redhat.com, richard@nod.at, mikevs@xs4all.net,
	segoon@openwall.com, gregkh@suse.de, dhowells@redhat.com,
	eparis@redhat.com, "Serge E. Hallyn" <serge.hallyn@canonical.com>,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111020125801.GA1315@hallyn.com> (Serge E. Hallyn's message of
	"Thu, 20 Oct 2011 12:58:01 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serge@hallyn.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> Serge Hallyn <serge@hallyn.com> writes:
>> 
>> > From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
>> >
>> > Currently uids are compared without regard for the user namespace.
>> > Fix that to prevent tasks in a different user namespace from
>> > wrongly matching on SCM_CREDENTIALS.
>> >
>> > In the past, either your uids had to match, or you had to have
>> > CAP_SETXID.  In a namespaced world, you must either (both be in the
>> > same user namespace and have your uids match), or you must have
>> > CAP_SETXID targeted at the other user namespace.  The latter can
>> > happen for instance if uid 500 created a new user namespace and
>> > now interacts with uid 0 in it.
>> 
>> Serge this approach is wrong.
>
> Thanks for looking, Eric.
>
>> Because we pass the cred and the pid through the socket socket itself
>> is just a conduit and should be ignored in this context.
>
> Ok, that makes sense, but
>
>> The only interesting test should be are you allowed to impersonate other
>> users in your current userk namespace.
>
> Why in your current user namespace?  Shouldn't it be in the
> target user ns?  I understand it could be wrong to tie the
> user ns owning the socket to the target userns (though I still
> kind of like it), but just because I have CAP_SETUID in my
> own user_ns doesn't mean I should be able to pose as another
> uid in your user_ns.

First and foremost it is important that you be able if you have the
capability to impersonate other users in your current user namespace.
That is what the capability actually controls.

None of this allows you to impersonate any user in any other user
namespace.  The translation between users prevents that.

> (Now I also see that cred_to_ucred() translates to the current
> user_ns, so that should have been a hint to me before about
> your intent, but I'm not convinced I agree with your intent).
>
> And you do the same with the pid.  Why is that a valid assumption?

Yes.  Basically all the code is allow you to impersonate people you
would have been able to impersonate before.  If your target is in
another namespace you can not fool them.

With pids the logic should be a lot clearer.  Pretend to be a pid you can
see in your current pid namespace.  Lookup and convert to struct pid aka
the namespace agnostic object.  On output return the pid value that
the target process will know you as.

Ultimately I think we need a ns_capable for the current user namespace
instead of a global one.  But I don't see any rush to introduce
ns_capable here.

Eric
