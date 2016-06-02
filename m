From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Make inotify instance/watches be accounted per
	userns
Date: Thu, 2 Jun 2016 09:27:48 +0300
Message-ID: <574FD1E4.8090109@kyup.com>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
	<8737ow7vcp.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8737ow7vcp.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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



On 06/01/2016 07:00 PM, Eric W. Biederman wrote:
> Cc'd the containers list.
> 
> 
> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
> 
>> Currently the inotify instances/watches are being accounted in the 
>> user_struct structure. This means that in setups where multiple 
>> users in unprivileged containers map to the same underlying 
>> real user (e.g. user_struct) the inotify limits are going to be 
>> shared as well which can lead to unplesantries. This is a problem 
>> since any user inside any of the containers can potentially exhaust 
>> the instance/watches limit which in turn might prevent certain 
>> services from other containers from starting.
> 
> On a high level this is a bit problematic as it appears to escapes the
> current limits and allows anyone creating a user namespace to have their
> own fresh set of limits.  Given that anyone should be able to create a
> user namespace whenever they feel like escaping limits is a problem.
> That however is solvable.

This is indeed a problem and the presented solution is rather dumb in
that regard. I'm happy to work with you on suggestions so that I arrive
at a solution that is upstreamable.

> 
> A practical question.  What kind of limits are we looking at here?
> 
> Are these loose limits for detecting buggy programs that have gone
> off their rails?

Loose limits.

> 
> Are these tight limits to ensure multitasking is possible?
> 
> 
> 
> For tight limits where something is actively controlling the limits you
> probably want a cgroup base solution.
> 
> For loose limits that are the kind where you set a good default and
> forget about I think a user namespace based solution is reasonable.

That's exactly the use case I had in mind.

> 
>> The solution I propose is rather simple, instead of accounting the 
>> watches/instances per user_struct, start accounting them in a hashtable, 
>> where the index used is the hashed pointer of the userns. This way
>> the administrator needn't set the inotify limits very high and also 
>> the risk of one container breaching the limits and affecting every 
>> other container is alleviated.
> 
> I don't think this is the right data structure for a user namespace
> based solution, at least in part because it does not account for users
> escaping.

Admittedly this is a naive solution, what are you ideas on something
which achieves my initial aim of having limits per users, yet not
allowing them to just create another namespace and escape them. The
current namespace code has a hard-coded limit of 32 for nesting user
namespaces. So currently at the worst case one can escape the limits up
to 32 * current_limits.
