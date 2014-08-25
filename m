From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH V4 3/8] namespaces: expose ns instance serial numbers in
	proc
Date: Mon, 25 Aug 2014 07:04:28 -0700
Message-ID: <CALCETrW1Lv0qeccMjNHSEzgtiaNN3NgJVR1dFjjR_dw5KVVnqA@mail.gmail.com>
References: <cover.1408581429.git.rgb@redhat.com>
	<cd6cd0622ce677b639afae18a69ff79c72490bab.1408581429.git.rgb@redhat.com>
	<CALCETrUnzG1V8w+H9ctAJP+Hvo8LQax=dhLG4bBpBKmVi+C1cQ@mail.gmail.com>
	<20140822015803.GG20529@madcap2.tricolour.ca>
	<CALCETrUkFD0iNi1SV_6ypN5Kf4GYybT5tzjRjRQuLzT9iBnQAg@mail.gmail.com>
	<53FB3A86.2060203@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53FB3A86.2060203-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

On Aug 25, 2014 6:30 AM, "Nicolas Dichtel" <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
>> CRIU wants to save the complete state of a namespace and then restore
>> it.  For that to work, any information exposed to things in the
>> namespace *cannot* be globally unique or unique per boot, since CRIU
>> needs to arrange for that information to match whatever it was when
>> CRIU saved it.
>
> How are ifindex of network devices managed? These ifindexes are unique per boot,
> thus can change depending on the order in which netdev are created.
> These ifindexes are unique per boot and exposed to userspace ...
>

This does not appear to be true.

$ sudo unshare --net
# ip link add veth0 type veth peer name veth1
# ip link
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default qlen 1000
    link/ether 06:0d:59:c7:a6:a8 brd ff:ff:ff:ff:ff:ff
3: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default qlen 1000
    link/ether b2:5c:8b:f2:12:28 brd ff:ff:ff:ff:ff:ff
# logout
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
3: em1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN qlen 1000

>
>>
>> Also, I think that code running in a namespace has no business even
>> knowing a unique identity of that namespace from the perspective of
>> the host.
>
> Another scenario is when you have virtual network devices across two netns. You
> need to identify the peer netns to have a netlink message which is fully interpretable by the userspace.

Let me try again, with emphasis in the right place.

I think that *code running in a namespace* has no business even
knowing a unique identity of *that namespace* from the perspective of
the host.

In your example, if there's a veth device between netns A and netns B,
then code *in netns A* has no business knowing the identity of its
veth peer if its peer (B) is a sibling or ancestor.  It also IMO has
no business knowing the identity of its own netns (A) other than as
"my netns".

If A and B are siblings, then their parent needs to know where that
veth device goes, but I think this is already the case to a sufficient
extent today.

I feel like this discussion is falling into a common trap of new API
discussions.  Can one of you who wants this API please articulate,
with a reasonably precise example, what it is that you want to do, why
you can't easily do it already, and how this API helps?  I currently
understand how the API creates problems, but I don't understand how it
solves any problems, and I will NAK it (and I suspect that Eric will,
too, which is pretty much fatal) unless that changes.

Thanks,
Andy

>
>
> Regards,
> Nicolas
