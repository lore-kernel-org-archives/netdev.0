From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 3/6] sysfs: Implement sysfs tagged directory support.
Date: Mon, 05 Apr 2010 17:17:32 +0900
Message-ID: <4BB99C9C.4070308@gmail.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org> <1269973889-25260-3-git-send-email-ebiederm@xmission.com> <4BB2F083.1050803@kernel.org> <m11vf12ayb.fsf@fess.ebiederm.org> <4BB30520.2030100@kernel.org> <4BB30644.9090809@gmail.com> <m1oci4zv7h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1oci4zv7h.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Eric.

On 03/31/2010 06:39 PM, Eric W. Biederman wrote:
> Let me try a happy median between overwhelming and too little
> information by giving you some experts, and a bit of overview.
> 
> (Ugh after have writing this I certainly will agree that we
>  have some many layers in the device model that they become
>  obfuscating abstractions).

Yeah, exactly, and this patchset is pushing it further with no
documentation and indirections to high heavens.  As someone who
doesn't have much experience with namespaces, I can't make much sense
of this patchset and it obfuscates the whole kobject thing more and
that's a bad direction to be heading toward.

> Looking through my code there are 3 types of callbacks.
> - Callbacks to the namespace type of a children.
>   .child_ns_type

Can you please also explain the relationships among kobjects, ns_types
and NSes?

> - Callbacks to find the namespace of a kobject.
>   .namespace
> - Callbacks on the a namespace type to find the namespace
>   of a particular context.
>   .current_ns
>   .initial_ns  (not used in my patchset)
>   .netlink_ns  (not used in my patchset)
> 
> In a world of weird explicitness I expect .child_ns_type and
> .namespace could be made to go away by pushing through explicit
> ns_type, and namespace parameters everywhere. But that seems
> like an awful lot of unnecessary code churn and bloat with
> the only real advantage being that we have an abstraction
> stored explicit at each layer.

* How much churn would it be?  I would be willing to trade quite a bit
  if the following can go away.  The sheer amount of indirection there
  scares me a lot.

  struct kobj_type {
  ...
	const struct kobj_ns_type_operations *(*child_ns_type)(struct kobject *kobj);
  ...
  };

* Is it necessary to teach kobject layer the concept of namespaces?
  Wouldn't it be possible to let kobject and sysfs deal with tags and
  make namespaces use them?

> static int kobj_bcast_filter(struct sock *dest_sk, struct sk_buff *skb, void *data)
> {
> 	struct kobject *kobj = data;
> 	const struct kobj_ns_type_operations *ops;
> 
> 	ops = kobj_ns_ops(kobj);
> 	if (ops) {
> 		const void *sock_ns, *ns;
> 		ns = kobj->ktype->namespace(kobj);
> 		sock_ns = ops->netlink_ns(dsk);
> 		return sock_ns != ns;
> 	}
> 
> 	return 0;
> }
> 
> initial_ns is used to figure out what the initial/default
> namespace is for a class of namespaces.  We only report
> with /sbin/hotplug events in the initial network namespace.
> At least for now.
> 
> static int kobj_usermode_filter(struct kobject *kobj)
> {
> 	const struct kobj_ns_type_operations *ops;
> 
> 	ops = kobj_ns_ops(kobj);
> 	if (ops) {
> 		const void *init_ns, *ns;
> 		ns = kobj->ktype->namespace(kobj);
> 		init_ns = ops->initial_ns();
> 		return ns != init_ns;
> 	}
> 
> 	return 0;
> }

I can understand you would need two different ways of establishing the
accessor depending on the mode of access (file IO or netlink) but can
initial_ns ever be dynamic?  Can't it just be void *inital_ns instead
of a callback?

Thanks.

-- 
tejun
