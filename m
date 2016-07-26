From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Tue, 26 Jul 2016 10:14:06 -0500
Message-ID: <877fc8tosh.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<87d1m754jc.fsf@x220.int.ebiederm.org>
	<94b608ae-1d06-5c41-cbd5-94e663a2163a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <94b608ae-1d06-5c41-cbd5-94e663a2163a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Michael
	Kerrisk's message of "Tue, 26 Jul 2016 12:27:59 +0200")
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

"Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hello Eric,
>
> On 07/21/2016 06:39 PM, Eric W. Biederman wrote:
>>
>> This patchset addresses two use cases:
>> - Implement a sane upper bound on the number of namespaces.
>> - Provide a way for sandboxes to limit the attack surface from
>>   namespaces.
>>
>> The maximum sane case I can imagine is if every process is a fat
>> process, so I set the maximum number of namespaces to the maximum
>> number of threads.
>>
>> I make these limits recursive and per user namespace so that a
>> usernamespace root can reduce the limits further.  If a user namespace
>> root raises the limit the limit in the parent namespace will be honored.
>>
>> I have cut this implementation to the bare minimum needed to achieve
>> these objectives.
>>
>> Does anyone know if there is a proper error code to return for resource
>> limit exceeded?  I am currently using -EUSERS or -ENFILE but both of
>> those feel a little wrong.
>
> ENFILE certainly seems weird. I suppose my first question is: why two
> different errors?

EUSERS was there in the user namespace case for this condition (well
nesting depth but same principle) so it made sense to start with.  But
too many users doesn't really make sense.

ENFILE is actually slightly less insane.  It actually is about hitting a
resource limit, and seemed the most generic catchall we had.

> Some alternatives you might want to consider: E2BIG, EOVERFLOW,
> or (maybe) ERANGE.

My problem with those is typically those are about the values in fields,
not about creating too many things.  So those really don't feel right.
EACCESS or EPERM might be better but those are very very generic.

I really want ETOOMANY or something like that.

I am actually surprised given how common this pattern is, and the fact that
rlimits have existed forever, that we don't have a resource limit
exceeded error code.  I suppose it might be worth looking at Posix to
see if they have any suggestions.  Perhaps it may even be time to add an
appropriate error code to the list.

Not the most important thing out of this patch series but something
worth looking at.

Eric
