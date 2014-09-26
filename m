From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Fri, 26 Sep 2014 11:26:13 -0700
Message-ID: <CALCETrX5e0cp4QFCv1eAqR1hjoROU9Rh=cRos9U35DaR-py3Eg@mail.gmail.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
	<87ppei45ig.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ppei45ig.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

On Fri, Sep 26, 2014 at 11:10 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> writes:
>
>> The goal of this serie is to be able to multicast netlink messages with an
>> attribute that identify a peer netns.
>> This is needed by the userland to interpret some informations contained in
>> netlink messages (like IFLA_LINK value, but also some other attributes in case
>> of x-netns netdevice (see also
>> http://thread.gmane.org/gmane.linux.network/315933/focus=316064 and
>> http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=4239)).
>
> I want say that the problem addressed by patch 3/5 of this series is a
> fundamentally valid problem.  We have network objects spanning network
> namespaces and it would be very nice to be able to talk about them in
> netlink, and file descriptors are too local and argubably too heavy
> weight for netlink quires and especially for netlink broadcast messages.
>
> Furthermore the concept of ineternal concept of peernet2id seems valid.
>
> However what you do not address is a way for CRIU (aka process
> migration) to be able to restore these ids after process migration.
> Going farther it looks like you are actively breaking process migration
> at this time, making this set of patches a no-go.
>
> When adding a new form of namespace id CRIU patches are just about
> as necessary as iproute patches.
>
>> Ids are stored in the parent user namespace. These ids are valid only inside
>> this user namespace. The user can retrieve these ids via a new netlink messages,
>> but only if peer netns are in the same user namespace.
>
> That does not describe what you have actually implemented in the
> patches.
>
> I see two ways to go with this.
>
> - A per network namespace table to that you can store ids for ``peer''
>   network namespaces.  The table would need to be populated manually by
>   the likes of ip netns add.
>
>   That flips the order of assignment and makes this idea solid.
>
>   Unfortunately in the case of a fully referencing mesh of N network
>   namespaces such a mesh winds up taking O(N^2) space, which seems
>   undesirable.
>
> - Add a netlink attribute that says this network element is in a peer
>   network namespace.
>
>   Add a unicast query message that let's you ask if the remote
>   end of a tunnel is in a network namespace specified by file
>   descriptor.
>
> I personally lean towards the second version as it is fundamentally
> simpler, and generally scales better, and the visibility controls are
> the existing visibility controls.  The only downside is it requires
> a query after receiving a netlink broadcast message for the times that
> we care.

The downside of that approach, and all the similar kcmp stuff, is that
it scales poorly for applications using it.  This is probably not the
end of the world, but it's not ideal.

--Andy
