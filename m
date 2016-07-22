From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Fri, 22 Jul 2016 13:45:07 -0500
Message-ID: <87poq5y0jw.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<87d1m754jc.fsf@x220.int.ebiederm.org>
	<1469194399.3817016.673814953.7581706C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1469194399.3817016.673814953.7581706C-2RFepEojUI2N1INw9kWLP6GC3tUn3ZHUQQ4Iyu8u01E@public.gmane.org>
	(Colin Walters's message of "Fri, 22 Jul 2016 09:33:19 -0400")
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

Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org> writes:

> On Thu, Jul 21, 2016, at 12:39 PM, Eric W. Biederman wrote:
>> 
>> This patchset addresses two use cases:
>> - Implement a sane upper bound on the number of namespaces.
>> - Provide a way for sandboxes to limit the attack surface from
>>   namespaces.
>
> Perhaps this is obvious, but since you didn't quite explicitly state it;
> do you see this as obsoleting the existing downstream patches
> mentioned in:
> https://lwn.net/Articles/673597/
> It seems conceptually similar to Kees' original approach, right?

Similar yes, and I expect it fills the need.  My primary difference is
that I believe this approach makes sense from a perspective of assuming
that user namespaces or other namespaces are not any buggier than any
other piece of kernel code and that people will use them.

I don't see these limits making sense from a perspective that user
namespaces are flawed and distro kernels should not have enabled them in
the first place.  That was my perception right or wrong of Kees patches
and the related patches that landed in Ubuntu and Debian.

With Kees approach I could not see how to handle the case where some
applications on the system wanted user namespaces and others don't.
Which made it very nasty for future evolution and more deployment of
user namespaces.  Being per user namespace these limits can be used to
sandbox applications without affecting the rest of the system.

> The high level makes sense to me...most interesting is
> per-userns sysctls.  I'll note most current container managers
> mount /proc/sys read-only, and Docker specifically drops
> CAP_SYS_RESOURCE by default, so they'd likely need to learn
> how to undo that if one wanted to support recursive container usage.
> We'd probably need to evaluate the safety of having /proc/sys
> writable generally.  (Also it's rather common to filter out CLONE_NEWUSER
> via seccomp, but that's easy to undo)

Just using a user namespace replaces most of those precautions.

> But that's the flip side - if we're aiming primarily for an upstreamable
> way to *limit* namespace usage, it seems sane to me.

Yes.  The primary target is to stop applications that have gone buggy
and allocated a crazy number of namespaces.  The secondary target
is to allow sandboxes to disable creation of additional namespaces.
Just set the limit to 0 and drop caps, or similarly set the limit
to 1 and create another fresh set of nested namespaces.

Eric
