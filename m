From: serge@hallyn.com
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Thu, 28 Feb 2008 15:17:20 -0600
Message-ID: <20080228211720.GA1232@vino.hallyn.com>
References: <47C6D743.1050802@openvz.org> <m1y794514k.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763943AbYB1VUo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1y794514k.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
> > Current /proc/net is done with so called "shadows", but current
> > implementation is broken and has little chances to get fixed.
> >
> > The problem is that dentries subtree of /proc/net directory has
> > fancy revalidation rules to make processes living in different
> > net namespaces see different entries in /proc/net subtree, but
> > currently, tasks see in the /proc/net subdir the contents of any
> > other namespace, depending on who opened the file first.
> >
> > The proposed fix is to turn /proc/net into a symlink, which behaves
> > similar to /proc/self link - it points to .netns/<id> directory 
> > where the <id> is the id of net namespace, current task lives in.
> >
> > # ls -l /proc/net
> > lrwxrwxrwx  1 root root 8 Feb 28 18:38 /proc/net -> .netns/0
> >
> > The /proc/.netns dir contains subtrees for all the namespaces in 
> > the system:
> >
> > # ls -l /proc/.netns/
> > total 0
> > dr-xr-xr-x  5 root root 0 Feb 28 18:39 0
> > dr-xr-xr-x  3 root root 0 Feb 28 18:39 1
> >
> > To provide some security each /proc/.netns/<id> directory allows
> > access to tasks that live in the owning namespace only (with the
> > exception, that init_net tasks can see everything).
> 
> 
> Nack.  Yet another global set of ids that require us to implement another
> namespace looks like the wrong way to go.

Sentiment granted, but I'm not sure it can be an issue.  It *could* be
in issue if we moved to a more flexible access control here here any
netns could access the .netns/N directories for all it's child
namespaces.

But it can't, and /proc/net is set by the kernel.  So the <id> can't be
an issue for any checkpoint/restart except htat of the whole system, and
of course on whole-system resume we have no <id> collision worries.

So userspace can't do anything with <id>, so there is no reason to worry
about it becoming another namespace?

Right?

thanks,
-serge

> Can you try this approach by capturing a struct pid instead of an id
> in a new global namespace? 
> 
> In particular the pid of the process that creates the pid namespace.
> Like we do with setsid.
> 
> I think the implementation difficulty should be about the same, but
> it will allow us something that works cleanly in the cases of
> migration and nested namespaces.  As well as not adding an unnecessary
> special case with init_net and visibility.
> 
> Eric
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
