From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 0/2][V2] net: Implement SO_PEERCGROUP to get cgroup of peer
Date: Wed, 12 Mar 2014 14:09:35 -0700
Message-ID: <CALCETrVPu_37FfY+DN8AowUdq7W4pLgczw-Pd7Z_O8h740giNw@mail.gmail.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <5320C9FC.6070301@amacapital.net> <1394657970.32465.200.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394657970.32465.200.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 1:59 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, 2014-03-12 at 13:56 -0700, Andy Lutomirski wrote:
>> On 03/12/2014 01:46 PM, Vivek Goyal wrote:
>> > Hi,
>> >
>> > This is V2 of patches. Fixed the function format issue and also I was using
>> > CONFIG_CGROUP instead of CONFIG_CGROUPS. That led to crash at boot. Fixed that.
>> >
>> > Some applications like sssd want to know the cgroup of connected peer over
>> > unix stream socket. They want to use this information to map the cgroup to
>> > the container client belongs to and then decide what kind of policies apply
>> > on the container.
>> >
>>
>> Can you explain what the use case is?
>
> External programs contacted from inside a container want to know 'who'
> is contacting them. Whee 'who' is determined by the cgroup their put in.
> This way these external programs can apply appropriate policy associated
> with the specific 'marking' cgroup.
>
>> My a priori opinion is that this is a terrible idea.  cgroups are a
>> nasty interface, and letting knowledge of cgroups leak into the programs
>> that live in the groups (as opposed to the cgroup manager) seems like a
>> huge mistake to me.
>
> I am not sure where you are going, the program that want's to know about
> the cgroup is outside the group.
>
>> If you want to know where in the process hierarchy a message sender is,
>> add *that* and figure out how to fix the races (it shouldn't be that hard).
>
> What is *that* here ?

It sounds like your use case is:

systemd shoves a service in a cgroup.  Its children stay in that
cgroup.  One of those children sends a message back to systemd or
something that knows about systemd's use of cgroups and wants to
identify which service it is.

Now imagine that you're using a non-systemd cgroup controller, or you
have more than one cgroup hierarchy, or you have two services that
want to share a cgroup.  Or imagine that you're totally happy with
systemd but that you want to use this same facility from something
unprivileged.

So let's rethink this.  There's already SCM_CREDENTIALS for sending
pid, but using pid there is inherently racy.  If that race were fixed
and there were a clean way to look up with process subtree or service
a pid lives in, then I think this would solve your problem.  No
cgroups needed.

--Andy

>
> Simo.
>
>
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
