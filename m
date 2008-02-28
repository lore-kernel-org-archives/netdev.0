From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Thu, 28 Feb 2008 12:31:23 -0700
Message-ID: <m1y794514k.fsf@ebiederm.dsl.xmission.com>
References: <47C6D743.1050802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763327AbYB1TeM@vger.kernel.org>
In-Reply-To: <47C6D743.1050802@openvz.org> (Pavel Emelyanov's message of "Thu,
	28 Feb 2008 18:46:11 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

> Current /proc/net is done with so called "shadows", but current
> implementation is broken and has little chances to get fixed.
>
> The problem is that dentries subtree of /proc/net directory has
> fancy revalidation rules to make processes living in different
> net namespaces see different entries in /proc/net subtree, but
> currently, tasks see in the /proc/net subdir the contents of any
> other namespace, depending on who opened the file first.
>
> The proposed fix is to turn /proc/net into a symlink, which behaves
> similar to /proc/self link - it points to .netns/<id> directory 
> where the <id> is the id of net namespace, current task lives in.
>
> # ls -l /proc/net
> lrwxrwxrwx  1 root root 8 Feb 28 18:38 /proc/net -> .netns/0
>
> The /proc/.netns dir contains subtrees for all the namespaces in 
> the system:
>
> # ls -l /proc/.netns/
> total 0
> dr-xr-xr-x  5 root root 0 Feb 28 18:39 0
> dr-xr-xr-x  3 root root 0 Feb 28 18:39 1
>
> To provide some security each /proc/.netns/<id> directory allows
> access to tasks that live in the owning namespace only (with the
> exception, that init_net tasks can see everything).


Nack.  Yet another global set of ids that require us to implement another
namespace looks like the wrong way to go.

Can you try this approach by capturing a struct pid instead of an id
in a new global namespace? 

In particular the pid of the process that creates the pid namespace.
Like we do with setsid.

I think the implementation difficulty should be about the same, but
it will allow us something that works cleanly in the cases of
migration and nested namespaces.  As well as not adding an unnecessary
special case with init_net and visibility.

Eric
